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

// test
//#define SocketUrl @"ws://115.29.193.48:8088"
// dev
#define SocketUrl @"ws://172.28.25.128:8080/chat"

#define kWebSocket     [FDWebSocket shareInstance]

// enum
typedef NS_ENUM(NSUInteger, FDWebSocketErrorCode) {
    Timeout_Connecting_To_Server = 504,
    Received_Bad_Response_Code_From_Server = 2132,
    Invalid_Sec_WebSocket_Accept_Response = 2133,
    Error_Writing_To_Stream = 2145,
    Invalid_Server_Cert = 23556
};

@interface FDWebSocket ()<SRWebSocketDelegate>

@property (strong, nonatomic) SRWebSocket *webSocket;

// 连接成功block
@property (copy, nonatomic) ConnectSocketSuccess connectSocketSuccess;
// 连接失败block
@property (copy, nonatomic) ConnectSocketFailure connectSocketFailure;
// 断开成功block
@property (copy, nonatomic) DisconnectCompletion disconnectCompletionBlock;
// 异常断开block
@property (copy, nonatomic) DisconnectCompletion exceptionDisconnectBlock;
// 发送信息成功block
@property (copy, nonatomic) WriteMessageSuccess writeMessageSuccess;
// 发送信息失败block
@property (copy, nonatomic) WriteMessageFailure writeMessageFailure;
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
    }else if (!kWebSocket.webSocket || kWebSocket.webSocket.readyState == SR_CLOSED) {
        // 已断开 重新连接
        kWebSocket.webSocket = nil;
        kWebSocket.connectSocketSuccess = success;
        kWebSocket.connectSocketFailure = failure;
        [kWebSocket open];
    }else if (kWebSocket.webSocket.readyState == SR_CLOSING) {
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
    }else if (kWebSocket.webSocket.readyState == SR_CLOSED){
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
    NSLog(@"入参：%@",message);
    if (message && kWebSocket.webSocket.readyState == SR_OPEN) {
        [kWebSocket sendData:message];
        kWebSocket.writeMessageSuccess = success;
        kWebSocket.writeMessageFailure = failure;
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

#pragma mark - PrivateMethod
- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)open {
    // 不用成员变量会闪退...
    if (!self.webSocket) {
        [self.webSocket close];
        self.webSocket.delegate = nil;
        
#warning 登陆信息
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:SocketUrl]];
        [request setValue:@"xietao3" forHTTPHeaderField:@"uid"];
        [request setValue:@"xietao3" forHTTPHeaderField:@"connectId"];
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
    self.writeMessageSuccess = nil;
    self.writeMessageFailure = nil;
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
    switch (error.code) {
        case Error_Writing_To_Stream:
        {
            if (self.writeMessageFailure) {
                self.writeMessageFailure();
                [self cleanBlock];
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
    
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    __weak typeof(self) weakSelf = self;
    [FDChatMessageManager parseMessage:message parseCompletion:^(FDChatMessage *chatMessage, BOOL isReply) {
        if (chatMessage) {
            if (isReply) {
                if (weakSelf.writeMessageSuccess) {
                    weakSelf.writeMessageSuccess();
                    [weakSelf cleanBlock];
                }
            }else{
                if (weakSelf.receiveMessageBlock) {
                    weakSelf.receiveMessageBlock(chatMessage);
                }
            }
        }
    }];
    
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WebSocket closed");
   
    // 主动断开
    if (self.disconnectCompletionBlock) {
        self.disconnectCompletionBlock();
        [self cleanBlock];
    // 被动断开
    }else if (self.exceptionDisconnectBlock) {
        self.exceptionDisconnectBlock();
    }
    
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"WebSocket received pong");
}

@end
