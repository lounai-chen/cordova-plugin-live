//
//  AlivcAnswerModel.h
//  AlivcLivePusherTest
//
//  Created by lyz on 2018/1/22.
//  Copyright © 2018年 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunJSONModel.h"

@interface AlivcAnswerModel : AliyunJSONModel

@property (nonatomic, copy) NSString *questionId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *showTime;

@end
