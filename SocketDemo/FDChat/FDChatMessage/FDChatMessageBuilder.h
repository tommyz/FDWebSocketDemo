//
//  FDChatMessageBuilder.h
//  SocketDemo
//
//  Created by xietao on 2017/3/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FDChatMessage;

@interface FDChatMessageBuilder : NSObject

#pragma mark - 指令
/**
 连接指令
 
 @return FDChatMessage
 */
+ (FDChatMessage *)buildConnectSocketMessage;

/**
 初始化、分配客服指令
 
 @return FDChatMessage
 */
+ (FDChatMessage *)buildSetupChatMessage;

/**
 断开连接指令
 
 @return FDChatMessage
 */
+ (FDChatMessage *)buildDisconnectMessage;

/**
 心跳指令
 
 @return FDChatMessage
 */
+ (FDChatMessage *)buildHeartPacketMessage;

#pragma mark - 消息
/**
 文本消息
 
 @param message 消息内容
 @return FDChatMessage
 */
+ (FDChatMessage *)buildTextMessage:(NSString *)message;

/**
 图片消息
 
 @param message 图片URL
 @return FDChatMessage
 */
+ (FDChatMessage *)buildImageMessage:(NSString *)message;

/**
 商品消息
 
 @param message 商品ID
 @return FDChatMessage
 */
+ (FDChatMessage *)buildProductMessage:(NSString *)message;

/**
 订单消息
 
 @param message 订单ID
 @return FDChatMessage
 */
+ (FDChatMessage *)buildOrderMessage:(NSString *)message;

/**
 提交评论消息
 
 @param score 评分(拒绝评分给nil)
 @return FDChatMessage
 */
+ (FDChatMessage *)buildCommentWithScore:(NSString *)score;


/**
 系统消息

 @param message 消息内容
 @return FDChatMessage
 */
+ (FDChatMessage *)buildSystemMessage:(NSString *)message;
@end
