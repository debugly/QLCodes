//
//  QLVideoListController.m
//  QLDownLoadDemo
//
//  Created by xuqianlong on 15/7/24.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLVideoListController.h"
#import "QLVideoListCell.h"
#import "QLNetworkEngine.h"
#import "QLVideoListModel.h"
#import "AFURLSessionManager.h"
#import "AFURLRequestSerialization.h"

NSString *const QLVideoListCellIdentifier = @"QLVideoListCellIdentifier";

@interface QLVideoListController ()

@property (nonatomic, strong) NSMutableArray *movieArr;
@property (nonatomic, strong) QLNetworkEngine *listRequest;

@end

@implementation QLVideoListController

- (NSMutableArray *)movieArr
{
    if (!_movieArr) {
        _movieArr = [[NSMutableArray alloc]initWithCapacity:3];
    }
    return _movieArr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.movieArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QLVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:QLVideoListCellIdentifier forIndexPath:indexPath];
    cell.model = self.movieArr[indexPath.row];
    [cell setNeedsUpdateConstraints];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QLVideoListModel *model = self.movieArr[indexPath.row];
    if (model.downLoading) {
        
    }else{
      AFURLSessionManager *manager = [[AFURLSessionManager alloc]init];
      NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]requestWithMethod:@"post" URLString:model.video_url parameters:nil error:nil];
       NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
            path = [path stringByAppendingString:model.video_name];
           return [NSURL URLWithString:path];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"----%@",filePath);
        }];
        [task resume];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.tableView registerClass:[QLVideoListCell class] forCellReuseIdentifier:QLVideoListCellIdentifier];
    
    self.listRequest = [[QLNetworkEngine alloc]init];
    
    __weakSelf__
    [self.listRequest PostPath:@"/index/videoList" parems:nil ResultModelName:@"QLVideoListModel" SuccBlock:^(id models, id resultJson) {
        [weakSelf.movieArr removeAllObjects];
        [weakSelf.movieArr addObjectsFromArray:models];
        [weakSelf.tableView reloadData];
    } FailedBlock:^(NSError *error, id resultJson) {
        
    }];
}



@end
