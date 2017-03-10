//
//  FDChatViewController.m
//  chatDemo
//
//  Created by xieyan on 2016/12/9.
//  Copyright © 2016年 Fruitday. All rights reserved.
//

#import "FDChatViewController.h"
#import "FDChatMessage.h"
#import "FDChatMessageFrame.h"
#import "FDChatMessageCell.h"
#import "FDInputTextView.h"
#import "FDChatMoreView.h"
#import "UIView+FDExtension.h"
#import "FDEmotionKeyboard.h"
#import "FDEmotion.h"
#import "NSString+Helper.h"
#import "MJRefresh.h"
#import "FDWebSocket.h"
#import "FDChatMessageDataHandleCenter.h"

@interface FDChatViewController ()<FDChatMoreViewDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewHeightConstraint;
@property (weak, nonatomic) IBOutlet FDInputTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, strong)NSMutableArray *messageFrames;
/** 退出键盘手势 */
@property (nonatomic, strong) UITapGestureRecognizer *hideKeyboardTap;
/** 输入框激活系统键盘手势 */
@property (nonatomic, strong) UITapGestureRecognizer *activeSystemKeyboardTap;
/** 更多(拍照、订单号) */
@property (nonatomic, weak) FDChatMoreView *moreView;
/** 表情键盘 */
@property (nonatomic, strong) FDEmotionKeyboard *emotionKeyboard;
/** 子控件外面包一层view 要不然回到前台tranfram会被篡改 */
@property (weak, nonatomic) IBOutlet UIView *fullView;
/** 工具栏选中按钮 */
@property (nonatomic, weak) UIButton *selectedButton;
/** 是否正在切换键盘 */
@property (nonatomic, assign) BOOL switchingKeybaord;
/** chatTableView的footer */
@property (nonatomic, strong) MJRefreshBackFooter *mj_footer;
/** 保存失败消息 */
@property (nonatomic, strong) FDChatMessageFrame *failMessageFrame;

@end

@implementation FDChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    // 集成下拉刷新控件(加载更多数据)
    [self setupDownRefresh];
    // 集成上拉刷新控件(弹出键盘)
    [self setupUpRefresh];
}

- (void)dealloc{
    //移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"FDEmotionDidSelectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"FDEmotionDidDeleteNotification" object:nil];
}

#pragma mark - privateMethod
- (void)initialize{
    //导航栏标题
    self.navigationItem.title = @"在线客服";
    //设置输入框相关属性
    self.inputTextView.delegate = self;
    __weak typeof(self) weakSelf = self;
    self.inputTextView.maxNumberOfLines = 4;
    [self.inputTextView setFd_textHeightChangeBlock:^(CGFloat textHeight) {
        // 工具栏高度随输入文字变化
        weakSelf.inputViewHeightConstraint.constant = textHeight + 10;
        [UIView animateWithDuration:0.25 animations:^{
            [weakSelf.view layoutIfNeeded];
          //  [weakSelf chatTableViewScrollToBottom];
        }];
    }];
    //手势
    self.hideKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    self.activeSystemKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activeSystemKeyboard)];
    
    //监听键盘通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    // 选择表情的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(emotionDidSelect:) name:@"FDEmotionDidSelectNotification" object:nil];
    // 删除表情的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidDelete) name:@"FDEmotionDidDeleteNotification" object:nil];
    
    // 收到消息
    [FDWebSocket setReceiveMessageBlock:^(FDChatMessage *message) {
#warning 判断信息类型 比如说评分 需要不同处理方式 不用加入聊天记录里
        message.chatMessageBy = FDChatMessageByServicer;
        [weakSelf addMessage:message];
        [weakSelf.chatTableView reloadData];
        [weakSelf  chatTableViewScrollToBottom];
    }];
    
    // 异常断开
    [FDWebSocket setExceptionDisconnectBlock:^(NSString *exceptionString){
        NSLog(@"%@",exceptionString);
    }];
    
#warning 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"连接" style:UIBarButtonItemStyleDone target:self action:@selector(openSocket)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"断开" style:UIBarButtonItemStyleDone target:self action:@selector(closeSocket)];
}

- (void)chatTableViewScrollToBottom{
    if (self.messageFrames.count == 0) return;
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.messageFrames.count - 1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)setupDownRefresh{

}

- (void)setupUpRefresh{
    MJRefreshBackFooter *footer = [MJRefreshBackFooter footerWithRefreshingTarget:self refreshingAction:@selector(showKeyBoard)];
    self.chatTableView.mj_footer = footer;
    self.mj_footer = footer;
}

- (void)openSocket{
    [FDWebSocket openSocketSuccess:^{
        NSLog(@"连接成功");
    } failure:^{
        NSLog(@"连接失败");
    }];
}

- (void)closeSocket{
    // 告知服务器用户离开
    [FDWebSocket finishChat];
    // 断开后离开聊天页面
}

#pragma mark - 懒加载
- (FDChatMoreView *)moreView{
    if (!_moreView) {
        _moreView = [FDChatMoreView moreView];
        _moreView.delegate = self;
        _moreView.height = 216;
        _moreView.width = self.view.width;
    }
    return _moreView;
}

- (FDEmotionKeyboard *)emotionKeyboard{
    if (!_emotionKeyboard) {
        self.emotionKeyboard = [[FDEmotionKeyboard alloc] init];
        // 键盘的宽度
        self.emotionKeyboard.width = self.view.width;
        self.emotionKeyboard.height = 216;
    }
    return _emotionKeyboard;
}

- (NSMutableArray *)messageFrames{
    if (_messageFrames == nil) {
        _messageFrames = [NSMutableArray array];
        NSArray *historyMessageFrames = [FDChatMessageDataHandleCenter getMessageFrames];
        if (historyMessageFrames.count > 0) {
            [_messageFrames addObjectsFromArray:historyMessageFrames];
        }
    }
    return _messageFrames;
}

#pragma mark - 通知处理
- (void)keyboardDidChangeFrame:(NSNotification *)noti{
    // 如果正在切换键盘，就不要执行后面的代码
    if (self.switchingKeybaord) return;
    // 键盘背景色
    self.view.window.backgroundColor = self.chatTableView.backgroundColor;
    // 键盘动画时间
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 获取窗口的高度
    CGFloat windowH = [UIScreen mainScreen].bounds.size.height;
    // 键盘结束的Frm
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘结束的y值
    CGFloat kbEndY = kbEndFrm.origin.y;
    //手势处理
    CGFloat constant = windowH - kbEndY;
    if (constant > 0) {
        [self.fullView addGestureRecognizer:self.hideKeyboardTap];
    }else{
        [self.fullView removeGestureRecognizer:self.hideKeyboardTap];
    }
    //聊天界面随键盘联动
    UIEdgeInsets insets = UIEdgeInsetsMake(64 + constant, 0, 0, 0);
    self.chatTableView.contentInset = insets;
    self.chatTableView.scrollIndicatorInsets = insets;
    [UIView animateWithDuration:duration animations:^{
        self.fullView.transform = CGAffineTransformMakeTranslation(0, -constant);
        if (constant > 0) {
            [self chatTableViewScrollToBottom];
        }
    } completion:nil];
}

- (void)emotionDidSelect:(NSNotification *)noti{
    FDEmotion *emotion = noti.userInfo[@"FDEmotionKey"];
    [self.inputTextView insertText:emotion.code.emoji];
}

- (void)emotionDidDelete{
    [self.inputTextView deleteBackward];
}

#pragma mark - 键盘处理
- (void)hideKeyBoard{
    [self.inputTextView endEditing:YES];
    //去除按钮选中状态
    if (self.selectedButton.isSelected) self.selectedButton.selected = NO;
    //切换回系统键盘
    self.inputTextView.inputView = nil;
    self.inputTextView.editable = YES;
}

- (void)activeSystemKeyboard{
    //去除按钮选中状态
    if (self.selectedButton.isSelected) self.selectedButton.selected = NO;
    // 开始切换键盘
    self.switchingKeybaord = YES;
    // 退出键盘
    [self.inputTextView endEditing:YES];
    // 结束切换键盘
    self.switchingKeybaord = NO;
    //切换回系统键盘
    self.inputTextView.editable = YES;
    self.inputTextView.inputView = nil;
    // 动画效果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 弹出键盘
        [self.inputTextView becomeFirstResponder];
    });
}

- (void)changeKeyboard:(UIView *)keyboardView isSelected:(BOOL)isSelected{
    if (isSelected) {
        self.inputTextView.inputView = keyboardView;
        // 开始切换键盘
        self.switchingKeybaord = YES;
        // 退出键盘
        [self.inputTextView endEditing:YES];
        // 结束切换键盘
        self.switchingKeybaord = NO;
        self.inputTextView.editable = NO;
        // 添加手势
        [self.inputTextView addGestureRecognizer:self.activeSystemKeyboardTap];
        // 动画效果
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 弹出键盘
            [self.inputTextView becomeFirstResponder];
        });
        
    }else{
        self.inputTextView.inputView = nil;
        // 退出键盘
        [self.inputTextView endEditing:YES];
        self.inputTextView.editable = YES;
        // 去除手势
        [self.inputTextView removeGestureRecognizer:self.activeSystemKeyboardTap];
    }
}

- (void)showKeyBoard{
    //消除没有更多数据的状态
    [self.mj_footer resetNoMoreData];
    [self.inputTextView becomeFirstResponder];
}

#pragma mark - 发消息
- (void)sendMessage:(FDChatMessage *)message isReSend: (BOOL) isReSend{
    
    __block FDChatMessage* blockMessage = message;
    __weak typeof(self) weakself = self;
    
    //1.把消息发送给服务器
    [FDWebSocket sendMessage:message Success:^{
        blockMessage.messageSendState = FDChatMessageSendStateSendSuccess;
        if (message == self.failMessageFrame.message) {//如果是重发消息,要更新此条在数据库的状态
            [FDChatMessageDataHandleCenter updateMessageFrame:weakself.failMessageFrame];
        }
        [weakself.chatTableView reloadData];
        
    } failure:^{
        message.messageSendState = FDChatMessageSendStateSendFailure;
        [weakself.chatTableView reloadData];
    }];
    
    //2.组装模型数据并加入数组中
    if (!isReSend) {//重发消息不要再加入数组
        [self addMessage:message];
    }
    
    //3. 刷新UI
    [self reloadUI];
}

- (void)addMessage:(FDChatMessage *)message{
    if (self.messageFrames.count > 0) {
        FDChatMessageFrame *lastFm = [self.messageFrames lastObject];
                
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
    [FDChatMessageDataHandleCenter addMessageFrame:fm];
    [self.messageFrames addObject:fm];
    
}

- (void)reloadUI{
    [self.chatTableView reloadData];
    
    // 自动滚到最后一条
    [self chatTableViewScrollToBottom];
    
    // 清空输入框
    self.inputTextView.text = nil;
    
    // 设置发送按钮不可点击
    self.sendButton.enabled = NO;
    
    // 文本框如果多行发完消息恢复为一行
    if (self.inputViewHeightConstraint.constant == 44) return;
    self.inputViewHeightConstraint.constant = 44;
}

#pragma mark - IBAction
- (IBAction)onSendMessagePress:(id)sender {
    FDChatMessage *message = [FDChatMessageBuilder buildTextMessage:self.  inputTextView.text];
    message.chatMessageBy = FDChatMessageByCustomer;
    message.messageSendState = FDChatMessageSendStateSending;
    [self sendMessage:message isReSend:NO];
}

- (IBAction)onEmotionPress:(UIButton *)sender {
    // 改变按钮选中状态
    if (sender != self.selectedButton) {
        self.selectedButton.selected = NO;
    }
    sender.selected = !sender.isSelected;
    self.selectedButton = sender;
    // 切换键盘
    [self changeKeyboard:self.emotionKeyboard isSelected:sender.isSelected];
}

- (IBAction)onMorePress:(UIButton *)sender {
    // 改变按钮选中状态
    if (sender != self.selectedButton) {
        self.selectedButton.selected = NO;
    }
    sender.selected = !sender.isSelected;
    self.selectedButton = sender;
    // 切换键盘
    [self changeKeyboard:self.moreView isSelected:sender.isSelected];
}

#pragma mark - FDChatMoreViewDelegate
- (void)chatMoreView:(FDChatMoreView *)moreView buttonDidSelect:(FDChatMoreViewType)type{
    if (type == FDChatMoreViewTypeCamera) {
        NSLog(@"拍照");
    }else if (type == FDChatMoreViewTypePhoto){
        NSLog(@"图片");
    }else{
        NSLog(@"我的订单号");
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    self.sendButton.enabled = textView.hasText;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString: @"\n"]) {
        FDChatMessage *message = [FDChatMessageBuilder buildTextMessage:self.inputTextView.text];
        message.chatMessageBy = FDChatMessageByCustomer;
        message.messageSendState = FDChatMessageSendStateSending;
        [self sendMessage:message isReSend:NO];
        return  NO;
    }
    return YES;
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageFrames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    static NSString *ID = @"messageCell";
    FDChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[FDChatMessageCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    [cell setSendFailMessageBlock:^(FDChatMessageFrame *messageFrame) {
        weakSelf.failMessageFrame = messageFrame;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重发该消息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重发",nil];
        alert.tag = 1;
        [alert show];
    }];
    cell.messageFrame = self.messageFrames[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FDChatMessageFrame *mf = self.messageFrames[indexPath.row];
    return mf.cellHeight;
}

#pragma mark - alert delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1 && alertView.tag == 1){
        self.failMessageFrame.message.messageSendState = FDChatMessageSendStateSending;
        [self sendMessage:self.failMessageFrame.message isReSend:YES];
    }
}

@end
