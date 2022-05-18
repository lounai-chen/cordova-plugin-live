//
//  AlivcPushConfigViewController.m
//  AlivcLiveCaptureDev
//
//  Created by lyz on 2017/9/20.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AlivcLivePushConfigViewController.h"
#import "AlivcParamTableViewCell.h"
#import "AlivcParamModel.h"
#import "AlivcWatermarkSettingView.h"
#import "AlivcLivePusherViewController.h"
#import "AlivcQRCodeViewController.h"
#import "UIColor+ALLiveColor.h"
#import <AlivcLivePusher/AlivcLivePusher.h>
#import "JYAddressPicker.h"
#import "DemoUtil.h"
#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@interface AlivcLivePushConfigViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *segmentLineView;
@property (nonatomic, strong) UITextField *publisherURLTextField;
@property (nonatomic, strong) UIButton *QRCodeButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *urlCopyButton;
@property (nonatomic, strong) UITableView *paramTableView;
@property (nonatomic, strong) UIButton *publisherButton;
@property (nonatomic, strong) NSMutableArray *dataArray;// 推流参数
@property (nonatomic, strong) NSMutableArray *pushArray;// 推流功能
@property (nonatomic, strong) AlivcWatermarkSettingView *waterSettingView;
@property (nonatomic, assign) NSInteger headTagIndex; // 0:推流参数 1:推流功能
@property (nonatomic, assign) BOOL isUseAsync; // 是否使用异步接口
@property (nonatomic, assign) BOOL isUseWatermark; // 是否使用水印
@property (nonatomic, copy) NSString *authDuration; // 测试鉴权，过期时长
@property (nonatomic, copy) NSString *authKey; // 测试鉴权，账号key
@property (nonatomic, strong) AlivcLivePushConfig *pushConfig;
@property (nonatomic, assign) BOOL isUserMainStream;
@property (nonatomic, assign) BOOL isUserMixStream;
@property (nonatomic, assign) BOOL isKeyboardShow;
@property (nonatomic, assign) CGRect tableViewFrame;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIActionSheet *m_actionSheet;

@property (nonatomic, assign) BOOL settingLelel;
@property (nonatomic, assign) BOOL beautyOn;
@end

@implementation AlivcLivePushConfigViewController

- (void)viewDidLoad {// : (NSString *)url{
    //[super viewDidLoad];
    [self setupParamData];
    [self setupSubviews];
    [self createTopTabBarSegment];
    [self addKeyboardNoti];
    [self setupInfoLabel];
    [self publiherButtonAction_v2];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UI
- (void)setupSubviews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"pusher_setting", nil);
    
    CGFloat retractX = 5;
    CGFloat viewWidth = 600 - retractX * 2;
    
    self.publisherURLTextField = [[UITextField alloc] init];
    
    if(KIsiPhoneX) {
        self.publisherURLTextField.frame = CGRectMake(80, 70, viewWidth - 90,  (25));
    }else {
        self.publisherURLTextField.frame = CGRectMake(80, 50, viewWidth - 90,  (25));
    }
    
    self.publisherURLTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.publisherURLTextField.placeholder = NSLocalizedString(@"input_tips", nil);
    self.publisherURLTextField.font = [UIFont systemFontOfSize:14.f];
    self.publisherURLTextField.clearsOnBeginEditing = NO;
    self.publisherURLTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(5, CGRectGetMinY(self.publisherURLTextField.frame), 30,  CGRectGetHeight(self.publisherURLTextField.frame));
    [self.backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    self.QRCodeButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.QRCodeButton.frame = CGRectMake(28,
                                         CGRectGetMinY(self.publisherURLTextField.frame),
                                         50,
                                         CGRectGetHeight(self.publisherURLTextField.frame));
    [self.QRCodeButton setImage:[UIImage imageNamed:@"QR"] forState:(UIControlStateNormal)];
    self.QRCodeButton.layer.masksToBounds = YES;
    self.QRCodeButton.layer.cornerRadius = 10;
    [self.QRCodeButton addTarget:self action:@selector(QRCodeButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.publisherButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.publisherButton.frame = CGRectMake(20, 0,   40, 50);
   // self.publisherButton.center = CGPointMake( 600 / 2, AlivcScreenHeight - 40);
    self.publisherButton.backgroundColor = [UIColor blueColor];
    [self.publisherButton setTitle:NSLocalizedString(@"start_button", nil) forState:(UIControlStateNormal)];
    self.publisherButton.layer.masksToBounds = YES;
    self.publisherButton.layer.cornerRadius = 10;
    [self.publisherButton addTarget:self action:@selector(publiherButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    // tableView设计
    CGRect tableframe = CGRectMake(retractX,
                                   CGRectGetMaxY(self.QRCodeButton.frame) + 45,
                                   viewWidth,
                                   CGRectGetMinY(self.publisherButton.frame) - CGRectGetMaxY(self.QRCodeButton.frame) - 45);
    self.paramTableView = [[UITableView alloc] initWithFrame:tableframe style:UITableViewStyleGrouped];
    self.paramTableView.delegate = (id)self;
    self.paramTableView.dataSource = (id)self;
    self.paramTableView.separatorStyle = YES;
    self.paramTableView.backgroundColor = [UIColor whiteColor];
    self.paramTableView.showsVerticalScrollIndicator = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.paramTableView reloadData];
        [self updateBitrateAndFPSCell];
    });

    
   // self.waterSettingView = [[AlivcWatermarkSettingView alloc] initWithFrame:(CGRectMake(0, AlivcScreenHeight - AlivcSizeHeight(330), AlivcScreenWidth, AlivcSizeHeight(330)))];
    
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.publisherURLTextField];
    [self.view addSubview:self.QRCodeButton];
    [self.view addSubview:self.publisherButton];
    [self.view addSubview:self.paramTableView];
    self.isKeyboardShow = false;
    self.tableViewFrame = self.paramTableView.frame;
}

#pragma mark - Segment
- (void)createTopTabBarSegment
{
    if(!_segmentLineView)
    {
      //  _segmentLineView = [[UIView alloc] initWithFrame:CGRectMake(50, self.QRCodeButton.bottom + 10, self.view.frame.size.width - 100, 35)];
        _segmentLineView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_segmentLineView];
    }
    //多个tab
    for (NSInteger i = 0; i < 2; i++)
    {
        UIButton * segmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        segmentButton.frame = CGRectMake(10 + i * 130, 0, 130,30);
        segmentButton.tag = 999 + i;
        if (i == 0) {
            [segmentButton setTitle:NSLocalizedString(@"推流参数",nil) forState:UIControlStateNormal];
//            [segmentButton setImageEdgeInsets:UIEdgeInsetsMake(25, 5, 0, 5)];
            [segmentButton setBackgroundImage:[UIImage imageNamed:@"alivc_slectbg"] forState:UIControlStateNormal];
        }else{
            [segmentButton setTitle:NSLocalizedString(@"推流功能",nil) forState:UIControlStateNormal];
        }
        [segmentButton  setTitleColor:[UIColor colorWithHexString:@"#222222"] forState:UIControlStateNormal];
        [segmentButton  setTitleColor:[UIColor colorWithHexString:@"#222222"] forState:UIControlStateSelected];
        segmentButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [segmentButton addTarget:self action:@selector(didTopTabSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        [_segmentLineView addSubview:segmentButton];
        // 初始化选中
        self.headTagIndex = 0;
        if (i == 0)//默认选中第一个tab
        {
            [segmentButton setSelected:YES];
//            [segmentButton setBackgroundColor:[UIColor greenColor]];
        }else{
//            [segmentButton setBackgroundColor:[UIColor blueColor]];
        }
    }
}
#pragma mark --  顶部tab选择事件
- (void)didTopTabSelectClick:(UIButton*)sender
{
    for (UIButton *btn in _segmentLineView.subviews) {
        [btn setTitleColor:[UIColor colorWithHexString:@"#222222"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    
    sender.selected = !sender.selected;
    UIButton *selBtn = (UIButton *)sender;
    if (selBtn.tag - 999 == 0) {
        self.headTagIndex = 0;
    }else{
        self.headTagIndex = 1;
    }
    [selBtn setBackgroundImage:[UIImage imageNamed:@"alivc_slectbg"] forState:UIControlStateNormal];
    selBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [selBtn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateNormal];
    
    // 刷新页面
    [self.paramTableView reloadData];

    // test
//    [self hurryupDataPicker:@[@"1111",NSLocalizedString(@"222222"]];
 }

- (void)hurryupDataPicker:(NSArray *)array{
    // 唤起actionsheet
    JYAddressPicker *addressPicker = [JYAddressPicker jy_showAt:self defaultShow:array];
    addressPicker.selectedItemBlock = ^(NSArray *addressArr) {
        
    };
}

#pragma mark - Data
- (void)setupParamData {
    self.isUseWatermark = NO;
    self.isUseAsync = YES;
    self.beautyOn = YES;
    
    self.pushConfig = [[AlivcLivePushConfig alloc] init];

    AlivcParamModel *titleresolutionModel = [[AlivcParamModel alloc] init];
    titleresolutionModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titleresolutionModel.title = NSLocalizedString(@"分辨率",nil);

    AlivcParamModel *resolutionModel = [[AlivcParamModel alloc] init];
    resolutionModel.title = NSLocalizedString(@"resolution_label", nil);
    resolutionModel.placeHolder = @"540P";
    resolutionModel.infoText = @"540P";
    resolutionModel.defaultValue = 4.0/7.0;
    resolutionModel.reuseId = AlivcParamModelReuseCellSlider;
    resolutionModel.sliderBlock = ^(int value){
        self.pushConfig.resolution = value;
        [self updateBitrateAndFPSCell];
    };
    
    AlivcParamModel *targetBitrateModel = [[AlivcParamModel alloc] init];
    targetBitrateModel.title = NSLocalizedString(@"target_bitrate", nil);
    targetBitrateModel.placeHolder = @"800";
    targetBitrateModel.infoText = @"Kbps";
    targetBitrateModel.reuseId = AlivcParamModelReuseCellInput;
    targetBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.targetVideoBitrate = value;
    };
    
    AlivcParamModel *segmentresolutionModel = [[AlivcParamModel alloc] init];
    segmentresolutionModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    segmentresolutionModel.title = @"";

    
    AlivcParamModel *minBitrateModel = [[AlivcParamModel alloc] init];
    minBitrateModel.title = NSLocalizedString(@"min_bitrate", nil);
    minBitrateModel.placeHolder = @"200";
    minBitrateModel.infoText = @"Kbps";
    minBitrateModel.reuseId = AlivcParamModelReuseCellInput;
    minBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.minVideoBitrate = value;
    };
    
    AlivcParamModel *initBitrateModel = [[AlivcParamModel alloc] init];
    initBitrateModel.title = NSLocalizedString(@"initial_bitrate", nil);
    initBitrateModel.placeHolder = @"800";
    initBitrateModel.infoText = @"Kbps";
    initBitrateModel.reuseId = AlivcParamModelReuseCellInput;
    initBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.initialVideoBitrate = value;
    };
    
    AlivcParamModel *audioBitrateModel = [[AlivcParamModel alloc] init];
    audioBitrateModel.title = NSLocalizedString(@"audio_bitrate", nil);
    audioBitrateModel.placeHolder = @"64";
    audioBitrateModel.infoText = @"Kbps";
    audioBitrateModel.reuseId = AlivcParamModelReuseCellInput;
    audioBitrateModel.valueBlock = ^(int value) {
        self.pushConfig.audioBitrate = value;
    };
    
    AlivcParamModel *titleaudioSampelModel = [[AlivcParamModel alloc] init];
    titleaudioSampelModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titleaudioSampelModel.title = @"音频采样率";

    
    AlivcParamModel *audioSampelModel = [[AlivcParamModel alloc] init];
    audioSampelModel.title = NSLocalizedString(@"audio_sampling_rate", nil);
    audioSampelModel.placeHolder = @"48kHz";
    audioSampelModel.infoText = @"48kHz";
    audioSampelModel.defaultValue = 1;
    audioSampelModel.reuseId = AlivcParamModelReuseCellSlider;
    audioSampelModel.sliderBlock = ^(int value) {
        self.pushConfig.audioSampleRate = value;
    };
    
    AlivcParamModel *titlefpsModel = [[AlivcParamModel alloc] init];
    titlefpsModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titlefpsModel.title = NSLocalizedString(@"采集帧率",nil);

    AlivcParamModel *fpsModel = [[AlivcParamModel alloc] init];
    fpsModel.title = NSLocalizedString(@"captrue_fps", nil);
//    fpsModel.segmentTitleArray = @[@"8",@"10",@"12",@"15",@"20",@"25",@"30"];
    fpsModel.defaultValue = 1.5/2.0;;
    fpsModel.infoText = @"20/fps";
    fpsModel.placeHolder = @"20/fps";
    fpsModel.reuseId = AlivcParamModelReuseCellSlider;
    fpsModel.sliderBlock = ^(int value) {
        self.pushConfig.fps = value;
    };
    
    AlivcParamModel *titleminFPSModel = [[AlivcParamModel alloc] init];
    titleminFPSModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titleminFPSModel.title = NSLocalizedString(@"最小帧率",nil);

    AlivcParamModel *minFPSModel = [[AlivcParamModel alloc] init];
    minFPSModel.title = NSLocalizedString(@"min_fps", nil);
//    minFPSModel.segmentTitleArray = @[@"8",@"10",@"12",@"15",@"20",@"25",@"30"];
    minFPSModel.defaultValue = 0/2.0;;
    minFPSModel.infoText = @"8/fps";
    minFPSModel.placeHolder = @"8/fps";
    minFPSModel.reuseId = AlivcParamModelReuseCellSlider;
    minFPSModel.sliderBlock = ^(int value) {
        self.pushConfig.minFps = value;
    };
    
    AlivcParamModel *titlegopModel = [[AlivcParamModel alloc] init];
    titlegopModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titlegopModel.title = NSLocalizedString(@"关键帧间隔",nil);

    AlivcParamModel *gopModel = [[AlivcParamModel alloc] init];
    gopModel.title = NSLocalizedString(@"keyframe_interval", nil);
//    gopModel.segmentTitleArray = @[@"1s",@"2s",@"3s",@"4s",@"5s"];
    gopModel.defaultValue =  1.0/2.0;
    gopModel.infoText = @"5s";
    gopModel.placeHolder = @"5s";
    gopModel.reuseId = AlivcParamModelReuseCellSlider;
    gopModel.sliderBlock = ^(int value) {
        self.pushConfig.videoEncodeGop = value;
    };
    
    AlivcParamModel *reconnectDurationModel = [[AlivcParamModel alloc] init];
    reconnectDurationModel.title = NSLocalizedString(@"reconnect_duration", nil);
    reconnectDurationModel.placeHolder = @"1000";
    reconnectDurationModel.infoText = @"ms";
    reconnectDurationModel.reuseId = AlivcParamModelReuseCellInput;
    reconnectDurationModel.valueBlock = ^(int value) {
        self.pushConfig.connectRetryInterval = value;
    };
    
    AlivcParamModel *reconnectTimeModel = [[AlivcParamModel alloc] init];
    reconnectTimeModel.title = NSLocalizedString(@"reconnect_times", nil);
    reconnectTimeModel.placeHolder = @"5";
    reconnectTimeModel.infoText = NSLocalizedString(@"次",nil);
    reconnectTimeModel.reuseId = AlivcParamModelReuseCellInput;
    reconnectTimeModel.valueBlock = ^(int value) {
        self.pushConfig.connectRetryCount = value;
    };
    
    AlivcParamModel *orientationModel = [[AlivcParamModel alloc] init];
    orientationModel.title = NSLocalizedString(@"landscape_model", nil);
    orientationModel.segmentTitleArray = @[NSLocalizedString(@"竖屏",nil),NSLocalizedString(@"横屏向左",nil),NSLocalizedString(@"横屏向右",nil)];
    orientationModel.defaultValue = 0;
    orientationModel.reuseId = AlivcParamModelReuseCellSegment;
    orientationModel.segmentBlock = ^(int value) {
        self.pushConfig.orientation = value;
        
        if(self.pushConfig.pauseImg) {
            if(self.pushConfig.orientation == AlivcLivePushOrientationPortrait) {
                self.pushConfig.pauseImg = [UIImage imageNamed:@"background_push.png"];
            } else{
                self.pushConfig.pauseImg = [UIImage imageNamed:@"background_push_land.png"];
            }
        }
        
        if(self.pushConfig.networkPoorImg) {
            if(self.pushConfig.orientation == AlivcLivePushOrientationPortrait) {
                self.pushConfig.networkPoorImg = [UIImage imageNamed:@"poor_network.png"];
            } else{
                self.pushConfig.networkPoorImg = [UIImage imageNamed:@"poor_network_land.png"];
            }
        }

    };
    
    AlivcParamModel *audioChannelModel = [[AlivcParamModel alloc] init];
    audioChannelModel.title = NSLocalizedString(@"sound_track", nil);
    audioChannelModel.segmentTitleArray = @[NSLocalizedString(@"single_track", nil),NSLocalizedString(@"dual_track", nil)];
    audioChannelModel.defaultValue = 0;
    audioChannelModel.reuseId = AlivcParamModelReuseCellSegment;
    audioChannelModel.segmentBlock = ^(int value) {
        self.pushConfig.audioChannel = value;
    };
    
    AlivcParamModel *audioProfileModel = [[AlivcParamModel alloc] init];
    audioProfileModel.title = NSLocalizedString(@"audio_profile", nil);
    audioProfileModel.segmentTitleArray = @[@"AAC_LC",@"HE_AAC",@"HEAAC_V2",@"AAC_LD"];
    audioProfileModel.defaultValue = 0;
    audioProfileModel.reuseId = AlivcParamModelReuseCellSegment;
    audioProfileModel.segmentBlock = ^(int value) {
        self.pushConfig.audioEncoderProfile = value;
    };
    
    AlivcParamModel *mirrorModel = [[AlivcParamModel alloc] init];
    mirrorModel.title = NSLocalizedString(@"push_mirror", nil);
    mirrorModel.defaultValue = 0;
//    mirrorModel.titleAppose = NSLocalizedString(@"preview_mirror", nil);
    mirrorModel.defaultValueAppose = 0;
    mirrorModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    mirrorModel.switchBlock = ^(int index, BOOL open) {
            self.pushConfig.pushMirror = open?true:false;
    };
    AlivcParamModel *premirrorModel = [[AlivcParamModel alloc] init];
    premirrorModel.title = NSLocalizedString(@"preview_mirror", nil);
    premirrorModel.defaultValue = 0;
//    premirrorModel.titleAppose = NSLocalizedString(@"preview_mirror", nil);
    premirrorModel.defaultValueAppose = 0;
    premirrorModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    premirrorModel.switchBlock = ^(int index, BOOL open) {
            self.pushConfig.previewMirror = open?true:false;
    };
    
    AlivcParamModel *audiOnly_encodeModeModel = [[AlivcParamModel alloc] init];
    audiOnly_encodeModeModel.title = NSLocalizedString(@"audio_only_push_streaming", nil);
    audiOnly_encodeModeModel.defaultValue = 0;
//    audiOnly_encodeModeModel.titleAppose = NSLocalizedString(@"video_hardware_encode", nil);
    audiOnly_encodeModeModel.defaultValueAppose = 1.0;
    audiOnly_encodeModeModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    audiOnly_encodeModeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.audioOnly = open?true:false;

    };
    
    
    AlivcParamModel *videoOnly_encodeModeModel = [[AlivcParamModel alloc] init];
    videoOnly_encodeModeModel.title = NSLocalizedString(@"video_hardware_encode", nil);
    videoOnly_encodeModeModel.defaultValue = 1;
//    audiOnly_encodeModeModel.titleAppose = NSLocalizedString(@"video_hardware_encode", nil);
    videoOnly_encodeModeModel.defaultValueAppose = 1.0;
    videoOnly_encodeModeModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    videoOnly_encodeModeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.videoEncoderMode = open?AlivcLivePushVideoEncoderModeHard:AlivcLivePushVideoEncoderModeSoft;
        if(open)
        {
            [self showAndHiddenVideoCodecVideo:NO];
        }
        else
        {
            [self showAndHiddenVideoCodecVideo:YES];
        }
    };
    
    AlivcParamModel *videohardEncoderCodec = [[AlivcParamModel alloc] init];
    videohardEncoderCodec.title = NSLocalizedString(@"video_hardware_encode_codec", nil);
    videohardEncoderCodec.segmentTitleArray = @[@"H264",@"H265"];
    videohardEncoderCodec.defaultValue = 0;
    videohardEncoderCodec.reuseId = AlivcParamModelReuseCellSegment;
    videohardEncoderCodec.segmentBlock = ^(int value) {
        self.pushConfig.videoHardEncoderCodec = (value == 1?AlivcLivePushVideoEncoderModeHardCodecHEVC:AlivcLivePushVideoEncoderModeHardCodecH264);
        
    };
    
    AlivcParamModel *bFrameModeModel = [[AlivcParamModel alloc] init];
    bFrameModeModel.title = NSLocalizedString(@"video_encode_b_frame", nil);
    bFrameModeModel.defaultValue = 0;
//    audiOnly_encodeModeModel.titleAppose = NSLocalizedString(@"video_hardware_encode", nil);
    bFrameModeModel.defaultValueAppose = 1.0;
    bFrameModeModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    bFrameModeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.openBFrame = open?true:false;

    };

    AlivcParamModel *autoFocus_FlashModel = [[AlivcParamModel alloc] init];
    autoFocus_FlashModel.title = NSLocalizedString(@"auto_focus", nil);
    autoFocus_FlashModel.defaultValue = 1.0;
//    autoFocus_FlashModel.titleAppose = NSLocalizedString(@"flash", nil);
    autoFocus_FlashModel.defaultValueAppose = 0;
    autoFocus_FlashModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    autoFocus_FlashModel.switchBlock = ^(int index, BOOL open) {

            self.pushConfig.autoFocus = open?true:false;
    };
    
    AlivcParamModel *FlashModel = [[AlivcParamModel alloc] init];
    FlashModel.title = NSLocalizedString(@"flash", nil);
    FlashModel.defaultValue = 1.0;
//    FlashModel.titleAppose = NSLocalizedString(@"flash", nil);
    FlashModel.defaultValueAppose = 0;
    FlashModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    FlashModel.switchBlock = ^(int index, BOOL open) {
            self.pushConfig.flash = open?true:false;
    };

    
    AlivcParamModel *beauty_cameraTypeModel = [[AlivcParamModel alloc] init];
    beauty_cameraTypeModel.title = NSLocalizedString(@"beauty_button", nil);
    beauty_cameraTypeModel.defaultValue = 1.0;
    beauty_cameraTypeModel.defaultValueAppose = 1.0;
    beauty_cameraTypeModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    beauty_cameraTypeModel.switchBlock = ^(int index, BOOL open) {
            self.beautyOn = open?true:false;
    };
    
    AlivcParamModel *cameraTypeModel = [[AlivcParamModel alloc] init];
    cameraTypeModel.title = NSLocalizedString(@"front_camera", nil);
    cameraTypeModel.defaultValue = 1.0;
    cameraTypeModel.defaultValueAppose = 1.0;
    cameraTypeModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    cameraTypeModel.switchBlock = ^(int index, BOOL open) {
            self.pushConfig.cameraType = open?AlivcLivePushCameraTypeFront:AlivcLivePushCameraTypeBack;
    };

    // 码率
    AlivcParamModel *autoBitrate = [[AlivcParamModel alloc] init];
    autoBitrate.title = NSLocalizedString(@"auto_bitrate", nil);
    autoBitrate.defaultValue = 1.0;
    autoBitrate.defaultValueAppose = 0;
    autoBitrate.reuseId = AlivcParamModelReuseCellSwitchButton;
    autoBitrate.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.enableAutoBitrate = open?true:false;
        /*
        if (index == 0) {
            self.pushConfig.enableAutoBitrate = open?true:false;
        } else {
            self.pushConfig.enableAutoResolution = open?true:false;
        }
         */
    };
    // 分辨率
    AlivcParamModel *pushStreamModel = [[AlivcParamModel alloc] init];
    pushStreamModel.title = NSLocalizedString(@"auto_resolution", nil);
    pushStreamModel.defaultValue = 0;
    pushStreamModel.defaultValueAppose = 0;
    pushStreamModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    pushStreamModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.enableAutoResolution = open?true:false;
        /*
        if (index == 0) {
            self.pushConfig.enableAutoBitrate = open?true:false;
        } else {
            self.pushConfig.enableAutoResolution = open?true:false;
        }
         */
    };
    // 分辨率Description
    AlivcParamModel *pushStreamModelDes = [[AlivcParamModel alloc] init];
    pushStreamModelDes.title = NSLocalizedString(@"分辨率自适应需要开启码率自适应,详细请参考Api文档",nil);
    pushStreamModelDes.reuseId = AlivcParamModelReuseCellSegmentWhite;
    
    
    // 分辨率
    AlivcParamModel *gaojisetModel = [[AlivcParamModel alloc] init];
    gaojisetModel.title = NSLocalizedString(@"gaojisetting", nil);
    gaojisetModel.defaultValue = 0;
    gaojisetModel.defaultValueAppose = 0;
    gaojisetModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    gaojisetModel.switchBlock = ^(int index, BOOL open) {
        self.settingLelel = open;
        [self.paramTableView reloadData];
        [self updateBitrateAndFPSCell];
    };
    
    AlivcParamModel *musicMode = [[AlivcParamModel alloc] init];
    musicMode.title = NSLocalizedString(@"audio_mode_music", nil);
    musicMode.reuseId = AlivcParamModelReuseCellSwitchButton;
    musicMode.defaultValue = 0.0;
    musicMode.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.pushConfig.audioScene = open ? AlivcLivePusherAudioScenarioMusicMode:AlivcLivePusherAudioScenarioDefaultMode;
        }
    };
    

    AlivcParamModel *userMainStream_userMixStreamModel = [[AlivcParamModel alloc] init];
    userMainStream_userMixStreamModel.title = NSLocalizedString(@"user_main_stream", nil);
    userMainStream_userMixStreamModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    userMainStream_userMixStreamModel.defaultValue = 0.0;
    //userMainStream_userMixStreamModel.titleAppose = NSLocalizedString(@"user_mix_stream", nil);
   // userMainStream_userMixStreamModel.defaultValueAppose = 0.0;
    //userMainStream_userMixStreamModel.reuseId = AlivcParamModelReuseCellSwitch;
    userMainStream_userMixStreamModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.isUserMainStream = open?true:false;
        }
        //else {
        //    self.isUserMixStream = open?true:false;
        //}
    };
    
    AlivcParamModel *asyncModel = [[AlivcParamModel alloc] init];
    asyncModel.title = NSLocalizedString(@"asynchronous_interface", nil);
    asyncModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    asyncModel.defaultValue = 1.0;
    asyncModel.switchBlock = ^(int index, BOOL open) {
        if (index == 0) {
            self.isUseAsync = open;
        }
    };
    
    AlivcParamModel *watermarkModel = [[AlivcParamModel alloc] init];
    watermarkModel.title = NSLocalizedString(@"watermark", nil);
    watermarkModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    watermarkModel.defaultValue = 0;
    watermarkModel.defaultValueAppose = 0;

    watermarkModel.switchBlock = ^(int index, BOOL open) {
        self.isUseWatermark = open;
    };

    
    AlivcParamModel *watermarSetkModel = [[AlivcParamModel alloc] init];
    watermarSetkModel.title = NSLocalizedString(@"watermark_setting", nil);
    watermarSetkModel.reuseId = AlivcParamModelReuseCellSwitchSetButton;
    watermarSetkModel.defaultValue = 1.0;
    watermarSetkModel.infoText = NSLocalizedString(@"去设置",nil);
    watermarSetkModel.switchBlock = ^(int index, BOOL open) {
        self.isUseWatermark = open;
    };
    watermarSetkModel.switchButtonBlock = ^(){
        [self.view addSubview:self.waterSettingView];
    };
    
    AlivcParamModel *videoOnly_audioHardwareEncodeModel = [[AlivcParamModel alloc] init];
    videoOnly_audioHardwareEncodeModel.title = NSLocalizedString(@"video_only_push_streaming", nil);
    videoOnly_audioHardwareEncodeModel.defaultValue = 0;
//    videoOnly_audioHardwareEncodeModel.titleAppose = NSLocalizedString(@"audio_hardware_encode", nil);
    videoOnly_audioHardwareEncodeModel.defaultValueAppose = 1.0;
    
    videoOnly_audioHardwareEncodeModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    videoOnly_audioHardwareEncodeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.videoOnly = open?true:false;
    };
    
    AlivcParamModel *audioHardwareEncodeModel = [[AlivcParamModel alloc] init];
    audioHardwareEncodeModel.title = NSLocalizedString(@"audio_hardware_encode", nil);
    audioHardwareEncodeModel.defaultValue = 1;
//    audioHardwareEncodeModel.titleAppose = NSLocalizedString(@"audio_hardware_encode", nil);
    audioHardwareEncodeModel.defaultValueAppose = 1.0;
    
    audioHardwareEncodeModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    audioHardwareEncodeModel.switchBlock = ^(int index, BOOL open) {
        self.pushConfig.audioEncoderMode = open?AlivcLivePushAudioEncoderModeHard:AlivcLivePushAudioEncoderModeSoft;
    };

    
    AlivcParamModel *backgroundImage_networkWeakImageModel = [[AlivcParamModel alloc] init];
    backgroundImage_networkWeakImageModel.title = NSLocalizedString(@"background_image", nil);
    backgroundImage_networkWeakImageModel.defaultValue = 1.0;
//    backgroundImage_networkWeakImageModel.titleAppose = NSLocalizedString(@"network_weak_image", nil);
    backgroundImage_networkWeakImageModel.defaultValueAppose = 1.0;
    
    backgroundImage_networkWeakImageModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    backgroundImage_networkWeakImageModel.switchBlock = ^(int index, BOOL open) {
            // 设置占位图片
            if(open) {
                if(self.pushConfig.orientation == AlivcLivePushOrientationPortrait) {
                    self.pushConfig.pauseImg = [UIImage imageNamed:@"background_push.png"];
                } else{
                    self.pushConfig.pauseImg = [UIImage imageNamed:@"background_push_land.png"];
                }
            }else {
                self.pushConfig.pauseImg = nil;
            }
            
        
    };
    
    AlivcParamModel *backweakNetgroundImage_networkWeakImageModel = [[AlivcParamModel alloc] init];
    backweakNetgroundImage_networkWeakImageModel.title = NSLocalizedString(@"network_weak_image", nil);
    backweakNetgroundImage_networkWeakImageModel.defaultValue = 1.0;
//    backweakNetgroundImage_networkWeakImageModel.titleAppose = NSLocalizedString(@"network_weak_image", nil);
    backweakNetgroundImage_networkWeakImageModel.defaultValueAppose = 1.0;
    
    backweakNetgroundImage_networkWeakImageModel.reuseId = AlivcParamModelReuseCellSwitchButton;
    backweakNetgroundImage_networkWeakImageModel.switchBlock = ^(int index, BOOL open) {
            if(open) {
                if(self.pushConfig.orientation == AlivcLivePushOrientationPortrait) {
                    self.pushConfig.networkPoorImg = [UIImage imageNamed:@"poor_network.png"];
                } else{
                    self.pushConfig.networkPoorImg = [UIImage imageNamed:@"poor_network_land.png"];
                }
            }else {
                self.pushConfig.networkPoorImg = nil;
            }
        
    };

    
    AlivcParamModel *qualityModeModel = [[AlivcParamModel alloc] init];
    qualityModeModel.title = NSLocalizedString(@"quality_mode_label", nil);
    qualityModeModel.segmentTitleArray = @[NSLocalizedString(@"清晰优先",nil),NSLocalizedString(@"流畅优先",nil),NSLocalizedString(@"自定义",nil)];
    qualityModeModel.defaultValue = 0;
    qualityModeModel.reuseId = AlivcParamModelReuseCellSegment;
    qualityModeModel.segmentBlock = ^(int value) {
        self.pushConfig.qualityMode = value;
        [self updateBitrateAndFPSCell];
    };
    
    AlivcParamModel *qualityModeModelDes = [[AlivcParamModel alloc] init];
    qualityModeModelDes.title = NSLocalizedString(@"视频码率和帧率仅在自定义模式下下可以调整",nil);
    qualityModeModelDes.reuseId = AlivcParamModelReuseCellSegmentWhite;
    
    AlivcParamModel *beautyModeModel = [[AlivcParamModel alloc] init];
    beautyModeModel.title = NSLocalizedString(@"beauty_mode_label", nil);
    beautyModeModel.segmentTitleArray = @[NSLocalizedString(@"普通版",nil),NSLocalizedString(@"专业版",nil)];
    beautyModeModel.defaultValue = 1.0;
    beautyModeModel.reuseId = AlivcParamModelReuseCellSegment;
    beautyModeModel.segmentBlock = ^(int value) {
        //self.pushConfig.beautyMode = value;
    };
    
    AlivcParamModel *authTimeModel = [[AlivcParamModel alloc] init];
    authTimeModel.title = NSLocalizedString(@"AuthTime", nil);
    authTimeModel.placeHolder = @"";
    authTimeModel.infoText = @"ms";
    authTimeModel.reuseId = AlivcParamModelReuseCellInput;
    authTimeModel.stringBlock = ^(NSString *message) {
        self.authDuration = message;
    };
    
    AlivcParamModel *authKeyModel = [[AlivcParamModel alloc] init];
    authKeyModel.title = NSLocalizedString(@"AuthKey", nil);
    authKeyModel.placeHolder = @"";
    authKeyModel.infoText = @"";
    authKeyModel.reuseId = AlivcParamModelReuseCellInput;
    authKeyModel.stringBlock = ^(NSString *message) {
        self.authKey = message;
    };

    AlivcParamModel *titlereconnectDurationModel = [[AlivcParamModel alloc] init];
    titlereconnectDurationModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titlereconnectDurationModel.title = NSLocalizedString(@"自动重连",nil);

    AlivcParamModel *titlewatermarkModel = [[AlivcParamModel alloc] init];
    titlewatermarkModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titlewatermarkModel.title = NSLocalizedString(@"水印",nil);

    AlivcParamModel *titlepremirrorModel = [[AlivcParamModel alloc] init];
    titlepremirrorModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titlepremirrorModel.title = NSLocalizedString(@"镜像",nil);

    AlivcParamModel *titlenetworkWeakImageModel = [[AlivcParamModel alloc] init];
    titlenetworkWeakImageModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titlenetworkWeakImageModel.title = NSLocalizedString(@"相机控制",nil);

    AlivcParamModel *titlebeauty_cameraTypeModel = [[AlivcParamModel alloc] init];
    titlebeauty_cameraTypeModel.reuseId = AlivcParamModelReuseCellSliderHeader;
    titlebeauty_cameraTypeModel.title = NSLocalizedString(@"美颜开关",nil);

    AlivcParamModel *titledianpianpush = [[AlivcParamModel alloc] init];
    titledianpianpush.reuseId = AlivcParamModelReuseCellSliderHeader;
    titledianpianpush.title = NSLocalizedString(@"垫片推流",nil);

    AlivcParamModel *titleother = [[AlivcParamModel alloc] init];
    titleother.reuseId = AlivcParamModelReuseCellSliderHeader;
    titleother.title = NSLocalizedString(@"其他功能",nil);

    
    self.dataArray = [NSMutableArray arrayWithObjects:titleresolutionModel,resolutionModel,autoBitrate,pushStreamModel,pushStreamModelDes,segmentresolutionModel,gaojisetModel, qualityModeModel,qualityModeModelDes,targetBitrateModel, minBitrateModel, initBitrateModel, audioBitrateModel, audioSampelModel, titlefpsModel,fpsModel, titleminFPSModel,minFPSModel, titlegopModel,gopModel,segmentresolutionModel, audioProfileModel, audioChannelModel,audiOnly_encodeModeModel,videoOnly_audioHardwareEncodeModel,audioHardwareEncodeModel,videoOnly_encodeModeModel,videohardEncoderCodec, bFrameModeModel, nil];
  
    self.pushArray = [NSMutableArray arrayWithObjects:segmentresolutionModel, orientationModel,titlereconnectDurationModel,reconnectDurationModel, reconnectTimeModel,titlewatermarkModel,watermarkModel,watermarSetkModel, titlepremirrorModel,mirrorModel,premirrorModel,titlenetworkWeakImageModel,cameraTypeModel,autoFocus_FlashModel,titlebeauty_cameraTypeModel,beauty_cameraTypeModel,titledianpianpush,backgroundImage_networkWeakImageModel,backweakNetgroundImage_networkWeakImageModel,titleother,userMainStream_userMixStreamModel, asyncModel, musicMode, nil];
    // Demo 中pushConfig初始值设置
    // 默认支持背景图片和弱网图片推流
    self.pushConfig.pauseImg = [UIImage imageNamed:@"background_push.png"];
    self.pushConfig.networkPoorImg = [UIImage imageNamed:@"poor_network.png"];
}

- (void)updateBitrateAndFPSCell {
    int targetBitrate = 0;
    int minBitrate = 0;
    int initBitrate = 0;
    BOOL enable = NO;
    
    if (self.pushConfig.qualityMode == AlivcLivePushQualityModeFluencyFirst) {
        // 流畅度优先模式，bitrate 固定值不可修改
        enable = NO;
        switch (self.pushConfig.resolution) {
            case AlivcLivePushResolution180P:
                targetBitrate = 250;
                minBitrate = 80;
                initBitrate = 200;
                break;
            case AlivcLivePushResolution240P:
                targetBitrate = 350;
                minBitrate = 120;
                initBitrate = 300;
                break;
            case AlivcLivePushResolution360P:
                targetBitrate = 600;
                minBitrate = 200;
                initBitrate = 400;
                break;
            case AlivcLivePushResolution480P:
                targetBitrate = 800;
                minBitrate = 300;
                initBitrate = 600;
                break;
            case AlivcLivePushResolution540P:
                targetBitrate = 1000;
                minBitrate = 300;
                initBitrate = 800;
                break;
            case AlivcLivePushResolution720P:
                targetBitrate = 1200;
                minBitrate = 300;
                initBitrate = 1000;
                break;
            case AlivcLivePushResolution1080P:
                targetBitrate = 2200;
                minBitrate = 1200;
                initBitrate = 1500;
                break;
            default:
                break;
        }
    }
    
    if (self.pushConfig.qualityMode == AlivcLivePushQualityModeResolutionFirst) {
        // 清晰度优先模式，bitrate 固定值不可修改
        enable = NO;
        switch (self.pushConfig.resolution) {
            case AlivcLivePushResolution180P:
                targetBitrate = 550;
                minBitrate = 120;
                initBitrate = 300;
                break;
            case AlivcLivePushResolution240P:
                targetBitrate = 750;
                minBitrate = 180;
                initBitrate = 450;
                break;
            case AlivcLivePushResolution360P:
                targetBitrate = 1000;
                minBitrate = 300;
                initBitrate = 600;
                break;
            case AlivcLivePushResolution480P:
                targetBitrate = 1200;
                minBitrate = 300;
                initBitrate = 800;
                break;
            case AlivcLivePushResolution540P:
                targetBitrate = 1400;
                minBitrate = 600;
                initBitrate = 1000;
                break;
            case AlivcLivePushResolution720P:
                targetBitrate = 2000;
                minBitrate = 600;
                initBitrate = 1500;
                break;
            case AlivcLivePushResolution1080P:
                targetBitrate = 2500;
                minBitrate = 1200;
                initBitrate = 1800;
                break;
            default:
                break;
        }
    }
    
    if (self.pushConfig.qualityMode == AlivcLivePushQualityModeCustom) {
        // 自定义模式，bitrate 固定值可修改
        enable = YES;
        targetBitrate = self.pushConfig.targetVideoBitrate;
        minBitrate = self.pushConfig.minVideoBitrate;
        initBitrate = self.pushConfig.initialVideoBitrate;
    }
    
    AlivcParamTableViewCell *targetCell = [self.paramTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0]];
    [targetCell updateDefaultValue:targetBitrate enable:enable];
        
    AlivcParamTableViewCell *minCell = [self.paramTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
    [minCell updateDefaultValue:minBitrate enable:enable];
        
    AlivcParamTableViewCell *initCell = [self.paramTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]];
    [initCell updateDefaultValue:initBitrate enable:enable];
    
}

- (void)showAndHiddenVideoCodecVideo:(BOOL) isHidden
{
    AlivcParamTableViewCell *targetCell = [self.paramTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:27 inSection:0]];
    if(isHidden)
    {
        [targetCell setHidden:YES];
    }
    else
    {
        [targetCell setHidden:NO];
    }
    
    targetCell = [self.paramTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:28 inSection:0]];
    if(isHidden)
    {
        [targetCell setHidden:YES];
    }
    else
    {
        [targetCell setHidden:NO];
    }
}

- (NSString *)getWatermarkPathWithIndex:(NSInteger)index {
    NSString *watermarkBundlePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"watermark"] ofType:@"png"];
    return watermarkBundlePath;
}

#pragma mark - Keyboard

- (void)addKeyboardNoti {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification *)sender {
  
    if(!self.isKeyboardShow){
     
        //获取键盘的frame
        CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        // 修改tableView frame
        [UIView animateWithDuration:0 animations:^{
            CGRect frame = self.paramTableView.frame;
            frame.size.height = frame.size.height - keyboardFrame.size.height;
            self.paramTableView.frame = frame;
        }];
        
        self.isKeyboardShow = true;
    }
 
}


- (void)keyboardWillHide:(NSNotification *)sender {
  
    if(self.isKeyboardShow){
        self.paramTableView.frame = self.tableViewFrame;
        self.isKeyboardShow = false;
    }
  
}

#pragma mark - TO PublisherVC
- (void)publiherButtonAction_v2{

    NSString *pushURLString = self.publisherURLTextField.text;
    if (!pushURLString || pushURLString.length == 0) {
        self.publisherURLTextField.text = @"rtmp://rtmp.huayustech.com/aaa/bbb?auth_key=1652079240-0-0-28bfb2a5ee4e42bae1df32c2f0cdfb9b";
        pushURLString = self.publisherURLTextField.text;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",nil) message:NSLocalizedString(@"请输入推流地址",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles: nil];
//        [alert show];
//        return;
    }
    
    // 判断推流地址是否是rtmp或者artc地址
    if (!([[pushURLString lowercaseString] hasPrefix:@"rtmp"] || [[pushURLString lowercaseString] hasPrefix:@"artc"])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入有效推流地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    // 更新水印坐标
    if (self.isUseWatermark) {
        for (int index = 0; index <= 3; index++) {
            AlivcWatermarkSettingStruct watermarkSetting = [self.waterSettingView getWatermarkSettingsWithCount:index];
            NSString *watermarkPath = [self getWatermarkPathWithIndex:index];
            [self.pushConfig addWatermarkWithPath:watermarkPath
                                  watermarkCoordX:watermarkSetting.watermarkX
                                  watermarkCoordY:watermarkSetting.watermarkY
                                   watermarkWidth:watermarkSetting.watermarkWidth];
        }
    }else {
        
        NSArray *watermarkArr = [self.pushConfig getAllWatermarks];
        for (NSDictionary *watermark in watermarkArr) {
            
            NSString *path = [watermark objectForKey:@"watermarkPath"];
            [self.pushConfig removeWatermarkWithPath:path];

        }
    }
    
    if (self.pushConfig.minFps > self.pushConfig.fps) {
        [DemoUtil showAlertWithTitle:NSLocalizedString(@"最小帧率不能大于视频帧率",nil) message:nil confirmBlock:nil cancelBlock:nil];
        return;
    }
    
    AlivcLivePusherViewController *publisherVC = [[AlivcLivePusherViewController alloc] init];
    publisherVC.pushURL = self.publisherURLTextField.text;
    publisherVC.pushConfig = self.pushConfig;
    publisherVC.beautyOn = self.beautyOn;
    publisherVC.isUseAsyncInterface = self.isUseAsync;
    publisherVC.authKey = self.authKey;
    publisherVC.authDuration = self.authDuration;
    publisherVC.isUserMainStream = self.isUserMainStream;
    publisherVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:publisherVC animated:YES completion:nil];
    
}

- (void)publiherButtonAction:(UIButton *)sender {

    NSString *pushURLString = self.publisherURLTextField.text;
    if (!pushURLString || pushURLString.length == 0) {
        self.publisherURLTextField.text = @"rtmp://rtmp.huayustech.com/aaa/bbb?auth_key=1652079240-0-0-28bfb2a5ee4e42bae1df32c2f0cdfb9b";
        pushURLString = self.publisherURLTextField.text;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",nil) message:NSLocalizedString(@"请输入推流地址",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles: nil];
//        [alert show];
//        return;
    }
    
    // 判断推流地址是否是rtmp或者artc地址
    if (!([[pushURLString lowercaseString] hasPrefix:@"rtmp"] || [[pushURLString lowercaseString] hasPrefix:@"artc"])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入有效推流地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    // 更新水印坐标
    if (self.isUseWatermark) {
        for (int index = 0; index <= 3; index++) {
            AlivcWatermarkSettingStruct watermarkSetting = [self.waterSettingView getWatermarkSettingsWithCount:index];
            NSString *watermarkPath = [self getWatermarkPathWithIndex:index];
            [self.pushConfig addWatermarkWithPath:watermarkPath
                                  watermarkCoordX:watermarkSetting.watermarkX
                                  watermarkCoordY:watermarkSetting.watermarkY
                                   watermarkWidth:watermarkSetting.watermarkWidth];
        }
    }else {
        
        NSArray *watermarkArr = [self.pushConfig getAllWatermarks];
        for (NSDictionary *watermark in watermarkArr) {
            
            NSString *path = [watermark objectForKey:@"watermarkPath"];
            [self.pushConfig removeWatermarkWithPath:path];

        }
    }
    
    if (self.pushConfig.minFps > self.pushConfig.fps) {
        [DemoUtil showAlertWithTitle:NSLocalizedString(@"最小帧率不能大于视频帧率",nil) message:nil confirmBlock:nil cancelBlock:nil];
        return;
    }
    
    AlivcLivePusherViewController *publisherVC = [[AlivcLivePusherViewController alloc] init];
    publisherVC.pushURL = self.publisherURLTextField.text;
    publisherVC.pushConfig = self.pushConfig;
    publisherVC.beautyOn = self.beautyOn;
    publisherVC.isUseAsyncInterface = self.isUseAsync;
    publisherVC.authKey = self.authKey;
    publisherVC.authDuration = self.authDuration;
    publisherVC.isUserMainStream = self.isUserMainStream;
    publisherVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:publisherVC animated:YES completion:nil];
    
}


#pragma mark - TO QRCodeVC
- (void)QRCodeButtonAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    AlivcQRCodeViewController *QRController = [[AlivcQRCodeViewController alloc] init];
//    __weak typeof(self) weakSelf = self;
//    QRController.backValueBlock = ^(NSString *value) {
//
//        if (value) {
//            weakSelf.publisherURLTextField.text = value;
//        }
//    };
    [self.navigationController pushViewController:QRController animated:YES];
}

#pragma mark TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.headTagIndex == 0) {
        if (self.settingLelel == NO) {
            return 7;
        }
        return self.dataArray.count;
    }else{
        return self.pushArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlivcParamModel *model;
    if (self.headTagIndex == 0) {
        model = self.dataArray[indexPath.row];

    }else{
        model = self.pushArray[indexPath.row];

    }
    
    if (model) {
        NSString *cellIdentifier = [NSString stringWithFormat:@"AlivcLivePushTableViewIdentifier%ld%ld", (long)indexPath.row,(long)self.headTagIndex];
        AlivcParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[AlivcParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell configureCellModel:model];
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlivcParamModel *model;
    if (self.headTagIndex == 0) {
        model = self.dataArray[indexPath.row];
    }else{
        model = self.pushArray[indexPath.row];
    }
    if ([model.reuseId isEqualToString:AlivcParamModelReuseCellSliderHeader]) {
        return 40;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.waterSettingView isEditing]) {
        [self.waterSettingView removeFromSuperview];
    }
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


#pragma mark - TO urlCpoy
- (void)urlCopyButtonAction:(UIButton *)sender {

    [UIPasteboard generalPasteboard].string = @"artp://testdomain.com/app/name";
    [self updateInfoText:NSLocalizedString(@"url_copy_tips", nil)];
}

- (void)setupInfoLabel {
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.frame = CGRectMake(20, 100, self.view.bounds.size.width - 40, 100);
    self.infoLabel.textColor = [UIColor blackColor];
//    self.infoLabel.backgroundColor = AlivcRGBA(255, 255, 255, 1.0);
    self.infoLabel.font = [UIFont systemFontOfSize:14.f];
    self.infoLabel.layer.masksToBounds = YES;
    self.infoLabel.layer.cornerRadius = 10;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.infoLabel];
    self.infoLabel.hidden = YES;
}

- (void)updateInfoText:(NSString *)text {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoLabel setHidden:NO];
        self.infoLabel.text = text;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(hiddenInfoLabel) withObject:nil afterDelay:2.0];
        
    });
}

- (void)hiddenInfoLabel {
    [self.infoLabel setHidden:YES];
}
 
@end

