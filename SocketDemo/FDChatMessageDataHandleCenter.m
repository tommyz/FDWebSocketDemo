//
//  FDChatMessageDataHandleCenter.m
//  SocketDemo
//
//  Created by xieyan on 2017/3/9.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "FDChatMessageDataHandleCenter.h"
#import "FMDB.h"
#import "FDChatMessageFrame.h"
#import "FDChatMessage.h"
#import "FDWebSocket.h"
#import "FDChatFileUploader.h"

static FMDatabase *_db;

@implementation FDChatMessageDataHandleCenter

+ (instancetype)shareInstance{
    static FDChatMessageDataHandleCenter *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[FDChatMessageDataHandleCenter alloc] init];
    });
    return shareInstance;
}


+ (void)initialize{
    // 1.打开数据库
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"chatMessages.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    // 2.创表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_message(id integer PRIMARY KEY, uuid text NOT NULL, message blob NOT NULL);"];
}

+ (NSArray *)getMessageFrames{
    // 得到结果集
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_message;"];
    // 不断往下取数据
    NSMutableArray *chatMessageFrames = [NSMutableArray array];
    while (set.next) {
        // 获得当前所指向的数据
        FDChatMessageFrame *chatMessageFrame = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"message"]];
        [chatMessageFrames addObject:chatMessageFrame];
    }
    return chatMessageFrames;
}

+ (void)addMessageFrame:(FDChatMessageFrame *)messageFrame{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageFrame];
    if ([self isExistMessage:messageFrame.message.uuid]) { //如果此条之前存在,则更新
        [_db executeUpdateWithFormat:@"UPDATE  t_message SET message = %@ where uuid = %@",data,messageFrame.message.uuid];
    }else{//如果此条之前存在,则添加
        [_db executeUpdateWithFormat:@"INSERT INTO t_message(message, uuid) VALUES(%@, %@);", data,messageFrame.message.uuid];
    }
}

- (void)openSocket {
    [FDWebSocket openSocketSuccess:^{
        NSLog(@"连接成功");
        
    } failure:^{
        NSLog(@"连接失败");
    }];
    __weak typeof(self) weakself = self;
    
    //收到消息
    [FDWebSocket setReceiveMessageBlock:^(FDChatMessage *message) {
        message.chatMessageBy = FDChatMessageByServicer;
        [FDChatMessageDataHandleCenter addMessageFrame:[self convertMessage:message]];
        if (weakself.reloadDataBlock) {
            weakself.reloadDataBlock();
        }
    }];
    
    // 异常断开
    [FDWebSocket setExceptionDisconnectBlock:^(NSString *exceptionString){
        NSLog(@"%@",exceptionString);
    }];

}

- (void)closeSocket{
    [FDWebSocket finishChat];
}

- (void)sendMessage:(FDChatMessage *)message {
    __block FDChatMessage* blockMessage = message;
    //1.把消息发送给服务器
    [FDWebSocket sendMessage:message Success:^{
        blockMessage.messageSendState = FDChatMessageSendStateSendSuccess;
        [FDChatMessageDataHandleCenter addMessageFrame:[self convertMessage:blockMessage]];
        // 发送成功 加进数组
        if (self.reloadDataBlock) {
            self.reloadDataBlock();
        }
        
    } failure:^{
        blockMessage.messageSendState = FDChatMessageSendStateSendFailure;
        [FDChatMessageDataHandleCenter addMessageFrame:[self convertMessage:blockMessage]];
        
        if (self.reloadDataBlock) {
            self.reloadDataBlock();
        }
    }];
}

- (FDChatMessageFrame *)convertMessage:(FDChatMessage *)message{
    NSArray *originalMessageFrames = [FDChatMessageDataHandleCenter getMessageFrames];
    if (originalMessageFrames.count > 0 && ![FDChatMessageDataHandleCenter isExistMessage:message.uuid]) {
        FDChatMessageFrame *lastFm = [originalMessageFrames lastObject];
        
        // 日历对象（方便比较两个日期之间的差距）
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        // NSCalendarUnit枚举代表想获得哪些差值
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        
        // 计算两个日期之间的差值
        NSDateComponents *cmps = [calendar components:unit fromDate:lastFm.message.messageDate toDate:message.messageDate options:0];
        message.hideTime = cmps.minute < 30 ? YES : NO;
    }
    
    FDChatMessageFrame *fm = [[FDChatMessageFrame alloc]init];
    fm.message = message;
    return fm;
}

- (void)uploadImage:(UIImage *)image {
    __block FDChatMessage *imageMessage = [FDChatMessageBuilder buildImageMessage:@""];
    [FDChatFileUploader uploadImage:image progress:^(NSProgress * _Nonnull progress) {
        CGFloat complete = progress.completedUnitCount/progress.totalUnitCount;
        NSLog(@"----------%f",complete);
    } success:^(NSURLSessionDataTask *task, id responseData) {
        NSString *imageUrl = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"----------finish:%@",[NSString stringWithFormat:@"https://file-kf-download.fruitday.com/%@",imageUrl]);
        imageMessage.msg = [NSString stringWithFormat:@"https://file-kf-download.fruitday.com/%@",imageUrl];
        [self sendMessage:imageMessage];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"----------failure");
    }];
}

+ (BOOL)isExistMessage:(NSString *)uuid;
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT count(*) AS message_count FROM t_message WHERE uuid = %@;",uuid];
    [set next];
    return [set intForColumn:@"message_count"] == 1;
}

@end
