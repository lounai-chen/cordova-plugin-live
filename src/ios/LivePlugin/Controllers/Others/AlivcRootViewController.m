//
//  AlivcRootViewController.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2017/10/9.
//  Copyright © 2017年 TripleL. All rights reserved.
//

#import "AlivcRootViewController.h"
#import "AlivcLivePushConfigViewController.h"
#import "AlivcLivePushReplayKitConfigViewController.h"
#import "AlivcCopyrightInfoViewController.h"

@interface AlivcRootViewController ()

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation AlivcRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    
    [self setupSubViews];
    
    
}


- (void)setupSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"live_scene_list", nil);
    
  //  self.listTableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, 0, AlivcScreenWidth, AlivcScreenHeight))
       //                                               style:(UITableViewStylePlain)];
    
    [self.listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ViewControllerListTableViewID"];
    self.listTableView.delegate = (id)self;
    self.listTableView.dataSource = (id)self;
    self.listTableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.listTableView];
}


- (void)setupData {
    
    self.dataArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"live_basic_function", nil),
                                                      NSLocalizedString(@"screen_record_live", nil),
                                                      NSLocalizedString(@"license_declaration", nil),
                                                      nil];
}


#pragma mark - TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ViewControllerListTableViewID" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        // 新接口 AlivcLivePusher
        AlivcLivePushConfigViewController *pushConfigVC = [[AlivcLivePushConfigViewController alloc] init];
        [self.navigationController pushViewController:pushConfigVC animated:YES];
        
    }else if (indexPath.row == 1) {
        
        // 新接口 AlivcLivePusher
        AlivcLivePushReplayKitConfigViewController *replayKitConfigVC = [[AlivcLivePushReplayKitConfigViewController alloc] init];
        [self.navigationController pushViewController:replayKitConfigVC animated:YES];
        
    } else {
        
        // 版权信息
        AlivcCopyrightInfoViewController *copyrightInfoVC = [[AlivcCopyrightInfoViewController alloc] init];
        [self.navigationController pushViewController:copyrightInfoVC animated:YES];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
