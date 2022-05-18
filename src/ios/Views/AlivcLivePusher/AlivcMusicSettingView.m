//
//  AlivcMusicSettingView.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/11/23.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import "AlivcMusicSettingView.h"
#import "AlivcMusicInfoModel.h"
#import "AlivcPushViewsProtocol.h"


#pragma mark - AlivcMusicListViewCell

@interface AlivcMusicListViewCell ()

@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *loopImageView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) AlivcMusicInfoModel *model;

@end

@implementation AlivcMusicListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat cellWidth = self.contentView.frame.size.width;

    self.selectImageView.frame = CGRectMake(0, 0, cellHeight, cellHeight);
    self.nameLabel.frame = CGRectMake(cellHeight, 0, 100, cellHeight);
    [self.nameLabel sizeToFit];
    self.nameLabel.center = CGPointMake(self.nameLabel.center.x, cellHeight/2);
    self.loopImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame), 0, cellHeight, cellHeight);
    self.timeLabel.frame = CGRectMake(cellWidth-cellHeight*3-5, 0, cellHeight*3, cellHeight);
    self.lineView.frame = CGRectMake(0, cellHeight-1, cellWidth, 1);
}

- (void)setupSubviews {
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.selectImageView = [[UIImageView alloc] init];
    self.selectImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.selectImageView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont systemFontOfSize:14.f];
    [self.contentView addSubview:self.nameLabel];
    
    self.loopImageView = [[UIImageView alloc] init];
    self.loopImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.loopImageView];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.font = [UIFont systemFontOfSize:13.f];
    self.timeLabel.text = @"00:00/00:00";
    [self.contentView addSubview:self.timeLabel];
    
    self.lineView = [[UIView alloc] init];
    //self.lineView.backgroundColor = AlivcRGB(141, 141, 141);
    [self.contentView addSubview:self.lineView];
}


- (void)setLoopHidden:(BOOL)isHidden {
    
    [self.loopImageView setHidden:isHidden];
}

- (void)setupMusicInfoModel:(AlivcMusicInfoModel *)model {
    
    _model = model;
    self.nameLabel.text = model.name;
    
    if ([model.name isEqualToString:@"无音乐"]) {
        [self.loopImageView removeFromSuperview];
        [self.timeLabel removeFromSuperview];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
       // self.nameLabel.textColor = AlivcRGB(0, 192, 251);
        self.selectImageView.image = [UIImage imageNamed:@"music_check"];
        self.loopImageView.image = [UIImage imageNamed:@"music_loop_simple_line"];
        [self.timeLabel setHidden:NO];
    } else {
        self.nameLabel.textColor = [UIColor whiteColor];
        self.selectImageView.image = [UIImage new];
        self.loopImageView.image = [UIImage new];
        [self.timeLabel setHidden:YES];
    }
}

- (void)updateMusicDuration:(long)currentTime totalTime:(long)totalTime {
    
    int currentTimeSecond = (int)currentTime/1000;
    int currentM = currentTimeSecond/60;
    int currentS = currentTimeSecond-currentM*60;
    
    int totalTimeSecond = (int)totalTime/1000;
    int totalM = totalTimeSecond/60;
    int totalS = totalTimeSecond-totalM*60;
    
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d", currentM, currentS, totalM, totalS];
    self.timeLabel.text = currentTimeStr;
}

@end


#pragma mark - AlivcMusicSettingView

@interface AlivcMusicSettingView ()

@property (nonatomic, weak) id<AlivcMusicViewDelegate>delegate;

@property (nonatomic, strong) UITableView *musicListView;
@property (nonatomic, strong) NSArray *musicDataArray;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *loopButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *earBackButton;
@property (nonatomic, strong) UIButton *denoiseButton;

@property (nonatomic, strong) UILabel *accompanyValue;
@property (nonatomic, strong) UISlider *accompanySlider;
@property (nonatomic, strong) UILabel *voiceValue;
@property (nonatomic, strong) UISlider *voiceSlider;

@property (nonatomic, assign) BOOL musicMode;

@end


@implementation AlivcMusicSettingView

- (instancetype)initWithFrame:(CGRect)frame musicMode:(BOOL)musicMode {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.musicMode = musicMode;
        [self setupSubViews];
        [self fetchData];
    }
    return self;
}

- (void)layoutSubviews {
    
}

- (void)setMusicDelegate:(id)delegate {
    
    self.delegate = delegate;
}

- (void)fetchData {
    
    AlivcMusicInfoModel *model0 = [[AlivcMusicInfoModel alloc] initWithMusicName:NSLocalizedString(@"无音乐",nil) musicPath:nil musicDuation:0.0 isLocal:YES];
    
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"Axol" ofType:@"mp3"];
    AlivcMusicInfoModel *model1 = [[AlivcMusicInfoModel alloc] initWithMusicName:NSLocalizedString(@"Axol(APP资源)",nil) musicPath:path1 musicDuation:0.0 isLocal:YES];
    
    NSString *path2 = [self getMusicPathWithMusicName:@"Pas de Deux"];
    
    AlivcMusicInfoModel *model2 = [[AlivcMusicInfoModel alloc] initWithMusicName:NSLocalizedString(@"Pas de Deux(沙盒资源)",nil) musicPath:path2 musicDuation:0.0 isLocal:YES];
    
    NSString *path3 = @"http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/attach/51991/cn_zh/1511776743437/JUST%202017.mp3";
    AlivcMusicInfoModel *model3 = [[AlivcMusicInfoModel alloc] initWithMusicName:NSLocalizedString(@"网络音乐1",nil) musicPath:path3 musicDuation:0.0 isLocal:NO];
    
    self.musicDataArray = [[NSArray alloc] initWithObjects:model0, model1, model2, model3, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.musicListView reloadData];
        NSIndexPath *selectIndex = [NSIndexPath indexPathForItem:1 inSection:0];
        [self.musicListView selectRowAtIndexPath:selectIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.musicListView didSelectRowAtIndexPath:selectIndex];
    });

}

- (NSString *)getMusicPathWithMusicName:(NSString *)musicName {
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:musicName ofType:@"mp3"];
    
    if (!bundlePath) {
        return nil;
    }
    
    NSString *cachePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:musicName] stringByAppendingPathExtension:@"mp3"];
        
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:cachePath error:nil];
    }
    
    return cachePath;
}

- (void)setupSubViews {
    
   // self.backgroundColor = AlivcRGB(74, 74, 74);
    
    [self setupMusicListView];
    
    [self setupMusicVolumeView];
    
    [self setupBottomView];
}


- (void)setupMusicListView {
    
    self.musicListView = [[UITableView alloc] init];
    self.musicListView.frame = CGRectMake(0,
                                          0,
                                          CGRectGetWidth(self.frame),
                                          CGRectGetHeight(self.frame) / 2);

    self.musicListView.backgroundColor = [UIColor clearColor];
    self.musicListView.delegate = (id)self;
    self.musicListView.dataSource = (id)self;
    self.musicListView.scrollEnabled = NO;
    self.musicListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.musicListView registerClass:[AlivcMusicListViewCell class] forCellReuseIdentifier:@"AlivcMusicListTableViewCellIndentifier"];
    [self addSubview:self.musicListView];
}


- (void)setupMusicVolumeView {
    
    UIView *volumeView = [[UIView alloc] init];
    volumeView.frame = CGRectMake(0,
                                  CGRectGetMaxY(self.musicListView.frame),
                                  self.frame.size.width,
                                  self.frame.size.height-(44));
    [self addSubview:volumeView];
    
    int labelCount = 2;
    CGFloat retract = 10;

    CGFloat labelWidth =  (30);

    NSArray *nameArray = @[NSLocalizedString(@"伴奏", nil),NSLocalizedString(@"人声", nil)];
    NSArray *textFieldActionArray = @[@"accompanySliderAction:", @"voiceSliderAction:"];
    
    for (int index = 0; index < labelCount; index++) {
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(retract,
                                     retract +(retract*(index+1))+(labelWidth*index),
                                     labelWidth * 2,
                                     labelWidth);
        nameLabel.textAlignment = NSTextAlignmentRight;
        nameLabel.font = [UIFont systemFontOfSize:14.f];
        nameLabel.text = nameArray[index];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        nameLabel.numberOfLines = 0;
        
        UISlider *slider = [[UISlider alloc] init];
        slider.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame) + retract,
                                  CGRectGetMinY(nameLabel.frame),
                                  CGRectGetWidth(volumeView.frame)- (110),
                                  labelWidth);
        slider.minimumValue = 0;
        slider.maximumValue = 100;
        slider.value = 50;
        [slider addTarget:self action:NSSelectorFromString(textFieldActionArray[index]) forControlEvents:(UIControlEventValueChanged)];
        
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.frame = CGRectMake(CGRectGetMaxX(slider.frame)+retract,
                                     CGRectGetMinY(nameLabel.frame),
                                     labelWidth * 2,
                                     labelWidth);
        valueLabel.textAlignment = NSTextAlignmentLeft;
        valueLabel.font = [UIFont systemFontOfSize:14.f];
        valueLabel.text = @"50";
        valueLabel.textColor = [UIColor whiteColor];

        [volumeView addSubview:nameLabel];
        [volumeView addSubview:slider];
        [volumeView addSubview:valueLabel];
        
        if (index == 0) {
            self.accompanyValue = valueLabel;
            self.accompanySlider = slider;
        }
        if (index == 1) {
            self.voiceValue = valueLabel;
            self.voiceSlider = slider;
        }
        
    }

}

- (void)setupBottomView {
    
    CGFloat viewWidth =  (50);
    CGFloat viewHeight = viewWidth/4*3;
    
 
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0,
                                  CGRectGetHeight(self.frame) - viewHeight,
                                  CGRectGetWidth(self.frame),
                                  viewHeight);
    [self addSubview:bottomView];
    
    CGFloat buttonCount = 6;
    CGFloat retractX = (CGRectGetWidth(bottomView.frame) - viewWidth * 6) / (buttonCount + 1);
    
    self.pauseButton = [self setupButtonWithFrame:(CGRectMake(retractX, 0, viewWidth, viewHeight))
                                      normalTitle:NSLocalizedString(@"pause_button", nil)
                                        selectTitle:NSLocalizedString(@"resume_button", nil)
                                             action:@selector(pauseButtonAction:)];
    [bottomView addSubview:self.pauseButton];
    
    self.playButton = [self setupButtonWithFrame:(CGRectMake(retractX * 2 + viewWidth, 0, viewWidth, viewHeight))
                                     normalTitle:NSLocalizedString(@"停止", nil)
                                     selectTitle:NSLocalizedString(@"播放", nil)
                                          action:@selector(playButtonAction:)];
    [bottomView addSubview:self.playButton];
    
    self.loopButton = [self setupButtonWithFrame:(CGRectMake(retractX * 3 + viewWidth * 2, 0, viewWidth, viewHeight))
                                      normalTitle:NSLocalizedString(@"关循环", nil)
                                      selectTitle:NSLocalizedString(@"开循环", nil)
                                           action:@selector(loopButtonAction:)];
    [bottomView addSubview:self.loopButton];
    
    self.muteButton = [self setupButtonWithFrame:(CGRectMake(retractX * 4 + viewWidth * 3, 0, viewWidth, viewHeight))
                                        normalTitle:NSLocalizedString(@"开静音", nil)
                                        selectTitle:NSLocalizedString(@"关静音", nil)
                                             action:@selector(muteButtonAction:)];
    [bottomView addSubview:self.muteButton];
    
    
    self.earBackButton = [self setupButtonWithFrame:(CGRectMake(retractX * 5 + viewWidth * 4, 0, viewWidth, viewHeight))
                                        normalTitle:NSLocalizedString(@"开耳返", nil)
                                        selectTitle:NSLocalizedString(@"关耳返", nil)
                                             action:@selector(earbackButtonAction:)];
    [bottomView addSubview: self.earBackButton];

    
    if(!self.musicMode)
    {
        self.denoiseButton = [self setupButtonWithFrame:(CGRectMake(retractX * 6 + viewWidth * 5, 0, viewWidth, viewHeight))
                                            normalTitle:NSLocalizedString(@"关降噪", nil)
                                            selectTitle:NSLocalizedString(@"开降噪", nil)
                                                 action:@selector(denoiseButtonAction:)];
        [bottomView addSubview: self.denoiseButton];
        [self.denoiseButton setSelected:NO];
    }
    else
    {
        self.denoiseButton = [self setupButtonWithFrame:(CGRectMake(retractX * 6 + viewWidth * 5, 0, viewWidth, viewHeight))
                                            normalTitle:NSLocalizedString(@"开降噪", nil)
                                            selectTitle:NSLocalizedString(@"关降噪", nil)
                                                 action:@selector(denoiseButtonAction:)];
        [bottomView addSubview: self.denoiseButton];
        [self.denoiseButton setSelected:NO];
    }
    
}

- (UIButton *)setupButtonWithFrame:(CGRect)rect normalTitle:(NSString *)normal selectTitle:(NSString *)select action:(SEL)action {
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = rect;
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    [button setTitle:normal forState:(UIControlStateNormal)];
    [button setTitle:select forState:(UIControlStateSelected)];
    [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [button setTitleColor:[UIColor grayColor] forState:(UIControlStateDisabled)];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = rect.size.height / 5;
    return button;
}

#pragma mark - Public

- (void)updateMusicDuration:(long)currentTime totalTime:(long)totalTime {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [self.musicListView indexPathForSelectedRow];
        AlivcMusicListViewCell *selectedCell = [self.musicListView cellForRowAtIndexPath:indexPath];
        [selectedCell updateMusicDuration:currentTime totalTime:totalTime];
    });
}

- (void)resetButtonTypeWithPlayError {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playButton setSelected:NO];
        [self.pauseButton setSelected:NO];
    });
}

#pragma mark - TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.musicDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlivcMusicListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlivcMusicListTableViewCellIndentifier" forIndexPath:indexPath];
    
    if (indexPath.row < self.musicDataArray.count) {
        AlivcMusicInfoModel *model = self.musicDataArray[indexPath.row];
        
        [cell setupMusicInfoModel:model];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = tableView.frame.size.height / self.musicDataArray.count;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    AlivcMusicListViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setLoopHidden:self.loopButton.selected];
    
    BOOL isNoneMusicCell = indexPath.row==0;
    
    [self.accompanySlider setEnabled:!isNoneMusicCell];
//    [self.voiceSlider setEnabled:!isNoneMusicCell];
    [self.pauseButton setEnabled:!isNoneMusicCell];
    [self.playButton setEnabled:!isNoneMusicCell];
    [self.loopButton setEnabled:!isNoneMusicCell];
//    [self.muteButton setEnabled:!isNoneMusicCell];
//    [self.earBackButton setEnabled:!isNoneMusicCell];

    if (indexPath.row >= self.musicDataArray.count) {
        return;
    }
    AlivcMusicInfoModel *model = self.musicDataArray[indexPath.row];
    
    if (isNoneMusicCell) {
        // 无音乐
        [self stopPlayBGM];
    } else {
        // 音乐
        [self startPlayBGMWithModel:model];
        [self.playButton setSelected:NO];
    }
}

#pragma mark - Private

- (void)startPlayBGMWithModel:(AlivcMusicInfoModel *)model {
    
    if (self.delegate) {
        [self.delegate musicOnClickPlayButton:YES musicPath:model.path];
    }
    [self.pauseButton setSelected:NO];
    [self.pauseButton setEnabled:YES];
}


- (void)stopPlayBGM {
    
    if (self.delegate) {
        [self.delegate musicOnClickPlayButton:NO musicPath:nil];
    }
    [self.pauseButton setSelected:NO];
    [self.pauseButton setEnabled:NO];
}

#pragma mark - Button Actions

- (void)pauseButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    
    if (self.delegate) {
        [self.delegate musicOnClickPauseButton:sender.selected];
    }
}

- (void)playButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];

    NSIndexPath *indexPath = [self.musicListView indexPathForSelectedRow];
    AlivcMusicInfoModel *musicModel = self.musicDataArray[indexPath.row];
    
    if (sender.selected) {
        [self stopPlayBGM];
    } else {
        [self startPlayBGMWithModel:musicModel];
    }
}

- (void)loopButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    
    NSIndexPath *indexPath = [self.musicListView indexPathForSelectedRow];
    AlivcMusicListViewCell *selectedCell = [self.musicListView cellForRowAtIndexPath:indexPath];
    [selectedCell setLoopHidden:sender.selected];
    
    if (self.delegate) {
        [self.delegate musicOnClickLoopButton:!sender.selected];
    }
}

- (void)muteButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    
    [self.voiceSlider setEnabled:!sender.selected];
    [self.accompanySlider setEnabled:!sender.selected];

    if (self.delegate) {
        [self.delegate musicOnClickMuteButton:sender.selected];
    }
}

- (void)earbackButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];

    if (self.delegate) {
        [self.delegate musicOnClickEarBackButton:sender.selected];
    }
}

- (void)denoiseButtonAction:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    
    if (self.delegate) {
        if(self.musicMode)
        {
            [self.delegate musicOnClickDenoiseButton:sender.selected];
        }
        else
        {
            [self.delegate musicOnClickDenoiseButton:!sender.selected];
        }
        
    }
}

#pragma mark - Slider Action

- (void)accompanySliderAction:(UISlider *)sender {
    
    self.accompanyValue.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    
    if (self.delegate) {
        [self.delegate musicOnSliderAccompanyValueChanged:(int)sender.value];
    }
}

- (void)voiceSliderAction:(UISlider *)sender {
    
    self.voiceValue.text = [NSString stringWithFormat:@"%d",(int)sender.value];

    if (self.delegate) {
        [self.delegate musicOnSliderVoiceValueChanged:(int)sender.value];
    }
}

@end
