//
//  ALLiveItemSettingView.m
//  AliLiveSdk-Demo
//
//  Created by 薛林 on 2020/12/17.
//  Copyright © 2020 alilive. All rights reserved.
//

#import "ALLiveItemSettingView.h"
#import "Masonry.h"
#import "ALLiveMacro.h"
#import "UIColor+ALLiveColor.h"
#import "DemoUtil.h"

@implementation ALLiveSettingItem

@end


@implementation ALLiveSettingCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView).offset(-10);
        make.width.height.equalTo(@44);
    }];
    self.imageView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.2];
    self.imageView.layer.cornerRadius = 22;
    self.imageView.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.imageView.mas_bottom).offset(5);
    }];
}

- (void)setItem:(ALLiveSettingItem *)item {
    _item = item;
    if (self.beautyType == 3) {
        self.imageView.image = [UIImage imageWithContentsOfFile:item.imageName];
    }else{
        self.imageView.image = [UIImage imageNamed:item.imageName];
    }
    self.titleLabel.text = item.title;
    if (item.textColor) {
        self.titleLabel.textColor = item.textColor;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(selected && self.item.changeStyleForSelected)
    {
        NSString *imageName = self.item.imageName;
        if(![imageName containsString:@"_selected"])
        {
            imageName = [NSString stringWithFormat:@"%@_selected", self.item.imageName];
        }
        self.imageView.image = [UIImage imageNamed:imageName];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#1AED99"];
        self.item.isSelect = YES;
    }
    else
    {
        self.titleLabel.textColor = [UIColor whiteColor];
        self.imageView.image = [UIImage imageNamed:self.item.imageName];
        self.item.isSelect = NO;
    }
}

@end


@interface ALLiveItemSettingView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) ALLiveItemSettingRole role;
@property (nonatomic, strong) NSArray<ALLiveSettingItem *> *items;
@end

@implementation ALLiveItemSettingView

- (instancetype)initWithSetting:(ALLiveItemSettingRole)settingRole {
    if (self = [super init]) {
        _role = settingRole;
        [self setupCollectionView];
        [self prepareData];
    }
    return self;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = false;
    if (self.role == ALLiveItemSettingRoleAudience || self.role == ALLiveItemSettingRolePull || self.role == ALLiveItemSettingRoleRTCPull) {
        layout.itemSize = CGSizeMake((SCREEN_WIDTH - 70 * 2) / 3, 90);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        if (self.role != ALLiveItemSettingRoleAudience) {
            collectionView.contentInset = UIEdgeInsetsMake(0, (SCREEN_WIDTH-90-70 * 2)/2, 0, 28);
        }

    } else {
        layout.itemSize = CGSizeMake(70, 70);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 28);
    }
    [collectionView registerClass:[ALLiveSettingCell class] forCellWithReuseIdentifier:NSStringFromClass([ALLiveSettingCell class])];
    self.collectionView = collectionView;
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)prepareData {
    if (self.role == ALLiveItemSettingRoleAnchor) {
        NSArray *titles = @[NSLocalizedString(@"推流",nil),NSLocalizedString(@"美颜",nil),NSLocalizedString(@"音效",nil),NSLocalizedString(@"摄像头",nil),NSLocalizedString(@"发起PK",nil),NSLocalizedString(@"静音",nil),NSLocalizedString(@"调节参数",nil),NSLocalizedString(@"数据指标",nil)];
        NSArray *imgs = @[@"live_push",@"live_beauty",@"live_music",@"live_camera",@"live_pk_enable",@"camera_push_silence",@"live_program",@"live_data"];
        NSMutableArray *mData = @[].mutableCopy;
        for(int i = 0; i < titles.count; i++) {
            NSString *title = titles[i];
            NSString *imgName = imgs[i];
            ALLiveSettingItem *item = [[ALLiveSettingItem alloc] init];
            item.title = title;
            item.imageName = imgName;
            item.changeStyleForSelected = NO;
            [mData addObject:item];
        }
        self.items = mData.copy;
    } else if(self.role == ALLiveItemSettingRoleAudience) {
        NSArray *titles = @[NSLocalizedString(@"连麦",nil),NSLocalizedString(@"美颜",nil),NSLocalizedString(@"数据指标",nil)];
        NSArray *imgs = @[@"audience_connect_mic",@"live_beauty",@"live_data"];
        NSMutableArray *mData = @[].mutableCopy;
        for(int i = 0; i < titles.count; i++) {
            NSString *title = titles[i];
            NSString *imgName = imgs[i];
            ALLiveSettingItem *item = [[ALLiveSettingItem alloc] init];
            item.title = title;
            item.imageName = imgName;
            item.changeStyleForSelected = NO;
            [mData addObject:item];
        }
        self.items = mData.copy;
    } else if(self.role == ALLiveItemSettingRoleCameraPush) {
        NSArray *titles = @[NSLocalizedString(@"推流",nil),NSLocalizedString(@"美颜",nil),NSLocalizedString(@"音效",nil),NSLocalizedString(@"摄像头",nil),NSLocalizedString(@"静音",nil),NSLocalizedString(@"调节参数",nil),NSLocalizedString(@"数据指标",nil)];
        NSArray *imgs = @[@"live_push",@"live_beauty",@"live_music",@"live_camera",@"camera_push_silence",@"live_program",@"live_data"];
        NSMutableArray *mData = @[].mutableCopy;
        for(int i = 0; i < titles.count; i++) {
            NSString *title = titles[i];
            NSString *imgName = imgs[i];
            ALLiveSettingItem *item = [[ALLiveSettingItem alloc] init];
            item.title = title;
            item.imageName = imgName;
            item.changeStyleForSelected = NO;
            [mData addObject:item];
        }
        self.items = mData.copy;
    } else if(self.role == ALLiveItemSettingRolePull) {
        NSArray *titles = @[NSLocalizedString(@"结束观看",nil)];
        NSArray *imgs = @[@"pull_stop_watch"];
        NSMutableArray *mData = @[].mutableCopy;
        for(int i = 0; i < titles.count; i++) {
            NSString *title = titles[i];
            NSString *imgName = imgs[i];
            ALLiveSettingItem *item = [[ALLiveSettingItem alloc] init];
            item.title = title;
            item.imageName = imgName;
            item.changeStyleForSelected = NO;
            [mData addObject:item];
        }
        self.items = mData.copy;
    } else if(self.role == ALLiveItemSettingRoleRTCPull) {
        NSArray *titles = @[NSLocalizedString(@"结束观看",nil)];
        NSArray *imgs = @[@"pull_stop_watch"];
        NSMutableArray *mData = @[].mutableCopy;
        for(int i = 0; i < titles.count; i++) {
            NSString *title = titles[i];
            NSString *imgName = imgs[i];
            ALLiveSettingItem *item = [[ALLiveSettingItem alloc] init];
            item.title = title;
            item.imageName = imgName;
            item.changeStyleForSelected = NO;
            [mData addObject:item];
        }
        self.items = mData.copy;
    }
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ALLiveSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ALLiveSettingCell class]) forIndexPath:indexPath];
    if (indexPath.row == 4) { // pk
        _pkCell = cell;
    }
    cell.item = self.items[indexPath.row];
    if ([cell.titleLabel.text isEqual:NSLocalizedString(@"静音",nil)]) {
        _setSilenceCell = cell;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALLiveSettingItem *item = self.items[indexPath.row];
    if ([item.title isEqualToString:NSLocalizedString(@"推流",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectPush)]) {
            [self.delegate didSelectPush];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"美颜",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectBeauty)]) {
            BOOL isBeautyOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"AliLiveBeautySwitch"];
            if (!isBeautyOpen) {
                [DemoUtil showToast: NSLocalizedString(@"美颜已关闭，请在调节参数中开启美颜",nil)];
                return;
            }else{
                [self.delegate didSelectBeauty];
            }
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"音效",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectSoundEffect)]) {
            [self.delegate didSelectSoundEffect];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"摄像头",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectCamera)]) {
            [self.delegate didSelectCamera];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"发起PK",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectPK)]) {
            [self.delegate didSelectPK];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"麦克风",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectMicphone)]) {
            [self.delegate didSelectMicphone];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"调节参数",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectSetProgram)]) {
            [self.delegate didSelectSetProgram];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"数据指标",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectDataIndicators)]) {
            [self.delegate didSelectDataIndicators];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"连麦",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectContectMic)]) {
            [self.delegate didSelectContectMic];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"音量",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectVolume)]) {
            [self.delegate didSelectVolume];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"静音",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectSilence)]) {
            [self.delegate didSelectSilence];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"磨皮",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectBlur)]) {
            [self.delegate didSelectBlur];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"结束观看",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectStopWatch)]) {
            [self.delegate didSelectStopWatch];
        }
    } else if([item.title isEqualToString:NSLocalizedString(@"听筒切换",nil)]) {
        if ([self.delegate respondsToSelector:@selector(didSelectReceiverChange)]) {
            [self.delegate didSelectReceiverChange];
        }
    }
}

@end
