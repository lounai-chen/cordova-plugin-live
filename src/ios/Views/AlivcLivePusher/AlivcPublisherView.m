//
//  AlivcPublisherView.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AlivcPublisherView.h"
#import "AlivcDebugChartView.h"
#import "AlivcDebugTextView.h"
#import "AlivcGuidePageView.h"
#import "AlivcMusicSettingView.h"
#import "AlivcAnswerGameView.h"
#import "AlivcPushViewsProtocol.h"

#import <AlivcLivePusher/AlivcLivePusher.h>

#define viewWidth  (80)
#define viewHeight viewWidth/4*3
#define topViewButtonSize  (55)

static const int moreSettingViewHeightcount = 7;
static const int maxDynamicWatermarkCount = 3;

@interface AlivcPublisherView () <UIGestureRecognizerDelegate>{
    NSMutableArray * dynamicWatermarkArr;
}

@property (nonatomic, weak) id<AlivcPublisherViewDelegate> delegate;

@property (nonatomic, strong) AlivcGuidePageView *guideView;

@property (nonatomic, strong) UIScrollView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *snapshotButton;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *musicButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *answerGameButton;
@property (nonatomic, strong) UIButton *beautySettingButton;

@property (nonatomic, strong) UIScrollView *bottomView;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *pushButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *restartButton;
@property (nonatomic, strong) UIButton *moreSettingButton;
@property (nonatomic, strong) UIButton *dataMonitorButton;

@property (nonatomic, strong) UISwitch *previewMirrorSwitch;
@property (nonatomic, strong) UISwitch *pushMirrorSwitch;

@property (nonatomic, strong) UIView *moreSettingView;
@property (nonatomic, strong) AlivcMusicSettingView *musicSettingView;
@property (nonatomic, strong) AlivcAnswerGameView *answerGameView;


@property (nonatomic, strong) AlivcDebugChartView *debugChartView;
@property (nonatomic, strong) AlivcDebugTextView *debugTextView;

@property (nonatomic, assign) BOOL isMoreSettingShow;
@property (nonatomic, assign) BOOL isMusicSettingShow;
@property (nonatomic, assign) BOOL isAnswerGameViewShow;
@property (nonatomic, assign) BOOL isKeyboardEdit;
@property (nonatomic, assign) BOOL isHiddenBtns;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) AlivcLivePushConfig *config;

@end

@implementation AlivcPublisherView


- (instancetype)initWithFrame:(CGRect)frame config:(AlivcLivePushConfig *)config {
    
    self = [super initWithFrame:frame];
    if (self) {
        _config = config;
        [self setupSubviews];
        [self addNotifications];
        dynamicWatermarkArr = [[NSMutableArray alloc]init];
    }
    return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setPushViewsDelegate:(id)delegate {
    
    self.delegate = delegate;
    [self.musicSettingView setMusicDelegate:delegate];
    [self.answerGameView setAnswerDelegate:delegate];

}

#pragma mark - UI

- (void)setupSubviews {
    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:AlivcUserDefaultsIndentifierFirst]) {
//        [self setupGuideView];
//    }
    
    [self setupTopViews];
    
    [self setupBottomViews];
    
    [self setupInfoLabel];
    
//    [self setupDebugViews];
    
    [self addGesture];
    
    if (self.config.audioOnly) {
        [self hiddenVideoViews];
    }
    
    self.currentIndex = 1;
}


- (void)setupGuideView {
    
    self.guideView = [[AlivcGuidePageView alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height/6)];
    self.guideView.center = self.center;
    [self addSubview:self.guideView];
}


- (void)setupTopViews {
    
    self.topView = [[UIScrollView alloc] init];
    CGFloat retractX = 10;

    if (_config.orientation == AlivcLivePushOrientationLandscapeLeft || _config.orientation == AlivcLivePushOrientationLandscapeRight ) {
        //self.topView.frame = CGRectMake(self.width - 80, 50, 80, self.height-100);
        
        self.backButton = [self setupButtonWithFrame:(CGRectMake(retractX + 80, 50, 40, 40))
                                         normalImage:[UIImage imageNamed:@"back"]
                                         selectImage:nil
                                              action:@selector(backButtonAction:)];

    }else{
        //self.topView.frame = CGRectMake(self.width - 80, self.height - 600, 80, 400);
        self.backButton = [self setupButtonWithFrame:(CGRectMake(retractX, 90, 40, 40))
                                         normalImage:[UIImage imageNamed:@"back"]
                                         selectImage:nil
                                              action:@selector(backButtonAction:)];

    }
    self.topView.backgroundColor = [UIColor clearColor];
    [self addSubview: self.topView];
    
    [self addSubview: self.backButton];
    
    self.snapshotButton = [self setupButtonWithFrame:CGRectMake(0, 320, topViewButtonSize, topViewButtonSize) title: NSLocalizedString(@"截图",nil)
                                       normalImage:[UIImage imageNamed:@"alivc_capture"]
                                       selectImage:nil
                                            action:@selector(snapshotButtonAction:)];
    [self.topView addSubview:self.snapshotButton];
    
    self.switchButton = [self setupButtonWithFrame:CGRectMake(0, 240, topViewButtonSize, topViewButtonSize) title: NSLocalizedString(@"摄像头",nil)
                                       normalImage:[UIImage imageNamed:@"alivc_camera_switch"]
                                       selectImage:[UIImage imageNamed:@"alivc_camera_switch"]
                                            action:@selector(switchButtonAction:)];
    [self.topView addSubview:self.switchButton];
    
    self.flashButton = [self setupButtonWithFrame:CGRectMake(0, 160, topViewButtonSize, topViewButtonSize) title: NSLocalizedString(@"闪光灯",nil)
                                                   normalImage:[UIImage imageNamed:@"alivc_flash"]
                                                   selectImage:[UIImage imageNamed:@"alivc_flash"]
                                                   action:@selector(flashButtonAction:)];
    [self.flashButton setSelected:self.config.flash];
    [self.flashButton setEnabled:self.config.cameraType==AlivcLivePushCameraTypeFront?NO:YES];
    [self.topView addSubview:self.flashButton];
    
    self.musicButton = [self setupButtonWithFrame:CGRectMake(0, 80, topViewButtonSize, topViewButtonSize) title: NSLocalizedString(@"背景音乐",nil)
                                     normalImage:[UIImage imageNamed:@"alivc_back_music"]
                                     selectImage:nil
                                          action:@selector(musicButtonAction:)];
    [self.topView addSubview: self.musicButton];
    
    if (self.config.videoOnly) {
        [self.musicButton setHidden:YES];
    }
    
    self.beautySettingButton = [self setupButtonWithFrame:CGRectMake(0, 0, topViewButtonSize, topViewButtonSize) title: NSLocalizedString(@"美颜",nil)
                                              normalImage:[UIImage imageNamed:@"alivc_beauty"]
                                              selectImage:nil
                                                   action:@selector(beautySettingButtonAction:)];
    //[self.beautySettingButton setEnabled:self.config.beautyOn];
    [self.topView addSubview: self.beautySettingButton];

    self.topView.showsVerticalScrollIndicator = NO;
    [self.topView setContentSize:CGSizeMake(topViewButtonSize, topViewButtonSize * 7)];
    //[self setupMusicSettingView];
    self.isMusicSettingShow = NO;
    self.isAnswerGameViewShow = NO;
}


- (void)setupBottomViews {
    
    self.bottomView = [[UIScrollView alloc] init];
    if (_config.orientation == AlivcLivePushOrientationLandscapeLeft || _config.orientation == AlivcLivePushOrientationLandscapeRight ) {
        self.bottomView.frame = CGRectMake(10,
                                           CGRectGetHeight(self.frame) -80,
                                           CGRectGetWidth(self.frame)  - 20,
                                           viewHeight);
        self.bottomView.contentSize = CGSizeMake(30, viewHeight);
        self.bottomView.alwaysBounceHorizontal = YES;

    }else{
        self.bottomView.frame = CGRectMake(10,
                                           CGRectGetHeight(self.frame) - viewHeight-80,
                                           CGRectGetWidth(self.frame) - 20,
                                           viewHeight);
        self.bottomView.contentSize = CGSizeMake(80*7, viewHeight);

    }
    
    self.bottomView.showsHorizontalScrollIndicator = NO;
    self.bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview: self.bottomView];
    
    CGFloat buttonCount = 6;
    CGFloat retractX = (CGRectGetWidth(self.bottomView.frame) - viewWidth * 6) / (buttonCount + 1) + 10;
    
    self.previewButton = [self setupButtonWithFrame:(CGRectMake(retractX, 0, viewWidth, viewHeight))
                                        normalTitle:NSLocalizedString(@"start_preview_button", nil)
                                        selectTitle:NSLocalizedString(@"stop_preview_button", nil)
                                          normalImg:[UIImage imageNamed:@"alivc_start_pre"] selectImage:[UIImage imageNamed:@"alivc_start_pre"]
                                             action:@selector(previewButtonAction:)];
    [self.bottomView addSubview: self.previewButton];
    [self.previewButton setSelected:YES];
    
    self.pushButton = [self setupButtonWithFrame:(CGRectMake(retractX * 2 + viewWidth, 0, viewWidth, viewHeight))
                                     normalTitle:NSLocalizedString(@"start_button", nil)
                                     selectTitle:NSLocalizedString(@"stop_button", nil)
                                       normalImg:[UIImage imageNamed:@"alivc_start_push"] selectImage:[UIImage imageNamed:@"alivc_start_push"]
                                          action:@selector(pushButtonAction:)];
    [self.bottomView addSubview: self.pushButton];
    
    self.pauseButton = [self setupButtonWithFrame:(CGRectMake(retractX * 3 + viewWidth * 2, 0, viewWidth, viewHeight))
                                      normalTitle:NSLocalizedString(@"pause_button", nil)
                                      selectTitle:NSLocalizedString(@"resume_button", nil)
                                        normalImg:[UIImage imageNamed:@"alivc_pause"] selectImage:[UIImage imageNamed:@"alivc_pause"]
                                           action:@selector(pauseButtonAction:)];
    [self.bottomView addSubview:self.pauseButton];
    
    self.restartButton = [self setupButtonWithFrame:(CGRectMake(retractX * 4 + viewWidth * 3, 0, viewWidth, viewHeight))
                                      normalTitle:NSLocalizedString(@"repush_button", nil)
                                      selectTitle:nil
                                          normalImg:[UIImage imageNamed:@"alivc_strop_push"] selectImage:[UIImage imageNamed:@"alivc_strop_push"]
                                           action:@selector(restartButtonAction:)];
    [self.bottomView addSubview:self.restartButton];

    
    self.moreSettingButton = [self setupButtonWithFrame:(CGRectMake(retractX * 5 + viewWidth * 4, 0, viewWidth, viewHeight))
                                              normalTitle:NSLocalizedString(@"more_setting_button", nil)
                                              selectTitle:nil
                                              normalImg:[UIImage imageNamed:@"alivc_more_setting"] selectImage:[UIImage imageNamed:@"alivc_more_setting"]
                                                   action:@selector(moreSettingButtonAction:)];
    [self.bottomView addSubview: self.moreSettingButton];
    
    self.dataMonitorButton = [self setupButtonWithFrame:(CGRectMake(retractX * 6 + viewWidth * 5, 0, viewWidth, viewHeight))
                                              normalTitle:NSLocalizedString(@"more_data_button", nil)
                                              selectTitle:nil
                                              normalImg:[UIImage imageNamed:@"alivc_data_show"] selectImage:[UIImage imageNamed:@"alivc_data_show"]
                                                   action:@selector(publisherDataMonitorView)];
    [self.bottomView addSubview: self.dataMonitorButton];

    
    self.isMoreSettingShow = NO;
    
}


- (void)setupInfoLabel {
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.frame = CGRectMake(20, 60, self.bounds.size.width - 40, 40);
    self.infoLabel.textColor = [UIColor blackColor];
//    self.infoLabel.backgroundColor = AlivcRGBA(255, 255, 255, 0.5);
    self.infoLabel.font = [UIFont systemFontOfSize:14.f];
    self.infoLabel.layer.masksToBounds = YES;
    self.infoLabel.layer.cornerRadius = 10;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.infoLabel];
    self.infoLabel.hidden = YES;
}

- (void)setupMoreSettingViews {
    
    self.moreSettingView = [[UIView alloc] init];
    CGFloat retractX = 0;
    
    CGFloat height = 40;
    if (self.bounds.size.width > self.bounds.size.height) {
        height = 35;
    }

    
    self.moreSettingView.frame = CGRectMake(retractX,
                                              CGRectGetHeight(self.frame) - height * moreSettingViewHeightcount,
                                              CGRectGetWidth(self.frame) - retractX * 2,
                                              height * moreSettingViewHeightcount);
    self.moreSettingView.backgroundColor = [UIColor whiteColor];

    
    UIButton *cancelBtn = [self setupButtonWithFrame:CGRectMake(10, 5, 50, 30) normalTitle:NSLocalizedString(@"取消",nil) selectTitle:NSLocalizedString(@"取消",nil) action:@selector(cancel:)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    UIButton *confirmBtn = [self setupButtonWithFrame:CGRectMake(50, 5, 50, 30) normalTitle:NSLocalizedString(@"确定",nil) selectTitle:NSLocalizedString(@"确定",nil) action:@selector(cancel:)];
    confirmBtn.backgroundColor = [UIColor clearColor];

    [self.moreSettingView addSubview: cancelBtn];
    [self.moreSettingView addSubview: confirmBtn];

    CGFloat buttonY = CGRectGetHeight(self.moreSettingView.frame) - height * 3;
    CGFloat middleW = CGRectGetWidth(self.moreSettingView.frame);
    
    NSArray *array = [NSArray arrayWithObjects:NSLocalizedString(@"tile", nil),NSLocalizedString(@"fit", nil),NSLocalizedString(@"cut", nil), nil];
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:array];
    segment.backgroundColor = [UIColor whiteColor];
    segment.frame = CGRectMake(retractX, buttonY - height, self.moreSettingView.frame.size.width - 2*retractX, height);
    segment.selectedSegmentIndex = _config.previewDisplayMode;
    [segment addTarget:self action:@selector(previewDisplayModeChange:) forControlEvents:UIControlEventValueChanged];
    [self.moreSettingView addSubview:segment];
    
   
    self.previewMirrorSwitch = [[UISwitch alloc] init];
    UIView *previewMirrorView = [self setupSwitchViewsWithFrame:(CGRectMake(retractX, buttonY, middleW, height)) title:NSLocalizedString(@"preview_mirror", nil) switchView:self.previewMirrorSwitch switchOn:self.config.previewMirror switchAction:@selector(previewMirrorSwitchAction:)];
    [self.moreSettingView addSubview:previewMirrorView];
    
    self.pushMirrorSwitch = [[UISwitch alloc] init];
    UIView *pushMirrorView = [self setupSwitchViewsWithFrame:(CGRectMake(retractX, buttonY+height, middleW, height)) title:NSLocalizedString(@"push_mirror", nil) switchView:self.pushMirrorSwitch switchOn:self.config.pushMirror switchAction:@selector(pushMirrorSwitchAction:)];
    [self.moreSettingView addSubview:pushMirrorView];
        
    
    int labelCount = 2;
    CGFloat retract = 5;
    CGFloat labelWidth = 30;
    NSArray *nameArray = @[NSLocalizedString(@"target_bitrate", nil),NSLocalizedString(@"min_bitrate", nil)];
    NSArray *textFieldActionArray = @[@"maxBitrateTextFieldValueChanged:", @"minBitrateTextFieldValueChanged:"];
    NSArray *value =@[@(self.config.targetVideoBitrate),@(self.config.minVideoBitrate)];
    
    for (int index = 0; index < labelCount; index++) {
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(retract,
                                     50 +(retract*(index+1))+(labelWidth*index),
                                     labelWidth * 2 + 40,
                                     labelWidth);
        nameLabel.textAlignment = NSTextAlignmentRight;
        nameLabel.font = [UIFont systemFontOfSize:14.f];
        nameLabel.text = nameArray[index];
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        nameLabel.numberOfLines = 0;
        
        UITextField *textField = [[UITextField alloc] init];
        textField.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame) + retract,
                                     CGRectGetMinY(nameLabel.frame),
                                     CGRectGetWidth(self.moreSettingView.frame) -  (70),
                                     30);
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = [NSString stringWithFormat:@"%@", value[index]];
        textField.text = [NSString stringWithFormat:@"%@", value[index]];
        textField.font = [UIFont systemFontOfSize:14.f];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.clearsOnBeginEditing = YES;
        [textField addTarget:self action:NSSelectorFromString(textFieldActionArray[index]) forControlEvents:(UIControlEventEditingDidEnd)];
        
        UILabel *unitLabel = [[UILabel alloc] init];
        unitLabel.frame = CGRectMake(CGRectGetMaxX(textField.frame) + retract,
                                     CGRectGetMinY(nameLabel.frame),
                                     labelWidth * 2,
                                     labelWidth);
        unitLabel.textAlignment = NSTextAlignmentLeft;
        unitLabel.font = [UIFont systemFontOfSize:14.f];
        unitLabel.text = @"Kbps";
        
        [self.moreSettingView addSubview:nameLabel];
        [self.moreSettingView addSubview:textField];
        [self.moreSettingView addSubview:unitLabel];
        
        if (self.config.qualityMode != AlivcLivePushQualityModeCustom) {
            // 非自定义模式下，不允许更改码率
            nameLabel.alpha = 0.5;
            [textField setEnabled:NO];
            textField.alpha = 0.5;
            unitLabel.alpha = 0.5;
        }

    }
}


- (void)setupMusicSettingView {
    
    CGRect frame = CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
    if (self.bounds.size.width > self.bounds.size.height) {
        frame = CGRectMake(0, self.frame.size.height/3, self.frame.size.width, self.frame.size.height/3*2);
    }
    
    BOOL isMusicMode = NO;
    if(_config.audioScene != AlivcLivePusherAudioScenarioDefaultMode)
    {
        isMusicMode = YES;
    }
    self.musicSettingView = [[AlivcMusicSettingView alloc] initWithFrame:frame musicMode:isMusicMode];
    [self.musicSettingView setMusicDelegate:(id)self.delegate];

}


- (void)setupAnswerGameView {
    
    CGRect frame = CGRectMake(20, self.frame.size.height/4, self.frame.size.width-40, self.frame.size.height/2);
    if (self.bounds.size.width > self.bounds.size.height) {
        frame = CGRectMake(self.frame.size.width/4, self.frame.size.height/3, self.frame.size.width/2, self.frame.size.height/3*2);
    }
    self.answerGameView = [[AlivcAnswerGameView alloc] initWithFrame:frame];
    self.answerGameView.center = self.center;
    [self.answerGameView setAnswerDelegate:(id)self.delegate];

}



- (UIView *)setupSwitchViewsWithFrame:(CGRect)viewFrame title:(NSString *)labelTitle switchView:(UISwitch *)switcher switchOn:(BOOL)switchOn switchAction:(SEL)switchAction{
    
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    view.clipsToBounds = YES;
    UILabel *viewLabel = [[UILabel alloc] init];
    viewLabel.frame = CGRectMake(20, 0, CGRectGetWidth(viewFrame)/2, CGRectGetHeight(viewFrame));
    viewLabel.text = labelTitle;
//    viewLabel.backgroundColor = [UIColor redColor];
    viewLabel.font = [UIFont systemFontOfSize:14.f];
    viewLabel.numberOfLines = 0;
    [viewLabel sizeToFit];
    viewLabel.center = CGPointMake(viewLabel.center.x, viewFrame.size.height/2);

    [view addSubview:viewLabel];
    
    //switcher.frame = CGRectMake(self.width - CGRectGetMaxX(viewLabel.frame) - 20, 0, CGRectGetWidth(viewFrame)/2, CGRectGetHeight(viewFrame));
    switcher.center = CGPointMake(switcher.center.x, viewFrame.size.height/2);
    switcher.on = switchOn;
//    switcher.backgroundColor = [UIColor greenColor];
    [switcher addTarget:self action:switchAction forControlEvents:(UIControlEventValueChanged)];
    [view addSubview:switcher];
    
    return view;
}


- (void)setupDebugViews {
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.debugChartView = [[AlivcDebugChartView alloc] initWithFrame:(CGRectMake(width, 0, width, height))];
   // self.debugChartView.backgroundColor = AlivcRGBA(255, 255, 255, 0.8);
    [self addSubview:self.debugChartView];
    
    
    self.debugTextView = [[AlivcDebugTextView alloc] initWithFrame:(CGRectMake(-width, 0, width, height))];
    //self.debugTextView.backgroundColor = AlivcRGBA(255, 255, 255, 0.8);
    [self addSubview:self.debugTextView];
}


- (void)addGesture {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;

    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer* doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleRecognizer.delegate = self;
    doubleRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleRecognizer];

    // 双击手势确定监测失败才会触发单击手势的相应操作
    [tap requireGestureRecognizerToFail:doubleRecognizer];

//    [self addGestureRecognizer:leftSwipeGestureRecognizer];
//    [self addGestureRecognizer:rightSwipeGestureRecognizer];
}



- (UIButton *)setupButtonWithFrame:(CGRect)rect
                       normalTitle:(NSString *)normal selectTitle:(NSString *)select
                            action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setTitle:normal forState:(UIControlStateNormal)];
    [button setTitle:select forState:(UIControlStateSelected)];
    [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = rect.size.height / 5;
    
    return button;
}

- (UIButton *)setupButtonWithFrame:(CGRect)rect
                       normalTitle:(NSString *)normal selectTitle:(NSString *)select
                         normalImg:(UIImage *)normalImg
                       selectImage:(UIImage *)selImg
                            action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setTitle:normal forState:(UIControlStateNormal)];
    [button setTitle:select forState:(UIControlStateSelected)];
    [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    button.titleLabel.backgroundColor = [UIColor redColor];
//    button.layer.masksToBounds = YES;
//    button.layer.cornerRadius = rect.size.height / 5;
    
    [button setImage:normalImg forState:UIControlStateNormal];
    [button setImage:selImg forState:UIControlStateSelected];

    CGSize imageSize = button.imageView.frame.size;
    CGSize titleSize = button.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + 5);
    
    // raise the image and push it right to center it
    button.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0 , 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                                  0.0, - imageSize.width, - (totalHeight - titleSize.height), 0.0);
    
//    button.backgroundColor = [UIColor redColor];
//    [button setImageEdgeInsets:UIEdgeInsetsMake(16, 35, 30, 35)];
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(40, -  (rect.size.width - (rect.size.width - 70/2)) / 2, 0, 10)];

    return button;
}




- (UIButton *)setupButtonWithFrame:(CGRect)rect normalImage:(UIImage *)normal selectImage:(UIImage *)select action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setImage:normal forState:(UIControlStateNormal)];
    [button setImage:select forState:(UIControlStateSelected)];
    return button;
}

- (UIButton *)setupButtonWithFrame:(CGRect)rect title:(NSString *)title normalImage:(UIImage *)normal selectImage:(UIImage *)select action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 30, 15)];
    [button setImage:normal forState:(UIControlStateNormal)];
    [button setImage:select forState:(UIControlStateSelected)];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button setTitleEdgeInsets:UIEdgeInsetsMake(40, -35, 0, 0)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return button;
}



#pragma mark - Button Actions
- (void)cancel:(id)sender{
    [self.moreSettingView removeFromSuperview];
    self.isMoreSettingShow = NO;
}
- (void)backButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickedBackButton];
    }
}


- (void)previewButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    
    if (self.delegate) {
        if([self.delegate publisherOnClickedPreviewButton:sender.selected button:sender] == 0 && sender.selected) {
            
            NSUInteger count = [dynamicWatermarkArr count];
            while(count > 0) {
                
                [dynamicWatermarkArr removeObjectAtIndex:0];
                count = [dynamicWatermarkArr count];
            }
        }
    }
    
    self.pushMirrorSwitch.enabled = sender.selected;
    self.previewMirrorSwitch.enabled = sender.selected;
}


- (void)pushButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    if (self.delegate) {
        BOOL ret = [self.delegate publisherOnClickedPushButton:sender.selected button:sender];
        if (ret) {
            [self.pauseButton setSelected:NO];
        }
    }
}


- (void)musicButtonAction:(UIButton *)sender {
    
    if (!self.musicSettingView) {
        [self setupMusicSettingView];
    }
    [self addSubview:self.musicSettingView];
    self.isMusicSettingShow = YES;
}


- (void)answerGameButtonAction:(UIButton *)sender {
    
    if (!self.answerGameView) {
        [self setupAnswerGameView];
    }
    [self addSubview:self.answerGameView];
    self.isAnswerGameViewShow = YES;
}


- (void)beautySettingButtonAction:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate publisherOnClickedBeautyButton:YES];
    }
}

- (void)moreSettingButtonAction:(UIButton *)sender {
    
    if (!self.moreSettingView) {
        [self setupMoreSettingViews];
    }
    [self addSubview:self.moreSettingView];
    self.isMoreSettingShow = YES;
}

- (void)publisherDataMonitorView{
    if (self.delegate) {
        [self.delegate publisherDataMonitorView];
    }
}
    
- (void)switchButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickedSwitchCameraButton];
    }
    
    [self.flashButton setEnabled:!self.flashButton.enabled];
}

- (void)snapshotButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickedSnapshotButton];
    }
}


- (void)flashButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    if (self.delegate) {
        [self.delegate publisherOnClickedFlashButton:sender.selected button:sender];
    }
}


- (void)pauseButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    if (self.delegate) {
        [self.delegate publisherOnClickedPauseButton:sender.selected button:sender];
    }
}


- (void)restartButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        if([self.delegate publisherOnClickedRestartButton] == 0) {
            
            NSUInteger count = [dynamicWatermarkArr count];
            while(count > 0) {
                
                [dynamicWatermarkArr removeObjectAtIndex:0];
                count = [dynamicWatermarkArr count];
            }
        }
    }
}

- (void)sharedButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickSharedButon];
    }
}

- (int)addButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
        
        NSString *resourceBundle = [[NSBundle mainBundle] pathForResource:@"AlivcLibDynamicWaterMark" ofType:@"bundle"];

        char filePath[188] = {0};
        const char *doc_path = 0;
        {
            NSString *docPath = [resourceBundle stringByAppendingFormat:@"/Resources"];
            doc_path = [docPath UTF8String];
            strncpy((char*)filePath, doc_path, 187);
        }

        NSString * bundleAddOnPath = [NSString stringWithUTF8String:filePath];
        
        int count = [dynamicWatermarkArr count];
        
        if(count >= maxDynamicWatermarkCount) {
            return -1;
        }
        
        int index = [self.delegate publisherOnClickAddDynamically:bundleAddOnPath  x:0.3+count*0.1 y:0.3+count*0.1 w:0.5 h:0.5];
        if(index <= 0)
        {
            return -1;
        }
        NSNumber *num = [NSNumber numberWithInt:index];
        [dynamicWatermarkArr addObject: num];
        return index;
        
    }
    return -1;
}

-(void)previewDisplayModeChange:(UISegmentedControl *)sender {
   
    if (self.delegate) {
        NSInteger index = sender.selectedSegmentIndex;
        
//        if (_config.orientation == AlivcLivePushOrientationLandscapeLeft || _config.orientation == AlivcLivePushOrientationLandscapeRight ) {
//            if (index == 1) {
//                self.infoLabel.origin = CGPointMake(20, 60);
//                self.backButton.origin = CGPointMake(90, 50);
//                self.bottomView.origin = CGPointMake(0, CGRectGetHeight(self.frame) -80);
//            }else{
//                self.backButton.origin = CGPointMake(30, 50);
//                self.infoLabel.origin = CGPointMake(20, 30);
//                self.bottomView.origin = CGPointMake(0, CGRectGetHeight(self.frame) -50);
//            }
//
//        }else{
//            if (index == 1) {
//                self.infoLabel.origin = CGPointMake(20, 90);
//                self.backButton.origin = CGPointMake(10, 90);
//                self.bottomView.origin = CGPointMake(0, CGRectGetHeight(self.frame) -viewHeight-80);
//            }else{
//                self.backButton.origin = CGPointMake(10, 30);
//                self.infoLabel.origin = CGPointMake(20, 30);
//                self.bottomView.origin = CGPointMake(0, CGRectGetHeight(self.frame) -viewHeight-50);
//            }
//
//        }
        [self.delegate publisherOnSelectPreviewDisplayMode:index];
    }
  
}

- (void)removeButtonAction:(UIButton *)sender {
    
    if (self.delegate) {
    
        int count = [dynamicWatermarkArr count];
        
        if(count > 0) {
            NSNumber *num = [dynamicWatermarkArr objectAtIndex:count - 1];
            
            int index = [num intValue];
            
            [dynamicWatermarkArr removeObjectAtIndex:count - 1];
            
            [self.delegate publisherOnClickRemoveDynamically:index];
        }
       
    }
}

- (void)autoFocusSwitchAction:(UISwitch *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickAutoFocusButton:sender.on];
    }
}

- (void)pushMirrorSwitchAction:(UISwitch *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickPushMirrorButton:sender.on];
    }
}

- (void)previewMirrorSwitchAction:(UISwitch *)sender {
    
    if (self.delegate) {
        [self.delegate publisherOnClickPreviewMirrorButton:sender.on];
    }
}


#pragma mark - Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([[touch.view class] isEqual:[self class]]) {
        return YES;
    }
    return  NO;
}

-(void)doubleTap:(UITapGestureRecognizer *)gesture{
    _isHiddenBtns = !_isHiddenBtns;
    self.topView.hidden = _isHiddenBtns;
    self.bottomView.hidden = _isHiddenBtns;
    self.backButton.hidden = _isHiddenBtns;
    self.infoLabel.hidden = _isHiddenBtns;
    if (_isHiddenBtns) {
        [AlivcLivePusher hideDebugView];
    }else{
        [AlivcLivePusher showDebugView];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture{

    if (self.isKeyboardEdit) {
        
        [self endEditing:YES];
    } else if (self.isMoreSettingShow) {
        
        [self.moreSettingView removeFromSuperview];
        self.isMoreSettingShow = NO;
//        [AlivcLivePusher showDebugView];
    } else if (self.isMusicSettingShow) {
        
        [self.musicSettingView removeFromSuperview];
        self.isMusicSettingShow = NO;
    } else if (self.isAnswerGameViewShow) {
        
        [self.answerGameView removeFromSuperview];
        self.isAnswerGameViewShow = NO;
    } else {
        
        CGPoint point = [gesture locationInView:self];
        CGPoint percentPoint = CGPointZero;
        percentPoint.x = point.x / CGRectGetWidth(self.bounds);
        percentPoint.y = point.y / CGRectGetHeight(self.bounds);
//        NSLog(@"聚焦点  - x:%f y:%f", percentPoint.x, percentPoint.y);
        if (self.delegate) {
            [self.delegate publisherOnClickedFocus:percentPoint];
        }
    }
    
}

static CGFloat lastPinchDistance = 0;
- (void)pinchGesture:(UIPinchGestureRecognizer *)gesture {
    
    if (gesture.numberOfTouches != 2) {
        return;
    }
    CGPoint p1 = [gesture locationOfTouch:0 inView:self];
    CGPoint p2 = [gesture locationOfTouch:1 inView:self];
    CGFloat dx = (p2.x - p1.x);
    CGFloat dy = (p2.y - p1.y);
    CGFloat dist = sqrt(dx*dx + dy*dy);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastPinchDistance = dist;
    }
    
    CGFloat change = dist - lastPinchDistance;

    NSLog(@"zoom - %f", change);

    if (self.delegate) {
        [self.delegate publisherOnClickedZoom:change/3000];
    }
}


- (void)leftSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (self.guideView) {
        [self.guideView removeFromSuperview];
        self.guideView = nil;
       // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AlivcUserDefaultsIndentifierFirst];
    }
    
    if (self.currentIndex == 0) {
        if (self.delegate) {
            [self.delegate publisherOnClickedShowDebugTextInfo:NO];
            [self animationWithView:self.debugTextView x:-self.bounds.size.width];
        }
        self.currentIndex++;
        return;
    }
    
    if (self.currentIndex == 1) {
        if (self.delegate) {
            [self.delegate publisherOnClickedShowDebugChartInfo:YES];
            [self animationWithView:self.debugChartView x:0];
        }
        self.currentIndex++;
        return;
    }
    
    if (self.currentIndex == 2) {
        // 无效
        return;
    }
}


- (void)rightSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (self.guideView) {
        [self.guideView removeFromSuperview];
        self.guideView = nil;
       // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AlivcUserDefaultsIndentifierFirst];
    }
    
    if (self.currentIndex == 0) {
        // 无效
        return;
    }
    
    if (self.currentIndex == 1) {
        if (self.delegate) {
            [self.delegate publisherOnClickedShowDebugTextInfo:YES];
            [self animationWithView:self.debugTextView x:0];
        }
        self.currentIndex--;
        return;
    }
    
    if (self.currentIndex == 2) {
        if (self.delegate) {
            [self.delegate publisherOnClickedShowDebugChartInfo:NO];
            [self animationWithView:self.debugChartView x:self.bounds.size.width];
        }
        self.currentIndex--;
        return;
    }

}


#pragma mark - Slider Actions

- (void)buffingValueChange:(UISlider *)slider {
    
    if (self.delegate) {
        [self.delegate publisherSliderBeautyBuffingValueChanged:(int)slider.value];
    }
}

- (void)whiteValueChange:(UISlider *)slider {
    
    if (self.delegate) {
        [self.delegate publisherSliderBeautyWhiteValueChanged:(int)slider.value];
    }
}



- (void)ruddyValueChange:(UISlider *)slider {
    
    if (self.delegate) {
        [self.delegate publisherSliderBeautyRubbyValueChanged:(int)slider.value];
    }
}

- (void)cheekPinkValueChange:(UISlider *)slider {
    
    if (self.delegate) {
        [self.delegate publisherSliderBeautyCheekPinkValueChanged:(int)slider.value];
    }
}

- (void)thinfaceValueChange:(UISlider *)slider {
    
    if (self.delegate) {
        [self.delegate publisherSliderBeautyThinFaceValueChanged:(int)slider.value];
    }
}

- (void)shortenfaceValueChange:(UISlider *)slider {
    
    if (self.delegate) {
        [self.delegate publisherSliderBeautyShortenFaceValueChanged:(int)slider.value];
    }
}

- (void)bigeyeValueChange:(UISlider *)slider {
    
    if (self.delegate) {
        [self.delegate publisherSliderBeautyBigEyeValueChanged:(int)slider.value];
    }
}

#pragma mark - Animation

- (void)animationWithView:(UIView *)view x:(CGFloat)x {
    
    [UIView animateWithDuration:0.5 animations:^{
       
        CGRect frame = view.frame;
        frame.origin.x = x;
        view.frame = frame;
    }];
    
}


#pragma mark - TextField Actions

- (void)maxBitrateTextFieldValueChanged:(UITextField *)sender {
    
    if (!sender.text.length) {
        sender.text = sender.placeholder;
    }
    
    if (self.delegate) {
        [self.delegate publisherOnBitrateChangedTargetBitrate:[sender.text intValue]];
    }
}

- (void)minBitrateTextFieldValueChanged:(UITextField *)sender {
    
    if (!sender.text.length) {
        sender.text = sender.placeholder;
    }
    
    if (self.delegate) {
        [self.delegate publisherOnBitrateChangedMinBitrate:[sender.text intValue]];
    }
}


#pragma mark - Public

- (void)updateInfoText:(NSString *)text {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!_isHiddenBtns){
            [self.infoLabel setHidden:NO];
        }
        self.infoLabel.text = text;
//        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        [self performSelector:@selector(hiddenInfoLabel) withObject:nil afterDelay:0];
    });
}

- (void)hiddenInfoLabel {
    
    [self.infoLabel setHidden:YES];
}


- (void)updateDebugChartData:(AlivcLivePushStatsInfo *)info {
    
    [self.debugChartView updateData:info];
}

- (void)updateDebugTextData:(AlivcLivePushStatsInfo *)info {
    
    [self.debugTextView updateData:info];
}


- (void)hiddenVideoViews {
    
    self.beautySettingButton.hidden = YES;
    self.flashButton.hidden = YES;
    self.switchButton.hidden = YES;
    self.moreSettingButton.hidden = YES;
}

- (void)updateMusicDuration:(long)currentTime totalTime:(long)totalTime {
    
    [self.musicSettingView updateMusicDuration:currentTime totalTime:totalTime];
}

- (void)resetMusicButtonTypeWithPlayError {
    
    [self.musicSettingView resetButtonTypeWithPlayError];
}


- (BOOL)getPushButtonType {
    
    return self.pushButton.selected;
}

#pragma mark - Notification

- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)sender {
    
    if(self.isKeyboardEdit){
        return;
    }
    self.isKeyboardEdit = YES;
    CGRect keyboardFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.moreSettingView.frame;
        frame.origin.y = frame.origin.y - keyboardFrame.size.height;
        self.moreSettingView.frame = frame;
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.isKeyboardEdit = NO;
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.moreSettingView.frame;
        frame.origin.y = self.bounds.size.height - frame.size.height;
        self.moreSettingView.frame = frame;
    }];
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification
{
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];

}


@end
