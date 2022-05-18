//
//  AlivcSweepCodeView.h
//  AlivcLiveCaptureDev
//
//  Created by lyz on 2017/9/28.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlivcSweepCodeViewDelegate <NSObject>

- (void)onClickSweepCodeViewLightButton:(BOOL)isLight;

@end

@interface AlivcSweepCodeView : UIView

@property (nonatomic, weak) id<AlivcSweepCodeViewDelegate> delegate;

@end
