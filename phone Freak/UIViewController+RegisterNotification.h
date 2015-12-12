//
//  UIViewController+RegisterNotification.h
//  phone Freak
//
//  Created by xulide on 15/10/11.
//  Copyright © 2015年 persist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (RegisterNotification)
-(void)registerApplicationEnterBackgroundNotification;
-(void)unregisterApplicationEnterBackgroundNotification;
@end
