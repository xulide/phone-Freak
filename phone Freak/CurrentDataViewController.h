//
//  CurrentDataViewController.h
//  phone Freak
//
//  Created by xulide on 15/8/29.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentDataViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *currentTable;
-(id)initWithTitle:(NSString *)title;
-(void)changCurrentTimeInfoToformatInfo:(NSArray *)currentTimeInfoArray;
-(void)selectRightAction:(NSArray*)tableSourceArray;
@end
