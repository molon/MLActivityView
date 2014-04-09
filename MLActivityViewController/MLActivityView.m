//
//  MLActivityView.m
//  MLActivityViewController
//
//  Created by molon on 4/4/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLActivityView.h"
#import "MLBroadcastView.h"
#import "MLActivityViewBroadcastCell.h"
#import "MLActivityItem.h"
#import "MLActivityDefine.h"


#define kAnimateDuration 0.30f
#define kMaskBackOpacity 0.4f

#define kBroadcastCellPadding 0.0f

#define kMainViewMaxHeightRatio 0.75 //即为最大的这玩意高度/self.superview高度

#define kCancelButtonBackgroundColor ([UIColor colorWithRed:53.0f/255.0f green:53.0f/255.0f blue:53.0f/255.0f alpha:1.0f])

#define kBundleName @"MLActivityView.bundle"
#define kSrcName(file) [kBundleName stringByAppendingPathComponent:file]

@interface MLActivityView()<MLBroadcastViewDataSource,MLBroadcastViewDelegate,MLActivityViewBroadcastCellDelegate>

@property (nonatomic,strong) UIView *maskBackgroundView;
@property (nonatomic,strong) UIView *mainView;
@property (nonatomic,strong) UIImageView *backgroundImageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) MLBroadcastView *broadcastView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) UIButton *cancelButton;

@property (nonatomic,copy) MLActivityViewActionBlock actionBlock;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) NSArray *items;

@property (nonatomic,assign) NSUInteger broadcastCellCount;
@property (nonatomic,assign) NSUInteger maxElementCountOfCell;

@end

@implementation MLActivityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}


- (id)initWithTitle:(NSString*)title andButtonTitles:(NSArray*)titles andButtonImages:(NSArray*)images andActionBlock:(MLActivityViewActionBlock)actionBlock
{
    NSAssert(titles.count == images.count, @"MLActivityView传递的标题和图片数量必须相同");
    
    self = [self init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.actionBlock = actionBlock;
        self.title = title;
        
        NSMutableArray *items = [NSMutableArray array];
        for (NSUInteger i=0; i<titles.count; i++) {
            MLActivityItem *item = [[MLActivityItem alloc]init];
            item.index = i;
            item.title = titles[i];
            item.image = images[i];
            [items addObject:item];
        }
        self.items = items;
        
    }
    return self;
}

- (void)showInView:(UIView*)view
{
    //view添加本view为子View
    [view addSubview:self];
    
    //先强制刷新更新布局。
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGRect frame = self.mainView.frame;
    frame.origin.y = CGRectGetHeight(self.frame);
    self.mainView.frame = frame; //跑到最底
    
    //回到原来的
    frame.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(self.mainView.frame);
    
    self.maskBackgroundView.layer.opacity = 0.01f;
    [UIView animateWithDuration:kAnimateDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.mainView.frame = frame;
        self.maskBackgroundView.layer.opacity = kMaskBackOpacity;
    } completion:nil];
}



- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex<0||buttonIndex>self.items.count-1) {
        buttonIndex = -1;
    }
    
    //消失动画
    CGRect newFrame = self.mainView.frame;
    newFrame.origin.y = CGRectGetHeight(self.frame);
    [UIView animateWithDuration:kAnimateDuration
                          delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                              self.mainView.frame = newFrame; //跑到最底
                              self.maskBackgroundView.layer.opacity = 0.01f;
                          } completion:^(BOOL finished) {
                              [self removeFromSuperview];
                              
                              if (self.actionBlock) {
                                  self.actionBlock(buttonIndex==-1?YES:NO,buttonIndex);
                              }
                          }];
}


#pragma mark - setter and getter

- (UIView*)maskBackgroundView
{
    if (!_maskBackgroundView){
        _maskBackgroundView = [[UIView alloc]init];
        _maskBackgroundView.backgroundColor = [UIColor blackColor];
        _maskBackgroundView.layer.opacity = 0.65f;
        _maskBackgroundView.exclusiveTouch = YES;
        
        _maskBackgroundView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapMaskBackground)];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        [_maskBackgroundView addGestureRecognizer:gesture];
        
        [self addSubview:_maskBackgroundView];
        
    }
    return _maskBackgroundView;
}

- (UIView*)mainView
{
    if (!_mainView){
        _mainView = [[UIView alloc]init];
        
        [self addSubview:_mainView];
    }
    return _mainView;
}

- (UIImageView*)backgroundImageView
{
    if (!_backgroundImageView){
        _backgroundImageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:kSrcName(@"background")] stretchableImageWithLeftCapWidth:0.0f topCapHeight:7.0f]];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        [self.mainView addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = self.title;
        _titleLabel.textColor = [UIColor whiteColor];
//        _titleLabel.backgroundColor = [UIColor greenColor];
        
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = kShadowOffset;
        
        [self.mainView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (MLBroadcastView*)broadcastView
{
    if (!_broadcastView) {
        _broadcastView = [[MLBroadcastView alloc]init];
        _broadcastView.delegate = self;
        _broadcastView.dataSource = self;
//        _broadcastView.backgroundColor = [UIColor yellowColor];
        _broadcastView.padding = kBroadcastCellPadding;
        [self.mainView addSubview:_broadcastView];
    }
    return _broadcastView;
}

- (UIPageControl*)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.exclusiveTouch = YES;
//        _pageControl.backgroundColor = [UIColor purpleColor];
        [self.mainView addSubview:_pageControl];
    }
    return _pageControl;
}

- (UIButton*)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.layer.cornerRadius = 5.0f;
        [_cancelButton setBackgroundImage:[self imageWithPureColor:kCancelButtonBackgroundColor] forState:UIControlStateNormal];
        _cancelButton.exclusiveTouch = YES;
        _cancelButton.clipsToBounds = YES;
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _cancelButton.titleLabel.shadowColor = [UIColor blackColor];
        _cancelButton.titleLabel.shadowOffset = kShadowOffset;
        
        [self.mainView addSubview:_cancelButton];
    }
    return _cancelButton;
}

- (void)setBroadcastCellCount:(NSUInteger)broadcastCellCount
{
    _broadcastCellCount = broadcastCellCount;
    
    self.pageControl.numberOfPages = broadcastCellCount;
    self.pageControl.currentPage = 0;
    
}

#pragma mark - tap event
- (void)tapMaskBackground
{
    [self cancel];
}

- (void)cancel
{
    [self dismissWithClickedButtonIndex:-1];
}

#pragma mark - ml broadcast delegate

- (NSUInteger)cellCountOfBroadcastView:(MLBroadcastView *)broadcastView
{
    return self.broadcastCellCount;
}

- (MLBroadcastViewCell *)broadcastView:(MLBroadcastView *)broadcastView cellAtPageIndex:(NSUInteger)pageIndex
{
    static NSString *CellIdentifier = @"MLActivityView_BroadcastCell";
    MLActivityViewBroadcastCell *cell = [broadcastView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MLActivityViewBroadcastCell alloc]initWithReuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    
    //传递元素进去
    NSUInteger len = self.maxElementCountOfCell;
    if (self.items.count-pageIndex*self.maxElementCountOfCell<len) {
        len = self.items.count-pageIndex*self.maxElementCountOfCell;
    }
    NSArray *itemsOfCell = [self.items subarrayWithRange:NSMakeRange(pageIndex*self.maxElementCountOfCell, len)];
    cell.items = itemsOfCell;
    
    return cell;
}

//滚到了某一个页面
- (void)didScrollToPageIndex:(NSUInteger)pageIndex ofBroadcastView:(MLBroadcastView *)broadcastView
{
    self.pageControl.currentPage = pageIndex;
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect superBounds = self.superview.bounds;
    
    self.frame = superBounds;
    
    //mask back
    self.maskBackgroundView.frame = self.bounds;
    
    //mainView
    self.mainView.frame = CGRectMake(0, 0,  CGRectGetWidth(superBounds), 0.0f);
    
#define kTopBottomPadding 13.0f
#define kTitleLabelHeight 20.0f
#define kTitleLabelBottonMargin 10.0f
#define kPageControlHeight 15.0f
#define kCancelButtonHeight 44.0f
#define kCancelButtonHMargin 20.0f
#define kCancelButtonTopMargin 10.0f
    
    CGFloat contentWidth = CGRectGetWidth(self.mainView.bounds);
    
    //title label
    self.titleLabel.frame = CGRectMake(0, kTopBottomPadding, contentWidth, kTitleLabelHeight);
    
    //broadcastView
    CGFloat maxBroadcastViewHeight = CGRectGetHeight(self.bounds)*kMainViewMaxHeightRatio - kTopBottomPadding*2 - kTitleLabelHeight - kTitleLabelBottonMargin - kPageControlHeight - kCancelButtonHeight - kCancelButtonTopMargin;
    
    CGFloat height = 0.0f;
    //计算每行最多可以放几个
    NSUInteger maxElementCountOfRow = floor((contentWidth-kBroadcastCellLeftRightPadding*2)/kElementBaseWidth);
    //计算最多可放多少行
    NSUInteger maxRowCount = floor(maxBroadcastViewHeight/kElementHeight);
    //计算真实需要多少行
    NSUInteger realNeedRowCount = ceil(self.items.count/(CGFloat)maxElementCountOfRow);
    //计算broadcastView的高度
    if (realNeedRowCount>=maxRowCount) {
        height = maxRowCount*kElementHeight;
    }else{
        height = realNeedRowCount*kElementHeight;
    }
    self.broadcastCellCount = ceil((double)realNeedRowCount/maxRowCount);
    self.maxElementCountOfCell = maxElementCountOfRow*maxRowCount;
    
    self.broadcastView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame)+kTitleLabelBottonMargin, contentWidth, height);
    
    [self.broadcastView reloadData]; //可能修改了broadcastCellCount和maxElementCountOfCell，例如在转屏的情况下，这里需要重新刷新下。
    
    //pageControl
    self.pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.broadcastView.frame), contentWidth, kPageControlHeight);
    
    //cancelButton
    self.cancelButton.frame = CGRectMake(kCancelButtonHMargin, CGRectGetMaxY(self.pageControl.frame)+kCancelButtonTopMargin, contentWidth-kCancelButtonHMargin*2, kCancelButtonHeight);
    
    //重新修正下mainView高度
    CGRect mainViewFrame = self.mainView.frame;
    mainViewFrame.size.height = CGRectGetMaxY(self.cancelButton.frame)+13.0f;
    mainViewFrame.origin.y = CGRectGetHeight(superBounds)-mainViewFrame.size.height;
    self.mainView.frame = mainViewFrame;
    
    
    //backgroundView
    self.backgroundImageView.frame = self.mainView.bounds;
    [self.mainView sendSubviewToBack:self.backgroundImageView];
    
}

#pragma mark - click delegate
- (void)clickIndex:(NSUInteger)index ofMLActivityViewBroadcastCell:(MLActivityViewBroadcastCell*)cell
{
    [self dismissWithClickedButtonIndex:index];
}

#pragma mark - helper

- (UIImage *)imageWithPureColor:(UIColor*)color
{
    return [self imageWithPureColor:color withSize:CGSizeMake(1, 1)];
}

- (UIImage *)imageWithPureColor:(UIColor*)color withSize:(CGSize)size
{
    CGSize imageSize = size;
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pressedColorImg;
}


@end
