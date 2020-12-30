//
//  CustomAlertController.h
//  VegetablePlatform
//
//  Created by 邱子硕 on 2020/5/30.
//  Copyright © 2020 邱子硕. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^leftBlock) (void);
typedef void(^rightBlock) (void);


@interface CustomAlertController : UIAlertController

@property (nonatomic,copy)leftBlock leftBlock;
@property (nonatomic,copy)rightBlock rightBlock;

+ (instancetype)showAlertWithTitle:(NSString*)title message:(NSString*)message preferredStyle:(UIAlertControllerStyle)style leftTitle:(NSString*)leftStr rightTitle:(NSString*)rightStr;
@end


