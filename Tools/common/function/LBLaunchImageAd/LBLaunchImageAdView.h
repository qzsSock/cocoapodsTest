
typedef enum {
    
    LogoAdType = 0,///带logo的广告
    FullScreenAdType = 1,///全屏的广告
    
}AdType;

typedef enum {
    
    skipAdType = 1,///点击跳过
    clickAdType = 2,///点击广告
    overtimeAdType = 3,///倒计时完成跳过
    
}clickType;

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>

typedef void (^LBClick) (const clickType);


@interface LBLaunchImageAdView : UIView

@property (nonatomic, strong) UIImageView *aDImgView;
///倒计时总时长,默认6秒
@property (nonatomic, assign) NSInteger adTime;
///跳过按钮 可自定义
@property (nonatomic, strong) UIButton *skipBtn;
///本地图片名字
@property (nonatomic, copy) NSString *localAdImgName;
///网络图片URL
@property (nonatomic, copy) NSString *imgUrl;
///广告点击URL
@property (nonatomic, copy) NSString *advertUrl;
///是否支持点击广告
@property (nonatomic, assign) BOOL isClickAdView;

@property (nonatomic, copy)LBClick clickBlock;

/*
 *  adType 广告类型
 */
- (void(^)(AdType const adType))getLBlaunchImageAdViewType;

@end
