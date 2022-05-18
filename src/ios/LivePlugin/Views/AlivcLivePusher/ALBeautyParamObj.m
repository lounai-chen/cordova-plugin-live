//
//  ALBeautyParamObj.m
//  AliLiveSdk-Demo
//
//  Created by lichentao on 2021/2/27.
//  Copyright © 2021 alilive. All rights reserved.
//  Queen美颜参数预处理

#import "ALBeautyParamObj.h"
#import <queen/Queen.h>
#import <queen/QueenEngine.h>
#import <queen/QueenEngineConfigInfo.h>

@implementation ALBeautyParamObj

+ (NSArray *)initBeautyParams{
    // 美颜
    NSArray *titles_my = @[NSLocalizedString(@"磨皮",nil),NSLocalizedString(@"美白",nil),NSLocalizedString(@"锐化",nil),NSLocalizedString(@"瘦脸",nil),NSLocalizedString(@"脸长",nil),NSLocalizedString(@"削脸",nil),NSLocalizedString(@"瘦颧骨",nil),NSLocalizedString(@"下颌骨",nil),NSLocalizedString(@"下巴",nil),NSLocalizedString(@"下巴拉长",nil),NSLocalizedString(@"大眼",nil),NSLocalizedString(@"眼睑下至",nil),NSLocalizedString(@"眼距",nil),NSLocalizedString(@"瘦鼻",nil),NSLocalizedString(@"鼻长",nil),NSLocalizedString(@"鼻翼",nil),NSLocalizedString(@"鼻头长",nil),NSLocalizedString(@"嘴型",nil),NSLocalizedString(@"嘴唇厚度",nil),NSLocalizedString(@"人中",nil)];
    NSArray *imgs_my = @[@"beauty_mopi_nornal",@"beauty_meibai_nornal",@"beauty_ruihua_nornal",@"beauty_shoulian_nornal",@"beauty_lianchang_nornal",@"beauty_xiaolian_nornal",@"beauty_shouquangu_nornal",@"beauty_xiahegu_nornal",@"beauty_xiaba_nornal",@"beauty_xiabalachang_nornal",@"beauty_dayan_nornal",@"beauty_yanjianxiazhi_nornal",@"beauty_yanju_nornal",@"beauty_shoubi_nornal",@"beauty_bichang_nornal",@"beauty_suobiyi_nornal",@"beauty_bitouchang_nornal",@"beauty_chunkuan_nornal",@"beauty_chungao_nornal",@"beauty_renzhong_nornal"];
    NSArray *beautyParam =
    @
    [@(kQueenBeautyParamsSkinBuffing),@(kQueenBeautyParamsWhitening),@(kQueenBeautyParamsSharpen),@(kQueenBeautyFaceShapeTypeThinFace),@(kQueenBeautyFaceShapeTypeLongFace),@(kQueenBeautyFaceShapeTypeCutFace),@(kQueenBeautyFaceShapeTypeCutCheek),@(kQueenBeautyFaceShapeTypeThinMandible),@(kQueenBeautyFaceShapeTypeThinJaw),@(kQueenBeautyFaceShapeTypeHigherJaw),@(kQueenBeautyFaceShapeTypeBigEye),@(kQueenBeautyFaceShapeTypeEyeAngle2),@(kQueenBeautyFaceShapeTypeCanthus),@(kQueenBeautyFaceShapeTypeThinNose),@(kQueenBeautyFaceShapeTypeNasalHeight),@(kQueenBeautyFaceShapeTypeNosewing),@(kQueenBeautyFaceShapeTypeNoseTipHeight),@(kQueenBeautyFaceShapeTypeMouthWidth),@(kQueenBeautyFaceShapeTypeMouthHigh),@(kQueenBeautyFaceShapeTypePhiltrum)];
    
    // 美妆
    NSArray *titles_mz = @[NSLocalizedString(@"高光",nil),NSLocalizedString(@"美瞳",nil),NSLocalizedString(@"口红",nil),NSLocalizedString(@"眼妆",nil),NSLocalizedString(@"腮红",nil),NSLocalizedString(@"整妆",nil)];
    NSArray *imgs_mz = @[@"beauty_gaoguang_normal",@"beauty_meitong_normal",@"beauty_kouhong_normal",@"beauty_yanzhuang_normal",@"beauty_saihong_normal",@"beauty_zhengzhuang_normal"];
    
    NSArray *mzBeautyParam =
    @[@(kQueenBeautyMakeupTypeHighlight),@(kQueenBeautyMakeupTypeEyeball),@(kQueenBeautyMakeupTypeMouth),@(kQueenBeautyMakeupTypeEyeBrow),@(kQueenBeautyMakeupTypeBlush),@(kQueenBeautyMakeupTypeWhole)];
    
    // 腮红
    NSArray *titles_sh = @[NSLocalizedString(@"无",nil),NSLocalizedString(@"黛紫",nil),NSLocalizedString(@"蜜橘",nil),NSLocalizedString(@"嫩粉",nil),NSLocalizedString(@"桃红",nil),NSLocalizedString(@"樱桃",nil)];
    NSArray *imgs_sh = @[@"common_none_normal",@"beauty_daizi_normal",@"beauty_miju_normal",@"beauty_nengfen_normal",@"beauty_taohong_normal",@"beauty_yintao_normal"];
    
    NSArray *titles_makeWhole = @[NSLocalizedString(@"无",nil),NSLocalizedString(@"活力",nil),NSLocalizedString(@"基础",nil),NSLocalizedString(@"梅子",nil),NSLocalizedString(@"魅惑",nil),NSLocalizedString(@"蜜桃",nil),NSLocalizedString(@"奶橘",nil),NSLocalizedString(@"杏粉",nil),NSLocalizedString(@"优雅",nil),NSLocalizedString(@"元气少女",nil)];
    NSArray *imgs_makewhole =
    @[@"common_none_normal",@"beauty_huoli_normal",@"beauty_jichu_normal",@"beauty_meizi_normal",@"beauty_meihuo_normal",@"beauty_mitao_normal",@"beauty_naiju_normal",@"beauty_xingfen_normal",@"beauty_youya_normal",@"beauty_yuanqishaonv_normal"];
    
    // 滤镜-资源
    NSString *strResourcesBundle = [[NSBundle mainBundle] pathForResource:@"res" ofType:@"bundle"];
    
    NSString *imgs_lj_1 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"超脱色卡" ofType:@"png" inDirectory:@"lookups"];
    NSString *imgs_lj_2 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"纯真色卡" ofType:@"png" inDirectory:@"lookups"];
    NSString *imgs_lj_3 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"怀旧色卡" ofType:@"png" inDirectory:@"lookups"];
    NSString *imgs_lj_4 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"蓝调色卡" ofType:@"png" inDirectory:@"lookups"];
    NSString *imgs_lj_5 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"清新色卡" ofType:@"png" inDirectory:@"lookups"];
    NSString *imgs_lj_6 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"元气色卡" ofType:@"png" inDirectory:@"lookups"];
    
    NSString *lookup_1 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_1" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_2 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_2" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_3 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_3" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_4 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_4" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_5 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_5" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_6 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_6" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_7 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_7" ofType:@"png" inDirectory:@"lookups"];
    //    NSString *lookup_8 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_8" ofType:@"png" inDirectory:@"lookups"];
    //    NSString *lookup_9 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_9" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_11 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_11" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_12 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_12" ofType:@"png" inDirectory:@"lookups"];
    //    NSString *lookup_16 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_16" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_18 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_18" ofType:@"png" inDirectory:@"lookups"];
    //    NSString *lookup_20 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_20" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_21 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_21" ofType:@"png" inDirectory:@"lookups"];
    //    NSString *lookup_23 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_23" ofType:@"png" inDirectory:@"lookups"];
    //    NSString *lookup_24 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_24" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_25 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_25" ofType:@"png" inDirectory:@"lookups"];
    NSString *lookup_27 = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"lookup_27" ofType:@"png" inDirectory:@"lookups"];
    // 滤镜-名称
    NSArray *titles_lj = @[NSLocalizedString(@"无",nil),NSLocalizedString(@"超脱",nil),NSLocalizedString(@"纯真",nil),NSLocalizedString(@"怀旧",nil),NSLocalizedString(@"蓝调",nil),NSLocalizedString(@"清新",nil),NSLocalizedString(@"元气",nil),NSLocalizedString(@"美白",nil),NSLocalizedString(@"初恋",nil),NSLocalizedString(@"清爽",nil),NSLocalizedString(@"非凡",nil),NSLocalizedString(@"动人",nil),NSLocalizedString(@"萌系",nil),NSLocalizedString(@"日系",nil),NSLocalizedString(@"年华",nil),NSLocalizedString(@"单纯",nil),NSLocalizedString(@"蔷薇",nil),NSLocalizedString(@"安静",nil),NSLocalizedString(@"严肃",nil),NSLocalizedString(@"日光",nil)];
    
    NSArray *imgs_lj = @[@"common_none_normal",@"beauty_chaotuo_normal",@"beauty_chunzhen_normal",@"beauty_huaijiu_normal",@"beauty_landiao_normal",@"beauty_qingxin_normal",@"beauty_yuanqi_normal",@"beauty_meibai_normal",@"beauty_chulian_normal",@"beauty_qingshuang_normal",@"beauty_feifan_normal",@"beauty_dongren_normal",@"beauty_mengxi_normal",@"beauty_rixi_normal",@"beauty_nianhua_normal",@"beauty_danchun_normal",@"beauty_qiangwei_normal",@"beauty_anjing_normal",@"beauty_yanshu_normal",@"beauty_riguang_normal"];
    
    NSArray *ljBeautyParam = @[@"",imgs_lj_1,imgs_lj_2,imgs_lj_3,imgs_lj_4,imgs_lj_5,imgs_lj_6,lookup_1,lookup_2,lookup_3,lookup_4,lookup_5,lookup_6,lookup_7,lookup_11,lookup_12,lookup_18,lookup_21,lookup_25,lookup_27];
    
    // 贴纸
    NSArray *titles_tz = @[NSLocalizedString(@"无",nil),NSLocalizedString(@"白羊",nil),NSLocalizedString(@"八字胡",nil),NSLocalizedString(@"布偶",nil),NSLocalizedString(@"小黄脸",nil),NSLocalizedString(@"猴子",nil),NSLocalizedString(@"胡须",nil),NSLocalizedString(@"猫耳朵",nil),NSLocalizedString(@"射手座",nil),NSLocalizedString(@"手绘胡子",nil),NSLocalizedString(@"兔子",nil)];
    
    NSString *raceBundlePath = [[NSBundle mainBundle] pathForResource:@"res" ofType: @"bundle"];
    
    NSString *baiyang = [raceBundlePath stringByAppendingString:@"/sticker/baiyang"];
    NSString *bazihu = [raceBundlePath stringByAppendingString:@"/sticker/bazihu"];
    NSString *buou = [raceBundlePath stringByAppendingString:@"/sticker/buou"];
    NSString *emoji = [raceBundlePath stringByAppendingString:@"/sticker/emoji"];
    NSString *houzi = [raceBundlePath stringByAppendingString:@"/sticker/houzi"];
    NSString *huxu = [raceBundlePath stringByAppendingString:@"/sticker/huxu"];
    NSString *maoerduo = [raceBundlePath stringByAppendingString:@"/sticker/maoerduo"];
    NSString *sheshou = [raceBundlePath stringByAppendingString:@"/sticker/sheshou"];
    NSString *shouhuihu = [raceBundlePath stringByAppendingString:@"/sticker/shouhuihuzi"];
    NSString *tuzi = [raceBundlePath stringByAppendingString:@"/sticker/tuzi"];
    
    NSArray *tzBeautyParam = @[
        @"", baiyang, bazihu, buou, emoji, houzi, huxu, maoerduo, sheshou, shouhuihu, tuzi
    ];
    
    NSArray *titleArray = @[@{@"name":NSLocalizedString(@"美颜",nil),@"type":@"0",@"data":@{@"titles":titles_my,@"imgs":imgs_my,@"beautyParam":beautyParam}}
                            
                            ,@{@"name":NSLocalizedString(@"美妆",nil),@"type":@"1",@"data":@{@"titles":titles_mz,@"imgs":imgs_mz,@"beautyParam":mzBeautyParam}}
                            
                            ,@{@"name":NSLocalizedString(@"滤镜",nil),@"type":@"2",@"data":@{@"titles":titles_lj,@"beautyParam":ljBeautyParam,@"imgs":imgs_lj}}
                            
                            ,@{@"name":NSLocalizedString(@"贴纸",nil),@"type":@"3",@"data":@{@"titles":titles_tz,@"beautyParam":tzBeautyParam}}
                            
                            ,@{@"name":NSLocalizedString(@"腮红",nil),@"type":@"4",@"data":@{@"titles":titles_sh,@"imgs":imgs_sh}}
                            
                            ,@{@"name":NSLocalizedString(@"整妆",nil),@"type":@"5",@"data":@{@"titles":titles_makeWhole,@"imgs":imgs_makewhole}}
    ];
    return titleArray;
}

+ (void)configParamsWithType:(int)type Params:(NSDictionary *)params{
    
}

+ (NSDictionary *)getCoinfigParamsWithType:(int)type{
    
    return nil;
}


@end

/*
 
 
 
 
 */
