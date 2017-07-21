//
//  YDCrashHandler.m
//  MyPersonalLibrary
//  This file is part of source code lessons that are related to the book
//  Title: Professional IOS Programming
//  Publisher: John Wiley & Sons Inc
//  ISBN 978-1-118-66113-0
//  Author: Peter van de Put
//  Company: YourDeveloper Mobile Solutions
//  Contact the author: www.yourdeveloper.net | info@yourdeveloper.net
//  Copyright (c) 2013 with the author and publisher. All rights reserved.
//

#import "GHWCrashHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "GHWEmailManager.h"

NSString * const YDCrashHandlerSignalExceptionName = @"YDCrashHandlerSignalExceptionName";
NSString * const YDCrashHandlerSignalKey = @"YDCrashHandlerSignalKey";
NSString * const YDCrashHandlerAddressesKey = @"YDCrashHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation GHWCrashHandler
+ (GHWCrashHandler *)sharedInstance
{
    static GHWCrashHandler *crashHandler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        crashHandler = [[GHWCrashHandler alloc] init];
    });
    
    return crashHandler;
}

- (void)configDismissed
{
    dismissed = YES;
}


+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    dismissed = YES;
}


- (void)handleException:(NSException *)exception
{
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowDateString = [formatter stringFromDate:nowDate];
    
    NSString *strError = [NSString stringWithFormat:@"\n\n\n=============异常崩溃报告=============\n崩溃发生的时间:\n %@\n崩溃名称:\n%@\n崩溃原因:\n%@\n堆栈信息:\n%@" ,nowDateString,name,reason, arr];
    [[GHWEmailManager shareInstance] sendEmail:strError];
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed)
    {
        for (NSString *mode in (NSArray *)CFBridgingRelease(allModes))
        {
            CFRunLoopRunInMode((CFStringRef)CFBridgingRetain(mode), 0.001, false);
        }
    }
    CFRelease(allModes);
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:YDCrashHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:YDCrashHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }

}

@end


void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    NSArray *callStack = [GHWCrashHandler backtrace];
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:YDCrashHandlerAddressesKey];
    [[[GHWCrashHandler alloc] init] performSelectorOnMainThread:@selector(handleException:)
     
                                                     withObject:[NSException exceptionWithName:[exception name]
                                                                                        reason:[exception reason]
                                                                                      userInfo:userInfo]
                                                  waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:YDCrashHandlerSignalKey];
    NSArray *callStack = [GHWCrashHandler backtrace];
    [userInfo setObject:callStack forKey:YDCrashHandlerAddressesKey];
    [[[GHWCrashHandler alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                                     withObject:[NSException
                                                                 exceptionWithName:YDCrashHandlerSignalExceptionName
                                                                 reason:[NSString stringWithFormat:@"Signal %d was raised.", signal]
                                                                 userInfo:[NSDictionary
                                                                           dictionaryWithObject:[NSNumber numberWithInt:signal]
                                                                           forKey:YDCrashHandlerSignalKey]]
                                                  waitUntilDone:YES];
}
void InstallCrashExceptionHandler()
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}




