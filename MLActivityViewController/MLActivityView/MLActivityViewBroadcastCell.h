//
//  MLActivityViewBroadcastCell.h
//  MLActivityViewController
//
//  Created by molon on 4/4/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLBroadcastViewCell.h"

@class MLActivityViewBroadcastCell;
@protocol MLActivityViewBroadcastCellDelegate <NSObject>

@required

- (void)clickIndex:(NSUInteger)index ofMLActivityViewBroadcastCell:(MLActivityViewBroadcastCell*)cell;

@end


@interface MLActivityViewBroadcastCell : MLBroadcastViewCell

@property (nonatomic,strong) NSArray *items;
@property (nonatomic,weak) id<MLActivityViewBroadcastCellDelegate> delegate;

@end
