//
//  FDChatMessageDataHandleCenter.h
//  SocketDemo
//
//  Created by xieyan on 2017/3/9.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FDChatMessage,UIImage;
@interface FDChatMessageDataHandleCenter : NSObject

// 用于刷新页面
@property (copy ,nonatomic) void (^reloadDataBlock)();

/*
 *  单例
 */
+ (instancetype)shareHandleCenter;


/*
 *  获取聊天历史记录
 */
+ (NSArray *)getMessages;

/*
 *  添加聊天记录
 *  message   要添加的聊天记录
 */
+ (void)addMessage:(FDChatMessage *)message;

/*
 *  用于查询此消息是否存在
 *  uuid   要查询的消息id
 */
+ (BOOL)isExistMessage:(NSString *)uuid;

/*
 *  初始化聊天socket
 */
- (void)openSocket;


/*
 *  关闭聊天socket
 */
- (void)closeSocket;

/*
 *  发送消息
 *  message   要发送的消息
 */
- (void)sendMessage:(FDChatMessage *)message;


- (void)uploadImage:(UIImage *)image;

@end
