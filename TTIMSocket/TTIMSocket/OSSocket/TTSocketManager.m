//
//  TTSocketManager.m
//  TTIMSocket
//
//  Created by TT on 2018/4/9.
//  Copyright © 2018年 TAO. All rights reserved.
//

#import "TTSocketManager.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface TTSocketManager ()

@property (nonatomic, assign) int clientSocket;

@end

@implementation TTSocketManager

#pragma mark - Static Method

static int CreateClientSocket() {
    int clientSocket = 0;
    
    // 创建一个socket,返回值为Int。（注scoket其实就是Int类型）
    // 第一个参数addressFamily IPv4(AF_INET) 或 IPv6(AF_INET6)。
    // 第二个参数 type 表示 socket 的类型，通常是流stream(SOCK_STREAM) 或数据报文datagram(SOCK_DGRAM)
    // 第三个参数 protocol 参数通常设置为0，以便让系统自动为选择我们合适的协议，对于 stream socket 来说会是 TCP 协议(IPPROTO_TCP)，而对于 datagram来说会是 UDP 协议(IPPROTO_UDP)。
    clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    
    return clientSocket;
}

static int ConnectionToServer(int client_socket, const char *server_ip, unsigned short port) {
    
    // 1. 生成一个 sockaddr_in 类型结构体
    struct sockaddr_in sAddr = { 0 };
    sAddr.sin_len = sizeof(sAddr);
    
    // 2. 设置 IPv4
    sAddr.sin_family = AF_INET;
    
    // inet_aton是一个改进的方法来将一个字符串IP地址转换为一个32位的网络序列IP地址
    // 如果这个函数成功，函数的返回值非零，如果输入地址不正确则会返回零。
    inet_aton(server_ip, &sAddr.sin_addr);
    
    // htons 是将整型变量从主机字节顺序转变成网络字节顺序，赋值端口号
    sAddr.sin_port = htons(port);
    
    // 用scoket和服务端地址，发起连接。
    // 客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回 -1。
    // 注意：该接口调用会阻塞当前线程，直到服务器返回。
    if (connect(client_socket, (struct sockaddr *)&sAddr, sizeof(sAddr)) == 0) {
        return client_socket;
    }
    
    return 0;
}

#pragma mark - 单例

+ (instancetype)sharedManager {
    static TTSocketManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TTSocketManager alloc] init];
    });
    return _instance;
}

#pragma mark - Public Method

- (void)connect {
    // 建立连接
    [self initSocket];
    [self pullMessage];
}

- (void)disConnect {
    // 关闭连接
    close(self.clientSocket);
}

- (void)sendMessage:(NSString *)message {
    const char *send_Message = [message UTF8String];
    send(self.clientSocket, send_Message, strlen(send_Message) + 1, 0);
}

#pragma mark - Private Method

// 初始化 socket
- (void)initSocket {
    
    // 每次连接前，先断开连接
    if (_clientSocket != 0) {
        [self disConnect];
        _clientSocket = 0;
    }
    
    // 创建客户端 socket
    _clientSocket = CreateClientSocket();
    
    // 服务器 ip
    const char *server_ip = "127.0.0.1";
    // 服务器端口
    short server_port = 6969;
    
    // 等于 0 说明连接失败
    if (ConnectionToServer(_clientSocket, server_ip, server_port) == 0) {
        printf("Connect to server error\n");
        return;
    }
    
    // 说明连接成功
    printf("Connect to server ok\n");
}

#pragma mark - 新线程来接收消息

- (void)pullMessage {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(recieveAction) object:nil];
    [thread start];
}

// 收取服务端发送的消息
- (void)recieveAction {
    while (1) {
        char recv_Message[1024] = { 0 };
        recv(self.clientSocket, recv_Message, sizeof(recv_Message), 0);
        
        printf("%s\n", recv_Message);
    }
}

@end
