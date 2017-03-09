//
//  FDChatMessageCell.h
//  chatDemo
//
//  Created by xieyan on 2016/12/9.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FDChatMessageFrame,FDChatMessage;
@interface FDChatMessageCell : UITableViewCell

@property(nonatomic, strong) FDChatMessageFrame *messageFrame;
@property (copy ,nonatomic) void (^sendFailMessageBlock)(FDChatMessage *);

@end
