//
//  HLine+Extension.h
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//

#import "HLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLine (Extension)

+(HLine *)creatViewLineFrame:(CGRect)frame withLineStyle:(UILineStyle)lineStyle withBackgroundColor:(UIColor *)color withContainerView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
