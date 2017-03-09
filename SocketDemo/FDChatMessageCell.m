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


@end
@implementation FDChatMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setMessageFrame:(FDChatMessageFrame *)messageFrame
{
    _messageFrame = messageFrame;
    
    //数据模型
    FDChatMessage *message = messageFrame.message;
    
    //1.时间
    self.timeLbl.text = message.time;
    self.timeLbl.frame = messageFrame.timeF;
    
    //2.头像
    if (message.chatMessageBy == FDChatMessageByCustomer) {
        self.iconImg.image = [UIImage imageNamed:@"Gatsby"];
        self.textBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 10);
    }else{
        self.iconImg.image = [UIImage imageNamed:@"Jobs"];
        self.textBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    self.iconImg.frame = messageFrame.iconF;
    
    //3.正文
    [self.textBtn setTitle:message.msg forState:UIControlStateNormal];
    self.textBtn.frame = messageFrame.textF;

    //4.指示器和红色感叹号按钮
    self.activityView.frame = messageFrame.activityViewF;
    self.redButton.frame = messageFrame.redButtonF;
    if (message.chatMessageBy == FDChatMessageByCustomer) {
        [self.textBtn setBackgroundImage:[UIImage imageNamed:@"chat_left_bg"] forState:UIControlStateNormal];
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
    }else{
        [self.textBtn setBackgroundImage:[UIImage imageNamed:@"chat_right_bg"] forState:UIControlStateNormal];
        [self.activityView stopAnimating];
        self.redButton.hidden = YES;
    }
}

- (void)sendFailMessage{
    if (self.sendFailMessageBlock) {
        self.sendFailMessageBlock(self.messageFrame.message);
    }
}

@end
