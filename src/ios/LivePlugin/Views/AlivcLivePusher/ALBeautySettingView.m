//
//  ALBeautySettingView.m
//  AliLiveSdk-Demo
//
//  Created by 薛林 on 2020/12/21.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "ALBeautySettingView.h"
#import "Masonry.h"
#import "ALLiveMacro.h"
#import "UIColor+ALLiveColor.h"
#import "ALBeautyParamObj.h"
#import <CoreMotion/CoreMotion.h>
#import "ALLiveConfig.h"

typedef NS_ENUM(NSInteger, UIBeautyLabel) {
    UIBeautyLabelBase      = 0,//美颜一级tab页
    UIBeautyLabelMakeup    = 1,//美妆一级tab页
    UIBeautyLabelLUT       = 2,//滤镜一级tab页
    UIBeautyLabelMaterial  = 3,//贴纸一级tab页
    UIBeautyLabelBlush     = 4,//美妆下的腮红二级tab页
    UIBeautyLabelWholeMakup = 5//美妆下的整妆二级tab页
};

@interface ALBeautySettingView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *headerBg;
@property (nonatomic, strong) UIView *makeupHeadView;
@property (nonatomic, strong) UILabel *makeupLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *titleSectionArray;

@property (nonatomic, strong) NSArray<ALLiveSettingItem *> *items;

@property (nonatomic, strong) ALLiveSettingItem *selectItem;
@property (nonatomic, strong) UILabel *sliderLabel;

@property (nonatomic, strong) UIView *faceStyleView;

@property (nonatomic, strong) UIButton *resetButton;

@property (nonatomic, assign) UIBeautyLabel currentUIBeautyLabel;//当前正在操作的美颜tab页
@property (nonatomic, assign) kQueenBeautyType currentQueenBeautyType;//阿里云美颜库提供的正在操作的一级美颜类型
@property (nonatomic, assign) int currentBeautySubType;//阿里云美颜库提供的二级类型，如美型下的二级分类
@property (nonatomic, strong) NSString *currentMaterialPath;//当前贴纸路径

//美颜角度计算
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *motionObserveQueue;
@property (nonatomic, assign) BOOL deviceCanRotate;
@end


@implementation ALBeautySettingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self setupCollectionView];
        [self prepareData:0];// 默认美颜
        [self startRetainCameraRotate];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AliLiveBeautySwitch"];// 首次加载默认是YES与调节参数保持一致
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    switch (device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        case UIDeviceOrientationPortraitUpsideDown:
        {
            self.deviceCanRotate = YES;
        }
            break;
        default:
        {
            self.deviceCanRotate = NO;
        }
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRetainCameraRotate];
}

- (void)setqueenEngine:(QueenEngine *)queenEngine
{
    _queenEngine = queenEngine;
    [_queenEngine setQueenBeautyType:kQueenBeautyTypeSkinBuffing enable:YES];
    [_queenEngine setQueenBeautyType:kQueenBeautyTypeSkinWhiting enable:YES];
    [_queenEngine setQueenBeautyParams:kQueenBeautyParamsWhitening value:0.8f];
    [_queenEngine setQueenBeautyParams:kQueenBeautyParamsSharpen value:0.6f];
    [_queenEngine setQueenBeautyParams:kQueenBeautyParamsSkinBuffing value:0.6];
}

- (void)setupViews {
    UIView *bgView = [[UIView alloc] init];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];

    // header标题
    // 创建美颜面板 header(美颜、美妆、滤镜、贴纸)
    UIView *headerBg = [[UIView alloc] init];
    self.headerBg = headerBg;
    [self addSubview:self.headerBg];
    [headerBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(@40);
    }];
    headerBg.backgroundColor = [UIColor clearColor];
    
    UIView *makeupHeadView = [[UIView alloc] init];
    self.makeupHeadView = makeupHeadView;
    [self addSubview:self.makeupHeadView];
    [makeupHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(@40);
    }];
    [self.makeupHeadView setHidden:YES];
    self.makeupLabel = [[UILabel alloc] init];
    [self.makeupHeadView addSubview:self.makeupLabel];
    [self.makeupLabel mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
        make.left.right.top.bottom.equalTo(self.makeupHeadView);
    }];
    self.makeupLabel.text = @"腮红";
    self.makeupLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.makeupLabel.textColor = [UIColor whiteColor];
    self.makeupLabel.textAlignment = NSTextAlignmentCenter;
    

    self.titleSectionArray = [ALBeautyParamObj initBeautyParams];
    for (int i = 0; i < 4; i ++){
        UIButton *headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSDictionary *itemDic = self.titleSectionArray[i];
        [headerBtn setTitle:itemDic[@"name"]forState:UIControlStateNormal];
        headerBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        headerBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [headerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [headerBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 60)/4;
        headerBtn.frame = CGRectMake(30 + i *  width, 0, width, 40);
        headerBtn.tag = 1000 + i;
        [headerBtn addTarget:self action:@selector(headerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            [headerBtn setImageEdgeInsets:UIEdgeInsetsMake(35, 22, 0, 10)];
        }else{
            [headerBtn setImageEdgeInsets:UIEdgeInsetsMake(40, 22, 0, 10)];
        }
        [headerBtn setImage:[UIImage imageNamed:@"beauty_bottom_line"] forState:UIControlStateNormal];
        [headerBtn setTitleEdgeInsets:UIEdgeInsetsMake(5, -25, 10, 10)];
        [self.headerBg addSubview:headerBtn];
    }
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(headerBg);
        make.top.equalTo(headerBg.mas_bottom);
        make.height.equalTo(@1);
    }];
    lineView.tag = 99;
}

- (void)headerBtnAction:(id)sender{
    UIButton *headerBtn = (UIButton *)sender;
    
    NSArray *headerArray = self.headerBg.subviews;
    for (UIButton *btn in headerArray) {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(40, 22, 0, 10)];
        [btn setImage:[UIImage imageNamed:@"beauty_bottom_line"] forState:UIControlStateNormal];
    }
    [headerBtn setImageEdgeInsets:UIEdgeInsetsMake(35, 22, 0, 10)];
    [headerBtn setImage:[UIImage imageNamed:@"beauty_bottom_line"] forState:UIControlStateNormal];
    [self prepareData:headerBtn.tag - 1000];
    
    if ((headerBtn.tag - 1000 == 2) || (headerBtn.tag - 1000 == 3)) {
        [_delegate hiddenSlider:YES];
        [self.resetButton setHidden:YES];
    }else{
        [_delegate hiddenSlider:NO];
        [self.resetButton setHidden:NO];
        if(self.delegate && [self.delegate respondsToSelector:@selector(didChangeSliderValue:label:)])
        {
            [self.delegate didChangeSliderValue:nil label:nil];
        }
    }
}

- (void)setupCollectionView {
    UIView *faceStyleView = [[UIView alloc] init];
    [self addSubview:faceStyleView];
    [faceStyleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerBg.mas_bottom);
        make.left.equalTo(self);
        make.height.equalTo(@80);
        make.width.equalTo(@76);
    }];
    ALLiveSettingCell *faceCell = [[ALLiveSettingCell alloc] initWithFrame:CGRectMake(0, 0, 76, 80)];
    faceCell.imageView.backgroundColor = [UIColor clearColor];
    [faceStyleView addSubview:faceCell];
    [faceCell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(faceStyleView);
        make.height.equalTo(faceStyleView);
    }];
    ALLiveSettingItem *faceItem = [[ALLiveSettingItem alloc] init];
    faceItem.imageName = @"beauty_lianxing_nornal";
    faceItem.title = NSLocalizedString(@"脸型",nil);
    faceItem.changeStyleForSelected = NO;
    faceCell.item = faceItem;
    
    UIImageView *splitLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_split_line"]];
    [faceStyleView addSubview:splitLineView];
    splitLineView.backgroundColor = [UIColor colorWithHexString:@"#212022"];
    [splitLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(faceStyleView.mas_left).offset(75);
        make.top.equalTo(faceStyleView.mas_top).offset(12);
        make.height.equalTo(@52);
        make.width.equalTo(@1);
    }];
    
    self.faceStyleView = faceStyleView;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = false;
    layout.itemSize = CGSizeMake((SCREEN_WIDTH - 70 * 2) / 3, 80);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [collectionView registerClass:[ALLiveSettingCell class] forCellWithReuseIdentifier:NSStringFromClass([ALLiveSettingCell class])];
    self.collectionView = collectionView;
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerBg.mas_bottom);
        make.left.equalTo(self).offset(76);
        make.right.equalTo(self);
        make.height.equalTo(@80);
    }];
    
    UIButton *resetButton = [[UIButton alloc] init];
    resetButton.hidden = NO;
    resetButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [resetButton setImage:[UIImage imageNamed:@"camera_push_beauty_reset"] forState:UIControlStateNormal];
    [resetButton setTitle:NSLocalizedString(@"重置",nil) forState:UIControlStateNormal];
    [resetButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:resetButton];
    [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom - 5);
        } else {
            make.bottom.equalTo(self).offset(-5);
        }
        make.width.equalTo(@50);
        make.height.equalTo(@20);
    }];
    [resetButton addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
    self.resetButton = resetButton;
    
    UIButton *controlButton = [[UIButton alloc] init];
    controlButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [controlButton setImage:[UIImage imageNamed:@"camera_push_beauty_hidden"] forState:UIControlStateNormal];
    [self addSubview:controlButton];
    [controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
        } else {
            make.bottom.equalTo(self);
        }
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    [controlButton addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)prepareData:(NSInteger)index {
    if(index == 0)
    {
        [self.faceStyleView setHidden:NO];
        [self.faceStyleView mas_updateConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.top.equalTo(self.headerBg.mas_bottom);
            make.left.equalTo(self);
            make.height.equalTo(@80);
            make.width.equalTo(@76);
        }];
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(76);
        }];
    }
    else
    {
        [self.faceStyleView setHidden:YES];
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(0);
        }];
    }
    
    NSDictionary *dataParams = self.titleSectionArray[index];
    NSArray *imgs = dataParams[@"data"][@"imgs"];
    NSArray *titles = dataParams[@"data"][@"titles"];

    NSMutableArray *mData = @[].mutableCopy;
    for(int i = 0; i < titles.count; i++) {
        NSString *title = titles[i];
        NSString *imgName = imgs[i];

        ALLiveSettingItem *item = [[ALLiveSettingItem alloc] init];
        item.title = title;
        item.imageName = imgName;
        item.changeStyleForSelected = YES;
        
        if(index == 0 || index == 1)
        {
            NSArray *beautyParams = dataParams[@"data"][@"beautyParam"];
            item.beautySubType = beautyParams[i];
        }
        if (index == 2 || index == 3) {
            NSArray *params = dataParams[@"data"][@"beautyParam"];
            NSString *imgPath= params[i];
            if(index == 3)
            {
                item.imageName = [NSString stringWithFormat:@"%@/icon.png",imgPath];
            }
            
            item.imagePath = imgPath;
        }
        if(index == UIBeautyLabelMaterial && i == 0)
        {
            //整妆第一个有图标
            item.imageName = @"common_none_normal";
        }
        
        [mData addObject:item];
    }
    self.currentUIBeautyLabel = index;
    self.items = mData.copy;
    [self.collectionView reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ALLiveSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ALLiveSettingCell class]) forIndexPath:indexPath];
        
    if((self.currentUIBeautyLabel != UIBeautyLabelMaterial) || indexPath.row == 0)
    {
        cell.imageView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        cell.imageView.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8" alpha:0.1];
    }
    
    /* modify by botao begin*/
    if (self.currentUIBeautyLabel == UIBeautyLabelMaterial) {
        cell.beautyType = 3;
    }else{
        cell.beautyType = -1; //不做处理
    }
    /* modify by botao end*/

    cell.item = self.items[indexPath.row];
      
    if(cell.selected)
    {
        NSString *imageName = cell.item.imageName;
        if(![imageName containsString:@"_selected"])
        {
            imageName = [NSString stringWithFormat:@"%@_selected", cell.item.imageName];
        }
        // 判断贴纸
        if (self.currentUIBeautyLabel == UIBeautyLabelMaterial) {
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:imageName];
            }else{
                cell.imageView.image = [UIImage imageWithContentsOfFile:cell.item.imageName];
            }
            cell.titleLabel.textColor = [UIColor colorWithHexString:@"#1AED99"];
        }else{
            cell.imageView.image = [UIImage imageNamed:imageName];
            cell.titleLabel.textColor = [UIColor colorWithHexString:@"#1AED99"];
        }
    }
    else
    {
        /* modify by botao begin*/
        // 判断贴纸
        if (self.currentUIBeautyLabel == UIBeautyLabelMaterial) {
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:cell.item.imageName];
            }else{
                cell.imageView.image = [UIImage imageWithContentsOfFile:cell.item.imageName];
            }
            cell.titleLabel.textColor = [UIColor whiteColor];
        /* modify by botao end*/
        }else{
            cell.titleLabel.textColor = [UIColor whiteColor];
            cell.imageView.image = [UIImage imageNamed:cell.item.imageName];
        }
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALLiveSettingCell *cell = (ALLiveSettingCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ALLiveSettingItem *item = self.items[indexPath.row];
    kQueenBeautyType aliLiveBeautType = kQueenBeautyTypeSkinBuffing;
    id subType = @(-1);
    BOOL isMaterialType = NO;
    NSString *typeName = nil;
    //如果选择的是腮红或者整妆(二级目录)下的选项
    if(self.currentUIBeautyLabel == UIBeautyLabelBlush || self.currentUIBeautyLabel == UIBeautyLabelWholeMakup)
    {
        BOOL isMakeUpWhole = YES;
        if(self.currentUIBeautyLabel == UIBeautyLabelBlush)
        {
           isMakeUpWhole = NO;
        }
        [self selectSubMakeUp:isMakeUpWhole subType:(int)indexPath.row param:typeName];
    }
    else
    {
        //选中的是一级目录下的选项
        if(self.currentUIBeautyLabel == UIBeautyLabelBase)
        {
            if(indexPath.row  == 0 || indexPath.row == 2)
            {
                aliLiveBeautType = kQueenBeautyTypeSkinBuffing;
            }
            else if(indexPath.row == 1)
            {
                aliLiveBeautType = kQueenBeautyTypeSkinWhiting;
            }
            else
            {
                aliLiveBeautType = kQueenBeautyTypeFaceShape;
            }
            subType = item.beautySubType;
            typeName = item.title;
        }
        else
        {
            if(self.currentUIBeautyLabel == UIBeautyLabelMakeup)
            {
                
                if(indexPath.row < 4)
                {
                    aliLiveBeautType = kQueenBeautyTypeMakeup;
                    subType = item.beautySubType;
                    typeName = item.title;
                }
                else
                {
                    [self prepareData:indexPath.row];
                    
                    [self.headerBg setHidden:YES];
                    [self.makeupHeadView setHidden:NO];
                    if(indexPath.row == 4)
                    {
                        self.makeupLabel.text = NSLocalizedString(@"腮红",nil);
                    }
                    else if(indexPath.row == 5)
                    {
                        self.makeupLabel.text = NSLocalizedString(@"整妆",nil);
                    }
                    else
                    {
                        self.makeupLabel.text = NSLocalizedString(@"未知",nil);
                    }
                    [_delegate hiddenSlider:YES];
                    return ;
                }
            }
            // 贴纸
            else if (self.currentUIBeautyLabel == UIBeautyLabelMaterial){
                typeName = item.imagePath;
                isMaterialType = YES;
            }
            // 滤镜
            else if(self.currentUIBeautyLabel == UIBeautyLabelLUT)
            {
                aliLiveBeautType = kQueenBeautyTypeLUT;
                typeName = item.imagePath;
            }
        }
        
        [self selectBeautyType:aliLiveBeautType subType:subType isMaterial:isMaterialType param:typeName cell:cell];
    }
}

// MARK: -  BeautyFunction
- (void)selectBeautyType:(kQueenBeautyType)beautyType subType:(id)subType isMaterial:(BOOL)isMaterial param:(id)param cell:(ALLiveSettingCell *)cell
{
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"res" ofType: @"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    BOOL shouldChangeSlideValue = YES;
    NSMutableDictionary *data = nil;
    if(!isMaterial)
    {
        self.currentQueenBeautyType = beautyType ;
        self.currentBeautySubType = [(NSNumber *)subType intValue];
        if(self.currentQueenBeautyType == kQueenBeautyTypeSkinBuffing || self.currentQueenBeautyType == kQueenBeautyTypeSkinWhiting)
        {
            [_queenEngine setQueenBeautyType:self.currentQueenBeautyType enable:YES];
            data = [ALLiveConfig sharedInstance].raceBeautyConfig[0][@"data"][self.currentBeautySubType - 1];
        }
        else if(self.currentQueenBeautyType == kQueenBeautyTypeFaceShape)
        {
            [_queenEngine setQueenBeautyType:kQueenBeautyTypeFaceShape enable:YES];
            data = [ALLiveConfig sharedInstance].raceBeautyConfig[1][@"data"][self.currentBeautySubType];
        }
        else if(self.currentQueenBeautyType == kQueenBeautyTypeMakeup)
        {
            data = [ALLiveConfig sharedInstance].raceBeautyConfig[2][@"data"][self.currentBeautySubType];
            

            NSString *imgPath = [bundle pathForResource:data[@"filename"] ofType:@"png" inDirectory:data[@"dir"]];
            
            [_queenEngine setQueenBeautyType:self.currentQueenBeautyType enable:YES];
            
            [_queenEngine setMakeupWithType:self.currentBeautySubType paths:@[imgPath] blendType:[self getBlendTypeByMakeupType:self.currentBeautySubType]];
            
        }else if (self.currentQueenBeautyType == kQueenBeautyTypeLUT){ // 滤镜
            [_queenEngine setQueenBeautyType:kQueenBeautyTypeLUT enable:YES];
            
            [_queenEngine setLutImagePath:param];
            shouldChangeSlideValue = NO;
            
        }
    }
    else{ // 贴纸
        
        if(!self.currentMaterialPath)
        {
            self.currentMaterialPath = param;
            [_queenEngine addMaterialWithPath:param];
        }
        else if(![self.currentMaterialPath isEqualToString:param])
        {
            [_queenEngine removeMaterialWithPath:self.currentMaterialPath];
            self.currentMaterialPath = param;
            [_queenEngine addMaterialWithPath:param];
            
        }else if ([self.currentMaterialPath isEqualToString:param]){
            [_queenEngine removeMaterialWithPath:self.currentMaterialPath];
            self.currentMaterialPath = nil;
        }
        shouldChangeSlideValue = NO;
    }
        
    if(shouldChangeSlideValue && self.delegate && [self.delegate respondsToSelector:@selector(didChangeSliderValue:label:)])
    {
        [self.delegate didChangeSliderValue:data label:param];
    }
}

- (void)selectSubMakeUp:(BOOL) isWholeMakeup subType:(int) subType param:(id) param
{
    if(subType > 0)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"res" ofType: @"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        
        NSMutableDictionary *data = nil;
        if(isWholeMakeup)
        {
            data = [ALLiveConfig sharedInstance].raceBeautyConfig[4][@"data"][subType - 1];
        }
        else
        {
            data = [ALLiveConfig sharedInstance].raceBeautyConfig[3][@"data"][subType - 1];
        }
        
        NSString *imgPath = [bundle pathForResource:data[@"filename"] ofType:@"png" inDirectory:data[@"dir"]];
        
        [_queenEngine setQueenBeautyType:kQueenBeautyTypeMakeup enable:YES];
        
        if(isWholeMakeup)
        {
            [_queenEngine setMakeupWithType:kQueenBeautyMakeupTypeWhole paths:@[imgPath] blendType:[self getBlendTypeByMakeupType:kQueenBeautyMakeupTypeWhole]];
        }
        else
        {
            [_queenEngine setMakeupWithType:kQueenBeautyMakeupTypeBlush paths:@[imgPath] blendType:[self getBlendTypeByMakeupType:kQueenBeautyMakeupTypeBlush]];
        }
        
    }
    else
    {
        if(isWholeMakeup)
        {
            [_queenEngine setMakeupWithType:kQueenBeautyMakeupTypeWhole paths:@[] blendType:[self getBlendTypeByMakeupType:kQueenBeautyMakeupTypeWhole]];
        }
        else
        {
            [_queenEngine setMakeupWithType:kQueenBeautyMakeupTypeBlush paths:@[] blendType:[self getBlendTypeByMakeupType:kQueenBeautyMakeupTypeBlush]];
        }
    }
}

- (void)resetSelectedBeauty
{
    if(self.currentUIBeautyLabel == UIBeautyLabelBase)
    {
        int beautyIndex = 0;
        int subIndex = self.currentBeautySubType - 1;
        if(self.currentQueenBeautyType == kQueenBeautyTypeFaceShape)
        {
            beautyIndex = 1;
            subIndex = self.currentBeautySubType;
        }
           
        //重置基础美颜设置项
        NSArray *dicsFaceBuffing = [ALLiveConfig sharedInstance].raceBeautyConfig[0][@"data"];
        NSMutableArray *datasFaceBuffing = [NSMutableArray array];
        for (int i = 0; i < [dicsFaceBuffing count]; i++) {
            NSMutableDictionary *item = [dicsFaceBuffing objectAtIndex:i];
            item[@"currentValue"] = item[@"value"];
            [datasFaceBuffing addObject:item];
            [_queenEngine setQueenBeautyParams:i + 1 value:[(NSNumber *)item[@"currentValue"] floatValue]];
        }
        [ALLiveConfig sharedInstance].raceBeautyConfig[0][@"data"] = datasFaceBuffing;
           
        //重置美型设置项
        NSArray *dicsFaceShape = [ALLiveConfig sharedInstance].raceBeautyConfig[1][@"data"];
        NSMutableArray *datasFaceShape = [NSMutableArray array];
        for (int i = 0; i < [dicsFaceShape count]; i++) {
            NSMutableDictionary *item = [dicsFaceShape objectAtIndex:i];
            item[@"currentValue"] = item[@"value"];
            [datasFaceShape addObject:item];
            [_queenEngine  setFaceShape:i value:[(NSNumber *)item[@"currentValue"] floatValue]];
        }
        [ALLiveConfig sharedInstance].raceBeautyConfig[1][@"data"] = datasFaceShape;
        if(self.currentBeautySubType >= 0 && subIndex >= 0 && [(NSArray *)[ALLiveConfig sharedInstance].raceBeautyConfig[beautyIndex][@"data"] count] > subIndex)
        {
            NSMutableDictionary *data = [ALLiveConfig sharedInstance].raceBeautyConfig[beautyIndex][@"data"][subIndex];
            if(self.delegate && [self.delegate respondsToSelector:@selector(didChangeSliderValue:label:)])
            {
                [self.delegate didChangeSliderValue:data label:nil];
            }
        }
    }
    else if(self.currentUIBeautyLabel == UIBeautyLabelMakeup)
    {
        NSArray *dicsMakeup = [ALLiveConfig sharedInstance].raceBeautyConfig[2][@"data"];
        NSMutableArray *datasMakeup = [NSMutableArray array];
        for (int i = 0; i < [dicsMakeup count]; i++) {
            NSMutableDictionary *item = [dicsMakeup objectAtIndex:i];
            item[@"currentValue"] = item[@"value"];
            [datasMakeup addObject:item];
            
            //[_queenEngine setMakeupAlphaWithType:i female:NO alpha:[(NSNumber *)item[@"currentValue"] floatValue]];
            //[_queenEngine setMakeupWithType:i paths:@[] blendType:kQueenBeautyBlendMultiply];
        }
        
        [_queenEngine resetAllMakeupType];
        [ALLiveConfig sharedInstance].raceBeautyConfig[2][@"data"] = datasMakeup;
        
        if(self.currentBeautySubType >= 0)
        {
            NSMutableDictionary *data = [ALLiveConfig sharedInstance].raceBeautyConfig[2][@"data"][self.currentQueenBeautyType];
            if(self.delegate && [self.delegate respondsToSelector:@selector(didChangeSliderValue:label:)])
            {
                [self.delegate didChangeSliderValue:data label:nil];
            }
        }
    }
    else if(self.currentUIBeautyLabel == UIBeautyLabelLUT)
    {
        [_queenEngine setLutImagePath:@""];
    }
    else if(self.currentUIBeautyLabel == UIBeautyLabelMaterial)
    {
        if(self.currentMaterialPath)
        {
            [_queenEngine removeMaterialWithPath:self.currentMaterialPath];
            self.currentMaterialPath = nil;
        }
    }
}

- (void)resetSelectedSubMakeUp
{
    //重置腮红和整妆类型
    [_queenEngine setMakeupWithType:kQueenBeautyMakeupTypeWhole paths:@[] blendType:[self getBlendTypeByMakeupType:kQueenBeautyMakeupTypeWhole]];
}

- (void)targetValueChanged:(CGFloat) value
{

    // 设置美颜类型
    [_queenEngine setQueenBeautyType:self.currentQueenBeautyType enable:YES];
    
    int beautyConfigIndex = 0;
    int beautyConfigSubIndex = self.currentBeautySubType;
    if(self.currentQueenBeautyType == kQueenBeautyTypeSkinBuffing || self.currentQueenBeautyType == kQueenBeautyTypeSkinWhiting)
    {
        [_queenEngine setQueenBeautyParams:self.currentBeautySubType value:value];
        beautyConfigSubIndex = self.currentBeautySubType - 1;
    }
    else if(self.currentQueenBeautyType == kQueenBeautyTypeFaceShape)
    {
        [_queenEngine setFaceShape:self.currentBeautySubType value:value];
        beautyConfigIndex = 1;
    }
    else if(self.currentQueenBeautyType == kQueenBeautyTypeMakeup)
    {
        [_queenEngine setMakeupAlphaWithType:self.currentBeautySubType female:NO alpha:value];
        beautyConfigIndex = 2;
    }
    //更新配置的值
    if (beautyConfigSubIndex >= 0) {
        NSMutableDictionary* data = [ALLiveConfig sharedInstance].raceBeautyConfig[beautyConfigIndex][@"data"][beautyConfigSubIndex];
        data[@"currentValue"] = @(value);
        [ALLiveConfig sharedInstance].raceBeautyConfig[beautyConfigIndex][@"data"][beautyConfigSubIndex] = data;
    }
}

- (kQueenBeautyBlend)getBlendTypeByMakeupType:(kQueenBeautyMakeupType)type {
    if (type == kQueenBeautyMakeupTypeMouth) {
            return kQueenBeautyBlendSoftLight;
        } else if (type == kQueenBeautyMakeupTypeHighlight) {
            return kQueenBeautyBlendOverlay;
        } else {
            return kQueenBeautyBlendNormal;
        }
}

// MARK: - Action
- (void)resetAction {
    if(self.currentUIBeautyLabel == UIBeautyLabelBase || self.currentUIBeautyLabel == UIBeautyLabelMakeup || self.currentUIBeautyLabel == UIBeautyLabelLUT || self.currentUIBeautyLabel == UIBeautyLabelMaterial)
    {
        [self resetSelectedBeauty];
    }
    else if(self.currentUIBeautyLabel == UIBeautyLabelBlush || self.currentUIBeautyLabel == UIBeautyLabelWholeMakup)
    {
        //如果是整妆或者腮红二级目录
        [_queenEngine resetAllMakeupType];
    }
    
    [self.collectionView deselectItemAtIndexPath:[self.collectionView.indexPathsForSelectedItems firstObject] animated:YES];
}

- (void)controlAction:(UIButton *)button {
    if (self.tapHidenHander) {
        if(self.currentUIBeautyLabel != UIBeautyLabelBlush && self.currentUIBeautyLabel != UIBeautyLabelWholeMakup){
            self.tapHidenHander();
        }
    }
    
    if(self.currentUIBeautyLabel == UIBeautyLabelBlush || self.currentUIBeautyLabel == UIBeautyLabelWholeMakup)
    {
        [self.headerBg setHidden:NO];
        [self.makeupHeadView setHidden:YES];
        [self prepareData:1];
    }
    else
    {
        self.hidden = YES;
    }
}

#pragma mark - CameraRotate

- (void)startRetainCameraRotate
{
    //初始化全局管理对象
    if (!_motionManager)
    {
        _motionManager = [[CMMotionManager alloc] init];
    }
    if (!_motionObserveQueue)
    {
        _motionObserveQueue = [[NSOperationQueue alloc] init];
    }
//    if ([self.motionManager isDeviceMotionAvailable])
//    {
//        self.motionManager.deviceMotionUpdateInterval = 1;
//        __weak typeof(self) weakSelf = self;
//        [self.motionManager startDeviceMotionUpdatesToQueue:self.motionObserveQueue
//                                                withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
//            // Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
//            double gravityX = motion.gravity.x;
//            double gravityY = motion.gravity.y;
//            double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;//手机旋转角度。
//            if (xyTheta >= -45 && xyTheta <= 45) //home键在上面
//            {
//                weakSelf.cameraRotate = 180;
//            }
//            else if (xyTheta > 45 && xyTheta < 135) //home键在左边
//            {
//                weakSelf.cameraRotate = 270;
//            }
//            else if ((xyTheta >= 135 && xyTheta < 180) || (xyTheta >= -180 && xyTheta < -135)) //home键在下面
//            {
//                weakSelf.cameraRotate = 0;
//            }
//            else if (xyTheta >= -135 && xyTheta < -45) //home键在右边
//            {
//                weakSelf.cameraRotate = 90;
//            }
//            if (weakSelf.deviceCanRotate)
//            {
//                weakSelf.cameraRotate = 0;
//            }
//            
//            //TODO 暂时屏蔽掉
//            //[self.liveRoom  setDeviceRotation:weakSelf.cameraRotate];
//            //NSLog(@"手机旋转的角度为 --- %d", weakSelf.cameraRotate);
//        }];
//    }
}

- (void)stopRetainCameraRotate
{
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionObserveQueue cancelAllOperations];
}


// MARK: - 磨皮/美白 滑动
- (void)setupSlider {
    UILabel *sliderLabel = [[UILabel alloc] init];
    self.sliderLabel = sliderLabel;
    sliderLabel.font = [UIFont systemFontOfSize:13];
}
@end

@implementation ALSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self);
    }];
    self.titleLabel = titleLabel;
    
    UISlider *slider = [[UISlider alloc] init];
    [self addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(10);
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-60);
        make.height.equalTo(@30);
    }];
    slider.thumbTintColor = [UIColor whiteColor];
    slider.minimumTrackTintColor = [UIColor whiteColor];
    slider.maximumTrackTintColor = [UIColor colorWithWhite:0 alpha:0.4];
    slider.alpha = 0.8;
    // 通常状态下
    [slider setThumbImage:[UIImage imageNamed:@"camera_slider_thump"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"camera_slider_thump"] forState:UIControlStateHighlighted];
    self.slider = slider;
}

- (void)setParam:(NSMutableDictionary *)param {
    _param = param;
    
    NSString *type = param[@"type"];
    if ([type isEqualToString:@"switch"]) {
//        self.valueSwitch.hidden = NO;
//        self.valueSwitch.on = [param[@"value"] boolValue];
    } else if ([type isEqualToString:@"slider"]) {
        self.slider.hidden = NO;
        self.slider.hidden = NO;
        self.slider.maximumValue = [param[@"max"] floatValue];
        self.slider.minimumValue = [param[@"min"] floatValue];
        self.slider.value = [param[@"value"] floatValue];
//        self.valueLabel.text = [NSString stringWithFormat:@"%.2f", [param[@"value"] floatValue]];
    }
}

@end
