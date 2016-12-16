//
//  FDChatMessageMamager.h
//  SocketDemo
//
//  Created by xietao on 16/12/12.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FDChatMessage;
@interface FDChatMessageMamager : NSObject



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
 文本信息指令

 @param message 消息
 @return FDChatMessage
 */
+ (FDChatMessage *)buildTextMessage:(NSString *)message;

/**
 图片信息

 @param message 图片URL
 @return FDChatMessage
 */
+ (FDChatMessage *)buildImageMessage:(NSString *)message;

/**
 商品信息

 @param message 商品ID
 @return FDChatMessage
 */
+ (FDChatMessage *)buildProductMessage:(NSString *)message;

/**
 订单信息

 @param message 订单ID
 @return FDChatMessage
 */
+ (FDChatMessage *)buildOrderMessage:(NSString *)message;

/**
 提交评论指令

 @param score 评分(拒绝评分给nil)
 @return FDChatMessage
 */
+ (FDChatMessage *)buildCommentWithScore:(NSString *)score;

/**
 心跳指令

 @return FDChatMessage
 */
+ (FDChatMessage *)buildHeartPacketMessage;

@end
