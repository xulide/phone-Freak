//
//  CurrentTimeInfo+GetAllProperties.m
//  phone Freak
//
//  Created by xulide on 15/9/14.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "CurrentTimeInfo+GetAllProperties.h"
#import <objc/runtime.h>
//@implementation CurrentTimeInfo (GetAllProperties)
//- (NSArray *)getAllProperties
//{
//    u_int count;
//    objc_property_t *properties  =class_copyPropertyList([self class], &count);
//    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
//    for (int i = 0; i<count; i++)
//    {
//        const char* propertyName =property_getName(properties[i]);
//        if (strcmp("historyTimeInfo",propertyName))
//        {
//            [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
//        }
//    }
//    free(properties);
//    return [propertiesArray copy];
//}
//@end
