//
//  HistoryTableViewController.m
//  phone Freak
//
//  Created by xulide on 15/8/29.
//  Copyright (c) 2015年 persist. All rights reserved.
//
#import "CreateCurrentDataViewCommand.h"
#import "CommanManagement.h"
#import "HistoryTableViewController.h"
#import "CurrentDataViewController.h"
#import "CoreDataInfo.h"
#import "HistoryTimeInfo.h"
#import "CurrentTimeInfo.h"
#import "UIViewController+RegisterNotification.h"

#import "UIViewController+getCurrentVisibleController.h"
#import <CoreData/CoreData.h>

@interface HistoryTableViewController () <NSFetchedResultsControllerDelegate>
@property (strong,nonatomic) NSFetchedResultsController * fetchedResultsController;
@property (strong,nonatomic) CoreDataInfo * coreDataInfo;
@property (strong,nonatomic) NSString *sortDescriptor;
@property (strong, nonatomic) NSValue *targetRect;
@end

@implementation HistoryTableViewController

-(id)init
{
    if(self = [super init])
    {
        [self registerApplicationEnterBackgroundNotification];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.coreDataInfo = [CoreDataInfo shareInstance];
    self.sortDescriptor =@"time";
    [self performFetch];
    CreateCurrentDataViewCommand *createCurrentDataViewCommand = [CreateCurrentDataViewCommand new];
    createCurrentDataViewCommand.commandExecuteInstance = self;
    
    [CommanManagement shareInstance].currentDataViewCommand =createCurrentDataViewCommand;
}

-(void)selectTableCellAction:(NSArray *)currentTimeInfoArray
{
    if (!currentTimeInfoArray)
    {
        NSLog(@"selectTableCellAction failed");
        return;
    }
    @autoreleasepool
    {
        CurrentDataViewController *currentDataViewController = [[CurrentDataViewController alloc] initWithTitle:@"Current Info"];
        [currentDataViewController changCurrentTimeInfoToformatInfo:currentTimeInfoArray];
        
        [self.navigationController pushViewController:currentDataViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"**********call %@ %@ start",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning];
    if (self != [self getCurrentVisibleController])
    {
        [self.coreDataInfo refreshAllManagedObjectContextToFault];
        self.view = nil;
        self.coreDataInfo = nil;
        self.sortDescriptor =nil;
        self.targetRect = nil;
        self.fetchedResultsController = nil;
    }
    else
    {
        [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(HistoryTimeInfo *historyTimeInfo , NSUInteger idx, BOOL *stop) {
            
            [historyTimeInfo.currentTimeInfo enumerateObjectsUsingBlock:^(CurrentTimeInfo *currentTimeInfo, BOOL *stop) {
                [self.fetchedResultsController.managedObjectContext refreshObject:currentTimeInfo mergeChanges:NO];
            }];
            
        }];
    }
    NSLog(@"**********call %@ %@ end",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}


#pragma mark - DATASOURCE: UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [[self.fetchedResultsController sections] count];
//    NSLog(@"numberOfSectionsInTableView = %lu",(unsigned long)count);
    return count;

}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"numberOfRowsInSection");

    NSInteger numberOfObjects = [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
//     NSLog(@"numberOfRowsInSection = %ld",(long)numberOfObjects);
    return numberOfObjects;
}


- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {

    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

#pragma mark - DELEGATE: NSFetchedResultsController
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
   
    [self.tableView beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
   
    [self.tableView endUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            if (!newIndexPath) {
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier: CMainCell] ;
    }
    
    [self setupCell:cell withIndexPath:indexPath ];

    return cell;
    
}


#pragma mark 点击行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryTimeInfo *historyTimeInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];

   [[CommanManagement shareInstance] createCurrentDataViewController:[historyTimeInfo.currentTimeInfo allObjects]];
}

-(NSString *)propertyToString:(HistoryTimeInfo *)historyTimeInfo
{
    if (!historyTimeInfo)
    {
        return  nil;
    }
    
    NSString * strTitle = nil;
    
    strTitle = [NSString stringWithFormat:@"%@  %ldmin",historyTimeInfo.time, (long)historyTimeInfo.totalMinute.integerValue];
    return strTitle;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil != _fetchedResultsController)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[HistoryTimeInfo description] inManagedObjectContext:self.coreDataInfo.mainManagedObjectContextInstance];
    [fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:self.sortDescriptor ascending:YES];
    
    NSMutableArray *sortDescriptorArray = [NSMutableArray arrayWithObject:sortDescriptor];
    
    [fetchRequest setSortDescriptors: sortDescriptorArray];
 
    fetchRequest.returnsObjectsAsFaults=NO;
    [fetchRequest setFetchBatchSize:40];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataInfo.mainManagedObjectContextInstance sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)performFetch {
    
    NSLog(@"performFetch begin");
    
    if (self.fetchedResultsController) {
        [self.fetchedResultsController.managedObjectContext performBlockAndWait:^{
            
            NSError *error = nil;
            if (![self.fetchedResultsController performFetch:&error]) {
                
                NSLog(@"Failed to perform fetch: %@", error);
            }
        }];
    } else {
        NSLog(@"Failed to fetch, the fetched results controller is nil.");
    }
    
    NSLog(@"performFetch end");
    
}

- (void)setupCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    CGRect cellFrame = [self.tableView rectForRowAtIndexPath:indexPath];

    if (self.targetRect && !CGRectIntersectsRect([self.targetRect CGRectValue], cellFrame))
    {
        /*不需要绘制*/
        return;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *title = [self propertyToString: object];
    
    cell.textLabel.text = title;
}

- (void)loadImageForVisibleCells
{
    NSArray *cells = [self.tableView visibleCells];
    for (UITableViewCell *cell in cells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self setupCell:cell withIndexPath:indexPath];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.targetRect = nil;
    [self loadImageForVisibleCells];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGRect targetRect = CGRectMake(targetContentOffset->x, targetContentOffset->y, scrollView.frame.size.width, scrollView.frame.size.height);
    self.targetRect = [NSValue valueWithCGRect:targetRect];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.targetRect = nil;
    [self loadImageForVisibleCells];
}

-(void)enterBackgroundNotification
{
    NSLog(@"HistoryTableViewController Receive Application enterBackgroundNotification");
    
    [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(HistoryTimeInfo *historyTimeInfo , NSUInteger idx, BOOL *stop) {
        
        [historyTimeInfo.currentTimeInfo enumerateObjectsUsingBlock:^(CurrentTimeInfo *currentTimeInfo, BOOL *stop) {
            [self.fetchedResultsController.managedObjectContext refreshObject:currentTimeInfo mergeChanges:NO];
        }];
        
    }];
    
    [self.coreDataInfo refreshAllManagedObjectContextToFault];
}

- (void)dealloc
{
    [self unregisterApplicationEnterBackgroundNotification];
    NSLog(@"HistoryTableViewController dealloc");
}
@end
