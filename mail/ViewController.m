//
//  ViewController.m
//  mail
//
//  Created by 朱斌 on 05/07/2017.
//  Copyright © 2017 朱斌. All rights reserved.
//

#import "ViewController.h"
#import "GHWEmailManager.h"

@interface ViewController (){
    GHWEmailManager * emmailManager;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 这里需要配置好发件箱，126的都很好用，这里要替换为你自己的
    [[GHWEmailManager shareInstance] configWithFromEmail:@"guohongwei719@126.com"
                                              andPasswod:@"*******"
                                              andToEmail:@"guohongwei719@126.com"
                                            andRelayHose:@"smtp.126.com"];
}

- (IBAction)sendMail:(id)sender
{
    // 故意制造一个crash
    
    NSArray * arr = @[@"1",@"2"];
    NSString *str = arr[3];
    return;
    
}

@end
