//
//  ALMainViewController.m
//  AliLiveSdk-Demo
//
//  Created by 薛林 on 2020/12/16.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "ALMainViewController.h"
#import "Masonry.h"
#import "UIColor+ALLiveColor.h"
#import "DemoUtil.h"

#import "AlivcLivePushReplayKitConfigViewController.h"
#import "AlivcLivePushConfigViewController.h"
#import "ALPullTestViewController.h"

@interface ALMainViewController ()

@property (nonatomic,strong)UILabel *titlelLabel;
@end

@implementation ALMainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupCellViews];
    [DemoUtil forceTestNetwork];
}

- (void)setupCellViews {
    UIImage *image = [UIImage imageNamed:@"home_background"];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@(image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width));
    }];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_title"]];
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    [bgView addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView).offset(20);
        make.bottom.equalTo(bgView).offset(-65);
        make.width.equalTo(@190);
        make.height.equalTo(@85);
    }];
    
    CGFloat margin = 20;
    CGFloat cellW = (self.view.frame.size.width - margin * 3) * 0.5;
    CGFloat cellH = 120;
    // 进入房间
    UIView *joinRoomView = [[UIView alloc] init];
    joinRoomView.tag = 1;
    [self setupConfige:joinRoomView title:NSLocalizedString(@"摄像头推流",nil) imageName:@"player_image"];
    [self.view addSubview:joinRoomView];
    [joinRoomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(margin);
        make.top.equalTo(bgView.mas_bottom).offset(10);
        make.width.equalTo(@(cellW));
        make.height.equalTo(@(cellH));
    }];
    // 摄像头推流
    UIView *cameraPushView = [[UIView alloc] init];
    cameraPushView.tag = 2;
    [self setupConfige:cameraPushView title:NSLocalizedString(@"录屏推流",nil) imageName:@"rtc_pull_image"];
    [self.view addSubview:cameraPushView];
    [cameraPushView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-margin);
        make.top.equalTo(joinRoomView);
        make.width.height.equalTo(joinRoomView);
    }];
    // 直播拉流
    UIView *livePullView = [[UIView alloc] init];
    livePullView.tag = 3;
    [self setupConfige:livePullView title:NSLocalizedString(@"直播播放",nil) imageName:@"pull_test_image"];
    [self.view addSubview:livePullView];
    [livePullView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(margin);
        make.top.equalTo(joinRoomView.mas_bottom).offset(margin);
        make.width.height.equalTo(joinRoomView);
    }];
    // 测试RTC拉流
    UIView *testRTCPullView = [[UIView alloc] init];
    testRTCPullView.tag = 4;
    [self setupConfige:testRTCPullView title:NSLocalizedString(@"直播播放",nil) imageName:@"main_rtc"];
//    [self.view addSubview:testRTCPullView];
//    [testRTCPullView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view).offset(-margin);
//        make.top.equalTo(livePullView);
//        make.width.height.equalTo(livePullView);
//    }];
    
    
    // 线上预发开关
//    UISwitch *envSwitch = [[UISwitch alloc] init];
//    envSwitch.tag = 105;
//    [self.view addSubview:envSwitch];
//    [envSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(testRTCPullView).offset(140);
//    }];
//    [envSwitch addTarget:self action:@selector(envswitchAction:) forControlEvents:UIControlEventValueChanged];
    // 默认线上
//    [[NSUserDefaults standardUserDefaults] setObject:LIVE_ONLINE_IP_URL forKey:@"AL_serverURL"];
//    [[UserSessionManager sharedInstance] setCurrentRoomIP:LIVE_ONLINE_IP_URL];
//    [[NSUserDefaults standardUserDefaults] setObject:LIVE_ONLINE_ACCOUNTID forKey:@"live_config_accountid"];

    // 环境文案
//    _titlelLabel = [[UILabel alloc] init];
//    _titlelLabel.tag = 106;
//    _titlelLabel.text = @"预发";
//    [self.view addSubview:_titlelLabel];
//    [_titlelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(envSwitch).offset(10);
//        make.left.equalTo(envSwitch).offset(80);
//        make.width.mas_equalTo(50);
//    }];
    // 版本号
    NSString *version = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.textColor = [UIColor colorWithHexString:@"#8C8C8C"];
    versionLabel.tag = 107;
    versionLabel.font = [UIFont systemFontOfSize:12.0];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.numberOfLines = 0;
    versionLabel.text = NSLocalizedString(@"本Demo为用于展示阿里云移动推流sdk主要功能",nil);//[NSString stringWithFormat:@"%@",version?version:@"4.0.2"];
    [self.view addSubview:versionLabel];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
}

- (void)envswitchAction:(id)sender{
    UISwitch *envSwitch = (UISwitch *)sender;
    if (envSwitch.isOn) {// 如果是线上，切到预发
//        [[NSUserDefaults standardUserDefaults] setObject:LIVE_ONLINE_IP_URL forKey:@"AL_serverURL"];
//        [[UserSessionManager sharedInstance] setCurrentRoomIP:LIVE_ONLINE_IP_URL];
//        [[NSUserDefaults standardUserDefaults] setObject:LIVE_ONLINE_ACCOUNTID forKey:@"live_config_accountid"];
        _titlelLabel.text = NSLocalizedString(@"线上",nil);
    }else{
//        [[NSUserDefaults standardUserDefaults] setObject:LIVE_PRE_IP_URL forKey:@"AL_serverURL"];
//        [[UserSessionManager sharedInstance] setCurrentRoomIP:LIVE_PRE_IP_URL];
//        [[NSUserDefaults standardUserDefaults] setObject:LIVE_PRE_ACCOUNTID forKey:@"live_config_accountid"];
        _titlelLabel.text = NSLocalizedString(@"预发",nil);
    }
}

- (void)setupConfige:(UIView *)targetView title:(NSString *)title imageName:(NSString *)imageName {
    targetView.backgroundColor = [UIColor whiteColor];
    targetView.layer.cornerRadius = 8.f;
    targetView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    targetView.layer.shadowOffset = CGSizeMake(0, 0);
    targetView.layer.shadowRadius = 8;
    targetView.layer.shadowOpacity = 0.8;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:imageName];
//    imageView.backgroundColor = [UIColor colorWithHexString:@"#1AED99" alpha:0.2];
    [targetView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(targetView).offset(12);
        make.left.equalTo(targetView).offset(20);
        make.width.height.equalTo(@48);
    }];

    UILabel *titleLabel = [[UILabel alloc] init];
    [targetView addSubview:titleLabel];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.text = title;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(targetView).offset(20);
        make.bottom.equalTo(targetView).offset(-15);
        make.right.equalTo(targetView);
    }];
    [targetView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)]];
}

- (void)gestureAction:(UIGestureRecognizer *)g {
    if (![DemoUtil getEssentialRights]) {
        return;
    }
    UIView *targetView = g.view;
    switch (targetView.tag) {
        case 1:
            [self joinRoom];
            break;
        case 2:
            [self cameraPush];
            break;
        case 3:
            [self livePull];
            break;
        case 4:
            [self testRTC];
            break;
        default:
            break;
    }
}

- (void)joinRoom {
    // 新接口 AlivcLivePusher
    AlivcLivePushConfigViewController *pushConfigVC = [[AlivcLivePushConfigViewController alloc] init];
    [self.navigationController pushViewController:pushConfigVC animated:YES];

//    ALRoomSettingViewController *roomVc = [[ALRoomSettingViewController alloc] init];
//    UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] init];
//    backBtnItem.title = @"返回";
//    self.navigationItem.backBarButtonItem = backBtnItem;
//    [self.navigationController pushViewController:roomVc animated:YES];
}

- (void)cameraPush {
    // 新接口 AlivcLivePusher
    AlivcLivePushReplayKitConfigViewController *replayKitConfigVC = [[AlivcLivePushReplayKitConfigViewController alloc] init];
    [self.navigationController pushViewController:replayKitConfigVC animated:YES];

//    ALPushTestViewController *pushVc = [[ALPushTestViewController alloc] init];
//    [self.navigationController pushViewController:pushVc animated:YES];
}
- (void)livePull {
    ALPullTestViewController *pushVc = [[ALPullTestViewController alloc] init];
    [self.navigationController pushViewController:pushVc animated:YES];
}
- (void)testRTC {
//    ALRTCTestViewController *pushVc = [[ALRTCTestViewController alloc] init];
//    [self.navigationController pushViewController:pushVc animated:YES];
}

@end
