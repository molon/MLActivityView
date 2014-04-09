//
//  MLBroadcastView.h
//  ImageSelectAndCrop
//
//  Created by molon on 14-1-20.
//  Copyright (c) 2014年 Molon. All rights reserved.
//
//不要尝试使用Cell的tag去获取当前的index。因为currentIndex和currentPageIndex的不同
//TIPS:在reoloadData和scrollToPageIndex之前必须要设置好BroadcastView的frame
//否则其内部的scrollView的滚动不会发生。

#import <UIKit/UIKit.h>

@class MLBroadcastView;
#import "MLBroadcastViewCell.h"

@protocol MLBroadcastViewDataSource <NSObject>

@required

- (NSUInteger)cellCountOfBroadcastView:(MLBroadcastView *)broadcastView;
- (MLBroadcastViewCell *)broadcastView:(MLBroadcastView *)broadcastView cellAtPageIndex:(NSUInteger)pageIndex;

@end

@protocol MLBroadcastViewDelegate <NSObject>

@optional
//滚到了某一个页面
- (void)didScrollToPageIndex:(NSUInteger)pageIndex ofBroadcastView:(MLBroadcastView *)broadcastView;

//针对于index的预操作，例如图片的预加载啊。注意此方法是在后台线程里执行的
//而且例如图片的预加载，建议对此方法内部的操作进行唯一次处理，只预加载一次。
- (void)preOperateInBackgroundAtPageIndex:(NSUInteger)pageIndex ofBroadcastView:(MLBroadcastView *)broadcastView;
@end

@interface MLBroadcastView : UIView
@property (nonatomic,assign) NSUInteger padding; //自定义padding

@property (nonatomic,weak) IBOutlet id<MLBroadcastViewDataSource> dataSource;
@property (nonatomic,weak) IBOutlet id<MLBroadcastViewDelegate> delegate;
@property(nonatomic,assign) BOOL isAutoRoll;//是否轮着来,默认不
@property (nonatomic,assign,readonly) NSUInteger currentPageIndex; //当前页,和私有属性currentIndex的区别是在轮播时候，currentIndex是真实的。但是外界需要得到和考虑的应该为currentPageIndex

- (void)reloadData;
- (void)scrollToPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated;

- (id)dequeueReusableCellWithIdentifier:(NSString*)identifier;

@end
