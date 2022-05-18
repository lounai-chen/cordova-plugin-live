//
//  AlivcParamModel.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *AlivcParamModelReuseCellInput = @"AlivcParamModelReuseCellInput";
static NSString *AlivcParamModelReuseCellSlider = @"AlivcParamModelReuseCellSlider";
static NSString *AlivcParamModelReuseCellSliderHeader= @"AlivcParamModelReuseCellSliderHeader";

static NSString *AlivcParamModelReuseCellSwitch = @"AlivcParamModelReuseCellSwitch";
static NSString *AlivcParamModelReuseCellSwitchButton = @"AlivcParamModelReuseCellSwitchButton";
static NSString *AlivcParamModelReuseCellSwitchSetButton = @"AlivcParamModelReuseCellSwitchSetButton";

static NSString *AlivcParamModelReuseCellSegment = @"AlivcParamModelReuseCellSegment";

static NSString *AlivcParamModelReuseCellSegmentWhite = @"AlivcParamModelReuseCellSegmenWhite";


@interface AlivcParamModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, copy) NSString *reuseId;
@property (nonatomic, copy) NSString *infoText;
@property (nonatomic, copy) NSArray *segmentTitleArray;
@property (nonatomic, assign) CGFloat defaultValue;

@property (nonatomic, copy) NSString *titleAppose; // 并排显示 switch title
@property (nonatomic, assign) CGFloat defaultValueAppose; // 并排显示 switch value

@property (nonatomic, copy) void(^valueBlock)(int value);
@property (nonatomic, copy) void(^switchBlock)(int index, BOOL open);
@property (nonatomic, copy) void(^sliderBlock)(int value);
@property (nonatomic, copy) void(^segmentBlock)(int value);
@property (nonatomic, copy) void(^switchButtonBlock)();
@property (nonatomic, copy) void(^stringBlock)(NSString *message);

@end
