//
//  UIButton+Extension.m
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)
+(HButton *)creatButtonlWithFrame:(CGRect)frame withNormalTtite:(NSString *)title withNormalTtiteColor:(UIColor *)color withFont:(UIFont *)font withNormalImageName:(NSString *)imageName withTarget:(nullable id)target withAction:(nonnull SEL)action withContainerView:( UIView * _Nullable )view;{
    
    HButton *button = [[HButton alloc] init];
    button.frame = frame;
    [button setTitle:title forState:0];
    [button setTitleColor:color forState:0];
    button.titleLabel.font = font;
    [button setImage:[UIImage imageNamed:imageName] forState:0];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    if (view != nil) {
         [view addSubview:button];
    }
   
    return button;
}

@end
