//
//  FDWebSocket.h
//  SocketDemo
//
//  Created by xietao on 16/12/9.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDChatMessageBuilder.h"



@class FDChatMessage;

// def block
typedef void(^ConnectSocketSuccess)();
typedef void(^ConnectSocketFailure)();
typedef void(^DisconnectCompletion)();
typedef void(^WriteMessageSuccess)();
typedef void(^WriteMessageFailure)();
typedef void(^ReceiveMessageBlock)(FDChatMessage *message);

@interface FDWebSocket : NSObject


/**
 创建单例

 @return 实例
 */
+ (instancetype)shareInstance;


/**
 建立会话

 @param success 成功block
 @param failure 失败block
 */
+ (void)openSocketSuccess:(ConnectSocketSuccess)success failure:(ConnectSocketFailure)failure;


/**
 关闭会话

 @param completionBlock completionBlock
 */
+ (void)closeSocketCompletionBlock:(void(^)())completionBlock;


/**
 异常断开block

 @param exceptionDisconnectBlock exceptionDisconnectBlock
 */
+ (void)setExceptionDisconnectBlock:(void(^)())exceptionDisconnectBlock;


/**
 发送信息

 @param message 信息
 @param success 成功block
 @param failure 失败block
 */
+ (void)sendMessage:(id)message Success:(WriteMessageSuccess)success failure:(WriteMessageFailure)failure;


/**
 接收信息

 @param receiveMessageBlock receiveMessageBlock
 */
+ (void)setReceiveMessageBlock:(ReceiveMessageBlock)receiveMessageBlock;


/**
 根据UUID移除messageManager从消息列表

 @param uuid uuid description
 */
+ (void)removeMessageManagerWithUuid:(NSString *)uuid;
@end
