//
//  UILabel+Extension.h
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Extension)
+(HLabel *)creatLabelWithFrame:(CGRect)frame withText:(NSString *)text withTextColor:(UIColor *)textColor withFont:(UIFont *)font withContainerView:(UIView *)view;

+(instancetype)initWithtextColor:(UIColor*)color font:(CGFloat)font textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSUInteger)nums text:(NSString*)text;
@end

NS_ASSUME_NONNULL_END
