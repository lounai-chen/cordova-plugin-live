//
//  AliLivePlayerFrameInfo.h
//  AliLivePlayerSDK
//
//  Copyright © 2021 Alibaba Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

typedef enum  AliLivePlayerFrameType : NSUInteger{
    AliLivePlayer_FrameType_Unknown,
    AliLivePlayer_FrameType_Video,
    AliLivePlayer_FrameType_Audio
} AliLivePlayerFrameType;

typedef  enum   AliLivePlayerSampleFormat : NSInteger {
    ALILIVEPLAYER_SAMPLE_FMT_NONE = -1,
    ALILIVEPLAYER_SAMPLE_FMT_U8,  ///< unsigned 8 bits
    ALILIVEPLAYER_SAMPLE_FMT_S16, ///< signed 16 bits
    ALILIVEPLAYER_SAMPLE_FMT_S32, ///< signed 32 bits
    ALILIVEPLAYER_SAMPLE_FMT_FLT, ///< float
    ALILIVEPLAYER_SAMPLE_FMT_DBL, ///< double
    
    ALILIVEPLAYER_SAMPLE_FMT_U8P,  ///< unsigned 8 bits, planar
    ALILIVEPLAYER_SAMPLE_FMT_S16P, ///< signed 16 bits, planar
    ALILIVEPLAYER_SAMPLE_FMT_S32P, ///< signed 32 bits, planar
    ALILIVEPLAYER_SAMPLE_FMT_FLTP, ///< float, planar
    ALILIVEPLAYER_SAMPLE_FMT_DBLP, ///< double, planar
    
    ALILIVEPLAYER_SAMPLE_FMT_NB, ///< Number of sample formats. DO NOT USE if linking dynamically
    
} AliLivePlayerSampleFormat;

typedef enum  AliLivePlayerPixelFormat : NSInteger {
    ALILIVEPLAYER_PIX_FMT_NONE = -1,
    ALILIVEPLAYER_PIX_FMT_YUV420P, ///< planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
    ALILIVEPLAYER_PIX_FMT_YUYV422, ///< packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
    ALILIVEPLAYER_PIX_FMT_RGB24,   ///< packed RGB 8:8:8, 24bpp, RGBRGB...
    ALILIVEPLAYER_PIX_FMT_BGR24,   ///< packed RGB 8:8:8, 24bpp, BGRBGR...
    ALILIVEPLAYER_PIX_FMT_YUV422P, ///< planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    ALILIVEPLAYER_PIX_FMT_YUV444P, ///< planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
    ALILIVEPLAYER_PIX_FMT_YUV410P, ///< planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
    ALILIVEPLAYER_PIX_FMT_YUV411P, ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
    ALILIVEPLAYER_PIX_FMT_GRAY8,   ///<        Y        ,  8bpp
    ALILIVEPLAYER_PIX_FMT_MONOWHITE, ///<        Y        ,  1bpp, 0 is white, 1 is black, in each
    ///<        byte pixels are ordered from the msb to the lsb
    ALILIVEPLAYER_PIX_FMT_MONOBLACK, ///<        Y        ,  1bpp, 0 is black, 1 is white, in each
    ///<        byte pixels are ordered from the msb to the lsb
    ALILIVEPLAYER_PIX_FMT_PAL8, ///< 8 bits with AV_PIX_FMT_RGB32 palette
    ALILIVEPLAYER_PIX_FMT_YUVJ420P, ///< planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in
    ///< favor of AV_PIX_FMT_YUV420P and setting color_range
    ALILIVEPLAYER_PIX_FMT_YUVJ422P, ///< planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in
    ///< favor of AV_PIX_FMT_YUV422P and setting color_range
    ALILIVEPLAYER_PIX_FMT_YUVJ444P, ///< planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in
    ///< favor of AV_PIX_FMT_YUV444P and setting color_range
    ALILIVEPLAYER_PIX_FMT_UYVY422,   ///< packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
    ALILIVEPLAYER_PIX_FMT_UYYVYY411, ///< packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
    ALILIVEPLAYER_PIX_FMT_BGR8,      ///< packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
    ALILIVEPLAYER_PIX_FMT_BGR4, ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a
    ///< byte contains two pixels, the first pixel in the byte is the
    ///< one composed by the 4 msb bits
    ALILIVEPLAYER_PIX_FMT_BGR4_BYTE, ///< packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
    ALILIVEPLAYER_PIX_FMT_RGB8,      ///< packed RGB 3:3:2,  8bpp, (msb)2R 3G 3B(lsb)
    ALILIVEPLAYER_PIX_FMT_RGB4,       ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a
    ///< byte contains two pixels, the first pixel in the byte is the
    ///< one composed by the 4 msb bits
    ALILIVEPLAYER_PIX_FMT_RGB4_BYTE, ///< packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
    ALILIVEPLAYER_PIX_FMT_NV12,      ///< planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the
    ///< UV components, which are interleaved (first byte U and the
    ///< following byte V)
    ALILIVEPLAYER_PIX_FMT_NV21, ///< as above, but U and V bytes are swapped
    
    ALILIVEPLAYER_PIX_FMT_YUV420P10BE = 63, ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb
    ///< sample per 2x2 Y samples), big-endian
    ALILIVEPLAYER_PIX_FMT_YUV420P10LE,      ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb
    ///< sample per 2x2 Y samples), little-endian
    
    ALILIVEPLAYER_PIX_FMT_D3D11 = 900,
    ALILIVEPLAYER_PIX_FMT_DXVA2_VLD,
    
    ALILIVEPLAYER_PIX_FMT_APPLE_PIXEL_BUFFER = 1000,
    ALILIVEPLAYER_PIX_FMT_ALILIVEPLAYER_AF,          // framework VideoFrame
    ALILIVEPLAYER_PIX_FMT_ALILIVEPLAYER_MEDIA_CODEC, // Android mediacodec buffer index
    
} AliLivePlayerPixelFormat;


@interface AliLivePlayerFrameInfo : NSObject

@property (nonatomic, assign) AliLivePlayerFrameType frameType;
@property (nonatomic, assign) long pts;
@property (nonatomic, assign) long duration;
@property (nonatomic, assign) BOOL key;
@property (nonatomic, assign) long timePosition;

@property (nonatomic, assign) AliLivePlayerSampleFormat audio_format;
@property (nonatomic, assign) int audio_nb_samples;
@property (nonatomic, assign) int audio_channels;
@property (nonatomic, assign) int audio_sample_rate;
@property (nonatomic, assign) uint64_t audio_channel_layout;
@property (nonatomic, assign) int  audio_data_lineNum;
@property (nonatomic, assign) uint8_t ** audio_data;
@property (nonatomic, assign) int audio_data_lineSize;

@property (nonatomic, assign) AliLivePlayerPixelFormat video_format;
@property (nonatomic, assign) int video_width;
@property (nonatomic, assign) int video_height;
@property (nonatomic, assign) int video_rotate;
@property (nonatomic, assign) double video_dar;
@property (nonatomic, assign) size_t video_crop_top;
@property (nonatomic, assign) size_t video_crop_bottom;
@property (nonatomic, assign) size_t video_crop_left;
@property (nonatomic, assign) size_t video_crop_right;
@property (nonatomic, assign) int video_colorRange;
@property (nonatomic, assign) int video_colorSpace;
@property (nonatomic, assign) int  video_data_lineNum;
@property (nonatomic, assign) int* video_data_lineSize;
@property (nonatomic, assign) uint8_t ** video_data_addr;
@property (nonatomic, assign) CVPixelBufferRef video_pixelBuffer;

@end

