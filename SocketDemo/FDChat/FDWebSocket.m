//
//  FDWebSocket.m
//  SocketDemo
//
//  Created by xietao on 16/12/9.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import "FDWebSocket.h"
#import "SRWebSocket.h"
#import "FDChatMessageManager.h"
#import "FDChatMessage.h"
#import "FDChatMessageParser.h"

// test
//#define SocketUrl @"ws://121.40.165.18:8088"
// dev
#define SocketUrl       @"ws://kf-app.test.fruitday.com/chat"
#define kWebSocket      [FDWebSocket shareInstance]

// error enum
typedef NS_ENUM(NSUInteger, FDWebSocketErrorCode) {
    Timeout_Connecting_To_Server = 504,
    Received_Bad_Response_Code_From_Server = 2132,
    Invalid_Sec_WebSocket_Accept_Response = 2133,
    Error_Writing_To_Stream = 2145,
    Invalid_Server_Cert = 23556
};

@interface FDWebSocket ()<SRWebSocketDelegate>

@property (strong, nonatomic) SRWebSocket *webSocket;

@property (nonatomic, strong) NSMutableDictionary *callBacks;

// 连接成功block
@property (copy, nonatomic) ConnectSocketSuccess connectSocketSuccess;
// 连接失败block
@property (copy, nonatomic) ConnectSocketFailure connectSocketFailure;
// 断开成功block
@property (copy, nonatomic) DisconnectCompletion disconnectCompletionBlock;
// 异常断开block
@property (copy, nonatomic) DisconnectCompletion exceptionDisconnectBlock;
// 接收消息block
@property (copy, nonatomic) ReceiveMessageBlock receiveMessageBlock;

@end

@implementation FDWebSocket

+ (instancetype)shareInstance {
    static FDWebSocket *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[FDWebSocket alloc] init];
    });
    return shareInstance;
}

+ (void)openSocketSuccess:(ConnectSocketSuccess)success failure:(ConnectSocketFailure)failure {
    if (kWebSocket.webSocket && kWebSocket.webSocket.readyState == SR_OPEN) {
        // 已连接 返回连接成功
        if (success) {
            success();
        }
    }else if (!kWebSocket.webSocket || kWebSocket.webSocket.readyState >= SR_CLOSING) {
        // 已断开 重新连接
        kWebSocket.connectSocketSuccess = success;
        kWebSocket.connectSocketFailure = failure;
        [kWebSocket open];
        
    }else {
        // 正在断开 返回连接失败
        if (failure) {
            failure();
        }
    }
}

+ (void)closeSocketCompletionBlock:(void(^)())completionBlock {
    if (kWebSocket.webSocket.readyState == SR_OPEN ||
        kWebSocket.webSocket.readyState == SR_CONNECTING) {
        
        [kWebSocket close];
        kWebSocket.disconnectCompletionBlock = completionBlock;
        
    }else if (kWebSocket.webSocket.readyState >= SR_CLOSING){
        // 已断开 则直接返回
        if (completionBlock) {
            completionBlock();
        }
    }
}

+ (void)setExceptionDisconnectBlock:(void(^)())exceptionDisconnectBlock {
    kWebSocket.exceptionDisconnectBlock = exceptionDisconnectBlock;
}

+ (void)sendMessage:(id)message Success:(WriteMessageSuccess)success failure:(WriteMessageFailure)failure {
    NSAssert(message, @"入参不能为空");
    if (!message) return;
//    NSLog(@"入参：%@",[message toJSONString]);
    
    if (kWebSocket.webSocket.readyState == SR_OPEN) {
        // 已连接
        FDChatMessageManager *manager = [[FDChatMessageManager alloc] initWithUUID:((FDChatMessage *)message).uuid writeMessageSuccess:success writeMessageFailure:failure];
        kWebSocket.callBacks[((FDChatMessage *)message).uuid] = manager;
        [kWebSocket sendData:[message toJSONString]];
        
    }else if (kWebSocket.webSocket.readyState >= SR_CLOSING) {
        // 未连接：重连后再发生
        [FDWebSocket openSocketSuccess:^{
            FDChatMessageManager *manager = [[FDChatMessageManager alloc] initWithUUID:((FDChatMessage *)message).uuid writeMessageSuccess:success writeMessageFailure:failure];
            kWebSocket.callBacks[((FDChatMessage *)message).uuid] = manager;
            [kWebSocket sendData:[message toJSONString]];
        } failure:^{
            if (failure) {
                failure();
            }
        }];
        
    }else{
        // 未连接状态直接返回发送失败
        if (failure) {
            failure();
        }
        
    }
}

+ (void)setReceiveMessageBlock:(ReceiveMessageBlock)receiveMessageBlock {
    kWebSocket.receiveMessageBlock = receiveMessageBlock;
}

+ (void)removeMessageManagerWithUuid:(NSString *)uuid {
    [kWebSocket.callBacks removeObjectForKey:uuid];
}

#pragma mark - PrivateMethod
- (id)init {
    self = [super init];
    if (self) {
        self.callBacks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)open {
    self.webSocket = nil;

    // 不用成员变量会闪退...
    if (!self.webSocket) {
        [self.webSocket close];
        self.webSocket.delegate = nil;
        
#warning 登陆信息 connect_id
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:SocketUrl]];
        [request setValue:FDChatSource forHTTPHeaderField:@"chatSource"];
        [request setValue:@"292d4f83f7f5ab3edbf484eeb8ce5149" forHTTPHeaderField:@"connectId"];
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
        self.webSocket.delegate = self;
        [self.webSocket open];
    }
}

- (void)close {
    [self.webSocket close];

}

- (void)sendPing:(NSData *)data {
    [self.webSocket sendPing:data];

}

- (void)sendData:(id)data {
    [self.webSocket send:data];
}

- (void)cleanBlock {
    self.connectSocketSuccess = nil;
    self.connectSocketFailure = nil;
    self.disconnectCompletionBlock = nil;
}


#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket Connected");
    if (self.connectSocketSuccess) {
        self.connectSocketSuccess();
        [self cleanBlock];
    }

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@":( Websocket Failed With Error %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
    // 连接失败
    if (self.connectSocketFailure) {
        self.connectSocketFailure();
        [self cleanBlock];
    }else if (self.callBacks.allValues.count == 1) {
        // 如果只有一个待处理CallBack 则调用该回调
        FDChatMessageManager *manager = self.callBacks.allValues[0];
        [manager setMessageFailure];
    }
    
    /* 方案二
    switch (error.code) {
        case Error_Writing_To_Stream:
        {
            // 如果只有一个待处理CallBack 则调用该回调
            if (self.callBacks.allValues.count == 1) {
                FDChatMessageManager *manager = self.callBacks.allValues[0];
                [manager setMessageFailure];
                [self.callBacks removeAllObjects];
            }
        }
            break;
        case Timeout_Connecting_To_Server:
        case Received_Bad_Response_Code_From_Server:
        case Invalid_Sec_WebSocket_Accept_Response:
        case Invalid_Server_Cert:
        default:
        {
            // 连接失败
            if (self.connectSocketFailure) {
                self.connectSocketFailure();
                [self cleanBlock];
            }
        }
            break;
    }
     */
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    // 解析接收到的数据
    [FDChatMessageParser parseMessage:message callBacks:self.callBacks receiveMessageBlock:self.receiveMessageBlock];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WebSocket closed");

    // 主动断开
    if (self.disconnectCompletionBlock) {
        self.disconnectCompletionBlock();
        [self cleanBlock];
    // 被动断开
    }else if (self.exceptionDisconnectBlock) {
        [FDWebSocket openSocketSuccess:^{
            NSLog(@"重连成功");
        } failure:^{
            NSLog(@"重连失败");
        }];
        self.exceptionDisconnectBlock();
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"WebSocket received pong");
}

@end
