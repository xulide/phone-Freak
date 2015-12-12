//
//  CrudOperation.h
//  financing
//
//  Created by xulide on 15/6/25.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrudOperation : NSObject
-(BOOL)saveToStore;
+(id)shareInstance;
@end
