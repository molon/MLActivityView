//
//  MLBroadcastViewCell.m
//  ImageSelectAndCrop
//
//  Created by molon on 14-1-20.
//  Copyright (c) 2014年 Molon. All rights reserved.
//

#import "MLBroadcastViewCell.h"

@implementation MLBroadcastViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
    self = [self init];
    if (self) {
        // Initialization code
        _reuseIdentifier = reuseIdentifier;
        self.exclusiveTouch = YES;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)prepareForReuse
{
    
}

@end
