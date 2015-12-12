//
//  CoreDataInfo.h
//  financing
//
//  Created by xulide on 15/6/20.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataInfo : NSObject
{
    NSString *storeType ;
    NSString *storeName ;
}
@property (nonatomic,readonly) NSManagedObjectModel* managedObjectModelInstance;
@property (nonatomic,readonly) NSManagedObjectContext* storeManagedObjectContextInstance;
@property (nonatomic,readonly) NSManagedObjectContext* mainManagedObjectContextInstance;
@property (nonatomic,readonly) NSManagedObjectContext* crudManagedObjectContextInstance;
@property (nonatomic,readonly) NSPersistentStoreCoordinator * persistentStoreCoordinatorInstance;
@property (nonatomic,readonly) NSPersistentStore  *storeInstance;

+(CoreDataInfo*)shareInstance;
-(BOOL) saveContext;
-(BOOL)saveToStore;
-(void)refreshPrivateManagedObjectContextToFault;
-(void)refreshAllManagedObjectContextToFault;
@end
