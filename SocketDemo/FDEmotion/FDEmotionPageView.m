//
//  FDEmotionPageView.m
//  chatDemo
//
//  Created by xieyan on 2016/12/12.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import "FDEmotionPageView.h"
#import "UIView+FDExtension.h"
#import "NSString+Helper.h"
#import "FDEmotion.h"

@interface FDEmotionPageView ()
/** 删除按钮 */
@property (nonatomic, weak) UIButton *deleteButton;
@end


@implementation FDEmotionPageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 1.删除按钮
        UIButton *deleteButton = [[UIButton alloc] init];
        [deleteButton setImage:[UIImage imageNamed:@"trash-bin"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteEmotionClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        self.deleteButton = deleteButton;
    }
    return self;
}

- (void)deleteEmotionClick{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FDEmotionDidDeleteNotification" object:nil];
}

- (void)setEmotions:(NSArray *)emotions
{
    _emotions = emotions;
    
    NSUInteger count = emotions.count;
    for (int i = 0; i<count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = i;
        [self addSubview:btn];
        FDEmotion *emotion = self.emotions[i];
        // 设置表情数据
        [btn setTitle:emotion.code.emoji forState:UIControlStateNormal];
        
        // 监听按钮点击
        [btn addTarget:self action:@selector(emotionButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)emotionButtonDidClick:(UIButton *)btn{
    // 发出通知
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"FDEmotionKey"] = self.emotions[btn.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FDEmotionDidSelectNotification" object:nil userInfo:userInfo];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 内边距(四周)
    CGFloat inset = 20;
    NSUInteger count = self.emotions.count;
    CGFloat btnW = (self.width - 2 * inset) / HWEmotionMaxCols;
    CGFloat btnH = (self.height - inset) / HWEmotionMaxRows;
    for (int i = 0; i<count; i++) {
        UIButton *btn = self.subviews[i + 1];
        btn.width = btnW;
        btn.height = btnH;
        btn.x = inset + (i%HWEmotionMaxCols) * btnW;
        btn.y = inset + (i/HWEmotionMaxCols) * btnH;
    }
    
    // 删除按钮
    self.deleteButton.width = btnW;
    self.deleteButton.height = btnH;
    self.deleteButton.y = self.height - btnH;
    self.deleteButton.x = self.width - inset - btnW;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"FDEmotionDidSelectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"FDEmotionDidDeleteNotification" object:nil];
}
@end
