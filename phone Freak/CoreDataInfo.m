//
//  CoreDataInfo.m
//  financing
//
//  Created by xulide on 15/6/20.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "CoreDataInfo.h"

@interface CoreDataInfo ()
- (void)createStoreManagedObjectContextInstance;
- (void)createMainManagedObjectContextInstance;
- (void)createCrudManagedObjectContextInstance;
- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                          error:(NSError **)error;
- (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL
   movingDestinationStoreAtURL:(NSURL *)destinationStoreURL
                         error:(NSError **)error;
- (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata;
- (NSURL *)storeURL;
- (NSString *)applicationDocumentsDirectory;
- (void)migrateStore;
- (NSDictionary *)getLoadStoreOptions;
@end

@implementation CoreDataInfo

-(id)init
{
    if(self = [super init])
    {
        storeType = NSSQLiteStoreType;
        storeName = @"phoneFreak.sqlite";
        [self setUp];
    }
    return self;
}


+(CoreDataInfo*)shareInstance
{
    static dispatch_once_t onceflag;
    static CoreDataInfo * coreDataInfo = nil;
    dispatch_once(&onceflag,^{
        coreDataInfo = [CoreDataInfo new];
    });
    return coreDataInfo;
}

- (NSManagedObjectModel *)createManagedObjectModel
{
    if (nil != _managedObjectModelInstance) {
        return _managedObjectModelInstance;
    }
    
    _managedObjectModelInstance = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModelInstance;
}

- (void)createStoreManagedObjectContextInstance
{
    if(nil == _storeManagedObjectContextInstance)
    {
        _storeManagedObjectContextInstance = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        /*createSaveManagedObjectContextInstance 在主线程中被调用*/
        [_storeManagedObjectContextInstance performBlockAndWait:
         ^{
             [_storeManagedObjectContextInstance setPersistentStoreCoordinator:_persistentStoreCoordinatorInstance];
             [_storeManagedObjectContextInstance setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
         }
         ];
    }
    

    
}

- (void)createMainManagedObjectContextInstance
{

    if(nil == _mainManagedObjectContextInstance)
    {
        _mainManagedObjectContextInstance = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainManagedObjectContextInstance setParentContext:_storeManagedObjectContextInstance];
        
        [_mainManagedObjectContextInstance setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
}



- (void)createCrudManagedObjectContextInstance
{
    if(nil == _crudManagedObjectContextInstance)
    {
        _crudManagedObjectContextInstance = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        /*createCrudManagedObjectContextInstance 在主线程中被调用*/
        [_crudManagedObjectContextInstance performBlockAndWait:
         ^{
             [_crudManagedObjectContextInstance setParentContext:_mainManagedObjectContextInstance];
             [_crudManagedObjectContextInstance setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
          }
        ];
        
    }
}

-(void)createManagedObjectContextInstanceOnMainThread
{
    if([NSThread isMainThread])
    {
        [self createStoreManagedObjectContextInstance];
        [self createMainManagedObjectContextInstance];
        [self createCrudManagedObjectContextInstance];
    }
    else
    {
        dispatch_sync
        (
         dispatch_get_main_queue(),
         ^{
            [self createStoreManagedObjectContextInstance];
            [self createMainManagedObjectContextInstance];
            [self createCrudManagedObjectContextInstance];
          }
        );
    }
}


- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator
{
    if (nil != _persistentStoreCoordinatorInstance)
    {
        return _persistentStoreCoordinatorInstance;
    }
    
    _persistentStoreCoordinatorInstance = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModelInstance];
   
    return _persistentStoreCoordinatorInstance;
}

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSURL *)storeURL
{    
    static NSURL *storeURL = nil;
    if (!storeURL) {
        storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:storeName]];
        NSLog(@"storeURL : %@\n", storeURL);
    }
    
    return  storeURL;
}

- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                          error:(NSError **)error
{
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                                                              URL:sourceStoreURL
                                                                                              error:error];
    if (!sourceMetadata) {
        return NO;
    }
    if ([finalModel isConfiguration:nil
        compatibleWithStoreMetadata:sourceMetadata]) {
        if (nil != error) {
            *error = nil;
        }
        return YES;
    }
    NSManagedObjectModel *sourceModel = [self sourceModelForSourceMetadata:sourceMetadata];
    NSManagedObjectModel *destinationModel = finalModel;

    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                                              forSourceModel:sourceModel
                                                                            destinationModel:destinationModel];

    NSURL *destinationStoreURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tempfinace.sqlite"]];
    
    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                                                 destinationModel:destinationModel];

    BOOL didMigrate = [manager migrateStoreFromURL:sourceStoreURL
                                         type:type
                                      options:nil
                             withMappingModel:mappingModel
                             toDestinationURL:destinationStoreURL
                              destinationType:type
                           destinationOptions:nil
                                        error:error];
    
    if (!didMigrate) {
        return NO;
    }
    // Migration was successful, move the files around to preserve the source in case things go bad
    if (![self backupSourceStoreAtURL:sourceStoreURL
          movingDestinationStoreAtURL:destinationStoreURL
                                error:error]) {
        return NO;
    }
    
    return YES;
}


- (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata
{
    return [NSManagedObjectModel mergedModelFromBundles:nil
                                       forStoreMetadata:sourceMetadata];
}

- (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL
   movingDestinationStoreAtURL:(NSURL *)destinationStoreURL
                         error:(NSError **)error
{
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *backupPath = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:sourceStoreURL.path
                              toPath:backupPath
                               error:error]) {
        //Failed to copy the file
        return NO;
    }
    //Move the destination to the source path
    if (![fileManager moveItemAtPath:destinationStoreURL.path
                              toPath:sourceStoreURL.path
                               error:error]) {
        //Try to back out the source move first, no point in checking it for errors
        [fileManager moveItemAtPath:backupPath
                             toPath:sourceStoreURL.path
                              error:nil];
        return NO;
    }
    return YES;
}

-(void)migrateStore
{
    NSError *migrateError = NULL;
    BOOL migrate = [self progressivelyMigrateURL:[self storeURL]
                                          ofType:storeType
                                         toModel:_managedObjectModelInstance
                                           error:&migrateError];
    if (!migrate)
    {
        NSLog(@"Error : %@\n", [migrateError localizedDescription]);
        NSAssert1(YES, @"Failed to migrate  source path = %@ with NSSQLiteStoreType", [[self storeURL] path]);
    }
}

-(void)loadStore
{
    [self migrateStore];
    
    if (_storeInstance)
    {
        NSLog(@"_storeInstance is exist\n");
        return;
    }
    
    NSError *error = NULL;
    NSDictionary *options = [self getLoadStoreOptions];
    
    _storeInstance = [_persistentStoreCoordinatorInstance addPersistentStoreWithType:storeType configuration:nil URL:[self storeURL] options:options error:&error];
    if (!_storeInstance)
    {
        NSLog(@"Error : %@\n", [error localizedDescription]);
        NSAssert1(YES, @"Failed to create store %@ with NSSQLiteStoreType", [[self storeURL] path]);
    }
}

-(NSDictionary *)getLoadStoreOptions
{
    NSDictionary *options =
    @{
          NSMigratePersistentStoresAutomaticallyOption : @YES,
          
          NSInferMappingModelAutomaticallyOption: @NO,
          
          NSSQLitePragmasOption: @{@"journal_mode":@"DELETE"}
     };
    
    return options;
}

-(void)setUp
{
    [self createManagedObjectModel];
    [self createPersistentStoreCoordinator];
    [self loadStore];
    [self createManagedObjectContextInstanceOnMainThread];
}

-(BOOL)saveToMainContext
{
    __block BOOL saveToMainContextResult = YES;
    
    [self.crudManagedObjectContextInstance performBlockAndWait:^{
    
        if([self.crudManagedObjectContextInstance hasChanges])
        {
            NSError  *error = nil;
            if([self.crudManagedObjectContextInstance save: &error])
            {
                NSLog(@ "crudManagedObjectContextInstance saved changes to mainManagedObjectContext");
            }
            else
            {
                NSLog(@ "Failed to save changes to persistent store %@",error);
                saveToMainContextResult = NO;
            }
        }
        else
        {
            NSLog(@ "Skip context save");
        }
      }
    ];
    
    return saveToMainContextResult;
}

-(BOOL)saveToStoreContext
{
    __block BOOL saveToStoreContextResult = YES;
    
    [self.mainManagedObjectContextInstance performBlockAndWait:^{

        if([self.mainManagedObjectContextInstance hasChanges])
        {
            NSError  *error = nil;
            if([self.mainManagedObjectContextInstance save: &error])
            {
                NSLog(@ "mainManagedObjectContextInstance saved changes to storeManagedObjectContext");
            }
            else
            {
                NSLog(@ "Failed to save changes to persistent store %@",error);
                saveToStoreContextResult = NO;
            }
        }
        else
        {
            NSLog(@ "Skip context save");
        }
      }
     ];
    
    return saveToStoreContextResult;
}

/*保证save main crud三个 上 下文内容一致 */
-(BOOL) saveContext
{
    if ([self saveToMainContext] && [self saveToStoreContext])
    {
        return YES;
    }
    
    return NO;
}

/*异步操作 保存到数据库中*/
-(BOOL)saveToStore
{
    __block BOOL saveToStoreResult = YES;
    [self.storeManagedObjectContextInstance performBlock:^{
    
        if([self.storeManagedObjectContextInstance hasChanges])
        {
            NSError  *error = nil;
            if([self.storeManagedObjectContextInstance save: &error])
            {
                NSLog(@ "managedContect saved changes to persistent store");
            }
            else
            {
                NSLog(@ "Failed to save changes to persistent store %@",error);
                saveToStoreResult = NO;
            }
        }
        else
        {
            NSLog(@ "Skip context save");
        }
    }];
    
    return saveToStoreResult;
}

-(void)refreshPrivateManagedObjectContextToFault
{
       [self.crudManagedObjectContextInstance performBlock:^{
        for (NSManagedObject *obj in [self.crudManagedObjectContextInstance registeredObjects]) {
            
            [self.crudManagedObjectContextInstance refreshObject:obj mergeChanges:NO];
        }
        
    }];
}

-(void)refreshAllManagedObjectContextToFault
{
    NSLog(@"**********call %@ %@ start",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [self saveToStore];
    
    NSArray *managedObjectContextStack = @[self.crudManagedObjectContextInstance,
                                           self.mainManagedObjectContextInstance,
                                           self.storeManagedObjectContextInstance];
    
    
    [managedObjectContextStack enumerateObjectsUsingBlock:^(NSManagedObjectContext*managedObjectContext , NSUInteger idx, BOOL *stop){
        [managedObjectContext performBlock:^{
            for (NSManagedObject *obj in [managedObjectContext registeredObjects])
            {
                [managedObjectContext refreshObject:obj mergeChanges:NO];
            }
            
        }];
    }];
    NSLog(@"**********call %@ %@ end",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
