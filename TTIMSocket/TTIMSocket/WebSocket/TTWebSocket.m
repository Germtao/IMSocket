//
//  TTWebSocket.m
//  TTIMSocket
//
//  Created by TT on 2018/4/9.
//  Copyright © 2018年 TAO. All rights reserved.
//

#import "TTWebSocket.h"
#import "SocketRocket.h"

#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

static NSString * Khost = @"127.0.0.1";
static const uint16_t Kport = 6969;

@interface TTWebSocket () <SRWebSocketDelegate> {
    SRWebSocket *_webSocket;
    NSTimer *_heartBeat;
    NSTimeInterval _reConnectTime; // 重连时间
}

@end

@implementation TTWebSocket

#pragma mark - 单例

+ (instancetype)sharedManager {
    static TTWebSocket *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

#pragma mark - Public Mehod

- (void)connect {
    
    [self initWebSocket];
    
    // 每次正常连接的时候清零重连时间
    _reConnectTime = 0;
}

- (void)disConnect {
    
    if (_webSocket) {
        [_webSocket close];
        _webSocket = nil;
    }
}

- (void)sendMessage:(NSString *)message {
    [_webSocket send:message];
}

#pragma mark - Private Method

/**
 初始化连接
 */
- (void)initWebSocket {
    if (_webSocket) {
        return;
    }
    
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%d", Khost, Kport]]];
    _webSocket.delegate = self;
    
    // 设置代理线程 queue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    [_webSocket setDelegateOperationQueue:queue];
    
    // 打开连接
    [_webSocket open];
}

#pragma mark - 心跳、PingPong机制、重连机制

/**
 初始化心跳
 */
- (void)initHeartBeat {
    dispatch_main_async_safe(^{
        
        // 取消心跳
        [self cancelHeartBeat];
        
        // 心跳时间设置为3分钟，NAT超时一般为5分钟
        _heartBeat = [NSTimer scheduledTimerWithTimeInterval:3 * 60 target:self selector:@selector(start) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_heartBeat forMode:NSRunLoopCommonModes];
    })
}

// 取消心跳
- (void)cancelHeartBeat {
    dispatch_main_async_safe(^{
        if (_heartBeat) {
            [_heartBeat invalidate];
            _heartBeat = nil;
        }
    })
}

/**
 PingPong机制
 */
- (void)pingPong {
    [_webSocket sendPing:nil];
}

/**
 重连机制
 */
- (void)reConnect {
    [self disConnect];
    
    // 超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (_reConnectTime > 64) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _webSocket = nil;
        [self initWebSocket];
    });
    
    // 重连时间 = 2的指数增长
    if (_reConnectTime == 0) {
        _reConnectTime = 2;
    } else {
        _reConnectTime *= 2;
    }
}

#pragma mark - Timer Event

- (void)start {
    NSLog(@"心跳");
    
    // 和server约定好发送什么作为心跳标识，尽可能的减小心跳包大小
    [self sendMessage:@"heart"];
}

#pragma mark - Delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"服务器返回收到消息：%@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功");
    
    // 连接成功开始发送心跳
    [self initHeartBeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"连接失败---\n%@", error);
    
    // 失败了就重连
    [self reConnect];
}

// 网络连接中断时调用
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"被关闭连接，code：%ld\nreason：%@\nwasClean：%d", code, reason, wasClean);
    
    // 如果是被用户自己中断的那么直接断开连接，否则开始重连
    if (code == DisconnectTypeByUser) {
        [self disConnect];
    } else {
        [self reConnect];
    }
    
    // 断开连接时， 取消心跳
    [self cancelHeartBeat];
}

// sendPing的时候，如果网络通的话，则会收到回调，但是必须保证ScoketOpen，否则会crash
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongData {
    NSLog(@"收到pong回调");
}

// 将收到的消息，是否需要把data转换为NSString，每次收到消息都会被调用，默认YES
//- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
//    NSLog(@"webSocketShouldConvertTextFrameToString");
//    
//    return NO;
//}

@end
