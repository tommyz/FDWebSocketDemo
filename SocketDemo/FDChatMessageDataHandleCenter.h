//
//  FDChatMessageDataHandleCenter.h
//  SocketDemo
//
//  Created by xieyan on 2017/3/9.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FDChatMessageFrame;
@interface FDChatMessageDataHandleCenter : NSObject

+ (NSArray *)getMessageFrames;

+ (void)addMessageFrame:(FDChatMessageFrame *)messageFrame;

+ (void)updateMessageFrame:(FDChatMessageFrame *)messageFrame;

@end
