//
//  FDChatMessageBuilder.m
//  SocketDemo
//
//  Created by xietao on 2017/3/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "FDChatMessageBuilder.h"
#import "FDChatMessage.h"

typedef NS_ENUM(NSUInteger, FDMessageSendChatType) {
    FDMessageSendChatTypeLINK = 0,
    FDMessageSendChatTypeFIRST_CHATING,
    FDMessageSendChatTypeCHATING,
    FDMessageSendChatTypeComment,
    FDMessageSendChatTypeULN,
    FDMessageSendChatTypeHEART
};

typedef NS_ENUM(NSUInteger, FDMessageReceiveChatType) {
    FDMessageReceiveChatTypeComment_SERVICE = 0,
    FDMessageReceiveChatTypeCHATTING_SERVICE,
    FDMessageReceiveChatTypeSTOP_CHAT_SERVICE,
    FDMessageReceiveChatTypeULN_SERVICE
};

typedef NS_ENUM(NSUInteger, FDMessageSendMsgType) {
    FDMessageSendMsgTypeNone = 0,
    FDMessageSendMsgTypeText,
    FDMessageSendMsgTypeImage,
    FDMessageSendMsgTypeProduct,
    FDMessageSendMsgTypeOrder,
    FDMessageSendMsgTypeComment
};

@implementation FDChatMessageBuilder

#pragma mark - Builder
+ (FDChatMessage *)buildConnectSocketMessage {
    return [self buildChatCommondType:FDMessageSendChatTypeLINK];
}

+ (FDChatMessage *)buildSetupChatMessage {
    return [self buildChatCommondType:FDMessageSendChatTypeFIRST_CHATING];
}

+ (FDChatMessage *)buildDisconnectMessage {
    return [self buildChatCommondType:FDMessageSendChatTypeULN];
}

+ (FDChatMessage *)buildTextMessage:(NSString *)message {
    return [self buildMessage:message msgType:FDMessageSendMsgTypeText chatType:FDMessageSendChatTypeCHATING];
}

+ (FDChatMessage *)buildImageMessage:(NSString *)message {
    return [self buildMessage:message msgType:FDMessageSendMsgTypeImage chatType:FDMessageSendChatTypeCHATING];
}

+ (FDChatMessage *)buildProductMessage:(NSString *)message {
    return [self buildMessage:message msgType:FDMessageSendMsgTypeProduct chatType:FDMessageSendChatTypeCHATING];
}

+ (FDChatMessage *)buildOrderMessage:(NSString *)message {
    return [self buildMessage:message msgType:FDMessageSendMsgTypeOrder chatType:FDMessageSendChatTypeCHATING];
}

+ (FDChatMessage *)buildCommentWithScore:(NSString *)score {
    return [self buildMessage:score msgType:FDMessageSendMsgTypeComment chatType:FDMessageSendChatTypeComment];
}

+ (FDChatMessage *)buildHeartPacketMessage {
    return [self buildChatCommondType:FDMessageSendChatTypeHEART];
}

#pragma mark Common
+ (FDChatMessage *)buildChatCommondType:(FDMessageSendChatType)commondType {
    return [self buildMessage:nil msgType:FDMessageSendMsgTypeNone chatType:commondType];
}

+ (FDChatMessage *)buildMessage:(NSString *)message msgType:(FDMessageSendMsgType)msgType chatType:(FDMessageSendChatType)chatType{
    FDChatMessage *chatMessage = [[FDChatMessage alloc] init];
    
    chatMessage.visitor = [[FDChatMessageVisitor alloc] init];
#warning user;
    chatMessage.visitor.name = @"xietao3";
    chatMessage.visitor.uid = @"xietao3";
    chatMessage.uuid = [self uuidString];
    chatMessage.chatSource = FDChatSource;
    
    
    switch (chatType) {
        // 连接服务器 传系统入参 获取离线消息
        case FDMessageSendChatTypeLINK:
        {
            chatMessage.chatType = FDChatType_LINK;
#warning 系统入参
            chatMessage.chatSource = @"IOS";
            //            chatMessage.version = @"";
            //            chatMessage.deviceId = @"";
            //            chatMessage.channel = @"";
            //            chatMessage.connectId = @"";
            //            chatMessage.lonlat = @"";
            //            chatMessage.address = @"";
        }
        break;
        // 建立会话 分配客服
        case FDMessageSendChatTypeFIRST_CHATING:
        {
            chatMessage.chatType = FDChatType_FIRST_CHAT;
        }
        break;
        // 正常聊天信息
        case FDMessageSendChatTypeCHATING:
        {
            chatMessage.chatType = FDChatType_CHATING;
            switch (msgType) {
                case FDMessageSendMsgTypeText:
                {
                    chatMessage.msgType = FDChatMsgTypeText;
                }
                break;
                case FDMessageSendMsgTypeImage:
                {
                    chatMessage.msgType = FDChatMsgTypeImg;
                }
                break;
                case FDMessageSendMsgTypeProduct:
                {
                    chatMessage.msgType = FDChatMsgTypeProduct;
                }
                break;
                case FDMessageSendMsgTypeOrder:
                {
                    chatMessage.msgType = FDChatMsgTypeOrder;
                }
                break;
                default:
                break;
            }
            chatMessage.msg = message;
        }
        break;
        // 评分
        case FDMessageSendChatTypeComment:
        {
            chatMessage.chatType = FDChatType_INVESTIGATION;
            if (message && msgType == FDMessageSendMsgTypeComment) {
                chatMessage.score = message;
                chatMessage.isScored = @"1";
            }else{
                chatMessage.isScored = @"0";
            }
        }
        break;
        // 断开连接
        case FDMessageSendChatTypeULN:
        {
            chatMessage.chatType = FDChatType_ULN;
        }
        break;
        // 心跳
        case FDMessageSendChatTypeHEART:
        {
            chatMessage.chatType = FDChatType_HEART;
        }
        break;
        default:
        break;
    }
    return chatMessage;
}





#pragma mark UUID
+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

@end
