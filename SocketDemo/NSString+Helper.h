//
//  NSString+Helper.h
//  FlashFresh
//
//  Created by xietao on 14-10-15.
//  Copyright (c) 2014年 YunYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Helper)

- (CGSize)getSizeWithWidth:(CGFloat)width andFont:(UIFont *)font;

+ (BOOL)isEmptyString:(NSString* )string;

- (BOOL)stringIsEmpty;
- (BOOL)stringContainsString:(NSString *)subString;
+ (NSString*)stringFromDate:(NSDate*)date;
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSString*)stringFromTimestamp:(NSString *)timestamp;
+ (NSString *)formatPostDate:(NSDate *)date;
#pragma mark - 正则
- (BOOL)isValidEmail;
- (BOOL)isValidPhoneNumber;
- (BOOL)isValidUrl;
- (BOOL)isVaildName;
- (BOOL)containsOnlyLetters;
- (BOOL)containsOnlyNumbers;
- (BOOL)containsOnlyNumbersAndLetters;
/**
 *  检测是否为手机号
 *
 *  @return 
 */
- (BOOL)isValidMobilePhoneNumber;
/**
 *  手机号加星号
 *
 *  @return 
 */
- (NSString *)formateSecretMobilePhoneNo;
/**
 *  将十六进制的编码转为emoji字符
 */
+ (NSString *)emojiWithIntCode:(int)intCode;

/**
 *  将十六进制的编码转为emoji字符
 */
+ (NSString *)emojiWithStringCode:(NSString *)stringCode;
- (NSString *)emoji;

/**
 *  是否为emoji字符
 */
- (BOOL)isEmoji;

@end
