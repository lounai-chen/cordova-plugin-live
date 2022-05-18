//
//  AlivcSweepCodeViewController.h
//  AlivcLiveCaptureDev
//
//  Created by lyz on 2017/9/28.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlivcQRCodeViewController : UIViewController

@property (nonatomic, copy) void(^backValueBlock)(NSString *sweepString);

@end
