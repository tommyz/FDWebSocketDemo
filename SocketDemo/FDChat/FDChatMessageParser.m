//
//  FDChatMessageParser.m
//  SocketDemo
//
//  Created by xietao on 2017/3/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "FDChatMessageParser.h"
#import "FDChatMessage.h"
#import "FDChatMessageManager.h"
#import "FDChatConfig.h"

@implementation FDChatMessageParser

+ (void)parseMessage:(NSString *)message callBacks:(NSMutableDictionary *)callBacks receiveMessageBlock:(void(^)(FDChatMessage *))receiveMessageBlock {
    if (!message) return;
    FDChatMessage *chatMessage = [[FDChatMessage alloc] initWithString:message error:NULL];
    if (!chatMessage) return;
    // 是否为服务器应答
    if ([chatMessage.chatType isEqualToString:FDChatType_LINK] ||
        [chatMessage.chatType isEqualToString:FDChatType_FIRST_CHAT] ||
        [chatMessage.chatType isEqualToString:FDChatType_CHATING] ||
        [chatMessage.chatType isEqualToString:FDChatType_INVESTIGATION] ||
        [chatMessage.chatType isEqualToString:FDChatType_ULN] ||
        [chatMessage.chatType isEqualToString:FDChatType_HEART]
        ) {
        // 是服务器应答 调发送成功回调
        chatMessage.isReply = YES;
        if ([callBacks.allKeys containsObject:chatMessage.uuid]) {
            FDChatMessageManager *manager = callBacks[chatMessage.uuid];
            [manager setMessageSuccess:chatMessage];
        }else{
            NSLog(@"发送超时的消息又收到了");
        }

    }else{
        // 客服发送的消息 包含多种类型
        if (receiveMessageBlock) {
            receiveMessageBlock(chatMessage);
        }
    }
    
}

@end
