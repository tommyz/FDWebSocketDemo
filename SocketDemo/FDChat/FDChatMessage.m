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

///**
// *  当一个对象要归档进沙盒中时，就会调用这个方法
// *  目的：在这个方法中说明这个对象的哪些属性要存进沙盒
// */
//- (void)encodeWithCoder:(NSCoder *)encoder
//{
//    [encoder encodeObject:self.chatType forKey:@"chatType"];
//    [encoder encodeObject:self.uuid forKey:@"uuid"];
//    
//    [encoder encodeObject:self.visitor forKey:@"visitor"];
//    [encoder encodeObject:self.code forKey:@"code"];
//    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
//    [encoder encodeObject:self.errMsg forKey:@"errMsg"];
//    [encoder encodeObject:self.msgType forKey:@"msgType"];
//    [encoder encodeObject:self.msg forKey:@"msg"];
//    [encoder encodeObject:self.timeDate forKey:@"timeDate"];
//    [encoder encodeObject:self.chatSource forKey:@"chatSource"];
//    [encoder encodeObject:self.version forKey:@"version"];
//    [encoder encodeObject:self.deviceId forKey:@"deviceId"];
//    [encoder encodeObject:self.channel forKey:@"channel"];
//    [encoder encodeObject:self.connectId forKey:@"connectId"];
//    [encoder encodeObject:self.lonlat forKey:@"lonlat"];
//    [encoder encodeObject:self.address forKey:@"address"];
//    [encoder encodeObject:self.score forKey:@"score"];
////    [encoder encodeObject:@self.isScored forKey:@"isScored"];
////    [encoder encodeObject:@self.isReply forKey:@"isReply"];
////    [encoder encodeObject:self.hideTime forKey:@"hideTime"];
////    [encoder encodeObject:self.msg forKey:@"msg"];
//
//}
//
///**
// *  当从沙盒中解档一个对象时（从沙盒中加载一个对象时），就会调用这个方法
// *  目的：在这个方法中说明沙盒中的属性该怎么解析（需要取出哪些属性）
// */
//- (id)initWithCoder:(NSCoder *)decoder
//{
//    if (self = [super init]) {
//        self.chatType = [decoder decodeObjectForKey:@"chatType"];
//        self.uuid = [decoder decodeObjectForKey:@"uuid"];
//        
//        self.visitor = [decoder decodeObjectForKey:@"visitor"];
//        self.code = [decoder decodeObjectForKey:@"code"];
//        
//        self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
//        self.errMsg = [decoder decodeObjectForKey:@"errMsg"];
//        self.msgType = [decoder decodeObjectForKey:@"msgType"];
//        self.msg = [decoder decodeObjectForKey:@"msg"];
//        self.timeDate = [decoder decodeObjectForKey:@"timeDate"];
//        self.chatSource = [decoder decodeObjectForKey:@"chatSource"];
//        self.version = [decoder decodeObjectForKey:@"version"];
//        self.deviceId = [decoder decodeObjectForKey:@"deviceId"];
//        self.channel = [decoder decodeObjectForKey:@"channel"];
//        self.connectId = [decoder decodeObjectForKey:@"connectId"];
//        self.lonlat = [decoder decodeObjectForKey:@"lonlat"];
//        self.address = [decoder decodeObjectForKey:@"address"];
//        self.score = [decoder decodeObjectForKey:@"score"];
////        self.isScored = [decoder decodeObjectForKey:@"isScored"];
////        self.isReply = [decoder decodeObjectForKey:@"isReply"];
////        self.hideTime = [decoder decodeObjectForKey:@"hideTime"];
////        self.hideTime = [decoder decodeObjectForKey:@"hideTime"];
////        self.hideTime = [decoder decodeObjectForKey:@"hideTime"];
////        self.hideTime = [decoder decodeObjectForKey:@"hideTime"];
//
//    }
//    return self;
//}

@end


@implementation FDChatMessageVisitor

///**
// *  当一个对象要归档进沙盒中时，就会调用这个方法
// *  目的：在这个方法中说明这个对象的哪些属性要存进沙盒
// */
//- (void)encodeWithCoder:(NSCoder *)encoder
//{
//    [encoder encodeObject:self.name forKey:@"name"];
//    [encoder encodeObject:self.uid forKey:@"uid"];
//}
//
///**
// *  当从沙盒中解档一个对象时（从沙盒中加载一个对象时），就会调用这个方法
// *  目的：在这个方法中说明沙盒中的属性该怎么解析（需要取出哪些属性）
// */
//- (id)initWithCoder:(NSCoder *)decoder
//{
//    if (self = [super init]) {
//        self.name = [decoder decodeObjectForKey:@"name"];
//        self.uid = [decoder decodeObjectForKey:@"uid"];
//    }
//    return self;
//}

@end
