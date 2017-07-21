//
//  ViewController.m
//  mail
//
//  Created by 朱斌 on 05/07/2017.
//  Copyright © 2017 朱斌. All rights reserved.
//

#import "ViewController.h"
#import "GHWEmailManager.h"
//#import "NSData+Base64Additions.h"

@interface ViewController (){
    GHWEmailManager * emmailManager;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)sendMail:(id)sender {
    NSArray * arr = @[@"1",@"2"];
    NSString *str = arr[3];
    return;
    
}

@end
