//
//  NSObject+LBLaunchImage.h
//  LBLaunchImageAdDemo
//
//  Created by 邱子硕 on 2020/6/19.
//  Copyright © 2020 zjjcy. All rights reserved.
//  启动图

#import <Foundation/Foundation.h>
#import "LBLaunchImageAdView.h"

@interface NSObject (LBLaunchImage)


+ (void)makeLBLaunchImageAdView:(void(^)(LBLaunchImageAdView *))block;

@end
