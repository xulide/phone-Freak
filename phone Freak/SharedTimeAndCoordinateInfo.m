//
//  SharedTimeAndCoordinateInfo.m
//  phone Freak
//
//  Created by xulide on 15/9/5.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "SharedTimeAndCoordinateInfo.h"
#import "TimeAndCoordinateInfo.h"
#import <libkern/OSAtomic.h>

static OSSpinLock spinlock = OS_SPINLOCK_INIT;

@implementation SharedTimeAndCoordinateInfo
+(instancetype) shareInstance
{
    static dispatch_once_t once;
    static SharedTimeAndCoordinateInfo*  sharedTimeAndCoordinateInfo;
    dispatch_once(&once,^{sharedTimeAndCoordinateInfo = [SharedTimeAndCoordinateInfo new];});
    return sharedTimeAndCoordinateInfo;
}

-(id)init
{
    if (self = [super init])
    {
        _timeAndCoordinateInfoDictionary = [[NSMutableDictionary alloc]init];
    }
    
    return self;
}

-(void) insertTimeAndCoordinateInfo:(NSString *)time TimeAndCoordinateInfo:(TimeAndCoordinateInfo *)timeAndCoordinateInfoInstance
{
    if (time && timeAndCoordinateInfoInstance)
    {
        /*时间相同不做处理，直接返回*/
        if ([timeAndCoordinateInfoInstance.startTime isEqualToDate:timeAndCoordinateInfoInstance.endTime])
        {
            return;
        }
        
        __block BOOL updateFlg = NO;
        
        NSDictionary *timeAndCoordinateInfoDictionary = @{@"startTime":timeAndCoordinateInfoInstance.startTime,
                                                          @"endTime":timeAndCoordinateInfoInstance.endTime,
                                                          @"latitude":[NSNumber numberWithDouble: timeAndCoordinateInfoInstance.latitude],
                                                          @"longitude":[NSNumber numberWithDouble: timeAndCoordinateInfoInstance.longitude]};
        
        OSSpinLockLock(&spinlock);
        {
            [_timeAndCoordinateInfoDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *obj, BOOL *stop) {
                if ([key isEqualToString:time])
                {
                    [obj addObject:timeAndCoordinateInfoDictionary];
                    updateFlg = YES;
                    *stop = YES;
                    
                }
            }];
            
            /*没有找到，直接插入*/
            if (!updateFlg)
            {
                NSMutableArray * mutableArray = [[NSMutableArray alloc]init];

                [mutableArray addObject:timeAndCoordinateInfoDictionary];

                if (!_timeAndCoordinateInfoDictionary)
                {
                    _timeAndCoordinateInfoDictionary = [[NSMutableDictionary alloc]init];
                }
                
                [_timeAndCoordinateInfoDictionary setObject:mutableArray forKey:time];
            }
        }
        OSSpinLockUnlock(&spinlock);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TimeAndCoordinateInfoUpdateNotification object:nil];
    }
}

-(NSMutableDictionary *) getTimeAndCoordinateInfo
{
    NSMutableDictionary * tempDictionary = nil;
    OSSpinLockLock(&spinlock);
    {
        tempDictionary = _timeAndCoordinateInfoDictionary;
        _timeAndCoordinateInfoDictionary = nil;
    }
    OSSpinLockUnlock(&spinlock);

    return tempDictionary;
}
@end
