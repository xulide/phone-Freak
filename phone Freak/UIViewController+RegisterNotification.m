//
//  UIViewController+RegisterNotification.m
//  phone Freak
//
//  Created by xulide on 15/10/11.
//  Copyright © 2015年 persist. All rights reserved.
//

#import "UIViewController+RegisterNotification.h"

@implementation UIViewController (RegisterNotification)
-(void)registerApplicationEnterBackgroundNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)unregisterApplicationEnterBackgroundNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
@end

