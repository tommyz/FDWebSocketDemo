//
//  NSString+Helper.m
//  FlashFresh
//
//  Created by xietao on 14-10-15.
//  Copyright (c) 2014年 YunYi. All rights reserved.
//

#import "NSString+Helper.h"
#define EmojiCodeToSymbol(c) ((((0x808080F0 | (c & 0x3F000) >> 4) | (c & 0xFC0) << 10) | (c & 0x1C0000) << 18) | (c & 0x3F) << 24)

@implementation NSString (Helper)
- (CGSize)getSizeWithWidth:(CGFloat)width andFont:(UIFont *)font{
    
    CGSize stringSize;
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ) {
        NSDictionary *attribute = @{NSFontAttributeName: font};
        stringSize = [self boundingRectWithSize:CGSizeMake(width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    else{
        stringSize = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, 20) lineBreakMode:NSLineBreakByCharWrapping];
    }
    return stringSize;
}

+ (BOOL)isEmptyString:(NSString* )string {
    if (!string || [string isEqualToString:@""] || [string isEqual:[NSNull null]]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)stringIsEmpty{
    if (!self || [self isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)stringContainsString:(NSString *)subString
{
    return ([self rangeOfString:subString].location == NSNotFound) ? NO : YES;
}

/**
 *  是否为有效的邮箱地址
 *
 *  @return
 */
- (BOOL)isValidEmail
{
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTestPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailTestPredicate evaluateWithObject:self];
}

/**
 *  是否为有效电话号码
 *
 *  @return
 */
- (BOOL)isValidPhoneNumber
{
    NSString *regex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}
- (BOOL)isValidMobilePhoneNumber{
    NSString *pattern = @"^(1)[0-9]{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}
- (NSString *)formateSecretMobilePhoneNo{
    return self?([self isValidMobilePhoneNumber]?([self stringByReplacingCharactersInRange:NSMakeRange(3,4) withString:@"****"]):self):@"";
}
/**
 *  是否为有效的URL链接
 *
 *  @return
 */
- (BOOL)isValidUrl
{
    NSString *regex =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

/**
 *  是否为有效姓名 中文10字 英文20
 *
 *  @return 
 */
- (BOOL)isVaildName{
    NSString *regex =@"[a-zA-Z]{1,20}|[\u4e00-\u9fa5]{1,10}";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

/**
 *  只包含字母
 *
 *  @return
 */
- (BOOL)containsOnlyLetters
{
    NSCharacterSet *letterCharacterset = [[NSCharacterSet letterCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:letterCharacterset].location == NSNotFound);
}

/**
 *  只包含数字
 *
 *  @return
 */
- (BOOL)containsOnlyNumbers
{
    NSCharacterSet *numbersCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ([self rangeOfCharacterFromSet:numbersCharacterSet].location == NSNotFound);
}

/**
 *  只包含字母及数字
 *
 *  @return
 */
- (BOOL)containsOnlyNumbersAndLetters
{
    NSCharacterSet *numAndLetterCharSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:numAndLetterCharSet].location == NSNotFound);
}

+ (NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string{
    NSDateFormatter* messageDateFormat = [[NSDateFormatter alloc] init];
    [messageDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return  [messageDateFormat dateFromString:string];
}


+ (NSString*)stringFromTimestamp:(NSString *)timestamp{
    NSString *dateString = [NSString formatPostDate:[NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]]];
    return dateString;
}

+ (NSString *)formatPostDate:(NSDate *)date
{
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSInteger currentYear = [currentComps year];
    NSDateComponents *postComps = [currentCalendar components:unitFlags fromDate:date];
    NSInteger postYear = [postComps year];
    
    NSString *customizedDate = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    NSTimeInterval interval = [date timeIntervalSinceNow];
    if (interval <= 0) {
        interval = (-1) * interval;
        if (interval < 10) {
            customizedDate = @"刚刚";
        } else if (interval >= 10 && interval < 60) {
            customizedDate = [NSString stringWithFormat:@"%.f秒前", interval];
        } else if (interval >= 60 && interval < 30 * 60) {
            customizedDate = [NSString stringWithFormat:@"%.f分钟前", interval / 60];
        } else if (interval >= 30 * 60 && interval < 60 * 60) {
            customizedDate = [NSString stringWithFormat:@"半小时前"];
        } else if (interval >= 60 * 60 && interval < 24 * 60 * 60) {
            customizedDate = [NSString stringWithFormat:@"%.f小时前", interval / (60 * 60)];
        } else if (interval >= 24 * 60 * 60 && interval < 7 * 24 * 60 * 60) {
            customizedDate = [NSString stringWithFormat:@"%.f天前", interval / (24 * 60 * 60)];
        } else {
            if (postYear == currentYear) {
                [dateFormatter setDateFormat:@"MM月dd日"];
            } else {
                [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
            }
            customizedDate = [dateFormatter stringFromDate:date];
        }
    } else {
        if (interval < 30) { // 服务器与App时间差容忍度
            customizedDate = @"刚刚";
        } else {
            if (postYear == currentYear) {
                [dateFormatter setDateFormat:@"MM月dd日"];
            } else {
                [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
            }
            customizedDate = [dateFormatter stringFromDate:date];
        }
    }
    return customizedDate;
}

+ (NSString *)emojiWithIntCode:(int)intCode {
    int symbol = EmojiCodeToSymbol(intCode);
    NSString *string = [[NSString alloc] initWithBytes:&symbol length:sizeof(symbol) encoding:NSUTF8StringEncoding];
    if (string == nil) { // 新版Emoji
        string = [NSString stringWithFormat:@"%C", (unichar)intCode];
    }
    return string;
}

- (NSString *)emoji
{
    return [NSString emojiWithStringCode:self];
}

+ (NSString *)emojiWithStringCode:(NSString *)stringCode
{
    char *charCode = (char *)stringCode.UTF8String;
    int intCode = strtol(charCode, NULL, 16);
    return [self emojiWithIntCode:intCode];
}

// 判断是否是 emoji表情
- (BOOL)isEmoji
{
    BOOL returnValue = NO;
    
    const unichar hs = [self characterAtIndex:0];
    // surrogate pair
    if (0xd800 <= hs && hs <= 0xdbff) {
        if (self.length > 1) {
            const unichar ls = [self characterAtIndex:1];
            const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
            if (0x1d000 <= uc && uc <= 0x1f77f) {
                returnValue = YES;
            }
        }
    } else if (self.length > 1) {
        const unichar ls = [self characterAtIndex:1];
        if (ls == 0x20e3) {
            returnValue = YES;
        }
    } else {
        // non surrogate
        if (0x2100 <= hs && hs <= 0x27ff) {
            returnValue = YES;
        } else if (0x2B05 <= hs && hs <= 0x2b07) {
            returnValue = YES;
        } else if (0x2934 <= hs && hs <= 0x2935) {
            returnValue = YES;
        } else if (0x3297 <= hs && hs <= 0x3299) {
            returnValue = YES;
        } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

@end
