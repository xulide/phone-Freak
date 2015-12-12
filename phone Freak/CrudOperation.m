//
//  CrudOperation.m
//  financing
//
//  Created by xulide on 15/6/25.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "CoreDataInfo.h"
#import "CrudOperation.h"
#import <UIKit/UIApplication.h>
#import <UIKit/UILocalNotification.h>
#import "SharedTimeAndCoordinateInfo.h"
#import "SharedTimeAndCoordinateInfo.h"
#import "HistoryTimeInfo.h"
#import "CurrentTimeInfo.h"
#import <libkern/OSAtomic.h>
typedef void (^TimeAndCoordinateInfoHandler)(void);

@interface CrudOperation()
@property (strong,nonatomic)CoreDataInfo * coreDataInfo;
@property (assign,atomic)BOOL isBackground;
@property (assign,atomic)BOOL hasUpdateData;
@property (nonatomic,strong) dispatch_queue_t  timeAndCoordinateInfoHandlerSerialQueue;
@property (nonatomic,strong) TimeAndCoordinateInfoHandler timeAndCoordinateInfoHandler;
@property (nonatomic,strong) SharedTimeAndCoordinateInfo * sharedTimeAndCoordinateInfoInstance;
@property (nonatomic,assign) OSSpinLock spinlock;

@end


@implementation CrudOperation

-(id)init
{
    if(self = [super init])
    {
        _spinlock = OS_SPINLOCK_INIT;
        _coreDataInfo = [CoreDataInfo shareInstance];
        _isBackground = NO;
        _hasUpdateData = NO;

        _sharedTimeAndCoordinateInfoInstance = [SharedTimeAndCoordinateInfo shareInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActiveNotification)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(enterBackgroundNotification)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
            
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleTimeAndCoordinateInfoUpdate)
                                                         name:TimeAndCoordinateInfoUpdateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        const char* serialQueueHandlerName = "serialQueueHandler";
        _timeAndCoordinateInfoHandlerSerialQueue = dispatch_queue_create(serialQueueHandlerName, DISPATCH_QUEUE_SERIAL);

    }
    return self;
}



+(id)shareInstance
{
    static CrudOperation *crudOperation ;
    static dispatch_once_t onceflag;
    dispatch_once(&onceflag, ^{
        crudOperation = [CrudOperation new];
    });
    return crudOperation;
}


+(void)initialize
{
    if(self == [CrudOperation class])
    {
        NSLog(@"CrudOperation initialize");
    }
}

-(void)enterBackgroundNotification
{
    NSLog(@"Application enterBackgroundNotification");
    _isBackground = YES;

}

-(void)becomeActiveNotification
{
    NSLog(@"Application becomeActiveNotification");
    _isBackground = NO;
    
    if (_hasUpdateData)
    {
        dispatch_async(_timeAndCoordinateInfoHandlerSerialQueue, self.timeAndCoordinateInfoHandler);
    }
}

-(void)handleTimeAndCoordinateInfoUpdate
{
    NSLog(@"handleTimeAndCoordinateInfoUpdate,  _isBackground=%d",_isBackground);
    if (_isBackground)
    {
        /*background*/
        _hasUpdateData = YES;
    }
    else
    {
        dispatch_async(_timeAndCoordinateInfoHandlerSerialQueue, self.timeAndCoordinateInfoHandler);
    }
}

-(void)handleMemoryWarning
{
    [[CoreDataInfo shareInstance] refreshPrivateManagedObjectContextToFault];
}

-(TimeAndCoordinateInfoHandler)timeAndCoordinateInfoHandler
{
    if (_timeAndCoordinateInfoHandler)
    {
        return _timeAndCoordinateInfoHandler;
    }
    else
    {
        __weak CrudOperation * crudOperationWeak = self;
        _timeAndCoordinateInfoHandler =
        ^{@autoreleasepool{
            NSLog(@"timeAndCoordinateInfoHandler start");
            
            CrudOperation * strongCrudOperation = crudOperationWeak;
            
            NSAssert(strongCrudOperation != nil, @"TimeAndCoordinateInfoHandler strongCrudOperation is nil");
            
            NSMutableDictionary *mutableDictionary = nil;
            mutableDictionary = [strongCrudOperation.sharedTimeAndCoordinateInfoInstance getTimeAndCoordinateInfo];
            
            [mutableDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSMutableArray* obj, BOOL *stop) {
                
                HistoryTimeInfo *historyTimeInfo = [self fetchFromManagedObjectContext:key];
                
                if (!historyTimeInfo)
                {
                    historyTimeInfo = [self insertHistoryTimeInfo:key];
                }
                
                if(historyTimeInfo)
                {
                    NSArray *currentTimeInfo = [self insertCurrentTimeInfo:obj];
                    if (currentTimeInfo)
                    {
                        BOOL updateResult = [self updateHistoryValueInstance:historyTimeInfo currentTimeInfos:currentTimeInfo];
                        if (updateResult)
                        {
                            NSLog(@"updateHistoryValueInstance success");
                        }
                        else
                        {
                            NSLog(@"updateHistoryValueInstance failed");
                        }
                    }
                    else
                    {
                        NSLog(@"insertCurrentTimeInfo failed");
                    }
                }
                else
                {
                    NSLog(@"insertHistoryTimeInfo failed");
                }
                
            }];
            
        NSLog(@"timeAndCoordinateInfoHandler end");
        }};
    }
    
    return _timeAndCoordinateInfoHandler;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TimeAndCoordinateInfoUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

}


//insertHistoryValue
-(HistoryTimeInfo *)insertHistoryTimeInfo:(NSString *)time
{
    if(!time)  return nil;
    
    __block BOOL saveContextResult = NO;;

    __block HistoryTimeInfo *insertHistoryTimeInfo = nil;
    
    OSSpinLockLock(&_spinlock);
    {
        [self.coreDataInfo.crudManagedObjectContextInstance performBlockAndWait: ^{
            insertHistoryTimeInfo = [NSEntityDescription insertNewObjectForEntityForName:[HistoryTimeInfo description] inManagedObjectContext:self.coreDataInfo.crudManagedObjectContextInstance];
            
            insertHistoryTimeInfo.time = time; /*需要进行字符串的裁剪，去掉多余的00:00:00*/
            insertHistoryTimeInfo.totalMinute = 0;
            saveContextResult = [self.coreDataInfo saveContext];
        }];
    }
    OSSpinLockUnlock(&_spinlock);
    
    if (!saveContextResult)
    {
        return nil;
    }
    
    return insertHistoryTimeInfo;
}

-(NSMutableArray *)insertCurrentTimeInfo :(NSMutableArray *)currentTimeInfoArray
{
    if(!currentTimeInfoArray)  return nil;
    
    __block BOOL saveContextResult = NO;;
    
    NSMutableArray *insertCurrentTimeInfoArray = [[NSMutableArray alloc]init];
    
    OSSpinLockLock(&_spinlock);
    {
        [self.coreDataInfo.crudManagedObjectContextInstance performBlockAndWait: ^{
            
            __block CurrentTimeInfo *insertCurrentTimeInfo = nil;
            
            [currentTimeInfoArray enumerateObjectsUsingBlock:^(NSDictionary *propertyDictionary, NSUInteger idx, BOOL *stop) {
                
                insertCurrentTimeInfo = [NSEntityDescription insertNewObjectForEntityForName:[CurrentTimeInfo description] inManagedObjectContext:self.coreDataInfo.crudManagedObjectContextInstance];
                
                [insertCurrentTimeInfo setValuesForKeysWithDictionary:propertyDictionary];
                
                NSLog(@"CurrentTimeInfo = %@",insertCurrentTimeInfo);
                
                [insertCurrentTimeInfoArray addObject:insertCurrentTimeInfo];

            }];
            
            saveContextResult = [self.coreDataInfo saveContext];
        }];
    }
    OSSpinLockUnlock(&_spinlock);
    
    if (!saveContextResult)
    {
        return nil;
    }
    
    return [insertCurrentTimeInfoArray copy];
}

-(BOOL)updateHistoryValueInstance: (HistoryTimeInfo *)historyTimeInfo currentTimeInfos:(NSArray *)currentTimeInfoArray
{
    if (!historyTimeInfo || !currentTimeInfoArray) return NO;
    
    __block BOOL saveContextResult ;
    
    __block NSInteger totalMinute = 0;
    
    OSSpinLockLock(&_spinlock);
    {
        [self.coreDataInfo.crudManagedObjectContextInstance performBlockAndWait: ^{
            [currentTimeInfoArray enumerateObjectsUsingBlock:^(CurrentTimeInfo* currentTimeInfo, NSUInteger idx, BOOL *stop) {
                currentTimeInfo.historyTimeInfo = historyTimeInfo;
                
                NSTimeInterval subTimeIntervalMinute = [currentTimeInfo.endTime timeIntervalSinceDate :currentTimeInfo.startTime ]/60; /*秒转换成分钟*/
                totalMinute += subTimeIntervalMinute;
            }];
            NSInteger totalMinuteExist = historyTimeInfo.totalMinute.integerValue;
            historyTimeInfo.totalMinute = [NSNumber numberWithInteger: totalMinute + totalMinuteExist];

            saveContextResult = [self.coreDataInfo saveContext];
        }];
    }
    OSSpinLockUnlock(&_spinlock);
    
    BOOL saveToStoreFlag = [self.coreDataInfo saveToStore];
    
    return (saveContextResult && saveToStoreFlag);
}

-(HistoryTimeInfo *)fetchFromManagedObjectContext:(NSString *)time
{
    if(!time)
    {
        NSLog(@"fetchFromManagedObjectContext parameter time is nil");
        return nil;
    }
    
    __block NSArray *fetchObjects = nil;
    
    __block NSError *error = nil;
    
    OSSpinLockLock(&_spinlock);
    {
        NSFetchRequest *request = [[NSFetchRequest alloc]init];
        
        [self.coreDataInfo.crudManagedObjectContextInstance performBlockAndWait: ^{
            
            request.entity = [NSEntityDescription entityForName:[HistoryTimeInfo description] inManagedObjectContext:self.coreDataInfo.crudManagedObjectContextInstance];
            request.predicate = [NSPredicate predicateWithFormat:@"time==%@",time];
            
            fetchObjects = [self.coreDataInfo.crudManagedObjectContextInstance executeFetchRequest:request error:&error];
        }];
        
        if(error)
        {
            NSLog(@"managedObjectContext executeFetchRequest fail %@",[error localizedDescription]);
           
        }

    }
    OSSpinLockUnlock(&_spinlock);
    
    NSAssert(fetchObjects.count <= 1, @"fetchFromManagedObjectContext  fetchObjects.count >1");
    
    if (fetchObjects.count != 0)
    {
        return fetchObjects[0];
    }
    else
    {
        return nil;
    }
}

-(BOOL)saveToStore
{
    return [self.coreDataInfo saveToStore];
}

@end