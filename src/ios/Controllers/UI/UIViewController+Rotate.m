//
//  UIViewController+Rotate.m
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/3/16.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import "UIViewController+Rotate.h"
#import <objc/runtime.h>

@implementation UIViewController (Rotate)

- (void)setAllowSelectInterfaceOrientation:(BOOL)allowSelectInterfaceOrientation {
    objc_setAssociatedObject(self, @selector(allowSelectInterfaceOrientation), @(allowSelectInterfaceOrientation), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)allowSelectInterfaceOrientation {
    return [objc_getAssociatedObject(self, @selector(allowSelectInterfaceOrientation)) boolValue];
}

@end
