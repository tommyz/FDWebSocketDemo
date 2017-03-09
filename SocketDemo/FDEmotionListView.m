//
//  FDEmotionListView.m
//  chatDemo
//
//  Created by xieyan on 2016/12/12.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import "FDEmotionListView.h"
#import "FDEmotion.h"
#import "UIView+FDExtension.h"
#import "FDEmotionPageView.h"

@interface FDEmotionListView ()<UIScrollViewDelegate>

/** 表情内容 */
@property (nonatomic, weak) UIScrollView *scrollView;
/** 分页指示器 */
@property (nonatomic, weak) UIPageControl *pageControl;

@end
@implementation FDEmotionListView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];

        //1.表情内容
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        // 去除水平方向的滚动条
        scrollView.showsHorizontalScrollIndicator = NO;
        // 去除垂直方向的滚动条
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        //2.分页指示器
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        // 当只有1页时，自动隐藏pageControl
        pageControl.hidesForSinglePage = YES;
        pageControl.userInteractionEnabled = NO;
        // 设置颜色
        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0];
        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:254/255.0 green:206/255.0 blue:161/255.0 alpha:1.0];
        [self addSubview:pageControl];
        self.pageControl = pageControl;
    }
    return self;
}

// 根据emotions，创建对应个数的表情
- (void)setEmotions:(NSArray *)emotions
{
    _emotions = emotions;
    
    // 删除之前的控件
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger count = (emotions.count + HWEmotionPageSize - 1) / HWEmotionPageSize;
    
    // 1.设置页数
    self.pageControl.numberOfPages = count;

    // 2.创建用来显示每一页表情的控件
    for (int i = 0; i<count; i++) {
        FDEmotionPageView *pageView = [[FDEmotionPageView alloc] init];
        // 计算这一页的表情范围
        NSRange range;
        range.location = i * HWEmotionPageSize;
        // left：剩余的表情个数（可以截取的）
        NSUInteger left = emotions.count - range.location;
        if (left >= HWEmotionPageSize) { // 这一页足够20个
            range.length = HWEmotionPageSize;
        } else {
            range.length = left;
        }
        // 设置这一页的表情
        pageView.emotions = [emotions subarrayWithRange:range];
        [self.scrollView addSubview:pageView];
    }
    
    [self setNeedsLayout];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.分页指示器
    self.pageControl.width = self.width;
    self.pageControl.height = 25;
    self.pageControl.x = 0;
    self.pageControl.y = self.height - self.pageControl.height;
    
    // 2.表情内容
    self.scrollView.width = self.width;
    self.scrollView.height = self.pageControl.y;
    self.scrollView.x = self.scrollView.y = 0;
    
    // 3.设置scrollView内部每一页的尺寸
    NSUInteger count = self.scrollView.subviews.count;
    for (int i = 0; i<count; i++) {
        FDEmotionPageView *pageView = self.scrollView.subviews[i];
        pageView.height = self.scrollView.height;
        pageView.width = self.scrollView.width;
        pageView.x = pageView.width * i;
        pageView.y = 0;
    }
    
    // 4.设置scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(count * self.scrollView.width, 0);
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    double pageNo = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = (int)(pageNo + 0.5);
}

@end
