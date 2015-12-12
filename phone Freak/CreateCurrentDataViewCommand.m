//
//  CreateCurrentTimeInfoCommand.m
//  phone Freak
//
//  Created by xulide on 15/10/2.
//  Copyright © 2015年 persist. All rights reserved.
//

#import "CreateCurrentDataViewCommand.h"
#import "HistoryTableViewController.h"

@implementation CreateCurrentDataViewCommand
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
    [ (HistoryTableViewController*)(self.commandExecuteInstance) selectTableCellAction:(NSArray *)paramInfo];
}
@end
