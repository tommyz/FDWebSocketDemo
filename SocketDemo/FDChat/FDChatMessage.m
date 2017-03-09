//
//  FDChatMessage.m
//  SocketDemo
//
//  Created by xietao on 16/12/12.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import "FDChatMessage.h"

@interface FDChatMessage ()

@end

@implementation FDChatMessage

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (NSString *)time{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.timestamp doubleValue]/ 1000.0];
    NSDateFormatter *dateFt = [[NSDateFormatter alloc]init];
    dateFt.dateFormat = @"HH:mm";
    NSString* dateString = [dateFt stringFromDate:date];
    return dateString;
}

@end


@implementation FDChatMessageVisitor


@end
