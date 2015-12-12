//
//  IdleState.m
//  phone Freak
//
//  Created by xulide on 15/9/4.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "IdleState.h"

@implementation IdleState
-(void)changeToIdle //idle->running or running->idle
{
    NSLog(@"**********call %@ %@ ",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
-(void)changeToRunning:(CLLocationCoordinate2D)coordinateInfo //running->running(location)   running(location)--->running
{
    NSLog(@"**********call %@ %@ ",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [self.stateContext setStartTimeAndCoordinate: coordinateInfo];
    self.stateContext.currentState = self.stateContext.runningState;
}
-(void)changeToMovement:(CLLocationCoordinate2D)coordinateInfo //running->running(location)   running(location)--->running
{
    NSLog(@"**********call %@ %@ ",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
@end
