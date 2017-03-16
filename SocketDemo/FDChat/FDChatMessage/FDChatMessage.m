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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uuid = [self getUUID];
        _messageDate = [self getmessageDate];
    }
    return self;
}

- (NSString *)getUUID {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

- (NSDate *)getmessageDate {
    return [NSDate date];
}

@end


@implementation FDChatMessageVisitor

@end
