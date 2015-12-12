//
//  RunningState.m
//  phone Freak
//
//  Created by xulide on 15/9/4.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "RunningState.h"
#import "DateFormat.h"
@implementation RunningState
-(void)changeToIdle // running->idle
{
    NSLog(@"**********call %@ %@ ",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [self.stateContext setEndTimeAndBackInfo];
    self.stateContext.currentState = self.stateContext.idleState;
}
-(void)changeToRunning:(CLLocationCoordinate2D)coordinateInfo //running->running(location)   running(location)--->running
{
    NSLog(@"**********call %@ %@ ",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
-(void)changeToMovement:(CLLocationCoordinate2D)coordinateInfo //running->running(location)   running(location)--->running
{
    NSLog(@"**********call %@ %@ ",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [self.stateContext setEndTimeAndBackInfo];
    [self.stateContext setStartTimeAndCoordinate:coordinateInfo];
}
@end
