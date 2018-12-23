//
//  JMLoginHandler.m
//  Pods
//
//  Created by Jiaming Tu on 2018/7/4.
//

#import "JMLoginHandler.h"

#define LH_StringIsEmpty(string) ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"] ? @"" : string )


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
    if ([LH_StringIsEmpty(self.mobile) isEqualToString:@""]) {
        return _realNoPhoneNum;
    } else if (![self lh_isMobileNumber:self.mobile]) {
        return _realWrongPhoneNum;
    }
    //根据type 判断
    if (self.loginType == JMLoginTypeForget || _loginType == JMLoginTypeRegister || JMLoginTypeCodeLogin) {
        if ([LH_StringIsEmpty(self.code) isEqualToString:@""]) {
            return _realNoCode;
        } else if (self.code.length < self.codeLengthLimit) {
            return _realCodeToolShort;
        }
    }
    if (self.loginType != JMLoginTypeCodeLogin) {
        if ([LH_StringIsEmpty(self.pswd) isEqualToString:@""]) {
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
    if ([LH_StringIsEmpty(self.mobile) isEqualToString:@""]) {
        return _realNoPhoneNum;
    } else if (![self lh_isMobileNumber:self.mobile]) {
        return _realWrongPhoneNum;
    }
    return nil;
}

#pragma  mark - sign 处理
+ (NSDictionary *)signWithDictionary:(NSDictionary *)dictionary pswdKey:(NSString *)pswdKey secretKey:(NSString *)secretKey encrypt:(NSString *(^)(NSString *keyword))encrypt {
    //变为可变数组
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    //MD5 加密
    NSString *pswd = parameters[pswdKey];
    if (![LH_StringIsEmpty(pswd) isEqualToString:@""]) {
        pswd = encrypt(pswd);
        parameters[pswdKey] = pswd;
    }
    //升序得到 健值对应的两个数组
    NSArray *allKeyArray = [parameters allKeys];
    NSArray *afterSortKeyArray = [allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult resuest = [obj1 compare:obj2];
        return resuest;
    }];
    //通过排列的key值获取value
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortsing in afterSortKeyArray) {
        NSString *valueString = [parameters objectForKey:sortsing];
        [valueArray addObject:valueString];
    }
    //健值合并
    NSMutableArray *signArray = [NSMutableArray array];
    for (int i = 0 ; i < afterSortKeyArray.count; i++) {
        NSString *keyValue = [NSString stringWithFormat:@"%@%@",afterSortKeyArray[i],valueArray[i]];
        [signArray addObject:keyValue];
    }
    //signString用于签名的原始参数集合
    NSString *signString = [signArray componentsJoinedByString:@""];
    //秘钥拼接
    signString = [NSString stringWithFormat:@"%@%@%@",secretKey,signString,secretKey];
    //MD5加密
    signString = encrypt(signString);
    //添加健值  sign
    [parameters setObject:signString forKey:@"sign"];
    return parameters;

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

#pragma  mark - 判断是否电话号码
- (BOOL)lh_isMobileNumber:(NSString *)mobile {
    if (mobile.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[0, 1, 6, 7, 8], 18[0-9]
     * 移动号段: 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
     * 联通号段: 130,131,132,145,155,156,170,171,175,176,185,186
     * 电信号段: 133,149,153,170,173,177,180,181,189
     */
    //    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|7[0135678]|8[0-9])\\d{8}$";
    NSString *MOBILE = @"^1[0-9]{10}$";//1开头且为11位
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
     */
    NSString *CM = @"^1(3[4-9]|4[7]|5[0-27-9]|7[08]|8[2-478])\\d{8}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,145,155,156,170,171,175,176,185,186
     */
    NSString *CU = @"^1(3[0-2]|4[5]|5[56]|7[0156]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,149,153,170,173,177,180,181,189
     */
    NSString *CT = @"^1(3[3]|4[9]|53|7[037]|8[019])\\d{8}$";
    
    
    NSPredicate *regExtestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regExtestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regExtestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regExtestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regExtestmobile evaluateWithObject:mobile] == YES)
        || ([regExtestcm evaluateWithObject:mobile] == YES)
        || ([regExtestct evaluateWithObject:mobile] == YES)
        || ([regExtestcu evaluateWithObject:mobile] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end





