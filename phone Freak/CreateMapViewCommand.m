//
//  CreateMapViewCommand.m
//  phone Freak
//
//  Created by xulide on 15/10/8.
//  Copyright © 2015年 persist. All rights reserved.
//

#import "CreateMapViewCommand.h"
#import "CurrentDataViewController.h"
@implementation CreateMapViewCommand

@synthesize commandExecuteInstance;

//-(id)initWithCommandExecuteInstance:(id)commandExecuteInstanceParam
//{
//    if(self =[super init])
//    {
//        self.commandExecuteInstance = commandExecuteInstanceParam;
//    }
//    return self;
//}


-(void)executeCommand:(id)paramInfo
{
    if(paramInfo != nil)
    {
        [ (CurrentDataViewController*)(self.commandExecuteInstance) selectRightAction:(NSArray*)paramInfo];
    }
}
@end
