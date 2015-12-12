//
//  StateContext.m
//  phone Freak
//
//  Created by xulide on 15/9/4.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "StateContext.h"
#import "DateFormat.h"
#import "IdleState.h"
#import "InitialState.h"
#import "RunningState.h"
#import "MovementState.h"
#import "TimeAndCoordinateInfo.h"
#import "SharedTimeAndCoordinateInfo.h"

@interface StateContext()
@property (strong ,nonatomic)TimeAndCoordinateInfo *timeAndCoordinateInfo;
@property (strong ,nonatomic)TimeAndCoordinateInfo *timeAndCoordinateInfoBackup;
@end

@implementation StateContext


+(instancetype) shareInstance
{
    static dispatch_once_t once;
    static StateContext*  stateContext;
    dispatch_once(&once,^{stateContext = [StateContext new];});
    return stateContext;
}

-(id)init
{
    if (self = [super init])
    {
        _idleState = [[IdleState alloc]initWithStateContext:self];
        _runningState = [[RunningState alloc]initWithStateContext:self];
        _timeAndCoordinateInfo = [[TimeAndCoordinateInfo alloc]init];
        _timeAndCoordinateInfoBackup = [[TimeAndCoordinateInfo alloc]init];
        _currentState = _idleState;
    }
    
    return self;
}

-(void)changeToIdle //idle->running or running->idle
{
    [_currentState changeToIdle];
}

-(void)changeToRunning:(CLLocationCoordinate2D) coordinate //running->running(location)   running(location)--->running
{
    if ([_currentState isMemberOfClass:[_runningState class]])
    {
        [_currentState changeToMovement:coordinate];
    }
    else
    {
        [_currentState changeToRunning:coordinate];
    }
   
}
/*输入时间参数已经增加8小时时差计算，并且格式化成分钟的形式*/
-(void) setStartTimeAndCoordinate:(CLLocationCoordinate2D)coordinateInfo
{
    @autoreleasepool
    {
        DateFormat *dateFormat = [DateFormat new];
        NSDate * startTime = [dateFormat formatDateToMinute:[NSDate date]];
        _timeAndCoordinateInfo.startTime = startTime;
        _timeAndCoordinateInfo.latitude = coordinateInfo.latitude;
        _timeAndCoordinateInfo.longitude = coordinateInfo.longitude;
    }
    return;
}

/*输入时间参数已经增加8小时时差计算，并且格式化成分钟的形式*/
-(void) setEndTimeAndBackInfo
{
    @autoreleasepool
    {
        DateFormat *dateFormat = [DateFormat new];
        
        NSDate * endTime = [dateFormat formatDateToMinute:[NSDate date]];

        _timeAndCoordinateInfo.endTime = endTime;
        
        NSArray *dateArray = nil;
        
      
            dateArray = [dateFormat calculateDateToDifferentDate:_timeAndCoordinateInfo.startTime secondDate:_timeAndCoordinateInfo.endTime];
        

        NSDate *keyDate = [dateFormat formatDateToDay:_timeAndCoordinateInfo.startTime] ;
        
        NSString *keyDateStr = [dateFormat dateToValidStringDescription:keyDate];
        
        if(dateArray)
        {
            NSAssert(dateArray.count == 2, @"dateArray.count != 2");
            _timeAndCoordinateInfo.endTime = dateArray[0];
            _timeAndCoordinateInfoBackup.startTime = dateArray[1];
            _timeAndCoordinateInfoBackup.latitude = _timeAndCoordinateInfo.latitude;
            _timeAndCoordinateInfoBackup.longitude = _timeAndCoordinateInfo.longitude;
            _timeAndCoordinateInfoBackup.endTime = endTime;
            
            [[SharedTimeAndCoordinateInfo shareInstance]  insertTimeAndCoordinateInfo:keyDateStr TimeAndCoordinateInfo:_timeAndCoordinateInfo];
            
            /*插入第2个key时，时间key应该被更新*/
            keyDate = [dateFormat formatDateToDay:_timeAndCoordinateInfoBackup.startTime] ;
            
            keyDateStr = [dateFormat dateToValidStringDescription:keyDate];
            
            [[SharedTimeAndCoordinateInfo shareInstance]  insertTimeAndCoordinateInfo:keyDateStr TimeAndCoordinateInfo:_timeAndCoordinateInfoBackup];
        }
        else
        {
            [[SharedTimeAndCoordinateInfo shareInstance]  insertTimeAndCoordinateInfo:keyDateStr TimeAndCoordinateInfo:_timeAndCoordinateInfo];
        }
    }
    return;
}
@end
