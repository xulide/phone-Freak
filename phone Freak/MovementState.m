//
//  MovementState.m
//  phone Freak
//
//  Created by xulide on 15/9/4.
//  Copyright (c) 2015年 persist. All rights reserved.
//

//#import "MovementState.h"
//
//@implementation MovementState
//-(void)changeToIdle//idle->running or running->idle
//{
//    [self.stateContext setEndTimeAndBackInfo];
//    self.stateContext.currentState = self.stateContext.idleState;
//}
//-(void)changeToRunning:(CLLocationCoordinate2D)coordinateInfo //running->running(location)   running(location)--->running
//{
//    NSLog(@"call %@ %@ error",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
//}
//-(void)changeToMovement:(CLLocationCoordinate2D)coordinateInfo //running->running(location)   running(location)--->running
//{
//    [self.stateContext setEndTimeAndBackInfo];
//    [self.stateContext setStartTimeAndCoordinate:coordinateInfo];
//    self.stateContext.currentState = self.stateContext.movementState;
//
//}
//@end
