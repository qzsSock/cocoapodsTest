//
//  UIView+Extension.h
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extension)
@property(nonatomic,strong,readonly) UIViewController *viewController;
+(HView *)creatViewWithFrame:(CGRect)frame withBackgroundColor:(UIColor *)color withContainerView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
