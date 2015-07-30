//
//  EZCarouseImageView.m
//  QLStudyDemo
//
//  Created by xuqianlong on 15/6/13.
//  Copyright (c) 2015年 前沿科技. All rights reserved.
//

#import "EZCarouseImageView.h"
#import "NSTimer+Util.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"

#define kScrollTimeintervalEZCarouseImageView 2

NSString *const EZCarouseCellReuseIdentifier = @"EZCarouseCellReuseIdentifier";

@interface EZCarouseCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *imgView;

@end

@implementation EZCarouseCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareImgView];
    }
    return self;
}

- (void)prepareImgView
{
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.bounds];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imgView];
    _imgView = imgView;
}

@end

@interface EZCarouseImageView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, assign) NSUInteger currentIdx;
@property (nonatomic, strong) NSMutableDictionary *showURLIdxMap;
@property (nonatomic, strong) NSArray *urlArr;//网络下载图片的数组；
@property (nonatomic, weak  ) NSTimer *timer;
@property (nonatomic, copy  ) void (^DidClickedBlock)(NSUInteger);

@end

@implementation EZCarouseImageView

- (void)initialization
{
    _autoScrollTimeInterval = kScrollTimeintervalEZCarouseImageView;
    _allowAutoScroll = YES;
    
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[EZCarouseCell class] forCellWithReuseIdentifier:EZCarouseCellReuseIdentifier];
    
    [self resetTimer];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = frame.size;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initialization];
        [self registerMemoryWarningNotification];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    if (self = [self initWithFrame:frame]) {
        self.autoScrollTimeInterval = animationDuration;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)registerMemoryWarningNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needLoadImageFromDisk2Memory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

//内存警告后，从本地加载当前需要显示的图片到内存；
- (void)needLoadImageFromDisk2Memory
{
    NSInteger idx = [self itemMapedURLidx:self.currentIdx];
    if (idx != NSNotFound) {
        [self fetchImageForCellWithURLidx:idx];
    }
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    if (_autoScrollTimeInterval != autoScrollTimeInterval) {
        _autoScrollTimeInterval = autoScrollTimeInterval;
        
        self.allowAutoScroll = self.allowAutoScroll;
    }
}

- (void)setAllowAutoScroll:(bool)allowAutoScroll
{
    _allowAutoScroll = allowAutoScroll;
    
    if (_allowAutoScroll && ([self totalCount] > 1) && _autoScrollTimeInterval > 0) {
        [self resetTimer];
        [self resumeAutoScroll];
    }else{
        [self invalidateTimer];
    }
}

- (void)setUrlArr:(NSArray *)urlArr
{
//    copy个新的，防止外部改变了，影响了轮播图
    _urlArr = [urlArr copy];
    if (_urlArr && _urlArr.count > 0) {
        
        self.currentIdx = 0;
//        更新映射的索引；
        [self updateMapedIdx:[self prepareNeedShowPageIdxArr]];
        [self reloadData];
        
        if ([self totalCount] > 1) {
            self.scrollEnabled = YES;
//            显示第一张；假如有n（n > 1）帧，那么［n－1，0，1］
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }else{
            self.scrollEnabled = NO;
        }
//        重设下，更新自动轮播的状态；
        self.allowAutoScroll = self.allowAutoScroll;
//        下载图片；
        for (NSString *url in _urlArr) {
            __weak __typeof(self)weakSelf = self;
            [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                更新下当前显示的图片；
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (strongSelf && image) {
                    [strongSelf reloadItemsAtIndexPaths:[strongSelf indexPathsForVisibleItems]];
                }
            }];
        }
    }else{
//        重设下，更新自动轮播的状态；
        self.allowAutoScroll = self.allowAutoScroll;
        [self reloadData];
    }
}

- (NSUInteger)totalCount
{
    return self.urlArr.count;
}

- (NSMutableDictionary *)showURLIdxMap
{
    if (!_showURLIdxMap) {
        _showURLIdxMap = [[NSMutableDictionary alloc]initWithCapacity:2];
    }
    return _showURLIdxMap;
}

/**
 *  暂停自动滚动轮播图
 */
- (void)pauseAutoScroll
{
    [_timer pauseTimer];
}

/**
 *  开始轮播, 时间间隔默认
 */
- (void)resumeAutoScroll
{
    if (_allowAutoScroll && (_autoScrollTimeInterval > 0)) {
        [_timer resumeTimerAfterTimeInterval:_autoScrollTimeInterval];
    }
}

- (void)invalidateTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

//配置timer；
- (void)resetTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    __weak __typeof(self)weakSelf = self;
    NSTimer *timer = [NSTimer scheduledWithTimeInterval:_autoScrollTimeInterval repeats:YES block:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf autoScrollLoop];
    }];
    
    self.timer = timer;
}

- (void)resetEasyURLArr:(NSArray *)arr
{
    self.urlArr = arr;
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex {
    if(currentPageIndex <= -1) {
        return self.totalCount - 1;
    } else if (currentPageIndex >= self.totalCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

- (void)autoScrollLoop
{
    if ([self totalCount] < 2) {
        [self pauseAutoScroll];
    }else{
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

- (NSString *)getMapKey:(NSUInteger)idx
{
    return [NSString stringWithFormat:@"%zi",idx];
}

//通过item获取对应的数组索引；
- (NSInteger)itemMapedURLidx:(NSUInteger)item
{
    NSNumber *number = [self.showURLIdxMap objectForKey:[self getMapKey:item]];
    if (number) {
        return [number integerValue];
    }else{
        return NSNotFound;
    }
}

//通过索引查找（下载）图片；
- (UIImage *)fetchImageForCellWithURLidx:(NSUInteger)idx
{
    if (idx < self.urlArr.count) {
        NSString *url = [self.urlArr objectAtIndex:idx];
//        先查内存；
        UIImage *image = [[SDImageCache sharedImageCache]imageFromMemoryCacheForKey:url];
        if(image){
            return image;
        }else{
//            内存里没有，就查本地；
            __weak __typeof(self)weakSelf = self;
            [[SDImageCache sharedImageCache]queryDiskCacheForKey:url done:^(UIImage *image, SDImageCacheType cacheType) {
//                查到了就放内存，刷新下view；
                if (image) {
                    [[SDImageCache sharedImageCache]storeImage:image forKey:url toDisk:NO];
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (strongSelf && image) {
                        [strongSelf reloadItemsAtIndexPaths:[strongSelf indexPathsForVisibleItems]];
                    }
                }
            }];
        }
    }
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZCarouseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EZCarouseCellReuseIdentifier forIndexPath:indexPath];
//    通过item获取对应的数组索引；
    NSInteger idx = [self itemMapedURLidx:indexPath.item];
    UIImage *image = nil;
    if (idx != NSNotFound) {
        image = [self fetchImageForCellWithURLidx:idx];
    }
//    找不到图片就用placeHolder
    if (!image && self.placeHolderImage) {
        image = self.placeHolderImage;
    }
    cell.imgView.image = image;
    return cell;
}

//根据图片的数量配置cell个数；
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self totalCount] == 1){
        return 1;//一个不让滚动
    }else if([self totalCount] > 1){
        return 3;//超过一个就用3个，然后显示中间的
    }else{
        return 0;
    }
}
//点击支持代理和block回调
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.carouseDelegate && [self.carouseDelegate respondsToSelector:@selector(ezCarouseImageView:didClickedImageView:)]) {
        [self.carouseDelegate ezCarouseImageView:self didClickedImageView:[self itemMapedURLidx:indexPath.item]];
    }
    if (self.DidClickedBlock) {
        self.DidClickedBlock([self itemMapedURLidx:indexPath.item]);
    }
}

- (void)didClickedEZCarouseImageView:(void (^)(NSUInteger))block
{
    self.DidClickedBlock = block;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    //显示了第3个item,或者第1个item时就要更新下显示的图片索引数组
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        [self showNextPage];//这个会更新视图
    }else if(contentOffsetX <= 0) {
        [self showPreviousPage];//这个会更新视图
    }
}

//准备当前需要显示的索引数组；
- (NSArray *)prepareNeedShowPageIdxArr
{
    NSArray *idxArr = nil;
    
    if (_urlArr.count == 1) {
        idxArr = @[@(0)];
    }else{
        NSInteger prevPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentIdx - 1];
        NSInteger nestPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentIdx + 1];
        idxArr = @[@(prevPageIndex),@(self.currentIdx),@(nestPageIndex)];
    }
    return idxArr;
}

- (void)item:(NSInteger)item mapURL:(NSUInteger)idx
{
    [self.showURLIdxMap setObject:@(idx) forKey:[self getMapKey:item]];
}

- (void)updateMapedIdx:(NSArray *)idxArr
{
    NSInteger item = 0;
    
    [self.showURLIdxMap removeAllObjects];
    for (NSNumber *tempNumber in idxArr)
    {
        NSInteger tempIndex = [tempNumber integerValue];
        [self item:item mapURL:tempIndex];
        item++;
    }
}

#pragma mark - -更新视图
- (void)updateSubViews
{
    NSArray *idxArr = [self prepareNeedShowPageIdxArr];
    [self updateMapedIdx:idxArr];
    [self reloadData];
    
    if (self.urlArr.count > 1)
    {
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)showPage:(NSUInteger)idx
{
    if (idx != self.currentIdx) {
        self.currentIdx = idx;
        [self updateSubViews];
    }
}

- (void)showNextPage
{
    NSInteger currentIdx = [self getValidNextPageIndexWithPageIndex:self.currentIdx + 1];
    [self showPage:currentIdx];
}

- (void)showPreviousPage
{
    NSInteger currentIdx = [self getValidNextPageIndexWithPageIndex:self.currentIdx - 1];
    [self showPage:currentIdx];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resumeAutoScroll];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self resumeAutoScroll];
}

@end