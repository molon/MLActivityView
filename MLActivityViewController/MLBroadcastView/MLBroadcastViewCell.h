//
//  MLBroadcastViewCell.h
//  ImageSelectAndCrop
//
//  Created by molon on 14-1-20.
//  Copyright (c) 2014年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLBroadcastViewCell : UIView

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

- (void)prepareForReuse;

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
