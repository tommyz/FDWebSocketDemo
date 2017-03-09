//
//  FDChatMessage.h
//  SocketDemo
//
//  Created by xietao on 16/12/12.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

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
static NSString *const FDChatType_CHATTING_SERVICE         = @"CHATTING_SERVICE";       // 客服回复
static NSString *const FDChatType_STOP_CHAT_SERVICE        = @"STOP_CHAT_SERVICE";             // 客服结束聊天
static NSString *const FDChatType_ULN_SERVICE              = @"ULN_SERVICE";            // 服务器主动断开


/*----------- msgType ----------------*/
static NSString *const FDChatMsgTypeText        = @"text";      // 文本
static NSString *const FDChatMsgTypeImg         = @"img";       // 图片
static NSString *const FDChatMsgTypeProduct     = @"product";   // 商品
static NSString *const FDChatMsgTypeOrder       = @"order";     // 订单

typedef NS_ENUM(NSInteger,FDChatMessageBy) {
    FDChatMessageByServicer = 0,      //客服发的消息
    FDChatMessageByCustomer,          //客户发的消息
    FDChatMessageBySystem             //系统消息
};

#define FDChatSource      @"IOS"

typedef NS_ENUM(NSInteger,FDChatMessageState) {
    FDChatMessageStateSending = 0,         //消息发送中
    FDChatMessageStateSendSuccess,         //消息发送成功
    FDChatMessageStateSendFailure          //系统发送失败
};

@class FDChatMessageVisitor;
@interface FDChatMessage : JSONModel
// require
@property (strong, nonatomic) NSString *chatType;
@property (strong, nonatomic) NSString *uuid;

// send
@property (strong, nonatomic) FDChatMessageVisitor *visitor;

// receive
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *errMsg;

// optional
@property (strong, nonatomic) NSString *msgType;
@property (strong, nonatomic) NSString *msg;
@property (nonatomic, copy)NSString *time;
@property (nonatomic, assign) FDChatMessageBy chatMessageBy ;
@property (nonatomic, assign) BOOL hideTime;
@property (nonatomic, assign) FDChatMessageState messageState;


// 系统入参
@property (strong, nonatomic) NSString *chatSource;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) NSString *connectId;
@property (strong, nonatomic) NSString *lonlat;
@property (strong, nonatomic) NSString *address;
// 评分
@property (strong, nonatomic) NSString *score;
@property (strong, nonatomic) NSString *isScored;

// 其他
@property (assign, nonatomic) BOOL isReply;
@end

@interface FDChatMessageVisitor : JSONModel

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uid;

@end





