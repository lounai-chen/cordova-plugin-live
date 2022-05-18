//
//  YCFunction.h
//  YCKitTest
//
//  Created by yaochen.ww on 16/5/27.
//  Copyright (c) 2015年 com.taobao.mobileim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YCFunction : NSObject

// Text show on Function Button
@property NSString* text;
// ICON, best size with 70 x 60 png
@property UIImage* icon;
// target & sel for UIControlEventTouchUpInside event
@property id target;
@property SEL sel;

-(id) initWithText:(NSString*)text icon:(UIImage*)icon target:(id)target sel:(SEL)sel;

@end