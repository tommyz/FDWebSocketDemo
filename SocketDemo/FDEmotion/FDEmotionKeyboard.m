//
//  FDEmotionKeyboard.m
//  chatDemo
//
//  Created by xieyan on 2016/12/12.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import "FDEmotionKeyboard.h"
#import "FDEmotionListView.h"
#import "FDEmotion.h"
#import "UIView+FDExtension.h"

@interface FDEmotionKeyboard ()
/** 默认表情内容 */
@property (nonatomic, strong) FDEmotionListView *defaultListView;
/** 默认表情按钮 */
@property (nonatomic, strong) UIButton *defaultButton;
@end
@implementation FDEmotionKeyboard

#pragma mark - 懒加载

- (FDEmotionListView *)defaultListView
{
    if (!_defaultListView) {
        _defaultListView = [[FDEmotionListView alloc]init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/emoji/info.plist" ofType:nil];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *emotions = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            FDEmotion *emotion = [FDEmotion emotionWithDict:dict];
            [emotions addObject:emotion];
        }
        _defaultListView.emotions = emotions;
        [self addSubview:_defaultListView];
    }
    return _defaultListView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        //1.默认表情按钮
        UIButton *defaultButton = [[UIButton alloc]init];
        [defaultButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        defaultButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [defaultButton setTitle:@"默认表情" forState:UIControlStateNormal];
        [defaultButton setBackgroundColor:[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]];
        [self addSubview:defaultButton];
        self.defaultButton = defaultButton;
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 1.默认表情按钮
    self.defaultButton.width = self.width;
    self.defaultButton.height = 37;
    self.defaultButton.x = 0;
    self.defaultButton.y = self.height - self.defaultButton.height;
    
    // 2.默认表情内容
    self.defaultListView.x = self.defaultListView.y = 0;
    self.defaultListView.width = self.width;
    self.defaultListView.height = self.defaultButton.y;
}
@end
