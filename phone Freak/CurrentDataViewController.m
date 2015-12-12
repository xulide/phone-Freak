//
//  CurrentDataViewController.m
//  phone Freak
//
//  Created by xulide on 15/8/29.
//  Copyright (c) 2015年 persist. All rights reserved.
//
#import "CommanManagement.h"
#import "CreateMapViewCommand.h"
#import "CurrentDataViewController.h"
#import "CurrentMapViewController.h"
#import "CurrentTimeInfo.h"
#import "CurrentTimeInfoCache.h"
#import "UIViewController+getCurrentVisibleController.h"
#import "UIViewController+RegisterNotification.h"
@interface CurrentDataViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)NSMutableArray * tableSourceArray;
@end



@implementation CurrentDataViewController

-(id)initWithTitle:(NSString *)title
{
    NSLog(@"CurrentDataViewController init");
    if(self = [super init])
    {
        [self registerApplicationEnterBackgroundNotification];
        _tableSourceArray = [[NSMutableArray alloc]init];
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightButton =  [[UIBarButtonItem alloc] initWithTitle:@"xulide" style:UIBarButtonItemStylePlain target:self action:@selector(selectLocationAction)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.title = @"Location";
    
    self.currentTable.delegate = self;
    self.currentTable.dataSource = self;
    
    CreateMapViewCommand *createMapViewCommand = [CreateMapViewCommand new];
    createMapViewCommand.commandExecuteInstance = self;
    [CommanManagement shareInstance].mapViewCommand =createMapViewCommand;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear : animated];
    NSLog(@"CurrentDataViewController viewWillappear");
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear : animated];
    NSLog(@"CurrentDataViewController viewWillDisappear");
}

#pragma mark 点击行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool
    {
        CurrentTimeInfoCache *currentTimeInfoCache = [_tableSourceArray objectAtIndex:indexPath.row];
        [[CommanManagement shareInstance] createMapViewController:@[currentTimeInfoCache]];
    }
}

-(void)selectRightAction:(NSArray*)tableSourceArray
{
    CurrentMapViewController *currentMapViewController = [[CurrentMapViewController alloc] initWithData:[tableSourceArray copy] withTitle:@"Map Info"];
    [self.navigationController pushViewController:currentMapViewController animated:YES];
}

-(void)selectLocationAction
{
    @autoreleasepool
    {
        [[CommanManagement shareInstance] createMapViewController:[_tableSourceArray copy]];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"**********call %@ %@ start",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning];
    if (self != [self getCurrentVisibleController])
    {
        self.view = nil;
        self.tableSourceArray = nil;
    }
    NSLog(@"**********call %@ %@ end",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}


#pragma mark - DATASOURCE: UITableView

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

    NSInteger numberOfObjects = [self.tableSourceArray count] ;

    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier: CMainCell] ;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    CurrentTimeInfoCache *currentTimeInfoCache = _tableSourceArray[indexPath.row];
    
    cell.textLabel.text = currentTimeInfoCache.textLabel;
    cell.detailTextLabel.text = currentTimeInfoCache.detailTextLabel;
    return cell;
}

-(void)changCurrentTimeInfoToformatInfo:(NSArray *)currentTimeInfoArray
{
    if (!currentTimeInfoArray)
    {
        return;
    }
    
    [currentTimeInfoArray enumerateObjectsUsingBlock:^(CurrentTimeInfo* currentTimeInfo, NSUInteger idx, BOOL *stop) {
        CurrentTimeInfoCache * currentTimeInfoCache = [CurrentTimeInfoCache new];
        [currentTimeInfoCache currentTimeInfoToCurrentTimeInfoCache:currentTimeInfo];
        [_tableSourceArray addObject:currentTimeInfoCache];
        [self startArraySort:@"textLabel" isAscending: YES];
    }];
    
}

-(void)startArraySort:(NSString *)keystring isAscending:(BOOL)isAscending
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:keystring ascending:isAscending];

    self.tableSourceArray=[[NSMutableArray alloc]initWithArray:
                           [self.tableSourceArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]
                           
                          ];
}

-(void)enterBackgroundNotification
{
    NSLog(@"CurrentDataViewController Receive Application enterBackgroundNotification");
}

- (void)dealloc
{
    [self unregisterApplicationEnterBackgroundNotification];
    NSLog(@"CurrentDataViewController dealloc");
}
@end
