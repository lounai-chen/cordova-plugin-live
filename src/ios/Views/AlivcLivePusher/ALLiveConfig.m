//
//  RaceBeautyConfig.m
//  AliLiveSdk-Demo
//
//  Created by ZhouGuixin on 2020/7/28.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "ALLiveConfig.h"
#import <queen/Queen.h>

@interface ALLiveConfig ()

@property (nonatomic, strong) NSMutableArray *raceBeautyConfig_bak;

@end

@implementation ALLiveConfig

+ (instancetype)sharedInstance {
    static ALLiveConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ALLiveConfig alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self mkConfig];
    }
    return self;
}

- (void)resetRaceBeautyConfig {
    self.raceBeautyConfig = CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(self.raceBeautyConfig_bak), kCFPropertyListMutableContainersAndLeaves));
}

- (void)mkConfig {
    NSArray *config = @[
        @{
                    @"type" : @(0), // 美颜
                    @"isopen" : @(YES),
                    @"data" : @[
                            @{@"name":@"磨皮",        @"key":@(1),    @"value":@(0.6),    @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0.6)},
                            @{@"name":@"锐化",        @"key":@(2),        @"value":@(0.8),    @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0.8)},
                            @{@"name":@"美白",        @"key":@(3),      @"value":@(0.6),    @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0.6)},
                    ]
                },
        @{
            @"type" : @(3), // 美型
            @"isopen" : @(NO),
            @"data" : @[
                    @{@"name":@"颧骨",    @"key":@(kQueenBeautyFaceShapeTypeCutCheek),         @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"削脸",    @"key":@(kQueenBeautyFaceShapeTypeCutFace),          @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"瘦脸",    @"key":@(kQueenBeautyFaceShapeTypeThinFace),         @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"脸长",    @"key":@(kQueenBeautyFaceShapeTypeLongFace),         @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"下巴缩短", @"key":@(kQueenBeautyFaceShapeTypeLowerJaw),         @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"下巴拉长", @"key":@(kQueenBeautyFaceShapeTypeHigherJaw),        @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"瘦下巴",  @"key":@(kQueenBeautyFaceShapeTypeThinJaw),           @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"瘦下颌",  @"key":@(kQueenBeautyFaceShapeTypeThinMandible),      @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"大眼",    @"key":@(kQueenBeautyFaceShapeTypeBigEye),            @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"眼角1",   @"key":@(kQueenBeautyFaceShapeTypeEyeAngle1),         @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"眼距",    @"key":@(kQueenBeautyFaceShapeTypeCanthus),           @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"拉宽眼距", @"key":@(kQueenBeautyFaceShapeTypeCanthus1),          @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"眼角2",   @"key":@(kQueenBeautyFaceShapeTypeEyeAngle2),         @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"眼睛高度", @"key":@(kQueenBeautyFaceShapeTypeEyeTDAngle),        @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"瘦鼻",    @"key":@(kQueenBeautyFaceShapeTypeThinNose),          @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"鼻翼",    @"key":@(kQueenBeautyFaceShapeTypeNosewing),          @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"鼻长",    @"key":@(kQueenBeautyFaceShapeTypeNasalHeight),       @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"鼻头长",  @"key":@(kQueenBeautyFaceShapeTypeNoseTipHeight),     @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"唇宽",    @"key":@(kQueenBeautyFaceShapeTypeMouthWidth),        @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"嘴唇大小",@"key":@(kQueenBeautyFaceShapeTypeMouthSize),          @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"唇高",   @"key":@(kQueenBeautyFaceShapeTypeMouthHigh),          @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"人中",   @"key":@(kQueenBeautyFaceShapeTypePhiltrum),           @"value":@(0),      @"min":@(-1), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},
                    @{@"name":@"最大值", @"key":@(kQueenBeautyFaceShapeTypeMAX),                 @"value":@(0),      @"min":@(0), @"max":@(1), @"type":@"slider", @"currentValue":@(0)},

            ]
        },
        @{
            @"type" : @(1), // 美妆
            @"isopen" : @(YES),
            @"data" : @[
                    @{@"name":@"整妆",        @"key":@(kQueenBeautyMakeupTypeWhole),    @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"eye_brow", @"currentValue":@(0.0)},
                    @{@"name":@"高光",        @"key":@(kQueenBeautyMakeupTypeHighlight),      @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"highlight", @"currentValue":@(0.0)},
                    @{@"name":@"美瞳",        @"key":@(kQueenBeautyMakeupTypeEyeball),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"eyeball", @"currentValue":@(0.0)},
                    @{@"name":@"口红",        @"key":@(kQueenBeautyMakeupTypeMouth),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"mouth", @"currentValue":@(0.0)},
                    @{@"name":@"眼妆",        @"key":@(kQueenBeautyMakeupTypeEyeBrow),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"eye_brow", @"currentValue":@(0.0)},
            ]
        },
        @{
            @"type" : @(1), // 腮红
            @"isopen" : @(YES),
            @"data" : @[
                    @{@"name":@"黛紫腮红",        @"key":@(kQueenBeautyMakeupTypeBlush),    @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"blush_黛紫腮红", @"currentValue":@(0.0)},
                    @{@"name":@"蜜橘腮红",        @"key":@(kQueenBeautyMakeupTypeBlush),      @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"blush_蜜橘腮红", @"currentValue":@(0.0)},
                    @{@"name":@"嫩粉腮红",        @"key":@(kQueenBeautyMakeupTypeBlush),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"blush_嫩粉腮红", @"currentValue":@(0.0)},
                    @{@"name":@"桃红腮红",        @"key":@(kQueenBeautyMakeupTypeBlush),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"blush_桃红腮红", @"currentValue":@(0.0)},
                    @{@"name":@"樱桃腮红",        @"key":@(kQueenBeautyMakeupTypeBlush),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"blush_樱桃腮红", @"currentValue":@(0.0)},
            ]
        },
        @{
            @"type" : @(1), // 整妆
            @"isopen" : @(YES),
            @"data" : @[
                    @{@"name":@"活力妆",        @"key":@(kQueenBeautyMakeupTypeWhole),    @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"活力妆", @"currentValue":@(0.0)},
                    @{@"name":@"基础妆",        @"key":@(kQueenBeautyMakeupTypeWhole),      @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"基础妆", @"currentValue":@(0.0)},
                    @{@"name":@"梅子妆",        @"key":@(kQueenBeautyMakeupTypeWhole),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"梅子妆", @"currentValue":@(0.0)},
                    @{@"name":@"魅惑妆",        @"key":@(kQueenBeautyMakeupTypeWhole),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"魅惑妆", @"currentValue":@(0.0)},
                    @{@"name":@"蜜桃妆",        @"key":@(kQueenBeautyMakeupTypeWhole),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"蜜桃妆", @"currentValue":@(0.0)},
                    @{@"name":@"奶橘妆",        @"key":@(kQueenBeautyMakeupTypeWhole),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"奶橘妆", @"currentValue":@(0.0)},
                    @{@"name":@"杏粉妆",        @"key":@(kQueenBeautyMakeupTypeWhole),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"杏粉妆", @"currentValue":@(0.0)},
                    @{@"name":@"优雅妆",        @"key":@(kQueenBeautyMakeupTypeWhole),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"优雅妆", @"currentValue":@(0.0)},
                    @{@"name":@"元气少女妆",        @"key":@(kQueenBeautyMakeupTypeWhole),        @"value":@(0.0),    @"min":@(0), @"max":@(1), @"type":@"slider", @"dir":@"makeup", @"filename":@"元气少女妆", @"currentValue":@(0.0)},
            ]
        }
    ];
    self.raceBeautyConfig_bak = CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (__bridge CFPropertyListRef)(config), kCFPropertyListMutableContainersAndLeaves));
    [self resetRaceBeautyConfig];
}

@end



