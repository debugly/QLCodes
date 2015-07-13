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

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSUInteger currentIdx;
@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, strong)NSMutableDictionary *showURLIdxMap;
//网络下载图片的数组；
@property (nonatomic, strong) NSArray *urlArr;

@end

@implementation EZCarouseImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
        [self initContentView];
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

- (void)initialization
{
    _autoScrollTimeInterval = kScrollTimeintervalEZCarouseImageView;
    _allowAutoScroll = YES;

    [self resetTimer];
}

- (void)initContentView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];

    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = self.bounds.size;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collection = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    collection.backgroundColor = self.backgroundColor;
    collection.pagingEnabled = YES;
    collection.showsHorizontalScrollIndicator = NO;
    collection.showsVerticalScrollIndicator = NO;
    collection.delegate = self;
    collection.dataSource = self;
    [collection registerClass:[EZCarouseCell class] forCellWithReuseIdentifier:EZCarouseCellReuseIdentifier];

    [self addSubview:collection];
    self.collectionView = collection;
    
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
    
    if (_allowAutoScroll) {
        [self resetTimer];
        [self startAutoScroll];
    }else{
        [self invalidateTimer];
    }
}

- (void)setUrlArr:(NSArray *)urlArr
{
    _urlArr = urlArr;
    if (_urlArr && _urlArr.count > 0) {
        
        [self.collectionView reloadData];
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        self.allowAutoScroll = self.allowAutoScroll;
        
        for (NSString *url in _urlArr) {
            
            [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:NULL completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (image) {
                    [[SDImageCache sharedImageCache]storeImage:image forKey:url];
                    [self.collectionView reloadData];
                }
            }];
        }
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
- (void)startAutoScroll
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

- (void)resetTimer
{
    NSTimer *timer = [[NSTimer alloc]initWithFireDate:[NSDate distantFuture] interval:_autoScrollTimeInterval target:self selector:@selector(autoScrollLoop) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
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
    if (!self.totalCount) {
        [self pauseAutoScroll];
    }else{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

- (NSString *)getMapKey:(NSUInteger)idx
{
    return [NSString stringWithFormat:@"%zi",idx];
}

- (NSInteger)itemMapedURLidx:(NSUInteger)item
{
    NSNumber *number = [self.showURLIdxMap objectForKey:[self getMapKey:item]];
    if (number) {
        return [number integerValue];
    }else{
        return NSNotFound;
    }
}

- (UIImage *)fetchImageForCellWithURLidx:(NSUInteger)idx
{
    if (idx < self.urlArr.count) {
        NSString *url = [self.urlArr objectAtIndex:idx];
        return [[SDImageCache sharedImageCache]imageFromMemoryCacheForKey:url];
    }
   
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZCarouseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EZCarouseCellReuseIdentifier forIndexPath:indexPath];
    NSInteger idx = [self itemMapedURLidx:indexPath.item];
    UIImage *image = nil;
    if (idx != NSNotFound) {
        image = [self fetchImageForCellWithURLidx:idx];
    }
    if (!image && self.placeHolderImage) {
        image = self.placeHolderImage;
    }
    cell.imgView.image = image;
    cell.imgView.backgroundColor = [UIColor redColor];
    return cell;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ezCarouseImageView:didClickedImageView:)]) {
        [self.delegate ezCarouseImageView:self didClickedImageView:[self itemMapedURLidx:indexPath.item]];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        [self showNextPage];
    }else if(contentOffsetX <= 0) {
        [self showPreviousPage];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self pauseAutoScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self pauseAutoScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startAutoScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startAutoScroll];
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

- (void)updateSubViews
{
    NSArray *idxArr = [self prepareNeedShowPageIdxArr];
    
    NSInteger item = 0;
    
    [self.showURLIdxMap removeAllObjects];
    for (NSNumber *tempNumber in idxArr)
    {
        NSInteger tempIndex = [tempNumber integerValue];
        [self item:item mapURL:tempIndex];
        item++;
    }
    
    if (self.urlArr.count > 1)
    {
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
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

@end
