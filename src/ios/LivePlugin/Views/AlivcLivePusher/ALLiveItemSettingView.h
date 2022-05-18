//
//  ALLiveItemSettingView.h
//  AliLiveSdk-Demo
//
//  Created by 薛林 on 2020/12/17.
//  Copyright © 2020 alilive. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ALLiveItemSettingRole) {
    ALLiveItemSettingRoleAnchor,   // 主播
    ALLiveItemSettingRoleAudience,  // 观众
    ALLiveItemSettingRoleCameraPush,// 摄像头推流
    ALLiveItemSettingRolePull, // 拉流
    ALLiveItemSettingRoleRTCPull // RTC
};

@protocol ALLiveItemSettingViewDelegate <NSObject>
@optional
// 推流
- (void)didSelectPush;
// 美颜
- (void)didSelectBeauty;
// 音效
- (void)didSelectSoundEffect;
// 摄像头
- (void)didSelectCamera;
// pk
- (void)didSelectPK;
// 麦克风
- (void)didSelectMicphone;
// 调节参数
- (void)didSelectSetProgram;
// 数据指标
- (void)didSelectDataIndicators;
// 连麦
- (void)didSelectContectMic;
// 音量
- (void)didSelectVolume;
// 静音
- (void)didSelectSilence;
// 磨皮
- (void)didSelectBlur;
// 结束观看
- (void)didSelectStopWatch;
// 听筒切换
- (void)didSelectReceiverChange;
@end


@interface ALLiveSettingItem : NSObject
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) id beautySubType;
@property (nonatomic, assign) BOOL changeStyleForSelected;
@end

@interface ALLiveSettingCell : UICollectionViewCell
@property (nonatomic, strong) ALLiveSettingItem *item;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL cellItemSelect;
@property (nonatomic, assign) NSInteger beautyType; //0美颜 1美妆 2滤镜 3贴纸
@end

@interface ALLiveItemSettingView : UIView
- (instancetype)initWithSetting:(ALLiveItemSettingRole)settingRole;

@property (nonatomic, strong, readonly) ALLiveSettingCell *pkCell;
@property (nonatomic, strong, readonly) ALLiveSettingCell *setSilenceCell;
@property (nonatomic, weak) id<ALLiveItemSettingViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
