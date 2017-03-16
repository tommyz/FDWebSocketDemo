//
//  FDChatMessage.h
//  SocketDemo
//
//  Created by xietao on 16/12/12.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FDChatConfig.h"

/*----------- FDChatStatusCode ----------------*/
/**
 FDChatStatusCode
 
 200 - 正常
 300 - 错误弹窗提示
 301 - 错误弱提示
 501 - 暂无客服
 502 - 客服忙碌
 503 - 客服离开
 */
typedef NS_ENUM(NSUInteger, FDChatStatusCode) {
    FDChatStatusCodeSuccess       = 200,
    FDChatStatusCodeAlert         = 300,
    FDChatStatusCodeToast         = 301,
    FDChatStatusCodeNoService     = 501,
    FDChatStatusCodeServiceBusy   = 502,
    FDChatStatusCodeServiceLeave  = 503
};

/*----------- ChatType ----------------*/
// 发送命令
static NSString *const FDChatType_LINK                     = @"LINK";               // 建立连接
static NSString *const FDChatType_FIRST_CHAT               = @"FIRST_CHAT";         // 开始聊天
static NSString *const FDChatType_CHATING                  = @"CHATING";            // 发送消息
static NSString *const FDChatType_INVESTIGATION            = @"INVESTIGATION";      // 提交评分
static NSString *const FDChatType_ULN                      = @"ULN";                // 用户主动断开
static NSString *const FDChatType_HEART                    = @"HEART";              // 心跳

// 接收命令
static NSString *const FDChatType_INVESTIGATION_SERVICE    = @"INVESTIGATION_SERVICE";  // 服务器发起评分提示
static NSString *const FDChatType_CHATTING_SERVICE         = @"CHATING_SERVICE";       // 客服回复
static NSString *const FDChatType_STOP_CHAT_SERVICE        = @"STOP_CHAT_SERVICE";      // 客服结束聊天
static NSString *const FDChatType_ULN_SERVICE              = @"ULN_SERVICE";            // 服务器主动断开
static NSString *const FDChatType_NOT_ACTIVE               = @"NOT_ACTIVE";             // 暂无客服


/*----------- msgType ----------------*/
static NSString *const FDChatMsgTypeText        = @"text";      // 文本
static NSString *const FDChatMsgTypeImg         = @"image";     // 图片
static NSString *const FDChatMsgTypeProduct     = @"product";   // 商品
static NSString *const FDChatMsgTypeOrder       = @"order";     // 订单
static NSString *const FDChatMsgTypeComment     = @"comment";   // 客服评分


/*----------- 消息来源 ----------------*/
typedef NS_ENUM(NSInteger,FDChatMessageBy) {
    FDChatMessageByServicer = 0,      // 客服发的消息
    FDChatMessageByCustomer,          // 客户发的消息
    FDChatMessageBySystem             // 系统消息
};

/*----------- 消息发送状态 ----------------*/
typedef NS_ENUM(NSInteger,FDChatMessageState) {
    FDChatMessageSendStateSending = 0,         // 消息发送中
    FDChatMessageSendStateSendSuccess,         // 消息发送成功
    FDChatMessageSendStateSendFailure          // 消息发送失败
};


@protocol FDChatMessage <NSObject>
@end

@class FDChatMessageVisitor;
@interface FDChatMessage : JSONModel
#pragma mark require
// 信息类型
@property (strong, nonatomic) NSString *chatType;
// 唯一标示符
@property (strong, nonatomic) NSString *uuid;


#pragma mark send
// 用户信息
@property (strong, nonatomic) FDChatMessageVisitor *visitor;


#pragma mark receive
//状态码
@property (assign, nonatomic) NSInteger code;
// 时间戳
@property (strong, nonatomic) NSString *timestamp;
// 错误消息
@property (strong, nonatomic) NSString *errMsg;
// 离线消息
@property (nonatomic, strong) NSArray<FDChatMessage> *offline;

#pragma mark optional
// 消息类型
@property (strong, nonatomic) NSString *msgType;
// 消息内容
@property (strong, nonatomic) NSString *msg;
// 消息日期
@property (nonatomic, strong) NSDate *messageDate;


#pragma mark 系统入参
// 平台 iOS
@property (strong, nonatomic) NSString *chatSource;
// 版本号
@property (strong, nonatomic) NSString *version;
// 设备ID
@property (strong, nonatomic) NSString *deviceId;
// 渠道 App Store
@property (strong, nonatomic) NSString *channel;
// 链接id
@property (strong, nonatomic) NSString *connectId;
// 经纬度
@property (strong, nonatomic) NSString *lonlat;
// 地址
@property (strong, nonatomic) NSString *address;

#pragma mark 评分
// 评分
@property (strong, nonatomic) NSString *score;
// 用户是否已打分
@property (strong, nonatomic) NSString *isScored;

#pragma mark 其他 （本地使用）
// 是否为应答的消息
@property (assign, nonatomic) BOOL isReply;
// 聊天页面是否需要显示消息时间
@property (nonatomic, assign) BOOL hideTime;
// 消息来源
@property (nonatomic, assign) FDChatMessageBy chatMessageBy;
// 消息发送状态
@property (nonatomic, assign) FDChatMessageState messageSendState;

@end

@interface FDChatMessageVisitor : JSONModel 
// 用户名
@property (strong, nonatomic) NSString *name;
// 用户ID
@property (strong, nonatomic) NSString *uid;

@end





