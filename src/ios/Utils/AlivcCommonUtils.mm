//
//  AlivcCommonUtils.m
//  AlivcLivePusherDemo
//
//  Created by zhangjc on 2021/12/14.
//  Copyright © 2021 TripleL. All rights reserved.
//

#import "AlivcCommonUtils.h"
#import <opencv2/opencv.hpp>

@implementation AlivcCommonUtils

+ (void)nv12toRGBWithYUV:(unsigned char* )pYUV withRGB:(unsigned char*)rgb withWidht:(int)width withHeight:(int)height
{
    if (width < 1 || height < 1 || pYUV == NULL)
    {
        return;
    }
    int yuvHeight = height + height / 2.0f;
    cv::Mat _yuv(yuvHeight, width, CV_8UC1, (uchar*)pYUV);
    cv::Mat _rgb(height, width, CV_8UC3, (uchar *)rgb);
    cv::cvtColor(_yuv, _rgb, CV_YUV2RGB_NV12);
}

@end
