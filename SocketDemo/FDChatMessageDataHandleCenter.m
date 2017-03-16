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
#import "FDSocketMonitor.h"

static FMDatabase *_db;
#define FDImagePath(imageName) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imageName]]

@interface FDChatMessageDataHandleCenter ()
// 连接监视器
@property (nonatomic, strong) FDSocketMonitor *socketMonitor;

@end

@implementation FDChatMessageDataHandleCenter

#pragma mark - public class Method
+ (instancetype)shareHandleCenter{
    static FDChatMessageDataHandleCenter *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[FDChatMessageDataHandleCenter alloc] init];
        shareInstance.isFinishChat = NO;
        shareInstance.socketMonitor = [[FDSocketMonitor alloc] init];
       
        [shareInstance.socketMonitor setReconnectBlock:^{
            if (!shareInstance.isFinishChat && ![FDWebSocket socketIsConnected]) {
                [shareInstance openSocket:nil];
            }
        }];
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

+ (NSArray *)getMessages:(int)page{
    int size = 10;
    int pos = (page - 1) * size;
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM (SELECT * FROM t_message ORDER BY id DESC LIMIT %d,%d) ORDER BY id ;", pos, size];
    NSMutableArray *messages = [NSMutableArray array];
    while (set.next) {
        FDChatMessage *message = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"message"]];
        [messages addObject:message];
    }
    return messages;
}

+ (BOOL)addMessage:(FDChatMessage *)message{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    if ([self isExistMessage:message.uuid]) { //如果此条之前存在,则更新
        [_db executeUpdateWithFormat:@"UPDATE  t_message SET message = %@ where uuid = %@",data,message.uuid];
        return NO;
    }else{//如果此条之前不存在,则添加
        [_db executeUpdateWithFormat:@"INSERT INTO t_message(message, uuid) VALUES(%@, %@);", data,message.uuid];
        return YES;
    }
}

+ (BOOL)isExistMessage:(NSString *)uuid;
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT count(*) AS message_count FROM t_message WHERE uuid = %@;",uuid];
    [set next];
    return [set intForColumn:@"message_count"] == 1;
}

+ (void)saveImageToSandBox:(UIImage *)image imageName:(NSString *)imageName{//用uuid存
    NSData *imageData = UIImageJPEGRepresentation(image,imageCompressionQuality);
    [imageData writeToFile:FDImagePath(imageName) atomically:YES];
}

+ (UIImage *)getImageFromSandBox:(NSString *)imageName{//用uuid取
    return [UIImage imageWithContentsOfFile:FDImagePath(imageName)];
}

#pragma mark - public instance Method
- (void)openSocket:(void(^)())complete {
    
    __weak typeof(self) weakself = self;
    self.isFinishChat = NO;
    [FDWebSocket openSocketSuccess:^{
        [weakself getOfflineMessages];
        if (complete) {
            complete();
        }
    } failure:^{
        FDChatMessage *message = [FDChatMessageBuilder buildSystemMessage:[NSString stringWithFormat:@"%@%@",FDChatSystemAlertTitle,FDChatSystemConnectFailureAlertString]];
        [weakself reloadUIAndUpdateMessageData:message];
        if (complete) {
            complete();
        }
    }];
    
    //收到消息
    [FDWebSocket setReceiveMessageBlock:^(FDChatMessage *message) {
        if ([message.chatType isEqualToString:FDChatType_CHATTING_SERVICE]) {
            message.chatMessageBy = FDChatMessageByServicer;
        }else if([message.chatType isEqualToString:FDChatType_INVESTIGATION_SERVICE]){
            message.chatMessageBy = FDChatMessageBySystem;
        }else{
            message.chatMessageBy = FDChatMessageBySystem;
        }
        [weakself reloadUIAndUpdateMessageData:message];
    }];
    
    // 异常断开
    [FDWebSocket setExceptionDisconnectBlock:^(NSString *exceptionString){
        FDChatMessage *message = [FDChatMessageBuilder buildSystemMessage:[NSString stringWithFormat:@"%@%@",FDChatSystemAlertTitle,exceptionString]];
        [weakself reloadUIAndUpdateMessageData:message];
    }];
}

- (void)closeSocket{
    [FDWebSocket finishChat];
}

- (void)sendMessage:(FDChatMessage *)message {
    __weak typeof(self) weakself = self;
    
    [self reloadUIAndUpdateMessageData:message];
    
    __block FDChatMessage* blockMessage = message;
    
    [FDWebSocket sendMessage:message Success:^(FDChatMessage *msg){
        blockMessage.messageSendState = FDChatMessageSendStateSendSuccess;
        [weakself reloadUIAndUpdateMessageData:message];
    } failure:^{
        blockMessage.messageSendState = FDChatMessageSendStateSendFailure;
        [weakself reloadUIAndUpdateMessageData:message];
    }];
}

- (void)uploadImage:(UIImage *)image {
    __block FDChatMessage *imageMessage = [FDChatMessageBuilder buildImageMessage:@""];
    
    [FDChatMessageDataHandleCenter saveImageToSandBox:image imageName:imageMessage.uuid];
    imageMessage.messageSendState = FDChatMessageSendStateSending;
    [self reloadUIAndUpdateMessageData:imageMessage];
    
    [FDChatFileUploader uploadImage:image progress:^(NSProgress * _Nonnull progress) {
        CGFloat complete = progress.completedUnitCount/progress.totalUnitCount;
        NSLog(@"----------%f",complete);
    } success:^(NSURLSessionDataTask *task, id responseData) {
        NSString *imageUrl = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"----------finish:%@",[NSString stringWithFormat:@"%@%@",imageUrlPrefix,imageUrl]);
        imageMessage.msg = [NSString stringWithFormat:@"%@%@",imageUrlPrefix,imageUrl];
        imageMessage.messageSendState = FDChatMessageSendStateSending;
        [self sendMessage:imageMessage];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"----------failure");
    }];
}

- (NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

#pragma mark - private method
+ (NSArray *)getAllMessages{
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

- (FDChatMessage *)judgeMessageHideTime:(FDChatMessage *)message{
    NSArray *originalMessages = [FDChatMessageDataHandleCenter getAllMessages];
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

- (void)reloadUIAndUpdateMessageData:(FDChatMessage *)message {
    
    FDChatMessage *addMessage = nil;
    
    if ([FDChatMessageDataHandleCenter addMessage:[self judgeMessageHideTime:message]]) {//新增消息
        addMessage = message;
    }
    
    if (self.reloadDataBlock) {
        self.reloadDataBlock(addMessage);
    }
}

- (void)getOfflineMessages {
    // 尝试获取历史记录
    [FDWebSocket sendMessage:[FDChatMessageBuilder buildConnectSocketMessage] Success:^(FDChatMessage *message){
        // 操作历史记录
        if (message.code == FDSocketSuccessCode) {
            if (message.offline) {
                for (FDChatMessage *msg in message.offline) {
                    // 转换日期
                    msg.messageDate = [self transferToDateFromTimestamp:msg.timestamp];
                    // 然后存起来
                    [FDChatMessageDataHandleCenter addMessage:msg];
                }
            }
            NSLog(@"offline；%@",message.offline);
        }
        
    } failure:^{
        
    }];
}

- (NSDate *)transferToDateFromTimestamp:(NSString *)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
    return date;
}

@end
