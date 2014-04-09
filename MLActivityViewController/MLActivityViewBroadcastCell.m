//
//  MLActivityViewBroadcastCell.m
//  MLActivityViewController
//
//  Created by molon on 4/4/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLActivityViewBroadcastCell.h"
#import "MLActivityItem.h"
#import "MLActivityElementView.h"
#import "MLActivityDefine.h"

@interface MLActivityViewBroadcastCell()<MLActivityElementViewDelegate>

@property (nonatomic,strong) NSMutableArray *elementViews;

@end

@implementation MLActivityViewBroadcastCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - reuse
- (void)prepareForReuse
{
    [super prepareForReuse];
    //重用需要做的
    self.items = nil;
}

#pragma mark - setter
- (void)setItems:(NSArray *)items
{
    _items = items;
    if (!items) {
        //移除所有的子View
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
        return;
    }
    
    self.elementViews = [NSMutableArray array];
    for (NSUInteger i=0; i<items.count; i++) {
        MLActivityElementView *elementView = [[MLActivityElementView alloc]init];
        elementView.item = items[i];
//        elementView.backgroundColor = [UIColor blueColor];
        elementView.delegate = self;
        [self addSubview:elementView];
        [self.elementViews addObject:elementView];
    }
    [self setNeedsLayout];
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //计算每行最多可以放几个
    CGFloat contentWidth = (CGRectGetWidth(self.bounds)-kBroadcastCellLeftRightPadding*2);
    NSUInteger maxElementCountOfRow = floor(contentWidth/kElementBaseWidth);
    CGFloat realWidth = contentWidth/maxElementCountOfRow;
    
    CGFloat baseY = 0;
    CGFloat baseX = kBroadcastCellLeftRightPadding;
    for (NSUInteger i=0; i<self.elementViews.count; i++) {
        UIView *elementView = self.elementViews[i];
        elementView.frame = CGRectMake(baseX, baseY, realWidth, kElementHeight);
        if ((i+1)%maxElementCountOfRow==0) {
            baseX = kBroadcastCellLeftRightPadding;
            baseY = CGRectGetMaxY(elementView.frame);
        }else{
            baseX = CGRectGetMaxX(elementView.frame);
        }
    }
}

#pragma mark - delegate
- (void)clickIndex:(NSUInteger)index ofElementView:(MLActivityElementView*)elementView
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(clickIndex:ofMLActivityViewBroadcastCell:)]) {
        [self.delegate clickIndex:index ofMLActivityViewBroadcastCell:self];
    }
}

@end
