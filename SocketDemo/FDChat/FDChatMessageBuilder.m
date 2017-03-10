//
//  FDChatMessageBuilder.m
//  SocketDemo
//
//  Created by xietao on 2017/3/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "FDChatMessageBuilder.h"
#import "FDChatMessage.h"

@implementation FDChatMessageBuilder

#pragma mark - Builder
+ (FDChatMessage *)buildConnectSocketMessage {
    return [self buildChatCommondType:FDChatType_LINK];
}

+ (FDChatMessage *)buildSetupChatMessage {
    return [self buildChatCommondType:FDChatType_FIRST_CHAT];
}

+ (FDChatMessage *)buildDisconnectMessage {
    return [self buildChatCommondType:FDChatType_ULN];
}

+ (FDChatMessage *)buildHeartPacketMessage {
    return [self buildChatCommondType:FDChatType_HEART];
}

+ (FDChatMessage *)buildTextMessage:(NSString *)message {
    return [self buildMessage:message msgType:FDChatMsgTypeText chatType:FDChatType_CHATING];
}

+ (FDChatMessage *)buildImageMessage:(NSString *)message {
    return [self buildMessage:message msgType:FDChatMsgTypeImg chatType:FDChatType_CHATING];
}

+ (FDChatMessage *)buildProductMessage:(NSString *)message {
    return [self buildMessage:message msgType:FDChatMsgTypeProduct chatType:FDChatType_CHATING];
}

+ (FDChatMessage *)buildOrderMessage:(NSString *)message {
    return [self buildMessage:message msgType:FDChatMsgTypeOrder chatType:FDChatType_CHATING];
}

+ (FDChatMessage *)buildCommentWithScore:(NSString *)score {
    return [self buildMessage:score msgType:FDChatMsgTypeComment chatType:FDChatType_INVESTIGATION];
}

+ (FDChatMessage *)buildSystemMessage:(NSString *)message {
    // 初始化时自动生成uuid、date
    FDChatMessage *chatMessage = [[FDChatMessage alloc] init];
    chatMessage.msg = message;
    chatMessage.chatMessageBy = FDChatMessageBySystem;
    return chatMessage;
}


#pragma mark Common
+ (FDChatMessage *)buildChatCommondType:(NSString *)commondType {
    return [self buildMessage:nil msgType:nil chatType:commondType];
}

+ (FDChatMessage *)buildMessage:(NSString *)message msgType:(NSString *)msgType chatType:(NSString *)chatType{
    // 初始化时自动生成uuid、date
    FDChatMessage *chatMessage = [[FDChatMessage alloc] init];
    chatMessage.visitor = [[FDChatMessageVisitor alloc] init];
#warning user;
    chatMessage.visitor.name = @"xietao3";
    chatMessage.visitor.uid = @"xietao3";
    chatMessage.chatSource = FDChatSource;
    chatMessage.chatType = chatType;
    
    // 根据不同类型注入不同信息
    if ([chatType isEqualToString:FDChatType_LINK]) {
        // 连接服务器 传系统入参 获取离线消息
#warning 系统入参
        chatMessage.chatSource = @"IOS";
        //            chatMessage.version = @"";
        //            chatMessage.deviceId = @"";
        //            chatMessage.channel = @"";
        //            chatMessage.connectId = @"";
        //            chatMessage.lonlat = @"";
        //            chatMessage.address = @"";

    }else if ([chatType isEqualToString:FDChatType_FIRST_CHAT]) {
        // 建立会话 分配客服

    }else if ([chatType isEqualToString:FDChatType_CHATING]) {
        // 正常聊天信息
        chatMessage.msgType = msgType;
        chatMessage.msg = message;

    }else if ([chatType isEqualToString:FDChatType_INVESTIGATION]) {
        // 评分
        chatMessage.chatType = FDChatType_INVESTIGATION;
        if (message && msgType == FDChatMsgTypeComment) {
            chatMessage.score = message;
            chatMessage.isScored = @"1";
        }else{
            chatMessage.isScored = @"0";
        }
    }else if ([chatType isEqualToString:FDChatType_ULN]) {
        // 断开连接

    }else if ([chatType isEqualToString:FDChatType_HEART]) {
        // 心跳

    }
    return chatMessage;
}


@end
