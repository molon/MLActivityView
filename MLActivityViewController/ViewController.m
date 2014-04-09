//
//  ViewController.m
//  MLActivityViewController
//
//  Created by molon on 4/4/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "ViewController.h"
#import "MLActivityView.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)press:(id)sender {
//    [self getGroup];
//    return;
//    
    MLActivityView *activityView = [[MLActivityView alloc]initWithTitle:@"分享到" andButtonTitles:@[@"发送给朋友",@"分享到朋友圈",@"收藏",@"分享到腾讯微博",@"查看公众号",@"调整字体",@"投诉",@"复制链接到剪切板",@"刷新",@"销售退款"] andButtonImages:@[[UIImage imageNamed:@"sns_icon_10"],[UIImage imageNamed:@"sns_icon_11"],[UIImage imageNamed:@"sns_icon_12"],[UIImage imageNamed:@"sns_icon_13"],[UIImage imageNamed:@"sns_icon_14"],[UIImage imageNamed:@"sns_icon_15"],[UIImage imageNamed:@"sns_icon_16"],[UIImage imageNamed:@"sns_icon_17"],[UIImage imageNamed:@"sns_icon_18"],[UIImage imageNamed:@"sns_icon_19"]] andActionBlock:^(BOOL isCancel, NSInteger clickedIndex) {
        if (!isCancel) {
            NSLog(@"选了%ld",clickedIndex);
        }else{
            NSLog(@"canceled");
        }
    }];
    [activityView showInView:self.view];
}

@end
