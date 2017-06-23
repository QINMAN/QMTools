//
//  RentExceptionGather.m
//  SouFun
//
//  Created by qinman on 2017/3/21.
//
//

#import "RentExceptionGather.h"
#import <objc/runtime.h>
#include <execinfo.h>

NSString * const kSignalExceptionName = @"kSignalExceptionName";
NSString * const kSignalKey = @"kSignalKey";

void UncaughtExceptionHandler(NSException *exception);
void SignalExceptionHandler(int signal);

NSString *appDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@implementation RentExceptionGather

static RentExceptionGather *instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:zone] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [RentExceptionGather setDefaultHandler];
    }
    return self;
}

+ (void)setDefaultHandler {
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    signal(SIGABRT, SignalExceptionHandler);
    
    signal(SIGILL, SignalExceptionHandler);
    
    signal(SIGSEGV, SignalExceptionHandler);
    
    signal(SIGFPE, SignalExceptionHandler);
    
    signal(SIGBUS, SignalExceptionHandler);
    
    signal(SIGPIPE, SignalExceptionHandler);
}

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)writeToLocal:(NSString *)info {
    NSString *path = [appDocumentsDirectory() stringByAppendingString:@"/error.txt"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        [manager createFileAtPath:path contents:nil attributes:nil];
        [info writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        [self writeFileWithThreadSafe:path info:info];
    }
}

- (void)writeFileWithThreadSafe:(NSString *)path info:(NSString *)info {
    dispatch_sync(dispatch_queue_create("mySerialQueue", NULL), ^{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    });
}

- (void)handleException:(NSException *)exception
{
    NSMutableString *errorStr = [NSMutableString string];
    
//    NSMutableDictionary *modelDic = [NSMutableDictionary dictionary];
    
    NSArray *arr = [exception callStackSymbols];
    if (!arr) {
        arr = [RentExceptionGather backtrace];
    }
    
//    [modelDic setSafeOBJC:[exception reason] forKey:@"LogContent"];
//    [modelDic setSafeOBJC:[arr componentsJoinedByString:@"\n"] forKey:@"CallStackSet"];
//    [modelDic setSafeOBJC:@"" forKey:@"ModuleName"];
    
    [errorStr appendString:[exception reason]];
    [errorStr appendString:[arr componentsJoinedByString:@"\n"]];
    [self writeToLocal:errorStr];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
        
    for (NSString *mode in (__bridge NSArray *)allModes) {
        CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);

    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:kSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:kSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

#pragma mark - UIAlertViewDelegate

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) {
//        
//    }
//}

@end

#pragma mark - 崩溃时的回调函数
void UncaughtExceptionHandler(NSException * exception) {
    [[RentExceptionGather sharedInstance] handleException:exception];
}

void SignalExceptionHandler(int signal)
{
    
    NSException *customException = [NSException exceptionWithName:kSignalExceptionName
                                                           reason:[NSString stringWithFormat:@"Signal %d was raised.", signal]
                                                         userInfo:@{kSignalKey:[NSNumber numberWithInt:signal]}];

    
    [[RentExceptionGather sharedInstance] handleException:customException];
}
