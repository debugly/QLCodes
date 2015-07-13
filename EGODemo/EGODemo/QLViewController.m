//
//  QLViewController.m
//  EGODemo
//
//  Created by xuqianlong on 14-10-13.
//  Copyright (c) 2014年 xuqianlong. All rights reserved.
//

#import "QLViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface QLViewController ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>

@property (nonatomic, retain)UITableView *tableView;
@property (nonatomic, retain)NSMutableArray *dataSource;
@property (nonatomic, retain)EGORefreshTableHeaderView *egoRefreshView;
@property (nonatomic, assign)BOOL isLoading;


@end

@implementation QLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataSource = [[NSMutableArray alloc]initWithCapacity:10];
    [self requestData];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.egoRefreshView];
    [self.egoRefreshView refreshLastUpdatedDate];
}

- (void)requestData
{
    [self.dataSource removeAllObjects];
    for (int i = 0 ; i < 5; i++) {
        UIColor *color = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
        [self.dataSource addObject:color];
    }
}

- (EGORefreshTableHeaderView *)egoRefreshView
{
    if (!_egoRefreshView) {
        CGFloat height = self.tableView.frame.size.height;
        _egoRefreshView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, -height, 320, height)];
        _egoRefreshView.delegate = self;
    }
    return _egoRefreshView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    
    cell.contentView.backgroundColor = self.dataSource[indexPath.row];
    cell.textLabel.text = [[NSDate date]description];
    return cell;
}



#pragma mark - - EGO代理

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;
{
    NSLog(@"-----TableHeaderDidTrigger2Refresh");
    [self refreshDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return self.isLoading;
}

#pragma mark - - 返回刷新时间

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - -下拉刷新

- (void)refreshDataSource
{
    self.isLoading = YES;
    //网络请求；
    [self requestData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doneLoadingTableviewData];
    });
}
#pragma mark - -下拉刷新完成
- (void)doneLoadingTableviewData
{
    self.isLoading = NO;
    [self.egoRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}


#pragma mark - - 这个是必须的

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[self.egoRefreshView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[self.egoRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

@end
