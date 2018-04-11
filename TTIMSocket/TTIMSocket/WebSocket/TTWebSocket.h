//
//  TTWebSocket.h
//  TTIMSocket
//
//  Created by TT on 2018/4/9.
//  Copyright © 2018年 TAO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DisconnectType) {
    DisconnectTypeByUser,
    DisconnectTypeServer
};

@interface TTWebSocket : NSObject

+ (instancetype)sharedManager;

/**
 连接
 */
- (void)connect;

/**
 断开连接
 */
- (void)disConnect;

/**
 发送消息
 
 @param message 消息
 */
- (void)sendMessage:(NSString *)message;

- (void)pingPong;

@end
