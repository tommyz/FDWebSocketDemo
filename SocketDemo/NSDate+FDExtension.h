//
//  NSDate+FDExtension.h
//  Fruitday
//
//  Created by xieyan on 2016/10/20.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FDExtension)

/**
 *  判断某个时间是否为今年
 */
- (BOOL)isThisYear;
/**
 *  判断某个时间是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  判断某个时间是否为今天
 */
- (BOOL)isToday;

@end
