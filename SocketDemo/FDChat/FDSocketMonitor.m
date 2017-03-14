//
//  FDSocketMonitor.m
//  SocketDemo
//
//  Created by xietao on 2017/3/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "FDSocketMonitor.h"
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

@implementation FDSocketMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNotification];
    }
    return self;
}

#pragma mark - PrivateMethod
- (void)addNotification {
    __weak __typeof__(self) weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"Unknow Network");
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"Not Reachable Network");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"WWAN Network");
                if (weakSelf.reconnectBlock) {
                    weakSelf.reconnectBlock();
                }
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"WIFI Network");
                if (weakSelf.reconnectBlock) {
                    weakSelf.reconnectBlock();
                }
            }
                break;
            default:
                break;
        }
    }];
}

- (void)willResignActive {
    NSLog(@"willResignActive");
}

- (void)didBecomeActive {
    NSLog(@"didBecomeActive");
    if (self.reconnectBlock) {
        self.reconnectBlock();
    }
}



@end
