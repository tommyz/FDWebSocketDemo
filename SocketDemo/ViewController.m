//
//  ViewController.m
//  SocketDemo
//
//  Created by xietao on 16/11/4.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import "ViewController.h"
#import "FDWebSocket.h"
#import "FDChatMessage.h"
#import "FDChatMessageMamager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [FDWebSocket openSocketSuccess:^{
        NSLog(@"连接成功");
    } failure:^{
        NSLog(@"连接失败");
    }];
    
    [FDWebSocket setExceptionDisconnectBlock:^{
        NSLog(@"异常断开");
    }];
    [FDWebSocket setReceiveMessageBlock:^(NSString *message) {
        NSLog(@"收到信息:%@",message);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)connectAction:(id)sender {

    [FDWebSocket openSocketSuccess:^{
        NSLog(@"连接成功");
    } failure:^{
        NSLog(@"连接失败");
    }];
    
}

- (IBAction)disconnectAction:(id)sender {

    [FDWebSocket closeSocketCompletionBlock:^{
        NSLog(@"断开成功");
    }];


}

- (IBAction)isConnectedAction:(id)sender {
    [FDWebSocket sendMessage:[[FDChatMessageMamager buildConnectSocketMessage] toJSONString] Success:^{
        NSLog(@"link成功");
    } failure:^{
        
    }];
    

}
- (IBAction)setupAction:(id)sender {
    [FDWebSocket sendMessage:[[FDChatMessageMamager buildSetupChatMessage] toJSONString] Success:^{
        NSLog(@"初始化成功");
    } failure:^{
        
    }];
}

- (IBAction)sendAction:(id)sender {
    [FDWebSocket sendMessage:[[FDChatMessageMamager buildTextMessage:@"dsadasd"] toJSONString] Success:^{
        NSLog(@"发送成功");
    } failure:^{
        NSLog(@"发送失败");
    }];
}


@end
