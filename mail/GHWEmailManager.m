//
//  EmailManager.m
//  mail
//
//  Created by 朱斌 on 13/07/2017.
//  Copyright © 2017 朱斌. All rights reserved.
//

#import "GHWEmailManager.h"
#import "SKPSMTPMessage.h"

@interface GHWEmailManager ()<SKPSMTPMessageDelegate>{
    
}

@end

@implementation GHWEmailManager
static GHWEmailManager * emailManager;
static NSString * fromEmail = @"";
static NSString * password = @"";
static NSString * toEmail = @"";

+ (GHWEmailManager*)shareInstance{
    if (emailManager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            emailManager = [[GHWEmailManager alloc] init];
        });
    }
    
    return emailManager;
}

-(void)sendEmail:(NSString*)content{
    // 发送邮箱很重要 这里需要配置一下
    
    password = @"110000guohongwei";
    fromEmail = @"guohongwei719@126.com";
    toEmail = @"guohongwei719@126.com";
    
    
    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
    myMessage.delegate = self;
    //此处发件箱已126为例：
    myMessage.fromEmail = fromEmail;//发送者邮箱
    myMessage.toEmail = toEmail;//收件邮箱
    //myMessage.bccEmail = @"******@qq.com";//抄送
    
    //myMessage.relayHost = @"smtp.exmail.qq.com";//发送地址host 腾讯企业邮箱:smtp.exmail.qq.com
    
    
    
    myMessage.relayHost = @"smtp.126.com";
    myMessage.requiresAuth = YES;
    if (myMessage.requiresAuth) {
        myMessage.login = fromEmail;//发送者邮箱的用户名
        myMessage.pass = password;//发送者邮箱的密码
    }
    
    myMessage.wantsSecure = YES;//为gmail邮箱设置 smtp.gmail.com
    myMessage.subject = @"iOS崩溃日志";//邮件主题
    
    /* >>>>>>>>>>>>>>>>>>>> *   设置邮件内容   * <<<<<<<<<<<<<<<<<<<< */
    //1.文字信息
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain; charset=UTF-8",kSKPSMTPPartContentTypeKey, content,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    myMessage.parts = [NSArray arrayWithObjects:plainPart,nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [myMessage send];
    });
}

#pragma mark - SKPSMTPMessageDelegate
- (void)messageSent:(SKPSMTPMessage *)message
{
    NSLog(@"发送邮件成功");
}
- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    NSLog(@"message - %@\nerror - %@", message, error);
}

@end
