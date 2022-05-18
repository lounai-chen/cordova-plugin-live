//
//  AlivcDebugTextView.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/10/17.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import "AlivcDebugTextView.h"

#import <AlivcLivePusher/AlivcLivePusher.h>

@interface AlivcDebugTextView()

@property (nonatomic, strong) UITextView *debugTextView;


@end

@implementation AlivcDebugTextView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews {
    
    self.debugTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.frame) - 40, CGRectGetHeight(self.frame) - 40)];
    self.debugTextView.textColor = [UIColor redColor];
    self.debugTextView.backgroundColor = [UIColor clearColor];
    self.debugTextView.font = [UIFont fontWithName:@"Arial" size:14.0];
    [self.debugTextView setEditable:NO];
    [self addSubview:self.debugTextView];

}


- (void)updateData:(AlivcLivePushStatsInfo *)info {
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];

    [mutableString appendString:[NSString stringWithFormat:@"\n%@:\n\n", NSLocalizedString(@"publisher_log", nil)]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %.2f%%\n", NSLocalizedString(@"text_log_1", nil), info.CPUHold]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %.2fMB\n\n", NSLocalizedString(@"text_log_2", nil), info.memoryHold]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_3", nil), info.videoCaptureFps]];
    
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", NSLocalizedString(@"text_log_5", nil), info.audioEncodedBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_6", nil), info.audioEncodedFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_42", nil), info.audioFramesInEncodeBuffer]];
    
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_7", nil), info.videoRenderFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_44", nil), info.videoFramesInRenderBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d ms\n", NSLocalizedString(@"text_log_45", nil), info.videoRenderConsumingTimePerFrame]];

//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", NSLocalizedString(@"text_log_9", nil), info.videoEncodedBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_43", nil), info.videoFramesInEncodeBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_10", nil), info.videoEncodedFps]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", NSLocalizedString(@"text_log_11", nil), info.totalFramesOfEncodedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", NSLocalizedString(@"text_log_12", nil), info.totalTimeOfEncodedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", NSLocalizedString(@"text_log_13", nil), info.videoEncodeParam]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %@\n", NSLocalizedString(@"text_log_8", nil), info.videoEncoderMode==0?@"Hardware":@"Soft"]];
    
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", NSLocalizedString(@"text_log_14", nil), info.audioUploadBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d Kbps\n", NSLocalizedString(@"text_log_15", nil), info.videoUploadBitrate]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_16", nil), info.audioPacketsInUploadBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_17", nil), info.videoPacketsInUploadBuffer]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_18", nil), info.videoUploadFps]];
//    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_19", nil), info.audioUploadFps]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", NSLocalizedString(@"text_log_21", nil), info.currentlyUploadedAudioFramePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", NSLocalizedString(@"text_log_20", nil), info.currentlyUploadedVideoFramePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", NSLocalizedString(@"text_log_22", nil), info.previousVideoKeyframePts]];
    [mutableString appendString:[NSString stringWithFormat:@"%@: %lld\n", NSLocalizedString(@"text_log_23", nil), info.lastVideoPtsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", NSLocalizedString(@"text_log_24", nil), info.lastAudioPtsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", NSLocalizedString(@"text_log_25", nil), info.totalSizeOfUploadedPackets]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", NSLocalizedString(@"text_log_26", nil), info.totalTimeOfUploading]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld\n", NSLocalizedString(@"text_log_27", nil), info.totalFramesOfUploadedVideo]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_28", nil), info.totalDurationOfDropingVideoFrames]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_29", nil), info.totalTimesOfDropingVideoFrames]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_30", nil), info.totalTimesOfDisconnect]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"text_log_31", nil), info.totalTimesOfReconnect]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", NSLocalizedString(@"text_log_32", nil), info.videoDurationFromCaptureToUpload]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", NSLocalizedString(@"text_log_33", nil), info.audioDurationFromCaptureToUpload]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", NSLocalizedString(@"text_log_34", nil), info.currentUploadPacketSize]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld ms\n", NSLocalizedString(@"text_log_35", nil), info.audioVideoPtsDiff]];
    [mutableString appendString:[NSString stringWithFormat:@"%@ %lld Bytes\n", NSLocalizedString(@"text_log_37", nil), info.maxSizeOfVideoPacketsInBuffer]];
    [mutableString appendString:[NSString stringWithFormat:@"%@%lld Bytes\n", NSLocalizedString(@"text_log_38", nil), info.maxSizeOfAudioPacketsInBuffer]];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.debugTextView.text = mutableString;
    });
}

@end
