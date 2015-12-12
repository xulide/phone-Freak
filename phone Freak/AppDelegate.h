//
//  AppDelegate.h
//  phone Freak
//
//  Created by xulide on 15/8/29.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "constDefine.h"

typedef void (^LocationTask)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic)dispatch_semaphore_t signal;
@property (nonatomic,strong) LocationTask locationTask;
@property (nonatomic,strong) LocationTask timerTask;
@property (atomic,assign) SystemStatus systemStatus;
@property (atomic,assign) SystemStatus previousSystemStatus;
@end

