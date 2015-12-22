//
//  AppDelegate.m
//  phone Freak
//
//  Created by xulide on 15/8/29.
//  Copyright (c) 2015年 persist. All rights reserved.
//
#import "CurrentMapViewController.h"
#import "CrudOperation.h"
#import "LocationMagager.h"
#import "HistoryTableViewController.h"
#import "AppDelegate.h"
#include <CoreFoundation/CFNotificationCenter.h>
#import <notify.h>
#import "CurrentDataViewController.h"
#import <libkern/OSAtomic.h>


//static OSSpinLock spinlock = OS_SPINLOCK_INIT;

@interface AppDelegate ()
@property (strong, nonatomic) NSTimer *myTimer;
//@property (atomic,assign)UIBackgroundTaskIdentifier bgTask;
//@property (strong, nonatomic) dispatch_block_t expirationHandler;
//@property (strong, nonatomic) dispatch_queue_t serialQueue;
@property (strong, nonatomic) dispatch_queue_t serialUpdateLocationQueue;
@property (strong, nonatomic) dispatch_source_t timer;
@property (strong,nonatomic) UINavigationController *navigationController;
@property (strong,nonatomic) CrudOperation *crudOperation;
@property (strong,nonatomic) LocationMagager *locationMagager;
@property (atomic,assign) BOOL isBackground; /*是否运行在后台模式*/

@end



@implementation AppDelegate

-(void)startLocationWithHeart
{
    [self.locationMagager startLocationWithHeart];
}

-(void)startTimer
{
    [self stopTimer];
    _myTimer = [NSTimer timerWithTimeInterval:900 target:self selector:@selector(startLocationWithHeart) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop]addTimer:_myTimer forMode:NSRunLoopCommonModes];
    
    return;
}

-(void)stopTimer
{
    if (_myTimer)
    {
        [_myTimer invalidate];
        _myTimer = nil;
    }
}

-(void)registerMonitorLockstate
{
    __block uint64_t locked;
    
    __block int token = 0;
    
    __weak AppDelegate * weakSelf = self;
    
    notify_register_dispatch("com.apple.springboard.lockstate",&token,dispatch_queue_create("com.apple.springboard.lockstate.serialqueue", NULL),^(int t){
        
        @autoreleasepool
        {
            notify_get_state(token, &locked);
            
            AppDelegate * strongSelf = weakSelf;
            
            NSAssert(strongSelf != nil, @"registerMonitorLockstate strongSelf is nil");
            
            strongSelf.systemStatus = (SystemStatus)locked;
            
            NSLog(@"backGround = %d strongSelf.systemStatus = %u",strongSelf.isBackground,(short)(strongSelf.systemStatus));
            
            strongSelf.locationTask();
        }
        
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    UIDevice *device = [UIDevice currentDevice];
//    if (![[device model] isEqualToString:@"iPad Simulator"]) {
//        // 开始保存日志文件
//        [self redirectNSlogToDocumentFolder];
//    }
    
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    HistoryTableViewController *historyTableViewController = [[HistoryTableViewController alloc] init];
    historyTableViewController.title = @"History Info";
    
    self.navigationController = [[UINavigationController alloc] init];
    [self.navigationController pushViewController:historyTableViewController animated:YES];
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];

    _crudOperation = [CrudOperation shareInstance] ;
    _previousSystemStatus = lockStatus;
    
    _locationMagager = [LocationMagager shareInstance];
    
    _serialUpdateLocationQueue = dispatch_queue_create("SERIAL UPDATE LOCATION", NULL);
    
    [self registerMonitorLockstate];

    self.locationTask();
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    self.isBackground = YES;
    @autoreleasepool
    {
        for (UIViewController *viewController in [[self.navigationController.viewControllers reverseObjectEnumerator]allObjects])
        {
            if (![viewController isMemberOfClass:[HistoryTableViewController class]])
            {
                NSLog(@"Delete viewController = %@",viewController);
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
    [self startTimer];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    self.isBackground = NO;
    self.systemStatus = RunningStatus;
    [self stopTimer];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate end");
    [_crudOperation saveToStore];
}


-(LocationTask)locationTask
{
    if (!_locationTask)
    {
        __weak AppDelegate * weakSelf = self;
        
        _locationTask = ^{
            
            @autoreleasepool
            {
                AppDelegate * strongSelf = weakSelf;
                NSAssert(strongSelf != nil, @"locationTask strongSelf is nil");
                dispatch_async(strongSelf.serialUpdateLocationQueue, ^{

                    if (RunningStatus == strongSelf.systemStatus )
                    {
                        NSLog(@"locationMagager startLocation NSThread = %@",[NSThread currentThread]);
                       [strongSelf.locationMagager startLocation];
                    }
                    else
                    {
                        NSLog(@"locationMagager stopLocation NSThread = %@",[NSThread currentThread]);
                       [strongSelf.locationMagager stopLocation];
                    }
                });
            }
        };
    }
    return  _locationTask;
}


//-(LocationTask)timerTask
//{
//    if (!_timerTask)
//    {
//        __weak AppDelegate * weakSelf = self;
//        
//        _timerTask = ^{
//            
//            NSLog(@"<<<<<<<<<<<<<<<<Background Timer>>>>>>>>>>>>>>>>>>");
//            
//            @autoreleasepool
//            {
//                AppDelegate * strongSelf = weakSelf;
//                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
//    
//                dispatch_after(time,strongSelf.serialUpdateLocationQueue,^{
//                    
//                    if (strongSelf.isBackground)
//                    {
//                        NSLog(@"<<<<<<<<<<<<<<<<Background Timer>>>>>>>>>>>>>>>>>>");
//                        
//                        [strongSelf.locationMagager startLocationWithHeart];
//                        
//                        strongSelf.timerTask();
//                    }
//                });
//            }
//        };
//    }
//    return  _locationTask;
//}


- (void)redirectNSlogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"dr.log"];// 注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

@end
