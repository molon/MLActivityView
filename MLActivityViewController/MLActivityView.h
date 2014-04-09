//
//  MLActivityView.h
//  MLActivityViewController
//
//  Created by molon on 4/4/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MLActivityViewActionBlock)(BOOL isCancel,NSInteger clickedIndex);

@interface MLActivityView : UIView

- (id)initWithTitle:(NSString*)title andButtonTitles:(NSArray*)titles andButtonImages:(NSArray*)images andActionBlock:(MLActivityViewActionBlock)actionBlock;
- (void)showInView:(UIView*)view;

@end
