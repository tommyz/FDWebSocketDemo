//
//  FDChatConfig.h
//  SocketDemo
//
//  Created by xietao on 2017/3/9.
//  Copyright © 2017年 xietao3. All rights reserved.
//


@protocol ChatType <NSObject>
@end

#ifndef FDChatConfig_h
#define FDChatConfig_h
#define kWebSocket      [FDWebSocket shareInstance]

// dev url
//#define SocketUrl @"ws://121.40.165.18:8088"
// product url
#define SocketUrl       @"ws://kf-app.test.fruitday.com/chat"
// 消息来源平台
#define FDChatSource      @"IOS"
// 消息超时
static const NSTimeInterval FDMessageTimeOutInterval = 15.0;
// 图片压缩比例  0 ~ 1.0
static float const imageCompressionQuality = 0.5;
// 图片服务器URL
static NSString *const uploadFileUrl = @"http://file-kf-upload.fruitday.com/iUploadFile";

static NSString *const ExceptionDisconnectAlertString = @"异常断开";


#endif /* FDChatConfig_h */

