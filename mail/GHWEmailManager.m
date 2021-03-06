//
//  EmailManager.m
//  mail
//
//  Created by 朱斌 on 13/07/2017.
//  Copyright © 2017 朱斌. All rights reserved.
//

#import "GHWEmailManager.h"
#import "SKPSMTPMessage.h"
#import "GHWCrashHandler.h"

@interface GHWEmailManager ()<SKPSMTPMessageDelegate>

@property (nonatomic, copy) NSString *fromEmail;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *toEmail;
@property (nonatomic, copy) NSString *relayHost;

@end

@implementation GHWEmailManager

+ (GHWEmailManager*)shareInstance
{
    static dispatch_once_t onceToken;
    static GHWEmailManager * emailManager;
    dispatch_once(&onceToken, ^{
        emailManager = [[GHWEmailManager alloc] init];
    });
    return emailManager;
}

- (void)configWithFromEmail:(NSString *)fromEmail andPasswod:(NSString *)password andToEmail:(NSString *)toEmail andRelayHose:(NSString *)relayHost
{
    self.fromEmail = fromEmail;
    self.password = password;
    self.toEmail = toEmail;
    self.relayHost = relayHost;
}

-(void)sendEmail:(NSString*)content
{
    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
    myMessage.delegate = self;
    myMessage.fromEmail = self.fromEmail;//发送者邮箱
    myMessage.pass = self.password;//发送者邮箱的密码
    myMessage.login = self.fromEmail;//发送者邮箱的用户名
    myMessage.toEmail = self.toEmail;//收件邮箱
    //myMessage.bccEmail = @"******@qq.com";//抄送
    myMessage.relayHost = self.relayHost;
    myMessage.requiresAuth = YES;
    myMessage.wantsSecure = YES;//为gmail邮箱设置 smtp.gmail.com
    myMessage.subject = @"iOS崩溃日志";//邮件主题
    
    /* >>>>>>>>>>>>>>>>>>>> *   设置邮件内容   * <<<<<<<<<<<<<<<<<<<< */
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
    [[GHWCrashHandler sharedInstance] configDismissed];

}
- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    NSLog(@"message - %@\nerror - %@", message, error);
}

@end
