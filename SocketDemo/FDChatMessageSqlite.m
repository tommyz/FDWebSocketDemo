//
//  FDChatMessageSqlite.m
//  SocketDemo
//
//  Created by xieyan on 2017/3/9.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "FDChatMessageSqlite.h"
#import "FMDB.h"
#import "FDChatMessageFrame.h"
#import "FDChatMessage.h"

static FMDatabase *_db;

@implementation FDChatMessageSqlite

+ (void)initialize
{
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
    [_db executeUpdateWithFormat:@"INSERT INTO t_message(message, uuid) VALUES(%@, %@);", data,messageFrame.message.uuid];
}

+ (void)updateMessageFrame:(FDChatMessageFrame *)messageFrame{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageFrame];
    [_db executeUpdateWithFormat:@"UPDATE  t_message SET message = %@ where uuid = %@",data,messageFrame.message.uuid];
}

@end
