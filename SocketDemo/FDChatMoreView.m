//
//  FDChatMoreView.m
//  chatDemo
//
//  Created by xieyan on 2016/12/12.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import "FDChatMoreView.h"

@implementation FDChatMoreView

+ (instancetype)moreView{
    return [[[NSBundle mainBundle] loadNibNamed:@"FDChatMoreView" owner:nil options:nil] lastObject];
}

- (IBAction)onCameraPress:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatMoreView:buttonDidSelect:)]) {
        [self.delegate chatMoreView:self buttonDidSelect:FDChatMoreViewTypeCamera];
    }
}


- (IBAction)onPhotoPress:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatMoreView:buttonDidSelect:)]) {
        [self.delegate chatMoreView:self buttonDidSelect:FDChatMoreViewTypePhoto];
    }
}

- (IBAction)onOrderPress:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatMoreView:buttonDidSelect:)]) {
        [self.delegate chatMoreView:self buttonDidSelect:FDChatMoreViewTypeOrder];
    }
}

@end
