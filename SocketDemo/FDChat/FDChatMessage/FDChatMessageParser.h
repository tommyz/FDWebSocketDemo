//
//  FDChatMessageParser.h
//  SocketDemo
//
//  Created by xietao on 2017/3/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FDChatMessage;
@interface FDChatMessageParser : NSObject

/**
 解析收到的数据
 
 @param message     message
 @param callBacks   callBacks

 @param receiveMessageBlock receiveMessageBlock
 */
+ (void)parseMessage:(NSString *)message callBacks:(NSMutableDictionary *)callBacks receiveMessageBlock:(void(^)(FDChatMessage *))receiveMessageBlock;


@end
