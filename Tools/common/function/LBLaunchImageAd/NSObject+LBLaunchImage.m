//
//  NSObject+LBLaunchImage.m
//  LBLaunchImageAdDemo
//
//  Created by 邱子硕 on 2020/6/19.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "NSObject+LBLaunchImage.h"

@implementation NSObject (LBLaunchImage)

+ (void)makeLBLaunchImageAdView:(void(^)(LBLaunchImageAdView *))block{
    
    LBLaunchImageAdView *imgAdView = [[LBLaunchImageAdView alloc]init];
    imgAdView.clickBlock = ^(const clickType type) {
        
    };
    block(imgAdView);
}
@end
