//
//  ParentState.h
//  phone Freak
//
//  Created by xulide on 15/9/4.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "StateContext.h"
@interface ParentState : NSObject
@property(strong,nonatomic) StateContext *stateContext;
-(void)changeToIdle; //idle->running or running->idle
-(void)changeToRunning:(CLLocationCoordinate2D)coordinateInfo; //running->running(location)   running(location)--->running
-(void)changeToMovement:(CLLocationCoordinate2D)coordinateInfo; //running->running(location)   running(location)--->running
-(id)initWithStateContext: (StateContext*)stateContext;
@end
