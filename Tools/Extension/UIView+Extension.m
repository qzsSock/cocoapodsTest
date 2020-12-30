//
//  UIView+Extension.m
//  Demo
//
//  Created by ZhuDabin on 2019/8/30.
//  Copyright © 2019年 ZhuDabin. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (UIViewController*) viewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

+(UIView *)creatViewWithFrame:(CGRect)frame withBackgroundColor:(UIColor *)color withContainerView:(UIView *)view{
    UIView * subView = [[UIView alloc] init];
    subView.frame = frame;
    subView.backgroundColor = color;
    [view addSubview:subView];
    return subView;
}

@end
