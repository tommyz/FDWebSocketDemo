//
//  UIImage+FDExtension.h
//  test
//
//  Created by xieyan on 2016/11/10.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FDExtension)
/**
 * 模糊图片 
 */
- (UIImage *)blurImage;
/**
 * 模糊图片
 * blur 模糊程度 范围0-1
 */
- (UIImage *)blurImageWithBlurExtent:(CGFloat)blur;
/**
 * 拉升图片
 * name 图片名字
 */
+ (UIImage *)resizeImageWithName:(NSString *)name;
/**
 * 拉升图片
 * size 图片大小
 */
-(UIImage*)scaleToSize:(CGSize)size;
@end
