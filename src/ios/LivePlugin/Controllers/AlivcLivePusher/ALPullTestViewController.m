//
//  ALPullTestViewController.m
//  AliLiveSdk-Demo
//
//  Created by BOTAO on 2020/12/17.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "ALPullTestViewController.h"
#import "AlivcQRCodeViewController.h"
#import "Masonry.h"
#import "ALLiveItemSettingView.h"
#import "UIColor+ALLiveColor.h"
#import "ALBeautySettingView.h"
#import "ALLiveMacro.h"
#import "ALLiveMonitorView.h"
#import "DemoUtil.h"
@interface ALPullTestViewController ()<AVPDelegate, UITextFieldDelegate, ALLiveItemSettingViewDelegate>
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) AliPlayer *player;
@property (nonatomic, strong) NSString *playurl;
@property (nonatomic, strong) ALBeautySettingView *beautyView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) ALLiveItemSettingView *settingView;
@property (nonatomic, strong) ALLiveMonitorView *monitorView;
@end

@implementation ALPullTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupViews];
    [self setupSearchView];
}


- (void)setupViews {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_push_bgm_bgImage"]];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
//    AlivcQRCodeViewController *QRController = [[AlivcQRCodeViewController alloc] init];
//    __weak typeof(self) weakSelf = self;
//    QRController.backValueBlock = ^(NSString *value) {
//
//        if (value) {
//            weakSelf.publisherURLTextField.text = value;
//        }
//    };
//    [self.navigationController pushViewController:QRController animated:YES];

    self.renderView = [[UIView alloc] init];
    [self.view addSubview:self.renderView];
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    // 监控数据view
     _monitorView = [[ALLiveMonitorView alloc] initWithFrame:CGRectMake(10, 130, self.view.frame.size.width - 20, 150)];
     _monitorView.backgroundColor = [UIColor clearColor];
     [self.view addSubview:_monitorView];
    _monitorView.hidden = YES;
}

// 扫描框
- (void)setupSearchView {
    [self.renderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction)]];
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setImage:[UIImage imageNamed:@"liveroom_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(leaveRoom) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(StatusBarHeight);
        make.left.equalTo(self.view).offset(20);
        make.height.width.equalTo(@30);
    }];
    closeButton.tag = 9;
    
    UIView *searchView = [[UIView alloc] init];
    [self.view addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@36);
        make.top.equalTo([self.view viewWithTag:9].mas_bottom).offset(28);
    }];
    searchView.layer.cornerRadius = 18;
    searchView.layer.masksToBounds = YES;
    searchView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    UIButton *scanButton = [[UIButton alloc] init];
    [searchView addSubview:scanButton];
    [scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView).offset(18);
        make.centerY.equalTo(searchView);
        make.width.height.equalTo(@20);
    }];
    [scanButton setImage:[UIImage imageNamed:@"QR"] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanUrl) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] init];
    [searchView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scanButton.mas_right).offset(8);
        make.centerY.equalTo(scanButton);
        make.height.equalTo(@20);
        make.width.equalTo(@1);
    }];
    line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    
    UITextField *textField = [[UITextField alloc] init];
    [searchView addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(line.mas_right).offset(8);
        make.centerY.equalTo(searchView);
        make.top.bottom.equalTo(searchView);
        make.right.equalTo(searchView).offset(-100);
    }];
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = [UIColor whiteColor];
    textField.delegate = self;
    [self setupTextField:textField playerholder:NSLocalizedString(@"输入拉流url", nil)];
    self.textField = textField;
    
    UIButton *pullButton = [[UIButton alloc] init];
    pullButton.backgroundColor = [UIColor colorWithHexString:@"#1AED99"];
    [pullButton setTitle:NSLocalizedString(@"拉流", nil) forState:UIControlStateNormal];
    [pullButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pullButton.titleLabel.font = [UIFont systemFontOfSize:17];
    pullButton.layer.cornerRadius = 18.f;
    pullButton.layer.masksToBounds = YES;
    [self.view addSubview:pullButton];
    [pullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(searchView);
        make.centerY.equalTo(searchView);
        make.width.equalTo(@100);
        make.height.equalTo(@38);
    }];
    [pullButton addTarget:self action:@selector(startPull) forControlEvents:UIControlEventTouchUpInside];
    
    ALLiveItemSettingView *itemSettingView = [[ALLiveItemSettingView alloc] initWithSetting:ALLiveItemSettingRolePull];
    itemSettingView.hidden = NO;
    itemSettingView.delegate = self;
    [self.view addSubview:itemSettingView];
    [itemSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(70);
        make.right.equalTo(self.view).offset(-70);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-36);
        } else {
            make.bottom.equalTo(self.view).offset(-36);
        }
        make.height.equalTo(@90);
    }];
    self.settingView = itemSettingView;
    [self.view layoutIfNeeded];
}


- (void)leaveRoom {
    [self stopPull];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createPlayerAndPlay {
    self.player = [[AliPlayer alloc] init];
    //先获取配置
    AVPConfig *config = [self.player getConfig];
    if([self.playurl hasPrefix:@"artc://"]){
        //设置最大延迟为1000，延迟控制交由RTS控制
        config.maxDelayTime = 1000;
        //设置播放器启播缓存为10ms，数据控制由RTS控制。
        config.highBufferDuration = 10;
        config.startBufferDuration = 10;
    }
    else
    {
        config.maxDelayTime = 10000;
        config.highBufferDuration = 100;
        config.startBufferDuration = 100;
    }
    [self.player setConfig:config];
    
    self.player.autoPlay = YES;
    self.player.delegate = self;
    self.player.playerView = self.renderView;
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:self.playurl];
    [self.player setUrlSource:source];
    [self.player prepare];
    // 开启播放器日志
    [AliPlayer setEnableLog:YES];
    [AliPlayer setLogCallbackInfo:LOG_LEVEL_TRACE callbackBlock:^(AVPLogLevel logLevel,NSString* strLog){
        [DemoUtil writeLogMessageToLocationFile:strLog isCover:NO];
    }];
}

- (void)startPull {
    self.playurl = self.textField.text;
    if (self.playurl == nil) {
        [DemoUtil showToastMessage:NSLocalizedString(@"无效的URL", nil)];
        return;
    }
    self.settingView.hidden = NO;
    [DemoUtil showToastMessage:NSLocalizedString(@"开始拉流", nil)];
    [self createPlayerAndPlay];
}

- (void)stopPull {
    [self.player stop];
    [self.player destroy];
}

- (void)scanUrl {
    
    AlivcQRCodeViewController *QRController = [[AlivcQRCodeViewController alloc] init];
//    __weak typeof(self) weakSelf = self;
//    QRController.backValueBlock = ^(NSString *value) {
//        self.playurl = value;
//        if (value) {
//            self.textField.text  = value;
//        }
//    };
    [self.navigationController pushViewController:QRController animated:YES];
}

- (void)inputUrl {
    [DemoUtil showTextInputAlert:NSLocalizedString(@"输入URL", nil) confirmBlock:^(NSString * _Nonnull url) {
        self.textField.text = [NSString stringWithFormat:@"%@", url];
        self.playurl = url;
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *url = textField.text ?:@"";
    if (url.length == 0) {
        [DemoUtil showToastMessage:NSLocalizedString(@"无效的URL", nil)];
        return NO;
    }
    self.playurl = textField.text ?:@"";
    [self startPull];
    [textField resignFirstResponder];
    return YES;
}
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    if (self.player.rate > 0) {
        [self.player stop];
    }
    [self.player destroy];
}

- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    [DemoUtil showErrorToast:errorModel.message];
    [self.player stop];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player prepare];
    });
}

- (void)setupTextField:(UITextField *)textField playerholder:(NSString *)playerholder {
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = [UIFont systemFontOfSize:16];
    textField.tintColor = [UIColor whiteColor];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:playerholder attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:textField.font}];
    textField.attributedPlaceholder = attrString;
}

- (void)didSelectStopWatch {
    [self stopPull];
}

- (void)didSelectSilence {
    if (self.player.muted) {
        self.player.muted = NO;
    } else {
        self.player.muted = YES;
    }
    if (self.player.muted) {
        self.settingView.setSilenceCell.imageView.image = [UIImage imageNamed:@"pull_cancel_slience"];
        self.settingView.setSilenceCell.titleLabel.text = NSLocalizedString(@"取消静音", nil);
    } else {
        self.settingView.setSilenceCell.imageView.image = [UIImage imageNamed:@"camera_push_silence"];
        self.settingView.setSilenceCell.titleLabel.text = NSLocalizedString(@"静音", nil);
    }
}

- (void)didSelectDataIndicators {
    self.monitorView.hidden =  !self.monitorView.hidden;
}


/**
 * @brief 本地视频统计信息(2s触发一次)
 * @param localVideoStats 本地视频统计信息
 * @note SDK每两秒触发一次此统计信息回调
 */
/*
- (void)onLiveLocalVideoStats:(AliLiveEngine *)publisher stats:(AliLiveLocalVideoStats *)localVideoStats{
    __weak ALPullTestViewController *wkSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO 12.30
//        if (wkSelf.monitorView.hidden) {
//            wkSelf.monitorView.hidden = NO;
//        }
        wkSelf.monitorView.hidden = YES;
        wkSelf.monitorView.titleLabel.text = @"本地视频统计信息";
        wkSelf.monitorView.sentBitrateLabel.text = [NSString stringWithFormat:@"发送码率： %d kbps", (int)localVideoStats.sentBitrate/1000];
        wkSelf.monitorView.sentFpsLabel.text = [NSString stringWithFormat:@"发送帧率：%d fps",localVideoStats.sentFps];
        wkSelf.monitorView.encodeFpsLabel.text = [NSString stringWithFormat:@"编码帧率：%d",localVideoStats.encodeFps];
    });
}
*/
- (void)touchAction {
    [self.view.window endEditing:YES];
}
@end
