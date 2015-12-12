//
//  UIViewController+getCurrentVisibleController.m
//  phone Freak
//
//  Created by xulide on 15/9/22.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "UIViewController+getCurrentVisibleController.h"
#import <UIKit/UIKit.h>
@implementation UIViewController (getCurrentVisibleController)
-(UIViewController *)getCurrentVisibleController
{
    return ((UINavigationController *)([[UIApplication sharedApplication] keyWindow].rootViewController)).visibleViewController;
}

//-(UINavigationController *)getNavigationController
//{
//    return ((UINavigationController *)([[UIApplication sharedApplication] keyWindow].rootViewController));
//}
@end
