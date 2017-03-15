//
//  FDChatMessageCell.m
//  chatDemo
//
//  Created by xieyan on 2016/12/9.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import "FDChatMessageCell.h"
#import "FDChatMessage.h"
#import "FDChatMessageFrame.h"
#import "NSString+Helper.h"
#import "UIView+FDExtension.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "FDChatMessageDataHandleCenter.h"
#import "UIImage+FDExtension.h"

@interface FDChatMessageCell ()
/**
 *  时间
 */
@property (nonatomic, weak)UILabel *timeLbl;

/**
 *  头像
 */
@property (nonatomic, weak)UIImageView *iconImg;

/**
 *  正文
 */
@property (nonatomic, weak)UIButton *textBtn;

/**
 *  指示器(发送中)
 */
@property (nonatomic, weak) UIActivityIndicatorView *activityView;

/**
 *  红色感叹号按钮(发送失败)
 */
@property (nonatomic, weak) UIButton *redButton;


/**
 *  系统提示
 */
@property (nonatomic, weak) UILabel *systemCueLabel;

/**
 *  图片
 */
@property (nonatomic, weak) UIButton *imgView;


@end

@implementation FDChatMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //1.时间
        UILabel *timeLbl = [[UILabel alloc]init];
        timeLbl.textAlignment = NSTextAlignmentCenter;
        timeLbl.font = [UIFont systemFontOfSize:12.0f];
        timeLbl.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1.0];
        [self.contentView addSubview:timeLbl];
        self.timeLbl = timeLbl;
        
        //2.头像
        UIImageView *iconImg = [[UIImageView alloc]init];
        iconImg.layer.cornerRadius = 20.f;
        iconImg.layer.masksToBounds = YES;
        [self.contentView addSubview:iconImg];
        self.iconImg = iconImg;
        
        //3.正文
        UIButton *btn = [[UIButton alloc]init];
        btn.userInteractionEnabled = NO;
        btn.adjustsImageWhenHighlighted = NO; //取消高亮图片变化效果
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.numberOfLines = 0;//自动换行
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:btn];
        self.textBtn = btn;
        
        //4.指示器
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:activityView];
        self.activityView = activityView;
        
        //5.红色感叹号按钮
        UIButton *redButton = [[UIButton alloc]init];
        [redButton setImage:[UIImage imageNamed:@"message_send_fail"] forState:UIControlStateNormal];
        [redButton addTarget:self action:@selector(sendFailMessage) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:redButton];
        self.redButton = redButton;
    
        //6.系统消息提示
        UILabel *systemCueLabel = [[UILabel alloc]init];
        systemCueLabel.textColor = [UIColor whiteColor];
        systemCueLabel.textAlignment = NSTextAlignmentCenter;
        systemCueLabel.font = [UIFont systemFontOfSize:14.0];
        systemCueLabel.backgroundColor = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0];
        systemCueLabel.layer.cornerRadius = 5.0f;
        systemCueLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:systemCueLabel];
        self.systemCueLabel = systemCueLabel;
        
        //7.图片
        UIButton *imgView = [[UIButton alloc]init];
        [imgView addTarget:self action:@selector(showBigImage) forControlEvents:UIControlEventTouchUpInside];
        imgView.adjustsImageWhenHighlighted = NO; //取消高亮图片变化效果
        [self.contentView addSubview:imgView];
        self.imgView = imgView;
    }
    return self;
}

- (void)setMessageFrame:(FDChatMessageFrame *)messageFrame
{
    _messageFrame = messageFrame;
    
    //数据模型
    FDChatMessage *message = messageFrame.message;
    
    //时间
    if (message.hideTime) {
        self.timeLbl.hidden = YES;
    }else{
        self.timeLbl.frame = messageFrame.timeF;
        self.timeLbl.text = [NSString stringFromDate:message.messageDate].formatTime;
        self.timeLbl.hidden = NO;
    }
    
    if (message.chatMessageBy == FDChatMessageByCustomer) {//客户发的消息
        
        [self showCustomerMessage:messageFrame];
        
    }else if (message.chatMessageBy == FDChatMessageByServicer){//客服发的消息
        
        [self showServicerMessage:messageFrame];
        
    }else{//系统消息
        
        [self showSystemMessage:messageFrame];
        
    }
}

- (void)showCustomerMessage:(FDChatMessageFrame *)messageFrame{
    //数据模型
    FDChatMessage *message = messageFrame.message;

    //头像
    self.iconImg.frame = messageFrame.iconF;
    self.iconImg.image = [UIImage imageNamed:@"Gatsby"];
    self.iconImg.hidden = NO;
    
    //指示器和红色感叹号按钮
    self.activityView.frame = messageFrame.activityViewF;
    self.redButton.frame = messageFrame.redButtonF;
    
    if (message.messageSendState == FDChatMessageSendStateSending) {
        [self.activityView startAnimating];
        self.redButton.hidden = YES;
    }else if (message.messageSendState == FDChatMessageSendStateSendSuccess) {
        [self.activityView stopAnimating];
        self.redButton.hidden = YES;
    }else {
        [self.activityView stopAnimating];
        self.redButton.hidden = NO;
    }
    
    if ([message.msgType isEqualToString:FDChatMsgTypeText] || [message.msgType isEqualToString:FDChatMsgTypeOrder]) {
        self.imgView.hidden = YES;
        //正文
        self.textBtn.frame = messageFrame.textF;
        self.textBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 10);
        [self.textBtn setBackgroundImage:[UIImage imageNamed:@"chat_left_bg"] forState:UIControlStateNormal];
        NSString *text = [message.msgType isEqualToString:FDChatMsgTypeOrder] ? [NSString stringWithFormat:@"订单号：%@",message.msg] : message.msg;
        [self.textBtn setTitle:text forState:UIControlStateNormal];
        self.textBtn.hidden = NO;
    }else if ([message.msgType isEqualToString:FDChatMsgTypeImg]){
        self.textBtn.hidden = YES;
        //图片
        self.imgView.frame = messageFrame.imgViewF;
        self.imgView.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 18);
        [self.imgView setBackgroundImage:[UIImage imageNamed:@"chat_left_bg"] forState:UIControlStateNormal];
        self.imgView.hidden = NO;
#warning placeholderImage后面补上
        UIImage *image = [FDChatMessageDataHandleCenter getImageFromSandBox:message.uuid];
        if (image) {
            [self.imgView setImage:[image scaleToSize:messageFrame.imgViewF.size] forState:UIControlStateNormal];
        }else{
            NSString *urlStr = [message.msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//过滤字符串中的特殊符号
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:urlStr] forState:UIControlStateNormal placeholderImage:nil];
        }
    }else if ([message.msgType isEqualToString:FDChatMsgTypeOrder]){
        
    }
    self.systemCueLabel.hidden = YES;
}

- (void)showServicerMessage:(FDChatMessageFrame *)messageFrame{
    //数据模型
    FDChatMessage *message = messageFrame.message;

    //头像
    self.iconImg.frame = messageFrame.iconF;
    self.iconImg.image = [UIImage imageNamed:@"Jobs"];
    self.iconImg.hidden = NO;
    
    if ([message.msgType isEqualToString:FDChatMsgTypeText]) {
        self.imgView.hidden = YES;
        //正文
        self.textBtn.frame = messageFrame.textF;
        self.textBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.textBtn setBackgroundImage:[UIImage imageNamed:@"chat_right_bg"] forState:UIControlStateNormal];
        [self.textBtn setTitle:message.msg forState:UIControlStateNormal];
        self.textBtn.hidden = NO;
    }else if ([message.msgType isEqualToString:FDChatMsgTypeImg]){
        self.textBtn.hidden = YES;
        //图片
        self.imgView.frame = messageFrame.imgViewF;
        self.imgView.contentEdgeInsets = UIEdgeInsetsMake(10, 17, 10, 10);
        [self.imgView setBackgroundImage:[UIImage imageNamed:@"chat_left_bg"] forState:UIControlStateNormal];
        NSString *urlStr = [message.msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//过滤字符串中的特殊符号
#warning placeholderImage后面补上
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:urlStr] forState:UIControlStateNormal placeholderImage:nil];
        self.imgView.hidden = NO;
    }
    
    [self.activityView stopAnimating];
    self.redButton.hidden = YES;
    self.systemCueLabel.hidden = YES;
}

- (void)showSystemMessage:(FDChatMessageFrame *)messageFrame{
    self.systemCueLabel.text = messageFrame.message.msg;
    self.systemCueLabel.frame = messageFrame.systemCueLabelF;
    self.systemCueLabel.hidden = NO;
    self.textBtn.hidden = YES;
    self.activityView.hidden = YES;
    self.redButton.hidden = YES;
    self.iconImg.hidden = YES;
    self.imgView.hidden = YES;
}

- (void)sendFailMessage{
    if (self.sendFailMessageBlock) {
        self.sendFailMessageBlock(self.messageFrame.message);
    }
}

- (void)showBigImage{
    NSLog(@"放大图片");
}

@end
