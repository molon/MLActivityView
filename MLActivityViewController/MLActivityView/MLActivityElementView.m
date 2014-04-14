//
//  MLActivityElementView.m
//  MLActivityViewController
//
//  Created by molon on 4/8/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLActivityElementView.h"
#import "MLActivityItem.h"
#import "MLActivityDefine.h"

#define kButtonWidthAndHeight 57.0f

@interface MLActivityElementView()

@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation MLActivityElementView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.exclusiveTouch = YES;
    }
    return self;
}

#pragma mark - event
- (void)buttonEvent:(id)sender
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(clickIndex:ofElementView:)]) {
        [self.delegate clickIndex:self.item.index ofElementView:self];
    }
}

#pragma mark - setter and getter
- (UIButton*)button
{
    if (!_button) {
        _button = [[UIButton alloc]init];
        _button.contentMode = UIViewContentModeScaleAspectFit;
        _button.backgroundColor = [UIColor clearColor];
        _button.clipsToBounds = YES;
        _button.exclusiveTouch = YES;
        
        _button.layer.cornerRadius = 5.0f;
        _button.layer.shadowColor = [UIColor blackColor].CGColor;
        _button.layer.shadowOffset = kShadowOffset;
        
        
        [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return _button;
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.clipsToBounds = YES;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = kShadowOffset;
        
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (void)setItem:(MLActivityItem *)item
{
    _item = item;
    
    [self.button setImage:item.image forState:UIControlStateNormal];
    self.titleLabel.text = item.title;
    if (item.customTextColor) {
        self.titleLabel.textColor = item.customTextColor;
        self.titleLabel.shadowColor = [UIColor clearColor];
        self.titleLabel.shadowOffset = CGSizeZero;
    }
    [self setNeedsLayout];
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.button.frame = CGRectMake((CGRectGetWidth(self.bounds)-kButtonWidthAndHeight)/2, 0, kButtonWidthAndHeight, kButtonWidthAndHeight);
    
    self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.button.frame), CGRectGetMaxY(self.button.frame)+5.0f, CGRectGetWidth(self.button.frame), CGRectGetHeight(self.bounds)-CGRectGetMaxY(self.button.frame)-5.0f);
    
    [self.titleLabel sizeToFit];
    if (CGRectGetWidth(self.titleLabel.frame)<CGRectGetWidth(self.button.frame)){
        CGRect titleFrame = self.titleLabel.frame;
        titleFrame.size.width = CGRectGetWidth(self.button.frame);
        self.titleLabel.frame = titleFrame;
    }
    
}

@end
