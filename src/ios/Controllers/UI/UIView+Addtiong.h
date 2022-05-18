//
//  UIView+Addtiong.h
//  AlivcLivePusherTest
//
//  Created by lichentao on 2021/5/18.
//  Copyright © 2021 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Addtiong)
- (CGPoint)origin;
- (void)setOrigin:(CGPoint)point;

- (CGSize)size;
- (void)setSize:(CGSize)size;

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGFloat)bottom;
- (void)setBottom:(CGFloat)bottom;

- (CGFloat)right;
- (void)setRight:(CGFloat)right;

@end

NS_ASSUME_NONNULL_END
