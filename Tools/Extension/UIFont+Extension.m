//
//  UIFont+Extension.m
//  WebXHSDK
//
//  Created by HeLiulin on 16/3/18.
//  Copyright © 2016年 zzz003. All rights reserved.
//

#import "UIFont+Extension.h"

@implementation UIFont(Extension)
+ (UIFont *) fontWithSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *) PingFangSCMedium:(CGFloat)size
{
     return [UIFont fontWithName:@"PingFangSC-Medium" size:size];
}

+ (UIFont *) PingFangSCBold:(CGFloat)size {
         return [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
}
@end
