//
//  TTOSSocketViewController.m
//  TTIMSocket
//
//  Created by TT on 2018/4/9.
//  Copyright © 2018年 TAO. All rights reserved.
//

#import "TTOSSocketViewController.h"
#import "TTSocketManager.h"

@interface TTOSSocketViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation TTOSSocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)connectSocket:(UIButton *)sender {
    
    [[TTSocketManager sharedManager] connect];
}

- (IBAction)disConnectSocket:(UIButton *)sender {
    
    [[TTSocketManager sharedManager] disConnect];
}

- (IBAction)sendMessage:(UIButton *)sender {
    
    if (![self.textField.text isEqualToString:@""]) {
        [[TTSocketManager sharedManager] sendMessage:self.textField.text];
    } else {
        NSLog(@"不能发送空数据");
    }
}


@end
