//
//  FDChatMessageParser.m
//  SocketDemo
//
//  Created by xietao on 2017/3/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "FDChatMessageParser.h"
#import "FDChatMessage.h"

@implementation FDChatMessageParser

+ (void)parseMessage:(NSString *)message parseCompletion:(void(^)(FDChatMessage *))parseCompletion {
    if (!message && parseCompletion) parseCompletion(nil);
#warning reply
    FDChatMessage *chatMessage = [[FDChatMessage alloc] initWithString:message error:NULL];
    if ([chatMessage.chatType isEqualToString:FDChatType_LINK] ||
        [chatMessage.chatType isEqualToString:FDChatType_FIRST_CHAT] ||
        [chatMessage.chatType isEqualToString:FDChatType_CHATING] ||
        [chatMessage.chatType isEqualToString:FDChatType_INVESTIGATION] ||
        [chatMessage.chatType isEqualToString:FDChatType_ULN] ||
        [chatMessage.chatType isEqualToString:FDChatType_HEART]
        ) {
        chatMessage.isReply = YES;
    }
    if (parseCompletion) {
        parseCompletion(chatMessage);
    }
}

@end
