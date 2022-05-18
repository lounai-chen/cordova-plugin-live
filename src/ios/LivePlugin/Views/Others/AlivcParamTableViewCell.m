//
//  AlivcParamTableViewCell.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AlivcParamTableViewCell.h"
#import "AlivcParamModel.h"
#import "UIColor+ALLiveColor.h"

@interface AlivcParamTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UISwitch *switcher;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UIButton *switchButton;

@property (nonatomic, strong) UILabel *titleLabelAppose;
@property (nonatomic, strong) UISwitch *switcherAppose;
@property (nonatomic, strong) UILabel *headerLabel;


@end


@implementation AlivcParamTableViewCell


- (void)setupSubViews {
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = self.cellModel.title;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];
    
    if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellInput]) {
        [self setupInputView];
    }else if([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSwitch]) {
        [self setupSwitchView];
    }else if([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSlider]) {
        [self setupSliderView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSwitchButton]) {
        [self setupSwitchButtonView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSwitchSetButton]){
        [self setupSwitchSignalButtonView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSegment]) {
        [self setupSegmentView];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSliderHeader]){
        [self setupSliderHeader];
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSegmentWhite]){
        [self setupSliderHeader];

    }
    else {
        
    }
}

- (void)setupInputView {
    self.inputView = [[UITextField alloc] init];
    self.inputView.borderStyle = UITextBorderStyleRoundedRect;
    self.inputView.textAlignment = 1;
    self.inputView.font = [UIFont systemFontOfSize:14];
    self.inputView.keyboardType = UIKeyboardTypeNumberPad;
    self.inputView.placeholder = self.cellModel.placeHolder;
    self.inputView.delegate = (id)self;
    [self.contentView addSubview:self.inputView];
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textAlignment = 0;
    self.infoLabel.font = [UIFont systemFontOfSize:12];
    self.infoLabel.text = self.cellModel.infoText;
    [self.contentView addSubview:self.infoLabel];

}

- (void)setupSwitchView {
    
    self.switcher = [[UISwitch alloc] init];
    self.switcher.onTintColor = [UIColor blueColor];
    [self.switcher setOn:(int)self.cellModel.defaultValue];
    [self.switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.switcher];
    
    self.titleLabelAppose = [[UILabel alloc] init];
    self.titleLabelAppose.textAlignment = NSTextAlignmentLeft;
    self.titleLabelAppose.font = [UIFont systemFontOfSize:14];
    self.titleLabelAppose.textColor = [UIColor blackColor];
    self.titleLabelAppose.text = self.cellModel.titleAppose;
    self.titleLabelAppose.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabelAppose.numberOfLines = 0;
    
    self.switcherAppose = [[UISwitch alloc] init];
    self.switcherAppose.onTintColor = [UIColor blueColor];
    [self.switcherAppose setOn:(int)self.cellModel.defaultValueAppose];
    [self.switcherAppose addTarget:self action:@selector(switchApposeAction:) forControlEvents:UIControlEventValueChanged];
    
    if (self.cellModel.titleAppose) {
        [self.contentView addSubview:self.titleLabelAppose];
        [self.contentView addSubview:self.switcherAppose];
    }
}


- (void)setupSliderHeader{
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    _headerLabel.text = self.cellModel.title;
    _headerLabel.font = [UIFont systemFontOfSize:12];
    _headerLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    [self.contentView addSubview:_headerLabel];

}
- (void)setupSliderView {
    
    self.slider = [[UISlider alloc] init];
    [self.slider addTarget:self action:@selector(silderValueDidChanged) forControlEvents:UIControlEventValueChanged];
    self.slider.value = self.cellModel.defaultValue;
    [self.contentView addSubview:self.slider];
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textAlignment = 0;
    self.infoLabel.font = [UIFont systemFontOfSize:12];
    self.infoLabel.text = self.cellModel.infoText;
    [self.contentView addSubview:self.infoLabel];
    
}

- (void)setupSwitchButtonView {
    
    [self setupSwitchView];
    self.switchButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.switchButton addTarget:self action:@selector(switchButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.switchButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    self.switchButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self.switchButton setTitle:self.cellModel.infoText forState:(UIControlStateNormal)];
    [self.contentView addSubview:self.switchButton];
}

- (void)setupSwitchSignalButtonView {
    
    [self setupSwitchView];
    self.switchButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self.switchButton addTarget:self action:@selector(switchButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.switchButton setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    self.switchButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self.switchButton setTitle:self.cellModel.infoText forState:(UIControlStateNormal)];
    [self.contentView addSubview:self.switchButton];
}


- (void)setupSegmentView {
    
    if (self.segment) {
        return;
    }
    self.segment = [[UISegmentedControl alloc] initWithItems:self.cellModel.segmentTitleArray];
    [self.segment addTarget:self action:@selector(segmentValueDidChanged:) forControlEvents:(UIControlEventValueChanged)];
    self.segment.selectedSegmentIndex = self.cellModel.defaultValue;

    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:10.f], NSFontAttributeName, nil];

    [self.segment setTitleTextAttributes:attr
                                forState:UIControlStateNormal];
    [self.contentView addSubview:self.segment];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat midY  = CGRectGetMidY(self.contentView.bounds);
    CGFloat midX  = CGRectGetMidX(self.contentView.bounds);
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    CGFloat titleWidth = (82);
    self.titleLabel.frame = CGRectMake(10, 0, titleWidth, CGRectGetHeight(self.contentView.bounds));
    if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellInput]) {
        self.inputView.frame = CGRectMake(titleWidth + 5, midY - 15, width - (140), 30);
        self.infoLabel.frame = CGRectMake(width - 40, midY - 10, 40, 20);
        
    }else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSwitch]) {
        self.switcher.frame = CGRectMake(titleWidth + 5, midY - 15, 40, 30);
        self.titleLabelAppose.frame = CGRectMake(midX, 0, 72, CGRectGetHeight(self.contentView.bounds));
        self.switcherAppose.frame = CGRectMake(CGRectGetMaxX(self.titleLabelAppose.frame) + 5, midY - 15, 40, 30);
        
    }else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSlider]) {
        self.titleLabel.frame = CGRectMake(0, 0, 0, 0);
        self.slider.frame = CGRectMake(5, midY - 15, width - (60), 30);
        self.infoLabel.frame = CGRectMake(width - 40, midY - 10, 40, 20);
        
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSegment]) {
        self.segment.frame = CGRectMake(titleWidth + 5, midY - 15, (200), 30);

    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSwitchButton]) {
        self.switcher.frame = CGRectMake(width - 70, midY - 15, 50, 30);
        self.switcher.hidden = NO;
        
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSwitchSetButton]){
        self.switcher.hidden = NO;
        self.switcher.frame = CGRectMake(width - 70, midY - 15, 50, 30);
        self.switchButton.hidden = YES;
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSliderHeader]){
        self.titleLabel.hidden = YES;
        _headerLabel.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSegmentWhite]){
        self.titleLabel.hidden = YES;
        _headerLabel.frame = CGRectMake(15, 0, self.frame.size.width-30, 40);
        _headerLabel.backgroundColor = [UIColor whiteColor];
    }
    else {
        
    }
}

- (void)configureCellModel:(AlivcParamModel *)cellModel {
    
    self.cellModel = cellModel;
    
    [self setupSubViews];
}


- (void)silderValueDidChanged {
    
    if ([self.titleLabel.text isEqual:NSLocalizedString(@"resolution_label", nil)]) {
        CGFloat total = 7;
        CGFloat value = self.slider.value;
        if (value <= (1.0/total)) {
            self.cellModel.sliderBlock(0);
            self.infoLabel.text = @"180P";
        } else if (value > (1.0/total) && value <= (2.0/total)) {
            self.cellModel.sliderBlock(1);
            self.infoLabel.text = @"240P";
        } else if (value > (2.0/total) && value <= (3.0/total)) {
            self.cellModel.sliderBlock(2);
            self.infoLabel.text = @"360P";
        } else if (value > (3.0/total) && value <= (4.0/total)) {
            self.cellModel.sliderBlock(3);
            self.infoLabel.text = @"480P";
        } else if (value > (4.0/total) && value <= (5.0/total)) {
            self.cellModel.sliderBlock(4);
            self.infoLabel.text = @"540P";
        } else if (value > (5.0/total) && value <= (6.0/total)) {
            self.cellModel.sliderBlock(5);
            self.infoLabel.text = @"720P";
        } else if (value > (6.0/total) && value <= (7.0/total)) {
            self.cellModel.sliderBlock(6);
            self.infoLabel.text = @"1080P";
        } else {
            
        }
    } else if ([self.titleLabel.text isEqual:NSLocalizedString(@"audio_sampling_rate", nil)]) {
        CGFloat total = 4;
        CGFloat value = self.slider.value;
        if (value <= (1.0/total) || value == 0) {
            self.cellModel.sliderBlock(16000);
            self.infoLabel.text = @"16kHz";
        } else if (value > (1.0/total) && value <= (2.0/total)) {
            self.cellModel.sliderBlock(32000);
            self.infoLabel.text = @"32kHz";
        } else if (value > (2.0/total) && value <= (3.0/total)) {
            self.cellModel.sliderBlock(44100);
            self.infoLabel.text = @"44kHz";
        }else if (value > (3.0/total) && value <= (4.0/total)) {
            self.cellModel.sliderBlock(48000);
            self.infoLabel.text = @"48kHz";
        }else {

        }
        //rts only support 44.1k and 48k
//        if (value <= (2.0/total)) {
//           self.cellModel.sliderBlock(44100);
//           self.infoLabel.text = @"44kHz";
//       }
//       else if (value > (2.0/total) && value <= (3.0/total)) {
//           self.cellModel.sliderBlock(48000);
//           self.infoLabel.text = @"48kHz";
//       }else if(value == 1){
//           self.cellModel.sliderBlock(48000);
//           self.infoLabel.text = @"48kHz";
//       }
    } else if([self.titleLabel.text isEqual:NSLocalizedString(@"captrue_fps", nil)] || [self.titleLabel.text isEqual:NSLocalizedString(@"min_fps", nil)]){
        CGFloat total = 7;
        CGFloat value = self.slider.value;
        CGFloat FPSvalue = 0;
        if (value < 1/total || value == 0) {
            self.infoLabel.text = @"8fps";
            FPSvalue=8;
        }else if ((value>1/total)&&(value<2/total)){
            self.infoLabel.text = @"10fps";
            FPSvalue=10;
        }else if ((value>2/total)&&(value<3/total)){
            self.infoLabel.text = @"12fps";
            FPSvalue=12;
        }else if ((value>3/total)&&(value<4/total)){
            self.infoLabel.text = @"15fps";
            FPSvalue=15;
        }else if ((value>4/total)&&(value<5/total)){
            self.infoLabel.text = @"20fps";
            FPSvalue=20;
        }else if ((value>5/total)&&(value<6/total)){
            self.infoLabel.text = @"25fps";
            FPSvalue=25;
        }else if ((value>6/total)&&(value<7/total)){
            self.infoLabel.text = @"30fps";
            FPSvalue=30;
        }else if (value == 1){
            self.infoLabel.text = @"30fps";
            FPSvalue=30;
        }
        self.cellModel.sliderBlock(FPSvalue);
    } else if([self.titleLabel.text isEqual:NSLocalizedString(@"keyframe_interval", nil)]){
        CGFloat total = 5;
        CGFloat value = self.slider.value;
        CGFloat FPSvalue = 0;
        if (value < 1/total || value == 0) {
            self.infoLabel.text = @"1s";
            FPSvalue=1;
        }else if ((value>1/total)&&(value<2/total)){
            self.infoLabel.text = @"2s";
            FPSvalue=2;
        }else if ((value>2/total)&&(value<3/total)){
            self.infoLabel.text = @"3s";
            FPSvalue=3;
        }else if ((value>3/total)&&(value<4/total)){
            self.infoLabel.text = @"4s";
            FPSvalue=4;
        }else if ((value>4/total)&&(value<5/total)){
            self.infoLabel.text = @"5s";
            FPSvalue=5;
        }else if (value == 1){
            self.infoLabel.text = @"5s";
            FPSvalue=5;
        }
        self.cellModel.sliderBlock(FPSvalue);
    }

    else {
        int beautyValue = self.slider.value*100;
        self.cellModel.sliderBlock(beautyValue);
        self.infoLabel.text = [NSString stringWithFormat:@"%d", beautyValue];
    }
    
    
//    fpsModel.title = NSLocalizedString(@"captrue_fps", nil);
//    fpsModel.segmentTitleArray = @[@"8",@"10",@"12",@"15",@"20",@"25",@"30"];

}


- (void)segmentValueDidChanged:(UISegmentedControl *)sender {
    
//    self.cellModel.segmentBlock((int)sender.selectedSegmentIndex);
    if ([self.cellModel.title isEqualToString:NSLocalizedString(@"sound_track", nil)]) {
        
        int value = (int)sender.selectedSegmentIndex + 1;
        self.cellModel.segmentBlock(value);
    } else if ([self.cellModel.title isEqualToString:NSLocalizedString(@"keyframe_interval", nil)]) {
        
        int value = (int)sender.selectedSegmentIndex + 1;
        self.cellModel.segmentBlock(value);
    } else if ([self.cellModel.title isEqualToString:NSLocalizedString(@"captrue_fps", nil)] || [self.cellModel.title isEqualToString:NSLocalizedString(@"min_fps", nil)]) {
     
        int value = 12;
        switch (sender.selectedSegmentIndex) {
            case 0:
                value = 8;
                break;
            case 1:
                value = 10;
                break;
            case 2:
                value = 12;
                break;
            case 3:
                value = 15;
                break;
            case 4:
                value = 20;
                break;
            case 5:
                value = 25;
                break;
            case 6:
                value = 30;
                break;
            default:
                break;
        }
        self.cellModel.segmentBlock(value);
    } else if ([self.cellModel.title isEqualToString:NSLocalizedString(@"audio_profile", nil)]) {
        
        int value = 2;
        switch (sender.selectedSegmentIndex) {
            case 0:
                value = 2;
                break;
            case 1:
                value = 5;
                break;
            case 2:
                value = 29;
                break;
            case 3:
                value = 23;
                break;
            default:
                break;
        }
        self.cellModel.segmentBlock(value);
    } else {
        
        int value = (int)sender.selectedSegmentIndex;
        self.cellModel.segmentBlock(value);
    }

}


- (void)switchAction:(id)sender {
    
    UISwitch *switcher = (UISwitch*)sender;
    BOOL isButtonOn = [switcher isOn];

    if (nil != self.cellModel && nil != self.cellModel.switchBlock) {
        self.cellModel.switchBlock(0, isButtonOn);
    }
}


- (void)switchApposeAction:(id)sender {
    
    UISwitch *switcher = (UISwitch*)sender;
    BOOL isButtonOn = [switcher isOn];

    if (nil != self.cellModel && nil != self.cellModel.switchBlock) {
        self.cellModel.switchBlock(1, isButtonOn);
    }
}

- (void)switchButtonAction:(UIButton *)sender {
    
    self.cellModel.switchButtonBlock();
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (self.cellModel.valueBlock) {
        self.inputView.keyboardType = UIKeyboardTypeNumberPad;
    }
    if (self.cellModel.stringBlock) {
        self.inputView.keyboardType = UIKeyboardTypeDefault;
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (!textField.text.length) {
        textField.text = textField.placeholder;
    }
    
    CGFloat r = [textField.text intValue];
    if (self.cellModel.valueBlock) {
        self.cellModel.valueBlock(r);
    }
    if (self.cellModel.stringBlock) {
        self.cellModel.stringBlock(textField.text);
    }
}

- (void)updateDefaultValue:(int)value enable:(BOOL)enable {
    
    if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellInput]) {
        
        self.inputView.placeholder = [NSString stringWithFormat:@"%d", value];
        self.inputView.text = nil;
        self.inputView.enabled = enable;
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSegment]) {
        
        self.segment.selectedSegmentIndex = value;
    } else if ([self.cellModel.reuseId isEqualToString:AlivcParamModelReuseCellSwitchButton]){
        
        self.inputView.placeholder = [NSString stringWithFormat:@"%d", value];
        self.inputView.text = nil;
        self.inputView.enabled = enable;
    }
    else {
        
    }

}

@end
