//
//  FDChatMessageDataHandleCenter.m
//  SocketDemo
//
//  Created by xieyan on 2017/3/9.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "FDChatMessageDataHandleCenter.h"
#import "FMDB.h"
#import "FDChatMessage.h"
#import "FDWebSocket.h"
#import "FDChatFileUploader.h"
#import "FDChatMessageBuilder.h"

static FMDatabase *_db;

@implementation FDChatMessageDataHandleCenter

#pragma mark - public class Method
+ (instancetype)shareHandleCenter{
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

+ (NSArray *)getMessages{
    // 得到结果集
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_message;"];
    // 不断往下取数据
    NSMutableArray *messages = [NSMutableArray array];
    while (set.next) {
        // 获得当前所指向的数据
        FDChatMessage *message = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"message"]];
        [messages addObject:message];
    }
    return messages;
}

+ (void)addMessage:(FDChatMessage *)message{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    if ([self isExistMessage:message.uuid]) { //如果此条之前存在,则更新
        [_db executeUpdateWithFormat:@"UPDATE  t_message SET message = %@ where uuid = %@",data,message.uuid];
    }else{//如果此条之前不存在,则添加
        [_db executeUpdateWithFormat:@"INSERT INTO t_message(message, uuid) VALUES(%@, %@);", data,message.uuid];
    }
}

+ (BOOL)isExistMessage:(NSString *)uuid;
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT count(*) AS message_count FROM t_message WHERE uuid = %@;",uuid];
    [set next];
    return [set intForColumn:@"message_count"] == 1;
}

#pragma mark - public instance Method
- (void)openSocket {
    
    __weak typeof(self) weakself = self;

    [FDWebSocket openSocketSuccess:^{
        FDChatMessage *message = [FDChatMessageBuilder buildSystemMessage:@"系统提示：访客建立会话成功"];
        [weakself reloadUIAndUpdateMessageData:message];
    } failure:^{
        FDChatMessage *message = [FDChatMessageBuilder buildSystemMessage:@"系统提示：访客建立会话失败"];
        [weakself reloadUIAndUpdateMessageData:message];
    }];
    
    //收到消息
    [FDWebSocket setReceiveMessageBlock:^(FDChatMessage *message) {
        message.chatMessageBy = FDChatMessageByServicer;
        [weakself reloadUIAndUpdateMessageData:message];
    }];
    
    // 异常断开
    [FDWebSocket setExceptionDisconnectBlock:^(NSString *exceptionString){
        FDChatMessage *message = [FDChatMessageBuilder buildSystemMessage:[NSString stringWithFormat:@"系统消息：%@",exceptionString]];
        [weakself reloadUIAndUpdateMessageData:message];
    }];
}

- (void)closeSocket{
    [FDWebSocket finishChat];
}

- (void)sendMessage:(FDChatMessage *)message {
    
    __weak typeof(self) weakself = self;

    [weakself reloadUIAndUpdateMessageData:message];
    
     __block FDChatMessage* blockMessage = message;

    [FDWebSocket sendMessage:message Success:^{
        blockMessage.messageSendState = FDChatMessageSendStateSendSuccess;
        [weakself reloadUIAndUpdateMessageData:blockMessage];
    } failure:^{
        blockMessage.messageSendState = FDChatMessageSendStateSendFailure;
        [weakself reloadUIAndUpdateMessageData:blockMessage];
    }];
}

#pragma mark - private method
- (FDChatMessage *)judgeMessageHideTime:(FDChatMessage *)message{
    NSArray *originalMessages = [FDChatMessageDataHandleCenter getMessages];
    if (originalMessages.count > 0 && ![FDChatMessageDataHandleCenter isExistMessage:message.uuid]) {
        FDChatMessage *lastMessage = [originalMessages lastObject];
        
        // 日历对象（方便比较两个日期之间的差距）
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        // NSCalendarUnit枚举代表想获得哪些差值
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        
        // 计算两个日期之间的差值
        NSDateComponents *cmps = [calendar components:unit fromDate:lastMessage.messageDate toDate:message.messageDate options:0];
        message.hideTime = cmps.minute < 5 ? YES : NO;
    }
    return message;
}

- (void)uploadImage:(UIImage *)image {
    [FDChatFileUploader uploadImage:image progress:^(NSProgress * _Nonnull progress) {
        CGFloat complete = progress.completedUnitCount/progress.totalUnitCount;
        NSLog(@"----------%f",complete);
    } success:^(NSURLSessionDataTask *task, id responseData) {
        NSString *imageUrl = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        [self sendMessage:[FDChatMessageBuilder buildImageMessage:imageUrl]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"----------failure");
    }];
}


- (void)reloadUIAndUpdateMessageData:(FDChatMessage *)message{
    [FDChatMessageDataHandleCenter addMessage:[self judgeMessageHideTime:message]];
    if (self.reloadDataBlock) {
        self.reloadDataBlock();
    }
}

@end
