//
//  MLBroadcastView.m
//  ImageSelectAndCrop
//
//  Created by molon on 14-1-20.
//  Copyright (c) 2014年 Molon. All rights reserved.
//

#import "MLBroadcastView.h"
#import "MLBroadcastViewCell.h"
#import "Debug.h"

#define kPadding 10 //Cell与Cell之间的黑色间隔/2,因为每个Cell左右都有占位，所以实际间隔是kPadding*2

#define kCellTagOffset 1000
#define kCellIndex(cell) ([cell tag] - kCellTagOffset)

@interface MLBroadcastView()<UIScrollViewDelegate>

@property(nonatomic,strong) UIScrollView *scrollView;
//当前显示的Cell
@property(nonatomic,strong) NSMutableSet *visibleCells;
//可重用的Cell
@property(nonatomic,strong) NSMutableSet *reusableCells;
//当前页
@property (nonatomic,assign) NSUInteger currentIndex;

@property(nonatomic,assign) BOOL isIgnoreScroll; //在重新layout时候防止触发showCells方法

@property(nonatomic,assign) BOOL isIgnorePreOperate;//在暗地里交换头尾位置时候防止触发预加载

@property(nonatomic,assign) BOOL isNotFirstSetCurrentIndex; //因为currentIndex是NSUInteger，默认就为0，所以用这个来标识判断下是否第一次设置

@end

@implementation MLBroadcastView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.isIgnoreScroll = NO;
    self.isNotFirstSetCurrentIndex = NO;
    
    self.clipsToBounds = YES;
    self.padding = kPadding;
    
    self.scrollView.scrollsToTop = NO;
}

#pragma mark - setter getter

- (UIScrollView*)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.pagingEnabled = YES; //设置分页
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.autoresizesSubviews = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingNone;
        _scrollView.clipsToBounds = YES;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSMutableSet*)visibleCells
{
    if (!_visibleCells) {
        _visibleCells = [NSMutableSet set];
    }
    return _visibleCells;
}

- (NSMutableSet*)reusableCells
{
    if (!_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    NSUInteger pageCount = [self pageCount];
    if (currentIndex>pageCount-1) {
        currentIndex = pageCount-1;
    }
    if (currentIndex == _currentIndex&&self.isNotFirstSetCurrentIndex) {
        return;
    }
    self.isNotFirstSetCurrentIndex = YES;
    
    _currentIndex = currentIndex;
    
    if (self.isAutoRoll&&pageCount>=4) { //轮播的话页面最少得4页
        //检测是否滚到了最后一个页面
        if (self.currentIndex>=pageCount-1) {
            self.isIgnorePreOperate = YES;
            
            //暗地里转换成相应的第一个页面位置
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x-(pageCount-2)*CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
            
            self.isIgnorePreOperate = NO;
            return; //这里修改无需重复调用delegate的didScrollToIndex方法
        }else if (self.currentIndex<=0) {
            self.isIgnorePreOperate = YES;
            
            //暗地里转换成相应的最后一个页面位置
            self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x+(pageCount-2)*CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
            
            self.isIgnorePreOperate = NO;
            return;
        }
    }
    
    //滚到了某个页面
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didScrollToPageIndex:ofBroadcastView:)]) {
        [self.delegate didScrollToPageIndex:[self switchToPageIndexForIndex:currentIndex] ofBroadcastView:self];
    }
}

- (NSUInteger)currentPageIndex
{
    return [self switchToPageIndexForIndex:self.currentIndex];
}

#pragma mark - helper
- (NSUInteger)pageCount
{
    NSAssert(self.dataSource, @"没有设置轮播资源");
    
    NSUInteger count = [self.dataSource cellCountOfBroadcastView:self];
    
    //超过一页轮播才有意义
    //若轮播则添加两页，第一页实际是最后一页的假象，最后一页是第一页的假象
    count = count>1?count+(self.isAutoRoll?2:0):count;
    
    return count;
}

//根据页面index获取pageIndex
- (NSUInteger)switchToPageIndexForIndex:(NSUInteger)index
{
    if (!self.isAutoRoll) {
        return index;
    }
    NSUInteger pageCount = [self pageCount];
    if (pageCount<4) {
        return index; //原样返回
    }
    
    if (index>=pageCount-1) { //最后一页为第一页
        return 0;
    }else if (index<=0){ //第一页为最后一页
        return pageCount-2-1;
    }
    
    return index-1;
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSUInteger pageCount = [self pageCount];
    
    //修正Cell位置
    //scrollView
    CGRect scrollFrame = self.bounds;
    scrollFrame.origin.x -= self.padding;
    scrollFrame.size.width += 2*self.padding;
    
    self.isIgnoreScroll = YES;
    //frame
    self.scrollView.frame = scrollFrame;
    
    //contentSize
    self.scrollView.contentSize = CGSizeMake(pageCount*scrollFrame.size.width, scrollFrame.size.height);
    
    //contentOffset
    self.scrollView.contentOffset = CGPointMake(self.currentIndex*scrollFrame.size.width, 0);
    
    self.isIgnoreScroll = NO;
    
    //每个cell
    CGRect bounds = self.scrollView.bounds;
    for (MLBroadcastViewCell *cell in self.visibleCells) {
        //设置对应的frame
        cell.frame = CGRectMake(CGRectGetWidth(bounds)*kCellIndex(cell)+self.padding, CGRectGetMinY(bounds), CGRectGetWidth(bounds)-2*self.padding, CGRectGetHeight(bounds));
    }
}

#pragma mark - reusable
- (id)dequeueReusableCellWithIdentifier:(NSString*)identifier
{
    MLBroadcastViewCell *cell = nil;
    for (MLBroadcastViewCell *aCell in self.reusableCells) {
        if ([aCell.reuseIdentifier isEqualToString:identifier]) {
            cell = aCell;
            break;
        }
    }
    if (cell) {
        [self.reusableCells removeObject:cell];
        [cell prepareForReuse];
    }
    
    return cell;
}

#pragma mark - showCell

- (void)showCells
{
    NSUInteger pageCount = [self pageCount];
    if (pageCount<=0) {
        return;
    }
    //scrollView的bounds.origin其实是contentOffset类似，size是和frame的一样
    CGRect visibleBounds = self.scrollView.bounds;

    //找到当前显示的第一个位置，例如正在拖动中，其实一般是显示了俩的
    //至于这里为什么要有self.padding*2是为了让拖动并未超过黑色间隔的时候不处理显示新的pictureView
	NSInteger firstIndex = (NSInteger)floor((CGRectGetMinX(visibleBounds)+self.padding*2) / CGRectGetWidth(visibleBounds));
	NSInteger lastIndex  = (NSInteger)floor((CGRectGetMaxX(visibleBounds)-1-self.padding*2) / CGRectGetWidth(visibleBounds));
    //越界校正
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= pageCount) firstIndex = pageCount - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= pageCount) lastIndex = pageCount - 1;
	if (firstIndex>lastIndex) {
        return;
    }
    NSInteger cellIndex;
	for (MLBroadcastViewCell *cell in self.visibleCells) {
        cellIndex = kCellIndex(cell);
        //visibleCells里的cell不再显示，则将其放入重用集合里面，并且从父View里移除
		if (cellIndex < firstIndex || cellIndex > lastIndex) {
			[self.reusableCells addObject:cell];
			[cell removeFromSuperview];
		}
	}
    //visibleCells里删去重用集合里重复的部分。
	[self.visibleCells minusSet:self.reusableCells];
    
    //相同的标识每个最多保存2个重用
    if (self.reusableCells.count>2) {
        /*   NSMutableSet *needRemoveCells = [NSMutableSet set]; //加入重复的元素会被忽略
         NSMutableArray *workedIdentifier = [NSMutableArray array];
         for (MLBroadcastViewCell *cell in self.reusableCells) {
         NSString *currentIdentifier = cell.reuseIdentifier;
         if ([workedIdentifier containsObject:currentIdentifier]) {
         continue; //处理过的标识符就不需要再次处理
         }
         [workedIdentifier addObject:currentIdentifier];
         
         NSUInteger count = 0;
         for (MLBroadcastViewCell *cell in self.reusableCells) {
         if ([cell.reuseIdentifier isEqualToString:currentIdentifier]) {
         count++;
         }
         if (count>2) {
         [needRemoveCells addObject:cell];
         }
         }
         }
         //删除不需要的了
         [self.reusableCells minusSet:needRemoveCells];
         */
        //另外一种整理方法
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (MLBroadcastViewCell *cell in self.reusableCells) {
            NSAssert(cell.reuseIdentifier, @"BroadcastCell没有对应的标识符");
            if (!dict[cell.reuseIdentifier]) {
                dict[cell.reuseIdentifier] = [NSMutableArray array];
            }
            [dict[cell.reuseIdentifier] addObject:cell];
        }
        for (NSMutableArray *array in [dict allValues]) {
            if (array.count>2) {
                for (NSUInteger i=2; i<array.count; i++) {
                    [self.reusableCells removeObject:array[i]];
                }
            }
        }
    }
	
    //检查如果有当前显示的下标并不存在于visiblePictureViews，则将其加入并且做相应处理
	for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        [self showCellAtIndex:index];
	}
}

- (void)showCellAtIndex:(NSUInteger)index
{
    NSAssert(self.dataSource, @"没有设置轮播资源");
    
    //如果当前显示的下标并存在于visibleCells，则无需处理
    for (MLBroadcastViewCell *cell in self.visibleCells) {
        if (kCellIndex(cell) == index) {
            return;
        }
    }
    
    NSUInteger cellIndex = index;
    NSUInteger pageCount = [self pageCount];;
    if (self.isAutoRoll&&pageCount>=4) {//轮播页面最少4张
        NSUInteger realPageCount = pageCount - 2;
        //如果是第一页,实际是外界看来的最后一个cell
        if (cellIndex<=0) {
            cellIndex = realPageCount-1;
        }else if (cellIndex>=pageCount-1) { //如果是最后一页,实际是外界看来的第一个cell
            cellIndex = 0;
        }else{
            cellIndex -=1; //其他的都超前移一个位置
        }
    }
    MLBroadcastViewCell *cell = [self.dataSource broadcastView:self cellAtPageIndex:cellIndex];
    NSAssert(cell,@"返回的cell资源有误");
    
    cell.tag = kCellTagOffset + index;
    
    //更新frame
    CGRect bounds = self.scrollView.bounds;
    cell.frame = CGRectMake(CGRectGetWidth(bounds)*index+self.padding, CGRectGetMinY(bounds), CGRectGetWidth(bounds)-2*self.padding, CGRectGetHeight(bounds));
    
    [self.visibleCells addObject:cell];
    [self.scrollView addSubview:cell];
    
    if (!self.isIgnorePreOperate) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(preOperateInBackgroundAtPageIndex:ofBroadcastView:)]) {
            [self preOperateNearIndex:index];
        }
    }
}

#pragma mark pre operate
- (void)justPreOperateWithIndex:(NSUInteger)index
{
    //如果当前显示的下标并存在于visibleCells，则无需处理
    for (MLBroadcastViewCell *cell in self.visibleCells) {
        if ([self switchToPageIndexForIndex:kCellIndex(cell)] == [self switchToPageIndexForIndex:index]) {
            return;
        }
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(preOperateInBackgroundAtPageIndex:ofBroadcastView:)]) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf.delegate preOperateInBackgroundAtPageIndex:[self switchToPageIndexForIndex:index] ofBroadcastView:weakSelf];
        });
    }
}

- (void)preOperateNearIndex:(NSUInteger)index
{
    NSUInteger pageCount = [self pageCount];
    if (self.isAutoRoll&&pageCount>=4) {
        //左边
        //如果当前是index==0的话，说明当前是到了最后一张图，所以要预加载倒数第二张和第一张
        //倒数第二张为pageCount-2==realPageCount,realPageCount-2为倒数第二张下标，但是第一个位置被占用
        //所以为pageCount-2-2+1
        NSUInteger leftIndex = index<1?pageCount-2-2+1:index-1;
        //右边
        //index==pageCount-1实际上为第一张图片，所以右边的话要加载第2张，即为2-1+1
        NSUInteger rightIndex = index+1>pageCount-1?2-1+1:index+1;
        [self justPreOperateWithIndex:leftIndex];
        if (leftIndex!=rightIndex&&[self switchToPageIndexForIndex:leftIndex]!=[self switchToPageIndexForIndex:rightIndex]) {
            [self justPreOperateWithIndex:rightIndex];
        }
    }else{
        if (index > 0) {
            [self justPreOperateWithIndex:index-1];
        }
        if (index < pageCount - 1) {
            [self justPreOperateWithIndex:index+1];
        }
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.dataSource) {
        DLOG(@"没有设置轮播资源，滚动也不应有任何反应");
        return;
    }
    if (self.isIgnoreScroll) {
        return;
    }
    [self showCells];
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    self.currentIndex = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

#pragma mark - other
- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSUInteger pageCount = [self pageCount];
    if (index>=pageCount) {
        index = pageCount-1;
    }
    //View加载完毕就直接调到目标位置
    [self.scrollView setContentOffset:CGPointMake(index * CGRectGetWidth(self.scrollView.frame), 0) animated:animated];
    [self showCells];
}

- (void)scrollToPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated
{
    NSUInteger pageCount = [self pageCount];
    NSUInteger index = pageIndex;
    //当前只处理了去头尾找比较近的方向
    //其实最好应该对所有的位置都计算一下，算算是向左还是向右比较空间少。这里暂时不做这个处理了
    if (self.isAutoRoll&&pageCount>=4) {
        NSUInteger realPageCount = pageCount - 2;
        NSUInteger currentPageIndex = self.currentPageIndex;
        if (pageIndex<=0&&currentPageIndex>=realPageCount/2) {
            index = pageCount - 1; //若目的是第一页，当前位置超过一半了就朝右跑，跑到最后
        }else if (pageIndex>=realPageCount-1&&currentPageIndex<realPageCount/2) {
            //同上
            index = 0;
        }else{
            index++;
        }
    }
    [self scrollToIndex:index animated:animated];
}

- (void)reloadData
{
    self.isNotFirstSetCurrentIndex = NO;
    self.isIgnoreScroll = NO;
    
    //清空存储
    for (MLBroadcastViewCell *cell in self.visibleCells) {
        [cell removeFromSuperview];
	}
    [self.visibleCells removeAllObjects];
    [self.reusableCells removeAllObjects];
    
    //找到第一页
    if (self.isAutoRoll&&[self pageCount]>=4) { //开启了轮播的默认页面index应该为1
        self.currentIndex = 1;
    }else{
        self.currentIndex = 0;
    }
    
//    _ps(self.scrollView.contentSize);
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
//    _ps(self.scrollView.contentSize);
    
    [self scrollToIndex:self.currentIndex animated:NO];
    
//    _ps(self.scrollView.contentSize);
}

@end
