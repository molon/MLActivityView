//
//  MLActivityItem.h
//  MLActivityViewController
//
//  Created by molon on 4/8/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLActivityItem : NSObject

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,strong) UIColor *customTextColor;

@end
