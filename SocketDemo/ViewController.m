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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [FDWebSocket openSocketSuccess:^{
        NSLog(@"连接成功");
    } failure:^{
        NSLog(@"连接失败");
    }];
    
    [FDWebSocket setExceptionDisconnectBlock:^(NSString *exceptionString){
        NSLog(@"%@",exceptionString);
    }];
    
    [FDWebSocket setReceiveMessageBlock:^(FDChatMessage *message) {
        NSLog(@"收到信息:%@",message);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message.chatType
                                                            message:[NSString stringWithFormat:@"%@:%@",message.msgType,message.msg]
                                                           delegate:self
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles: nil];
        [alertView show];
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

   
    
    [FDWebSocket sendMessage:[FDChatMessageBuilder buildDisconnectMessage] Success:^{
        [FDWebSocket closeSocketCompletionBlock:^{
            NSLog(@"断开成功");
        }];
    } failure:^{
        
    }];
}

- (IBAction)isConnectedAction:(id)sender {
    [FDWebSocket sendMessage:[FDChatMessageBuilder buildConnectSocketMessage] Success:^{
        NSLog(@"link成功");
    } failure:^{
        
    }];
    
}
- (IBAction)setupAction:(id)sender {
    [FDWebSocket sendMessage:[FDChatMessageBuilder buildSetupChatMessage] Success:^{
        NSLog(@"初始化成功");
    } failure:^{
        
    }];
}

- (IBAction)sendAction:(id)sender {
    static int count = 0;
    count++;
    [FDWebSocket sendMessage:[FDChatMessageBuilder buildTextMessage:_inputView.text] Success:^{
        NSLog(@"发送成功");
    } failure:^{
        NSLog(@"发送失败");
    }];
}


@end
