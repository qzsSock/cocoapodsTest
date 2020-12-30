//
//  UILabel+Extension.m
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//

#import "UILabel+Extension.h"

@implementation UILabel (Extension)

+(HLabel *)creatLabelWithFrame:(CGRect)frame withText:(NSString *)text withTextColor:(UIColor *)textColor withFont:(UIFont *)font withContainerView:(UIView *)view{
    HLabel * label = [[HLabel alloc] init];
    label.frame = frame;
    label.text = text;
    label.textColor = textColor;
    label.font = font;
    [view addSubview:label];
    return label;
}


+(instancetype)initWithtextColor:(UIColor*)color font:(CGFloat)font textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSUInteger)nums text:(NSString*)text
{
    UILabel*label =  [[UILabel alloc] init];
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:font];
    label.textAlignment=textAlignment;
    label.numberOfLines = nums;
    label.text = text;
    [label sizeToFit];
    return label;
}
@end
