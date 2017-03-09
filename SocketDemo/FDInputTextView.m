//
//  FDInputTextView.m
//  chatDemo
//
//  Created by xieyan on 2016/12/9.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import "FDInputTextView.h"

@interface FDInputTextView()
/** 文字高度 */
@property (nonatomic, assign) NSInteger textH;
/** 文字最大高度 */
@property (nonatomic, assign) NSInteger maxTextH;
@end

@implementation FDInputTextView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    self.layer.borderWidth = 1.0;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0;
    self.layer.borderColor = [[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0] CGColor];
    self.showsVerticalScrollIndicator = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
}

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    
    // 计算最大高度 = (每行高度 * 总行数 + 文字上下间距)
    _maxTextH = ceil(self.font.lineHeight * maxNumberOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
    
}

- (void)textDidChange
{
    NSInteger height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
    if (_textH != height) { // 高度不一样，就改变了高度
        // 最大高度，可以滚动
        self.scrollEnabled = height > _maxTextH && _maxTextH > 0;
        _textH = height;
        if (self.fd_textHeightChangeBlock && self.scrollEnabled == NO) {
            self.fd_textHeightChangeBlock(height);
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}
@end
