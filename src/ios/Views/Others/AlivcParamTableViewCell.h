//
//  AlivcParamTableViewCell.h
//  AlivcLiveCaptureDev
//
//  Created by TripleL on 17/7/10.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcParamModel;

@interface AlivcParamTableViewCell : UITableViewCell

@property (nonatomic, strong) AlivcParamModel *cellModel;

- (void)configureCellModel:(AlivcParamModel *)cellModel;

- (void)updateDefaultValue:(int)value enable:(BOOL)enable;

@end
