//
//  QLVideoListController.m
//  QLDownLoadDemo
//
//  Created by xuqianlong on 15/7/24.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

//限制网速；
//http://blog.imwangwei.cn/?p=130

#import "QLVideoListController.h"
#import "QLVideoListCell.h"
#import "QLNetworkEngine.h"
#import "QLVideoListModel.h"
#import "AFURLSessionManager.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "AFHTTPRequestOperationManager.h"

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
    QLVideoListCell *cell = (QLVideoListCell *)[tableView cellForRowAtIndexPath:indexPath];
    AFHTTPRequestOperation *op = cell.op;
    if (!op) {
        op = [[AFHTTPRequestOperationManager manager]POST:[model.video_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"--success--");
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"--failure--%@",[error localizedDescription]);
        }];
        op.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *download = [documents stringByAppendingPathComponent:@"download"];
        NSString *fileName = [model.video_url lastPathComponent];
        NSString *filePath = [download stringByAppendingPathComponent:fileName];
        
        op.downloadDestinationPath = filePath;
        cell.op = op;
    }else if(op.isPaused){
        [op resume];
//      AFURLSessionManager *manager = [[AFURLSessionManager alloc]init];
//      NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]requestWithMethod:@"post" URLString:[model.video_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil error:nil];
//       NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//            NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
//            path = [path stringByAppendingString:model.video_name];
//           return [NSURL fileURLWithPath:path];
//        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//            NSLog(@"----%@",response);
//            NSLog(@"----%@",filePath);
//           
//        }];
//        [task resume];

        
//        op.responseSerializer = [AFImageResponseSerializer serializer];
        
//        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
////            NSLog(@"-c:%.2fKb;a:%.2fKb;t:%.2fMb",bytesRead/1024.0,totalBytesRead/1024.0,totalBytesExpectedToRead/1024.0/1024.0);
//            float progress = 1.0*totalBytesRead/totalBytesExpectedToRead;
//            NSLog(@"-p:%.2f",progress);
//        }];
    }else if (!op.isPaused){
        [op pause];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.tableView registerClass:[QLVideoListCell class] forCellReuseIdentifier:QLVideoListCellIdentifier];
    [self refreshList];
}

- (IBAction)refreshListAction:(id)sender {
    [self refreshList];
}

- (void)refreshList
{
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *download = [documents stringByAppendingPathComponent:@"download"];
    NSError *error = nil;
    if (![[NSFileManager defaultManager]fileExistsAtPath:download]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:download withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSArray *itmes = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:download error:&error];
    for (NSString *item in itmes) {
        NSString *itemPath = [documents stringByAppendingPathComponent:item];
        if ([[NSFileManager defaultManager]fileExistsAtPath:itemPath]) {
            [[NSFileManager defaultManager]removeItemAtPath:itemPath error:nil];
        }
    }
    
    [self.movieArr removeAllObjects];
    [self.tableView reloadData];
    
    if(!self.listRequest){
        self.listRequest = [[QLNetworkEngine alloc]init];
    }
    __weakSelf__
    [self.listRequest PostPath:@"/index/videoList" parems:nil ResultModelName:@"QLVideoListModel" SuccBlock:^(id models, id resultJson) {
        [weakSelf.movieArr removeAllObjects];
        [weakSelf.movieArr addObjectsFromArray:models];
        [weakSelf.tableView reloadData];
    } FailedBlock:^(NSError *error, id resultJson) {
        
    }];
}

@end
