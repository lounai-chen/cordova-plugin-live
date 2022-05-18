//
//  AlivcMusicSettingView.h
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/11/23.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcMusicInfoModel;

@interface AlivcMusicListViewCell : UITableViewCell

- (void)setLoopHidden:(BOOL)isHidden;

- (void)setupMusicInfoModel:(AlivcMusicInfoModel *)model;

- (void)updateMusicDuration:(long)currentTime totalTime:(long)totalTime;


@end

@interface AlivcMusicSettingView : UIView

- (instancetype)initWithFrame:(CGRect)frame musicMode:(BOOL)musicMode;

- (void)setMusicDelegate:(id)delegate;

- (void)updateMusicDuration:(long)currentTime totalTime:(long)totalTime;

- (void)resetButtonTypeWithPlayError;

@end
