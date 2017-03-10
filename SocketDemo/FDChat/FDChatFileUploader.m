//
//  FDChatFileUploader.m
//  SocketDemo
//
//  Created by xietao on 2017/3/9.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "FDChatFileUploader.h"
#import "FDChatConfig.h"

@implementation FDChatFileUploader


+ (void)uploadImage:(UIImage *)image
           progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    [self uploadFileData:UIImageJPEGRepresentation(image,imageCompressionQuality)
                    name:@"image"
                fileName:@"imageName"
                fileType:FDChatFileTypeImage
                progress:uploadProgress
                 success:success failure:failure];
}

+ (void)uploadFileData:(NSData *)fileData
                  name:(NSString *)name
              fileName:(NSString *)fileName
              fileType:(FDChatFileType)fileType
              progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", nil];
    // 检测网络
    if (![self beforeRequest:manager]) {
        if (failure) {
            failure(nil,nil);
        }
    }
    
    // 参数
//    NSMutableDictionary *completeParams = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [manager POST:uploadFileUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (fileType == FDChatFileTypeImage) {
            // jpg图片格式
            [formData appendPartWithFileData:fileData name:name  fileName:fileName mimeType:@"image/jpeg"];
        }else if (fileType == FDChatFileTypeVoice) {
            // mp3音频格式
            [formData appendPartWithFileData:fileData name:name  fileName:fileName mimeType:@"audio/mpeg"];
        }else if (fileType == FDChatFileTypeVideo) {
            // mov视频格式
            [formData appendPartWithFileData:fileData name:name  fileName:fileName mimeType:@"video/quicktime"];
        }
        
    } progress:^(NSProgress * _Nonnull progress) {
        if (uploadProgress) {
            uploadProgress(progress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task,error);
        }
    }];
}


/**
 *  请求前检查网络情况
 *
 *  @param manager AFHTTPRequestOperationManager
 *
 *  @return 网络正常则返回YES，否则返回NO
 */
+ (BOOL)beforeRequest:(AFHTTPSessionManager *)manager {
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                break;
        }
    }];
    [manager.reachabilityManager startMonitoring];
    return true;
}

@end
