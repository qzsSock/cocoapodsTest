//
//  UIButton+Extension.h
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Extension)

+(HButton *)creatButtonlWithFrame:(CGRect)frame withNormalTtite:(NSString *)title withNormalTtiteColor:(UIColor *)color withFont:(UIFont *)font withNormalImageName:(NSString *)imageName withTarget:(nullable id)target withAction:(nonnull SEL)action withContainerView:( UIView * _Nullable )view;

@end

NS_ASSUME_NONNULL_END
