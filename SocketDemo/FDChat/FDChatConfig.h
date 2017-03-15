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

//通知
static NSString *const FDEmotionDidDeleteNotification = @"FDEmotionDidDeleteNotification";
static NSString *const FDEmotionDidSelectNotification = @"FDEmotionDidSelectNotification";
static NSString *const FDEmotionKey = @"FDEmotionKey";


// 图片链接前缀
static NSString *const imageUrlPrefix = @"https://file-kf-download.fruitday.com/";


#pragma mark - 提示文案
static NSString *const FDChatSystemAlertTitle = @"系统提示：";

static NSString *const FDChatSystemConnectFailureAlertString = @"访客建立会话失败，请检查当前网络状况";

static NSString *const ExceptionDisconnectAlertString = @"异常断开,请检查当前网络状况";

static NSInteger const FDSocketSuccessCode = 200;
#endif /* FDChatConfig_h */

