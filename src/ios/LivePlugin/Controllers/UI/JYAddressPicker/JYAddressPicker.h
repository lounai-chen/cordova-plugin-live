//
//  Created by botao on 2021/05/17.
//  Copyright © 2021年 alibaba All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectedItemBlock)(NSArray *addressArr);

@interface JYAddressPicker : UIViewController

+(JYAddressPicker *)jy_showAt:(UIViewController *)vc;
+(JYAddressPicker *)jy_showAt:(UIViewController *)vc defaultShow:(NSArray *)values;
@property (nonatomic, copy) SelectedItemBlock selectedItemBlock;

@end
