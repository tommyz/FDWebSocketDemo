//
//  FDInputTextView.h
//  chatDemo
//
//  Created by xieyan on 2016/12/9.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDInputTextView : UITextView

/** textView最大行数 */
@property (nonatomic, assign) NSUInteger maxNumberOfLines;

/**
 *  文字高度改变block → 文字高度改变会自动调用
 *  block参数(textHeight) → 文字高度
 */
@property (nonatomic, strong) void(^fd_textHeightChangeBlock)(CGFloat textHeight);

@end
