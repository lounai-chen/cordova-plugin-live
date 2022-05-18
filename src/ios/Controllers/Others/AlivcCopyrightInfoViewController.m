//
//  AlivcCopyrightInfoViewController.m
//  AlivcLivePusherTest
//
//  Created by TripleL on 2017/10/18.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AlivcCopyrightInfoViewController.h"

@interface AlivcCopyrightInfoViewController ()

@end

@implementation AlivcCopyrightInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"版权信息";

    UIScrollView *scrollView = [[UIScrollView alloc] init];
   // scrollView.frame = CGRectMake(0, 0, AlivcScreenWidth, AlivcScreenHeight);
   // scrollView.contentSize = CGSizeMake(AlivcScreenWidth, AlivcScreenHeight);
    [self.view addSubview:scrollView];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    //contentLabel.frame = CGRectMake(0, 0, AlivcScreenWidth, CGRectGetHeight(scrollView.frame));
    contentLabel.font = [UIFont systemFontOfSize:14.f];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.numberOfLines = 0;
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"版权信息" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    contentLabel.text = content;
    [contentLabel sizeToFit];
    //scrollView.contentSize = CGSizeMake(AlivcScreenWidth, contentLabel.frame.size.height + 50);
    [scrollView addSubview:contentLabel];
    
}

@end
