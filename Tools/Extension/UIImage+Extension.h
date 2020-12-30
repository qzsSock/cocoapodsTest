//
//  UIImage+Extension.h
//  MimiLife_User
//
//  Created by HeLiulin on 15/12/17.
//  Copyright © 2015年 zzz003. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
/**
 *  根据给定颜色生成纯色图片
 *
 *  @param color 颜色
 *
 *  @return 图片对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color;
/**
 *  按原比例压缩图片
 *
 *  @param defineWidth 横向分辨率
 *
 *  @return 处理后的图片
 */
- (UIImage*)imageCompressForWidth:(CGFloat)defineWidth;
/**
 *  修正图片旋转方向
 *
 *  @return 处理后的图片
 */
- (UIImage *)fixOrientation;
/**
 *  从SDK资源包中取图片
 *
 *  @param imageName 图片名称
 *
 *  @return UIImage对象
 */
+ (UIImage *) bundleImageName:(NSString*)imageName;

@end
