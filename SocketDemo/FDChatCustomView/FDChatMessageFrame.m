//
//  FDChatMessageFrame.m
//  chatDemo
//
//  Created by xieyan on 2016/12/9.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import "FDChatMessageFrame.h"
#import "FDChatMessage.h"

#define FDTextPadding 20
@implementation FDChatMessageFrame

- (void)setMessage:(FDChatMessage *)message
{
    _message = message;
    
    //设备屏幕的宽
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    //边距
    CGFloat padding = 10;
    //时间
    if (message.hideTime == NO) {
        CGFloat timeX = 0;
        CGFloat timeY = padding/2;
        CGFloat timeW = screenW;
        CGFloat timeH = 20;
        _timeF = CGRectMake(timeX, timeY, timeW, timeH);
    }else{
        _timeF = CGRectZero;
    }
    
    if (message.chatMessageBy == FDChatMessageBySystem) {
        CGSize msgSize = [message.msg boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
        //系统提示
        CGFloat systemCueLabelW = msgSize.width + 10;
        CGFloat systemCueLabelH = 20;
        CGFloat systemCueLabelX = (screenW - systemCueLabelW)/2;
        CGFloat systemCueLabelY = message.hideTime ? padding/2 : CGRectGetMaxY(_timeF) + padding/2;
        _systemCueLabelF = CGRectMake(systemCueLabelX, systemCueLabelY, systemCueLabelW, systemCueLabelH);
        _cellHeight = CGRectGetMaxY(_systemCueLabelF) +  padding;
    }else{
        //头像
        CGFloat iconX;
        CGFloat iconY = CGRectGetMaxY(_timeF) + padding;
        CGFloat iconW = 40;
        CGFloat iconH = 40;
        if (message.chatMessageBy == FDChatMessageByCustomer) {//客户发的  头像在右边
            iconX = screenW - iconW - padding;
        }else{//客服发的  头像在左边
            iconX = padding;
        }
        
        _iconF = CGRectMake(iconX, iconY, iconW, iconH);
        
        if ([message.msgType isEqualToString:FDChatMsgTypeText]) {
            //正文
            CGSize textSize = [message.msg boundingRectWithSize:CGSizeMake(screenW - 2 * iconW - 4 * padding, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
            
            //最终正文的size
            CGSize lastBtnSize = CGSizeMake(textSize.width + FDTextPadding , textSize.height + FDTextPadding );
            
            CGFloat textX ;
            CGFloat textY = iconY;
            
            if (message.chatMessageBy == FDChatMessageByCustomer) {
                textX = iconX - padding/2 - lastBtnSize.width;
            }else{
                textX = CGRectGetMaxX(_iconF) + padding/2;
            }
            
            _textF = (CGRect){{textX,textY},lastBtnSize};
            
            //指示器
            _activityViewF = CGRectMake(textX - 1.3 * FDTextPadding, textY + lastBtnSize.height/2 - FDTextPadding/2, FDTextPadding, FDTextPadding);
            
            //红色感叹号
            _redButtonF = CGRectMake(textX - 1.6 * FDTextPadding, textY + lastBtnSize.height/2 - FDTextPadding * 0.75, 1.5 * FDTextPadding, 1.5 * FDTextPadding);
            
            //cell的高度
            CGFloat iconMaxY = CGRectGetMaxY(_iconF);
            CGFloat textMaxY = CGRectGetMaxY(_textF);
            _cellHeight = MAX(iconMaxY, textMaxY) +  padding;

        }else if ([message.msgType isEqualToString:FDChatMsgTypeImg]){
            // 图片
            CGFloat imgViewX ;
            CGFloat imgViewY = iconY;
            CGFloat imgViewH = 120;
            CGFloat imgViewW = imgViewH + 10;
            
            if (message.chatMessageBy == FDChatMessageByCustomer) {
                imgViewX = iconX - padding/2 - imgViewW;
            }else{
                imgViewX = CGRectGetMaxX(_iconF) + padding/2;
            }
        
            _imgViewF = CGRectMake(imgViewX, imgViewY, imgViewW, imgViewH);
            
            //指示器
            _activityViewF = CGRectMake(imgViewX - 1.3 * FDTextPadding, imgViewY + imgViewH/2 - FDTextPadding/2, FDTextPadding, FDTextPadding);
            
            //红色感叹号
            _redButtonF = CGRectMake(imgViewX - 1.6 * FDTextPadding, imgViewY + imgViewH/2 - FDTextPadding * 0.75, 1.5 * FDTextPadding, 1.5 * FDTextPadding);
            
            //cell的高度
            _cellHeight = CGRectGetMaxY(_imgViewF) +  padding;

        }
    }
}
@end
