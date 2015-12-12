//
//  StateContext.h
//  phone Freak
//
//  Created by xulide on 15/9/4.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
@class ParentState;

@interface StateContext : NSObject
@property (strong,nonatomic) ParentState* idleState;
//@property (strong,nonatomic) ParentState* initialState;
//@property (strong,nonatomic) ParentState* movementState;
@property (strong,nonatomic) ParentState* runningState;
@property (strong,nonatomic) ParentState* currentState;
+(instancetype) shareInstance;
-(void)changeToIdle ; //idle->running or running->idle
-(void)changeToRunning:(CLLocationCoordinate2D) coordinate; //running->running(location)   running(location)--->running
//-(void)changeToMovement:(CLLocationCoordinate2D) coordinate; //running->running(location)   running(location)--->running
-(void) setStartTimeAndCoordinate:(CLLocationCoordinate2D)coordinateInfo;
-(void) setEndTimeAndBackInfo;
@end
