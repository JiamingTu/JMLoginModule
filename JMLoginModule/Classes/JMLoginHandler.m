//
//  JMLoginHandler.m
//  Pods
//
//  Created by Jiaming Tu on 2018/7/4.
//

#import "JMLoginHandler.h"
#import "TJMNetworkingManager.h"
#import "JMDefine.h"
#import "NSString+RegEx.h"
@interface JMLoginHandler ()
{
    NSString *_realNoPhoneNum;
    NSString *_realWrongPhoneNum;
    NSString *_realNoCode;
    NSString *_realNoPswd;
    NSString *_realPswdTooShort;
    NSString *_realCodeToolShort;
    NSString *_realPswdDiff;
    NSString *_realPswdSame;
    
    NSTimer *_timer;
    NSInteger _count;
}

@end

@implementation JMLoginHandler
#pragma  mark - init
- (instancetype)initWithLoginType:(JMLoginType)loginType isInternational:(BOOL)isInternational {
    if (self = [super init]) {
        self.loginType = loginType;
        //设置初始值
        [self initialize];
        self.isInternational = isInternational;
        
    }
    return self;
}

- (void)initialize {
    self.pswdLengthLimit    = 6;
    self.codeLengthLimit    = 6;
    self.countDownCount     = 59;
    self.codeOriginalTitle  = @"获取验证码";
    self.codeTitleFormatter = @"%zdS";
    self.codeTitle          = self.codeOriginalTitle;
    self.codeBtnEnable      = YES;
    
    //parameters
    self.mobileKey          = @"mobile";
    self.codeKey            = @"code";
    self.pswdKey            = @"pwd";
    self.freshPswd          = @"newPwd";
    self.oldPswdKey         = @"oldPwd";
    
    if (self.isInternational) {
        _wrongPhoneNum  = @"wrongPhoneNum";
        _noPhoneNum     = @"noPhoneNum";
        _noCode         = @"noCode";
        _noPswd         = @"noPswd";
        _pswdTooShort   = @"pswdTooShort";
        _codeTooShort   = @"codeTooShort";
        _pswdDiff       = @"pswdDiff";
        _pswdSame       = @"pswdSame";
    } else {
        _wrongPhoneNum  = @"账号格式错误";
        _noPhoneNum     = @"请输入账号";
        _noCode         = @"请输入验证码";
        _noPswd         = @"请输入密码";
        _pswdTooShort   = [NSString stringWithFormat:@"密码不足%zd位", self.pswdLengthLimit];
        _codeTooShort   = [NSString stringWithFormat:@"请输入%zd位验证码", self.codeLengthLimit];
        _pswdDiff       = @"两次输入密码不一致";
        _pswdSame       = @"新旧密码相同";
    }
}

#pragma  mark - set
- (void)setIsInternational:(BOOL)isInternational {
    if (isInternational) {
        _realWrongPhoneNum  = NSLocalizedString(_wrongPhoneNum, nil);
        _realNoPhoneNum     = NSLocalizedString(_noPhoneNum, nil);
        _realNoCode         = NSLocalizedString(_noCode, nil);
        _realNoPswd         = NSLocalizedString(_noPswd, nil);
        _realPswdTooShort   = NSLocalizedString(_pswdTooShort, nil);
        _realCodeToolShort  = NSLocalizedString(_codeTooShort, nil);
        _realPswdDiff       = NSLocalizedString(_pswdDiff, nil);
        _realPswdSame       = NSLocalizedString(_pswdSame, nil);
    } else {
        _realWrongPhoneNum  = _wrongPhoneNum;
        _realNoPhoneNum     = _noPhoneNum;
        _realNoCode         = _noCode;
        _realNoPswd         = _noPswd;
        _realPswdTooShort   = _pswdTooShort;
        _realCodeToolShort  = _codeTooShort;
        _realPswdDiff       = _pswdDiff;
        _realPswdSame       = _pswdSame;
    }
}

#pragma  mark - notice
- (NSString *)notice {
    //每个Type都要判断的(账号)
    if ([JMStringIsEmpty(self.mobile) isEqualToString:@""]) {
        return _realNoPhoneNum;
    } else if (![self.mobile isMobileNumber]) {
        return _realWrongPhoneNum;
    }
    //根据type 判断
    if (self.loginType == JMLoginTypeForget || _loginType == JMLoginTypeRegister || JMLoginTypeCodeLogin) {
        if ([JMStringIsEmpty(self.code) isEqualToString:@""]) {
            return _realNoCode;
        } else if (self.code.length < self.codeLengthLimit) {
            return _realCodeToolShort;
        }
    }
    if (self.loginType != JMLoginTypeCodeLogin) {
        if ([JMStringIsEmpty(self.pswd) isEqualToString:@""]) {
            return _noPswd;
        } else if (self.pswd.length < _pswdLengthLimit) {
            return _realPswdTooShort;
        }
    }
    if (self.loginType == JMLoginTypeChange) {
        if (self.freshPswd.length < self.pswdLengthLimit || self.confirmPswd.length < _pswdLengthLimit) {
            return _realPswdTooShort;
        } else if ([self.freshPswd isEqualToString:self.pswd]) {
            return _realPswdSame;
        } else if ([self.freshPswd isEqualToString:self.confirmPswd]) {
            return _realPswdDiff;
        }
    }
    return nil;
}

- (NSString *)getCodeNotice {
    if ([JMStringIsEmpty(self.mobile) isEqualToString:@""]) {
        return _realNoPhoneNum;
    } else if (![self.mobile isMobileNumber]) {
        return _realWrongPhoneNum;
    }
    return nil;
}

#pragma  mark - network
- (void)networkWithMethod:(NSString *)method isGetCode:(BOOL)isGetCode url:(NSString *)url needToken:(BOOL)needToken parameters:(NSDictionary *)parameters response:(void(^)(BOOL isSuccess, id responseObj, NSString *msg))response; {
    if ([method isEqualToString:@"GET"]) {
        [TJMNetworkingManager GET:url isNeedToken:needToken parameters:parameters progress:nil success:^(id successObj, NSString *msg) {
            if (response) response(YES, successObj, msg);
            if (isGetCode) [self startCountDown];
        } failure:^(NSInteger code, NSString *failString) {
            if (response) response(NO, nil, failString);
            NSLog(@"失败");
            if (isGetCode) [self startCountDown];
        }];
    } else if ([method isEqualToString:@"POST"]) {
        [TJMNetworkingManager POST:url isNeedToken:needToken parameters:parameters progress:nil success:^(id successObj, NSString *msg) {
            if (response) response(YES, successObj, msg);
            if (isGetCode) [self startCountDown];
        } failure:^(NSInteger code, NSString *failString) {
            if (response) response(NO, nil, failString);
        }];
    } else if ([method isEqualToString:@"PUT"]) {
        [TJMNetworkingManager PUT:url isNeedToken:needToken parameters:parameters success:^(id successObj, NSString *msg) {
            if (response) response(YES, successObj, msg);
            if (isGetCode) [self startCountDown];
        } failure:^(NSInteger code, NSString *failString) {
            if (response) response(NO, nil, failString);
        }];
    }
}

- (void)loginWithMethod:(NSString *)method response:(void (^)(BOOL, id, NSString *))response {
    NSString *notice = [self notice];
    if (notice) {
        if (response) response(NO, nil, notice);
    } else {
        NSString *url = _loginUrl;
        NSDictionary *parameters = @{
                                     _mobileKey : _mobile,
                                     _pswdKey   : _pswd
                                     };
        [self networkWithMethod:method isGetCode:NO url:url needToken:NO parameters:parameters response:response];
    }
}

- (void)getcodeWithMethod:(NSString *)method response:(void (^)(BOOL, id, NSString *))response {
    NSString *notice = [self getCodeNotice];
    if (notice) {
        if (response) response(NO, nil, notice);
    } else {
        NSString *url = _getCodeUrl;
        NSDictionary *parameters = @{
                                 _mobileKey : _mobile
                                 };
        [self networkWithMethod:method isGetCode:YES url:url needToken:NO parameters:parameters response:response];
    }
}

- (void)codeConfirmWithMethod:(NSString *)method response:(void (^)(BOOL, id, NSString *))response {
    NSString *notice = [self notice];
    if (notice) {
        if (response) response(NO, nil, notice);
    } else {
        NSString *url = _codeConfirmUrl;
        NSDictionary *parameters = @{
                                     _mobileKey : _mobile,
                                     _codeKey   : _code,
                                     _pswdKey   : _pswd
                                     };
        [self networkWithMethod:method isGetCode:NO url:url needToken:NO parameters:parameters response:response];
    }
}

- (void)changeWithMethod:(NSString *)method needToken:(BOOL)needToken response:(void (^)(BOOL, id, NSString *))response {
    NSString *notice = [self notice];
    if (notice) {
        if (response) response(NO, nil, notice);
    } else {
        NSString *url = _changeUrl;
        NSDictionary *parameters = @{
                                     _mobileKey     : _mobile,
                                     _oldPswdKey    : _pswd,
                                     _freshPswdKey  : _freshPswd
                                     };
        [self networkWithMethod:method isGetCode:NO url:url needToken:NO parameters:parameters response:response];
    }
}

#pragma  mark - timer
- (void)startCountDown {
    if (!_timer) {
        _count = _countDownCount;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)timerAction {
    self.codeTitle = [NSString stringWithFormat:self.codeTitleFormatter, _count];
    self.codeBtnEnable = NO;
    if (_count == 0) {
        self.codeTitle = self.codeOriginalTitle;
        self.codeBtnEnable = YES;
        [self cancelTiemr];
    }
    _count --;
}

- (void)cancelTiemr {
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
}

@end
