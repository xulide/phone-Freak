//
//  ParentState.m
//  phone Freak
//
//  Created by xulide on 15/9/4.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "ParentState.h"

@implementation ParentState

-(id)initWithStateContext: (StateContext*)stateContext
{
    if (self = [super init])
    {
        _stateContext = stateContext;
    }
    return self;
}
-(void)changeToIdle //idle->running or running->idle
{

}
-(void)changeToRunning:(CLLocationCoordinate2D)coordinateInfo //running->running(location)   running(location)--->running
{

}
-(void)changeToMovement:(CLLocationCoordinate2D)coordinateInfo //running->running(location)   running(location)--->running
{

}
@end
