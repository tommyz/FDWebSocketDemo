//
//  FDEmotionPageView.h
//  chatDemo
//
//  Created by xieyan on 2016/12/12.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDEmotionPageView : UIView

// 一页中最多3行
#define HWEmotionMaxRows 3
// 一行中最多7列
#define HWEmotionMaxCols 7
// 每一页的表情个数
#define HWEmotionPageSize ((HWEmotionMaxRows * HWEmotionMaxCols) - 1)

/** 这一页显示的表情 */
@property (nonatomic, strong) NSArray *emotions;

@end
