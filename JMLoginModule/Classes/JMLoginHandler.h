//
//  JMLoginHandler.h
//  Pods
//
//  Created by Jiaming Tu on 2018/7/4.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    JMLoginTypeCodeLogin,
    JMLoginTypeOriginalLogin,
    JMLoginTypeRegister,
    JMLoginTypeForget,
    JMLoginTypeChange,
} JMLoginType;

@interface JMLoginHandler : NSObject

/**
 初始化方法

 @param loginType 类型
 @param isInternational 是否国际化
 @return id
 */
- (instancetype)initWithLoginType:(JMLoginType)loginType isInternational:(BOOL)isInternational;

@property (nonatomic, assign) JMLoginType loginType;

@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *pswd;

@property (nonatomic, copy) NSString *freshPswd;

@property (nonatomic, copy) NSString *confirmPswd;

@property (nonatomic, copy) NSString *mobileKey;

@property (nonatomic, copy) NSString *codeKey;

@property (nonatomic, copy) NSString *pswdKey;

@property (nonatomic, copy) NSString *freshPswdKey;

@property (nonatomic, copy) NSString *oldPswdKey;

//获取验证码按钮设置
@property (nonatomic, copy) NSString *codeTitle;

@property (nonatomic, copy) NSString *codeOriginalTitle;

@property (nonatomic, assign) BOOL codeBtnEnable;

/**倒计时的格式 @"%zdS"*/
@property (nonatomic, copy) NSString *codeTitleFormatter;

@property (nonatomic, assign) NSInteger countDownCount;

- (void)cancelTiemr;


- (void)getcodeWithMethod:(NSString *)method response:(void(^)(BOOL isSuccess, id responseObj, NSString *msg))response;

- (void)loginWithMethod:(NSString *)method response:(void(^)(BOOL isSuccess, id responseObj, NSString *msg))response;

- (void)codeConfirmWithMethod:(NSString *)method response:(void(^)(BOOL isSuccess, id responseObj, NSString *msg))response;

- (void)changeWithMethod:(NSString *)method needToken:(BOOL)needToken response:(void(^)(BOOL isSuccess, id responseObj, NSString *msg))response;

///Path

@property (nonatomic, copy) NSString *loginUrl;

@property (nonatomic, copy) NSString *getCodeUrl;

/**验证码登录、注册、忘记密码 的path*/
@property (nonatomic, copy) NSString *codeConfirmUrl;

@property (nonatomic, copy) NSString *changeUrl;

/**是否国际化*/
@property (nonatomic, assign) BOOL isInternational;

/**密码至少几位 默认6*/
@property (nonatomic, assign) NSInteger pswdLengthLimit;

@property (nonatomic, assign) NSInteger codeLengthLimit;



///提示语
@property (nonatomic, copy) NSString *wrongPhoneNum;

@property (nonatomic, copy) NSString *noPhoneNum;

@property (nonatomic, copy) NSString *noCode;

@property (nonatomic, copy) NSString *noPswd;

@property (nonatomic, copy) NSString *pswdTooShort;

@property (nonatomic, copy) NSString *codeTooShort;

@property (nonatomic, copy) NSString *pswdDiff;

@property (nonatomic, copy) NSString *pswdSame;

@end
