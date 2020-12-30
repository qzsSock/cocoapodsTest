//
//  HLine+Extension.m
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//

#import "HLine+Extension.h"

@implementation HLine (Extension)
+(HLine *)creatViewLineFrame:(CGRect)frame withLineStyle:(UILineStyle)lineStyle withBackgroundColor:(UIColor *)color withContainerView:(HView *)view {
    HLine *line = [[HLine alloc] init];
    line.lineStyle = lineStyle;
    line.frame = frame;
    line.lineColor = KLineColor;
    [view addSubview:line];
    return line;
}
@end
