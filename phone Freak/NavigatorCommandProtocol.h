//
//  NavigatorCommandProtocol.h
//  phone Freak
//
//  Created by xulide on 15/10/1.
//  Copyright © 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NavigatorCommandProtocol <NSObject>
@required
@property (weak,nonatomic)id commandExecuteInstance;
-(void)executeCommand:(id)paramInfo;
@end
