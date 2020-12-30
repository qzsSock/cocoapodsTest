//
//  UIImageView+Extension.h
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Extension)

+(UIImageView *)creatImageViewWithFrame:(CGRect)frame withImageName:(NSString *)iamgeName withContainerView:(UIView *)view;

+ (CGSize)getImageSizeWithURL:(id)URL;

@end

NS_ASSUME_NONNULL_END
