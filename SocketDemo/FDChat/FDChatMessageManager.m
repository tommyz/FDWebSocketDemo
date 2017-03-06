//
//  FDChatMessageManager.m
//  SocketDemo
//
//  Created by xietao on 16/12/12.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import "FDChatMessageManager.h"
#import "FDWebSocket.h"

static const NSTimeInterval FDMessageTimeOutInterval = 15.0;

@interface FDChatMessageManager ()

// 发送信息成功block
@property (copy, nonatomic) WriteMessageSuccess writeMessageSuccess;
// 发送信息失败block
@property (copy, nonatomic) WriteMessageFailure writeMessageFailure;

@property (copy, nonatomic) NSString *uuid;


@end

@implementation FDChatMessageManager

- (instancetype)initWithUUID:(NSString *)UUID writeMessageSuccess:(WriteMessageSuccess)success writeMessageFailure:(WriteMessageFailure)failure {
    self = [super init];
    if (self) {
        self.uuid = UUID;
        self.writeMessageSuccess = success;
        self.writeMessageFailure = failure;
        [self performSelector:@selector(timeoutAction) withObject:nil afterDelay:FDMessageTimeOutInterval];
    }
    return self;
}

- (void)timeoutAction {
    if (self.writeMessageFailure) {
        self.writeMessageFailure();
    }
    [FDWebSocket removeMessageManagerWithUuid:_uuid];
}

- (void)setMessageSuccess {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.writeMessageSuccess) {
        self.writeMessageSuccess();
    }
}

- (void)setMessageFailure {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.writeMessageFailure) {
        self.writeMessageFailure();
    }
}




@end
