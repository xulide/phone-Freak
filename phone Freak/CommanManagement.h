//
//  CommanManagement.h
//  phone Freak
//
//  Created by xulide on 15/10/2.
//  Copyright © 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NavigatorCommandProtocol.h"
@class CommanManagement;
@interface CommanManagement : NSObject
+(CommanManagement*)shareInstance;
-(void)createCurrentDataViewController:(NSArray *)paramInfo;
-(void)createMapViewController:(NSArray *)paramInfo;
@property (strong,nonatomic) id<NavigatorCommandProtocol> currentDataViewCommand;
@property (strong,nonatomic) id<NavigatorCommandProtocol> mapViewCommand;
@end
