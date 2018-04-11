//
//  TTWebSocketViewController.m
//  TTIMSocket
//
//  Created by TT on 2018/4/10.
//  Copyright © 2018年 TAO. All rights reserved.
//

#import "TTWebSocketViewController.h"
#import "TTWebSocket.h"

@interface TTWebSocketViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation TTWebSocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectAction:(UIButton *)sender {
    
    [[TTWebSocket sharedManager] connect];
}

- (IBAction)disConnectAction:(UIButton *)sender {
    
    [[TTWebSocket sharedManager] disConnect];
}

- (IBAction)pingPongAction:(UIButton *)sender {
    
    [[TTWebSocket sharedManager] pingPong];
}

- (IBAction)sendMessageAction:(UIButton *)sender {
    
    if (![self.textField.text isEqualToString:@""]) {
        [[TTWebSocket sharedManager] sendMessage:self.textField.text];
    } else {
        NSLog(@"不能发送空数据");
    }
}

@end
