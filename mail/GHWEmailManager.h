//
//  EmailManager.h
//  mail
//
//  Created by 朱斌 on 13/07/2017.
//  Copyright © 2017 朱斌. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHWEmailManager : NSObject{
}
+ (GHWEmailManager*)shareInstance;

-(void)sendEmail:(NSString*)content;

@end
