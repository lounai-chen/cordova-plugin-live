//
//  AlivcAnswerTableViewCell.h
//  AlivcLivePusherTest
//
//  Created by lyz on 2018/1/22.
//  Copyright © 2018年 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcQuestionModel;

@protocol AlivcAnswerTableViewCellDelegate;


@interface AlivcAnswerTableViewCell : UITableViewCell

@property (nonatomic, weak) id<AlivcAnswerTableViewCellDelegate> delegate;
- (void)setupQuestionModel:(AlivcQuestionModel *)model;

@end


@protocol AlivcAnswerTableViewCellDelegate <NSObject>

- (void)onClickAnswerTableViewQuestionButton:(AlivcAnswerTableViewCell *)cell;
- (void)onClickAnswerTableViewAnswerButton:(AlivcAnswerTableViewCell *)cell;

@end
