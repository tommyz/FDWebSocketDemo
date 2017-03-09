//
//  FDChatMessageManager.h
//  SocketDemo
//
//  Created by xietao on 16/12/12.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDChatMessage.h"

typedef void(^WriteMessageSuccess)();
typedef void(^WriteMessageFailure)();

@interface FDChatMessageManager : NSObject


- (instancetype)initWithUUID:(NSString *)UUID writeMessageSuccess:(WriteMessageSuccess)success writeMessageFailure:(WriteMessageFailure)failure;

- (void)setMessageSuccess;

- (void)setMessageFailure;

@end
