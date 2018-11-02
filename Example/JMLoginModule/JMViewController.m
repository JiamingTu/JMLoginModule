//
//  JMViewController.m
//  JMLoginModule
//
//  Created by JiamingTu on 07/04/2018.
//  Copyright (c) 2018 JiamingTu. All rights reserved.
//

#import "JMViewController.h"
#import <ReactiveObjC.h>
#import <JMLoginHandler.h>
#import <TJMBaseTool.h>
@interface JMViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;

@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet UITextField *pswdTextField;

@property (weak, nonatomic) IBOutlet UIButton *getCodeButton;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@property (nonatomic, strong) JMLoginHandler *loginHandler;

@end

@implementation JMViewController
#pragma  mark - lazy loading
- (JMLoginHandler *)loginHandler {
    if (!_loginHandler) {
        self.loginHandler = [[JMLoginHandler alloc]initWithLoginType:JMLoginTypeRegister isInternational:NO];
        self.loginHandler.getCodeUrl = @"";
    }
    return _loginHandler;
}
#pragma  mark - view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loginHandler];
    RAC(self.loginHandler, mobile)  = _mobileTextField.rac_textSignal;
    RAC(self.loginHandler, code)    = _codeTextField.rac_textSignal;
    RAC(self.loginHandler, pswd)    = _pswdTextField.rac_textSignal;
    RAC(_getCodeButton, enabled) = RACObserve(self.loginHandler, codeBtnEnable);
    [RACObserve(self.loginHandler, codeTitle) subscribeNext:^(NSString *  _Nullable x) {
        [_getCodeButton setTitle:x forState:UIControlStateNormal];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.loginHandler cancelTiemr];
}


#pragma  mark - click

- (IBAction)getCode:(id)sender {
    [self.loginHandler getcodeWithMethod:@"GET" response:^(BOOL isSuccess, id responseObj, NSString *msg) {
        if (isSuccess) {
            
        } else {
            [TJMHUDHandle transientNoticeAtView:self.view withMessage:msg];
        }
    }];
}
- (IBAction)commit:(id)sender {
    [self.loginHandler codeConfirmWithMethod:@"POST" response:^(BOOL isSuccess, id responseObj, NSString *msg) {
        if (isSuccess) {
            
        } else {
            [TJMHUDHandle transientNoticeAtView:self.view withMessage:msg];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
