//
//  FDChatFileUploader.h
//  SocketDemo
//
//  Created by xietao on 2017/3/9.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

/* 支持上传的文件类型 (可增加) */
typedef NS_ENUM(NSUInteger, FDChatFileType) {
    FDChatFileTypeImage = 0,    // 图片(jpg)
    FDChatFileTypeVoice,        // 音频(mp3)
    FDChatFileTypeVideo         // 视频(mov)
};

NS_ASSUME_NONNULL_BEGIN
@interface FDChatFileUploader : NSObject

+ (void)uploadImage:(UIImage *)image
           progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


+ (void)uploadFileData:(NSData *)fileData
                  name:(NSString *)name
              fileName:(NSString *)fileName
              fileType:(FDChatFileType)fileType
              progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
NS_ASSUME_NONNULL_END
