//
//  FDEmotion.h
//  chatDemo
//
//  Created by xieyan on 2016/12/12.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDEmotion : NSObject

/** emoji表情的16进制编码 */
@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *type;


+ (instancetype)emotionWithDict:(NSDictionary *)dict;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
