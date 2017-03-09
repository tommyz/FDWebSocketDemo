//
//  FDChatMessageFrame.h
//  chatDemo
//
//  Created by xieyan on 2016/12/9.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FDChatMessage;
@interface FDChatMessageFrame : NSObject
/**
 *  正文的frame
 */
@property (nonatomic,assign,readonly)CGRect textF;

/**
 *  时间的frame
 */
@property (nonatomic,assign,readonly)CGRect timeF;

/**
 *  头像的frame
 */
@property (nonatomic,assign,readonly)CGRect iconF;

/**
 *  指示器的frame
 */
@property (nonatomic,assign,readonly)CGRect activityViewF;

/**
 *  红色感叹号的frame
 */
@property (nonatomic,assign,readonly)CGRect redButtonF;

/**
 *   cell高度
 */
@property (nonatomic,assign,readonly)CGFloat cellHeight;

/**
 *  根据数据模型设置frame
 */
@property (nonatomic, strong)FDChatMessage *message;
@end