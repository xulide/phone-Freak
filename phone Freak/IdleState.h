//
//  IdleState.h
//  phone Freak
//
//  Created by xulide on 15/9/4.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "ParentState.h"

@interface IdleState : ParentState
-(void)changeToIdle; //idle->running or running->idle
-(void)changeToRunning:(CLLocationCoordinate2D) coordinateInfo; //running->running(location)   running(location)--->running
-(void)changeToMovement:(CLLocationCoordinate2D) coordinateInfo; //running->running(location)   running(location)--->running
@end
