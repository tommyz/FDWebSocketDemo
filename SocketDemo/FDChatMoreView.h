//
//  FDChatMoreView.h
//  chatDemo
//
//  Created by xieyan on 2016/12/12.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FDChatMoreView;

typedef NS_ENUM(NSInteger,FDChatMoreViewType) {
    FDChatMoreViewTypePhoto = 0,  //拍照
    FDChatMoreViewTypeCamera,     //图片
    FDChatMoreViewTypeOrder       //我的订单号
};

@protocol FDChatMoreViewDelegate <NSObject>
- (void)chatMoreView:(FDChatMoreView *)moreView buttonDidSelect:(FDChatMoreViewType)type;
@end

@interface FDChatMoreView : UIView
@property (nonatomic, weak) id <FDChatMoreViewDelegate>delegate;
+ (instancetype)moreView;
@end
