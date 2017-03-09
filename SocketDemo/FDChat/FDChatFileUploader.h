//
//  FDChatFileUploader.h
//  SocketDemo
//
//  Created by xietao on 2017/3/9.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 支持上传的文件类型 (可增加) */
typedef NS_ENUM(NSUInteger, FDChatFileType) {
    FDChatFileTypeImage = 0,    // 图片(jpg)
    FDChatFileTypeVoice,        // 音频(mp3)
    FDChatFileTypeVideo         // 视频(mov)
};

@interface FDChatFileUploader : NSObject

@end
