//
//  MLActivityElementView.h
//  MLActivityViewController
//
//  Created by molon on 4/8/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLActivityItem;

@class MLActivityElementView;
@protocol MLActivityElementViewDelegate <NSObject>

@required

- (void)clickIndex:(NSUInteger)index ofElementView:(MLActivityElementView*)elementView;

@end

@interface MLActivityElementView : UIView

@property (nonatomic,strong) MLActivityItem *item;
@property (nonatomic,weak) id<MLActivityElementViewDelegate> delegate;

@end
