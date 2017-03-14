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

// 是否结束聊天
@property (nonatomic, assign) BOOL isFinishChat;

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

/*
 *  把图片存本地
 *  image     要存的图片
 *  imageName 图片名称(uuid)
 */
+ (void)saveImageToSandBox:(UIImage *)image imageName:(NSString *)imageName;

/*
 *  从本地取图片
 *  imageName 图片名称(uuid)
 */
+ (UIImage *)getImageFromSandBox:(NSString *)imageName;

/*
 *  上传图片
 *  image   要上传的图片
 */
- (void)uploadImage:(UIImage *)image;

@end
