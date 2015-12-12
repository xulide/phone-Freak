//
//  CommanManagement.m
//  phone Freak
//
//  Created by xulide on 15/10/2.
//  Copyright © 2015年 persist. All rights reserved.
//

#import "CommanManagement.h"
#import "CreateCurrentDataViewCommand.h"



@implementation CommanManagement

//-(void)setCurrentDataViewCommand:(id<NavigatorCommandProtocol>)currentDataViewCommand
//{
//    if (!_currentDataViewCommand)
//    {
//        _currentDataViewCommand = currentDataViewCommand;
//    }
//    return ;
//}

-(void)createCurrentDataViewController:(NSArray *)paramInfo
{
    [_currentDataViewCommand executeCommand:paramInfo];
}

-(void)createMapViewController:(NSArray *)paramInfo
{
    [_mapViewCommand executeCommand:paramInfo];
}

+(CommanManagement*)shareInstance
{
    static dispatch_once_t once;
    static CommanManagement * commanManagementInstance = nil;
    dispatch_once(&once, ^{
        commanManagementInstance = [CommanManagement new];
    });
    return commanManagementInstance;
}

@end
