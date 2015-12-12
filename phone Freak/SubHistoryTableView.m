//
//  SubHistoryTableView.m
//  phone Freak
//
//  Created by xulide on 15/9/17.
//  Copyright (c) 2015年 persist. All rights reserved.
//

#import "SubHistoryTableView.h"

@implementation SubHistoryTableView
{
    NSMutableArray *datas;
    NSMutableArray *needLoadArr;
    BOOL scrollToToping;
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        datas = [[NSMutableArray alloc] init];
        needLoadArr = [[NSMutableArray alloc] init];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
//- (void)drawRect:(CGRect)rect
//{
//    NSLog(@"drawRect drawRect drawRect drawRect");
//
//}

////按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    NSLog(@"scrollViewWillEndDragging  scrollViewWillEndDragging  scrollViewWillEndDragging");
//    NSIndexPath *ip = [self indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
//    NSIndexPath *cip = [[self indexPathsForVisibleRows] firstObject];
//    NSInteger skipCount = 8;
//    
//    if (labs(cip.row-ip.row)>skipCount)
//    {
//        NSArray *temp = [self indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y, self.frame.size.width, self.frame.size.width)];
//        NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
//        if (velocity.y<0)
//        {
//            NSIndexPath *indexPath = [temp lastObject];
//            if (indexPath.row+3<datas.count)
//            {
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:0]];
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+3 inSection:0]];
//            }
//        }
//        else
//        {
//            NSIndexPath *indexPath = [temp firstObject];
//            if (indexPath.row>3)
//            {
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-3 inSection:0]];
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-2 inSection:0]];
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
//            }
//        }
//        [needLoadArr addObjectsFromArray:arr];
//    }
//}
//
//- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
//    scrollToToping = YES;
//    return YES;
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
//    scrollToToping = NO;
////    [self loadContent];
//}
//
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
//    scrollToToping = NO;
////    [self loadContent];
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    [needLoadArr removeAllObjects];
//}
//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    if (!scrollToToping) {
//        [needLoadArr removeAllObjects];
////        [self loadContent];
//    }
//    return [super hitTest:point withEvent:event];
//}
@end
