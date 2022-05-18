//
//  AlivcAnswerGameView.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2018/1/22.
//  Copyright © 2018年 TripleL. All rights reserved.
//

#import "AlivcAnswerGameView.h"
#import "AlivcPushViewsProtocol.h"
#import "AlivcAnswerTableViewCell.h"
#import "AlivcQuestionModel.h"
#import "AlivcAnswerModel.h"

@interface AlivcAnswerGameView()

@property (nonatomic, weak) id<AlivcAnswerGameViewDelegate> delegate;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *questionDataArray;
@property (nonatomic, strong) NSMutableArray *answerDataArray;

@end

@implementation AlivcAnswerGameView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubView];
        [self fetchData];
    }
    return self;
}


- (void)setAnswerDelegate:(id)delegate {
    
    self.delegate = delegate;
}


- (void)setupSubView {
    
    
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.7;
    
    self.listTableView = [[UITableView alloc] init];
    self.listTableView.frame = self.bounds;
    
    self.listTableView.backgroundColor = [UIColor clearColor];
    self.listTableView.delegate = (id)self;
    self.listTableView.dataSource = (id)self;
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.listTableView.tableFooterView = [[UIView alloc] init];
    [self.listTableView registerClass:[AlivcAnswerTableViewCell class] forCellReuseIdentifier:@"AlivcAnswerTableViewCellIndentifier"];
    [self addSubview:self.listTableView];
}


- (void)fetchData {
    
    self.questionDataArray = [NSMutableArray array];
    
    NSString *questionPath = [[NSBundle mainBundle] pathForResource:@"question" ofType:@"json"];

    NSDictionary *questionDic = [self jsonDicWithFilePath:questionPath];
    [self.questionDataArray removeAllObjects];
    for (NSDictionary *dic in questionDic[@"contents"]) {
        AlivcQuestionModel *model = [[AlivcQuestionModel alloc] initWithDictionary:dic];
        [self.questionDataArray addObject:model];
    }
    
    
    self.answerDataArray = [NSMutableArray array];
    
    NSString *answerPath = [[NSBundle mainBundle] pathForResource:@"answer" ofType:@"json"];
    
    NSDictionary *answerDic = [self jsonDicWithFilePath:answerPath];
    [self.answerDataArray removeAllObjects];
    for (NSDictionary *dic in answerDic[@"contents"]) {
        AlivcAnswerModel *model = [[AlivcAnswerModel alloc] initWithDictionary:dic];
        [self.answerDataArray addObject:model];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.listTableView reloadData];
    });
}


- (NSDictionary *)jsonDicWithFilePath:(NSString *)path {
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return dataDic;
}


#pragma mark - TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.questionDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlivcAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlivcAnswerTableViewCellIndentifier" forIndexPath:indexPath];
    cell.delegate = (id)self;
    if (indexPath.row < self.questionDataArray.count) {
        [cell setupQuestionModel:self.questionDataArray[indexPath.row]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
}

#pragma mark - AlivcAnswerTableViewCellDelegate


- (void)onClickAnswerTableViewQuestionButton:(AlivcAnswerTableViewCell *)cell {
    
    NSIndexPath *path = [self.listTableView indexPathForCell:cell];
    AlivcQuestionModel *model = self.questionDataArray[path.row];
    
    NSString *text = [model toString];
    
    if (self.delegate) {
        [self.delegate answerGameOnSendQuestion:text questionId:model.questionId];
    }
}


- (void)onClickAnswerTableViewAnswerButton:(AlivcAnswerTableViewCell *)cell {
    
    NSIndexPath *path = [self.listTableView indexPathForCell:cell];
    AlivcAnswerModel *model = self.answerDataArray[path.row];

    NSString *text = [model toString];
    NSInteger duration = [model.showTime integerValue];
    
    if (self.delegate) {
        [self.delegate answerGameOnSendAnswer:text duration:duration];
    }
}




@end
