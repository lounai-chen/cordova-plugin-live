//
//  AliyunQueenPanelController.h
//  AliyunQueenUIKit
//
//  Created by zhangjc on 2021/12/14.
//  Copyright © 2021 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <queen/Queen.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunQueenPanelController : NSObject

@property (nonatomic, copy) void(^panelDidHiddenHandler)(void);
@property (nonatomic, weak) QueenEngine *queenEngine;

- (instancetype)initWithParentView:(UIView *)view;

- (void)selectDefaultBeautyEffect;
- (void)selectEmptyBeautyEffect;

- (void)showPanel:(BOOL)animated;
- (void)hidePanel:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
