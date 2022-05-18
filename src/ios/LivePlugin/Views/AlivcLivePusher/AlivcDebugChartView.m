//
//  AlivcDebugChartView.m
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 2017/10/9.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AlivcDebugChartView.h"
#import "AlivcChartView.h"

#import <AlivcLivePusher/AlivcLivePusher.h>

#define kAlivcChartViewRetractX  (20)
#define kAlivcChartViewRetractY ( (5) + kAlivcChartViewRetractX)
#define kAlivcChartModuleHeight  (150)
#define kAlivcChartViewModuleCount 4

@interface AlivcDebugChartView ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) AlivcChartView *videoRenderBuffer;
@property (nonatomic, strong) AlivcChartView *audioEncodeBuffer;
@property (nonatomic, strong) AlivcChartView *videoEncodeBuffer;
@property (nonatomic, strong) AlivcChartView *videoUploadBuffer;
@property (nonatomic, strong) AlivcChartView *audioUploadBuffer;

@property (nonatomic, strong) AlivcChartView *captureAudioFPS;
@property (nonatomic, strong) AlivcChartView *zoomAudioFPS;
@property (nonatomic, strong) AlivcChartView *encodeAudioFPS;
@property (nonatomic, strong) AlivcChartView *pushAudioFPS;

@property (nonatomic, strong) AlivcChartView *captureVideoFPS;
@property (nonatomic, strong) AlivcChartView *zoomVideoFPS;
@property (nonatomic, strong) AlivcChartView *encodeVideoFPS;
@property (nonatomic, strong) AlivcChartView *pushVideoFPS;

@property (nonatomic, strong) AlivcChartView *encodeVideoBitrate;
@property (nonatomic, strong) AlivcChartView *encodeAudioBitrate;
@property (nonatomic, strong) AlivcChartView *pushBiterate;

@end

@implementation AlivcDebugChartView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}


- (void)setupSubViews {
    
    [self setupScrollView];
    [self setupDurationViewsWithIndex:0];
    [self setupAudioFPSViewsWithIndex:1];
    [self setupVideoFPSViewsWithIndex:2];
    [self setupBitrateViewsWithIndex:3];
}


- (void)setupScrollView {
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.contentSize = CGSizeMake(0, kAlivcChartModuleHeight*kAlivcChartViewModuleCount);
    self.scrollView.frame = self.bounds;
    [self addSubview:self.scrollView];
}


- (void)setupDurationViewsWithIndex:(int)index {
    
    
    CGFloat totalProgress = 50;
    
    UIView *durationView = [[UIView alloc] init];
    durationView.frame = CGRectMake(0, kAlivcChartModuleHeight * index, CGRectGetWidth(self.frame), kAlivcChartModuleHeight);
    [self.scrollView addSubview:durationView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAlivcChartViewRetractX, kAlivcChartViewRetractX, 200, kAlivcChartViewRetractX);
    titleLabel.text = NSLocalizedString(@"buffer", nil);
    [durationView addSubview:titleLabel];
    
    self.videoRenderBuffer = [[AlivcChartView alloc]
                            initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                      kAlivcChartViewRetractY * 2,
                                                      CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                      kAlivcChartViewRetractX))
                            
                            backgroundColor:[UIColor clearColor]
                            barColor:[UIColor redColor]
                            barTitle:NSLocalizedString(@"video_renderbuffer", nil)
                            barTotalProgress:totalProgress];
    [durationView addSubview:self.videoRenderBuffer];
    
    self.videoEncodeBuffer = [[AlivcChartView alloc]
                         initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                   kAlivcChartViewRetractY * 3,
                                                   CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                   kAlivcChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor blueColor]
                         barTitle:NSLocalizedString(@"video_encodebuffer", nil)
                         barTotalProgress:totalProgress];
    [durationView addSubview:self.videoEncodeBuffer];
    
    
    self.audioEncodeBuffer = [[AlivcChartView alloc]
                           initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                     kAlivcChartViewRetractY * 4,
                                                     CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                     kAlivcChartViewRetractX))
                           backgroundColor:[UIColor clearColor]
                           barColor:[UIColor blackColor]
                           barTitle:NSLocalizedString(@"audio_encodebuffer", nil)
                           barTotalProgress:totalProgress];
    [durationView addSubview:self.audioEncodeBuffer];
    
    
    self.videoUploadBuffer = [[AlivcChartView alloc]
                         initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                   kAlivcChartViewRetractY * 5,
                                                   CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                   kAlivcChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor greenColor]
                         barTitle:NSLocalizedString(@"video_uploadbuffer", nil)
                         barTotalProgress:totalProgress];
    [durationView addSubview:self.videoUploadBuffer];
    
    self.audioUploadBuffer = [[AlivcChartView alloc]
                          initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                    kAlivcChartViewRetractY * 6,
                                                    CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                    kAlivcChartViewRetractX))
                          backgroundColor:[UIColor clearColor]
                          barColor:[UIColor orangeColor]
                          barTitle:NSLocalizedString(@"audio_uploadbuffer", nil)
                          barTotalProgress:totalProgress];
    [durationView addSubview:self.audioUploadBuffer];
    
}


- (void)setupAudioFPSViewsWithIndex:(int)index {
    
    CGFloat totalProgress = 50;
    
    UIView *audioFPSView = [[UIView alloc] init];
    audioFPSView.frame = CGRectMake(0, kAlivcChartModuleHeight * index, CGRectGetWidth(self.frame), kAlivcChartModuleHeight);
    [self.scrollView addSubview:audioFPSView];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAlivcChartViewRetractX, kAlivcChartViewRetractX, 200, kAlivcChartViewRetractX);
    titleLabel.text = NSLocalizedString(@"modules_audio_fps", nil);
    [audioFPSView addSubview:titleLabel];
    
    self.captureAudioFPS = [[AlivcChartView alloc]
                            initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                      kAlivcChartViewRetractY * 2,
                                                      CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                      kAlivcChartViewRetractX))
                            backgroundColor:[UIColor clearColor]
                            barColor:[UIColor redColor]
                            barTitle:NSLocalizedString(@"capture", nil)
                            barTotalProgress:totalProgress];
//    [audioFPSView addSubview:self.captureAudioFPS];
    
    
    self.encodeAudioFPS = [[AlivcChartView alloc]
                           initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                     kAlivcChartViewRetractY * 3,
                                                     CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                     kAlivcChartViewRetractX))
                           backgroundColor:[UIColor clearColor]
                           barColor:[UIColor blackColor]
                           barTitle:NSLocalizedString(@"encode", nil)
                           barTotalProgress:totalProgress];
    [audioFPSView addSubview:self.encodeAudioFPS];
    
    
    self.pushAudioFPS = [[AlivcChartView alloc]
                         initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                   kAlivcChartViewRetractY * 4,
                                                   CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                   kAlivcChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor greenColor]
                         barTitle:NSLocalizedString(@"push", nil)
                         barTotalProgress:totalProgress];
    [audioFPSView addSubview:self.pushAudioFPS];
    
}


- (void)setupVideoFPSViewsWithIndex:(int)index {
    
    CGFloat totalProgress = 50;
    
    UIView *videoFPSView = [[UIView alloc] init];
    videoFPSView.frame = CGRectMake(0, kAlivcChartModuleHeight * index, CGRectGetWidth(self.frame), kAlivcChartModuleHeight);
    [self.scrollView addSubview:videoFPSView];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAlivcChartViewRetractX, kAlivcChartViewRetractX, 200, kAlivcChartViewRetractX);
    titleLabel.text = NSLocalizedString(@"modules_video_fps", nil);
    [videoFPSView addSubview:titleLabel];
    
    self.captureVideoFPS = [[AlivcChartView alloc]
                            initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                      kAlivcChartViewRetractY * 2,
                                                      CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                      kAlivcChartViewRetractX))
                            backgroundColor:[UIColor clearColor]
                            barColor:[UIColor redColor]
                            barTitle:NSLocalizedString(@"capture", nil)
                            barTotalProgress:totalProgress];
    [videoFPSView addSubview:self.captureVideoFPS];
    
    self.zoomVideoFPS = [[AlivcChartView alloc]
                         initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                   kAlivcChartViewRetractY * 3,
                                                   CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                   kAlivcChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor blueColor]
                         barTitle:NSLocalizedString(@"render", nil)
                         barTotalProgress:totalProgress];
    [videoFPSView addSubview:self.zoomVideoFPS];
    
    
    self.encodeVideoFPS = [[AlivcChartView alloc]
                           initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                     kAlivcChartViewRetractY * 4,
                                                     CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                     kAlivcChartViewRetractX))
                           backgroundColor:[UIColor clearColor]
                           barColor:[UIColor blackColor]
                           barTitle:NSLocalizedString(@"encode", nil)
                           barTotalProgress:totalProgress];
    [videoFPSView addSubview:self.encodeVideoFPS];
    
    
    self.pushVideoFPS = [[AlivcChartView alloc]
                         initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                   kAlivcChartViewRetractY * 5,
                                                   CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                   kAlivcChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor greenColor]
                         barTitle:NSLocalizedString(@"push", nil)
                         barTotalProgress:totalProgress];
    [videoFPSView addSubview:self.pushVideoFPS];
    
}


- (void)setupBitrateViewsWithIndex:(int)index {
    
    CGFloat totalProgress = 5000;
    
    UIView *bitrateView = [[UIView alloc] init];
    bitrateView.frame = CGRectMake(0, kAlivcChartModuleHeight * index, CGRectGetWidth(self.frame), kAlivcChartModuleHeight);
    [self.scrollView addSubview:bitrateView];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(kAlivcChartViewRetractX, kAlivcChartViewRetractX, 200, kAlivcChartViewRetractX);
    titleLabel.text = NSLocalizedString(@"modules_bitrate", nil);
    [bitrateView addSubview:titleLabel];
    
    self.encodeVideoBitrate = [[AlivcChartView alloc]
                          initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                    kAlivcChartViewRetractY * 2,
                                                    CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                    kAlivcChartViewRetractX))
                          backgroundColor:[UIColor clearColor]
                          barColor:[UIColor blackColor]
                          barTitle:NSLocalizedString(@"video_encode", nil)
                          barTotalProgress:totalProgress];
    [bitrateView addSubview:self.encodeVideoBitrate];
    
    self.encodeAudioBitrate = [[AlivcChartView alloc]
                         initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                   kAlivcChartViewRetractY * 3,
                                                   CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                   kAlivcChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor blackColor]
                         barTitle:NSLocalizedString(@"audio_encode", nil)
                         barTotalProgress:totalProgress];
    [bitrateView addSubview:self.encodeAudioBitrate];
    
    self.pushBiterate = [[AlivcChartView alloc]
                         initWithFrame:(CGRectMake(kAlivcChartViewRetractX * 2,
                                                   kAlivcChartViewRetractY * 4,
                                                   CGRectGetWidth(self.frame) - kAlivcChartViewRetractX * 4,
                                                   kAlivcChartViewRetractX))
                         backgroundColor:[UIColor clearColor]
                         barColor:[UIColor greenColor]
                         barTitle:NSLocalizedString(@"push", nil)
                         barTotalProgress:totalProgress];
    [bitrateView addSubview:self.pushBiterate];
    
}


- (void)updateData:(AlivcLivePushStatsInfo *)info {
    
    
    [self.videoRenderBuffer updateBarProgress:info.videoFramesInRenderBuffer];
    [self.videoEncodeBuffer updateBarProgress:info.videoFramesInEncodeBuffer];
    [self.audioEncodeBuffer updateBarProgress:info.audioFramesInEncodeBuffer];
    [self.videoUploadBuffer updateBarProgress:info.videoPacketsInUploadBuffer];
    [self.audioUploadBuffer updateBarProgress:info.audioPacketsInUploadBuffer];

    [self.encodeAudioFPS updateBarProgress:info.audioEncodedFps];
    [self.pushAudioFPS updateBarProgress:info.audioUploadFps];
    
    [self.captureVideoFPS updateBarProgress:info.videoCaptureFps];
    [self.zoomVideoFPS updateBarProgress:info.videoRenderFps];
    [self.encodeVideoFPS updateBarProgress:info.videoEncodedFps];
    [self.pushVideoFPS updateBarProgress:info.videoUploadFps];
    
    [self.encodeVideoBitrate updateBarProgress:info.videoEncodedBitrate];
    [self.encodeAudioBitrate updateBarProgress:info.audioEncodedBitrate];
    [self.pushBiterate updateBarProgress:info.videoUploadBitrate];
}

@end
