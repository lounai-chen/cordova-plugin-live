//
//  Created by botao on 2021/05/17.
//  Copyright © 2021年 alibaba All rights reserved.
//

#import "JYAddressPicker.h"

#define PickerHeight 180
#define PickerToolBarHeight 44

@interface JYAddressPicker ()<UIPickerViewDelegate,UIPickerViewDataSource>

//picker控件数据源
@property(nonatomic,strong)NSMutableArray *showAddressArr;
//picker控件默认展示的元素下标
@property(nonatomic,strong)NSMutableArray *showIndexs;

@property (nonatomic, strong) UIView *pickerContainerView;
@property (nonatomic, strong) UIPickerView *pickerView;

@end

@implementation JYAddressPicker


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];

    [self initUI];
}

-(void)initUI{
    
    self.pickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - (PickerHeight + PickerToolBarHeight), [UIScreen mainScreen].bounds.size.width, PickerHeight + PickerToolBarHeight)];
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, PickerToolBarHeight)];
    toolBar.barTintColor = [UIColor whiteColor];

    UIBarButtonItem *noSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    noSpace.width=10;

    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];;
    doneBtn.tintColor = [UIColor grayColor];

    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    cancelBtn.tintColor = [UIColor grayColor];

    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:noSpace,cancelBtn,flexSpace,doneBtn,noSpace, nil]];
//    UILabel *titleLabel = [UILabel new];
//    titleLabel.frame = CGRectMake(0, 0, 200, PickerToolBarHeight);
//    titleLabel.center = toolBar.center;
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.textColor = [UIColor darkTextColor];
//    titleLabel.text = @"省市区选择";
//    [toolBar addSubview:titleLabel];

    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, PickerToolBarHeight, [UIScreen mainScreen].bounds.size.width, PickerHeight)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.backgroundColor = [UIColor whiteColor];

    [self.pickerContainerView addSubview:toolBar];
    [self.pickerContainerView addSubview:self.pickerView];
    [self.view addSubview:self.pickerContainerView];
}

#pragma mark-- UIPickerViewDataSource
//列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.showAddressArr count];
}


#pragma mark-- UIPickerViewDelegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (id)view;
    if (!label)
    {
        label= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.text = @"hhaha";
    }
    return label;
}

//点击选择
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}


-(instancetype)initWith:(NSArray *)defaultValues{
    
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        self.showIndexs = [NSMutableArray array];
        self.showAddressArr = defaultValues;
        
    }
    return self;
}

+(JYAddressPicker *)jy_showAt:(UIViewController *)vc{
    
    JYAddressPicker *addressPicker = [[JYAddressPicker alloc] initWith:@[@"ddd",@"ddd",@"dddd"]];
    [vc presentViewController:addressPicker animated:NO completion:^{
        
    }];
    return addressPicker;
}

+(JYAddressPicker *)jy_showAt:(UIViewController *)vc defaultShow:(NSArray *)values{
    
    NSParameterAssert(values);
    JYAddressPicker *addressPicker = [[JYAddressPicker alloc] initWith:values];
    [vc presentViewController:addressPicker animated:NO completion:^{
        
    }];
    return addressPicker;
}


#pragma mark--确定
-(void)done:(id)sender{

    [self hide];
}

#pragma mark--取消
-(void)cancel:(id)sender{

    [self hide];
}

-(void)hide{

    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
