//
//  FDSocketMonitor.h
//  SocketDemo
//
//  Created by xietao on 2017/3/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FDSocketMonitor : NSObject

@property (nonatomic, copy) void(^reconnectBlock)();

@end
