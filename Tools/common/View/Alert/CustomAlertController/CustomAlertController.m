//
//  CustomAlertController.m
//  VegetablePlatform
//
//  Created by 邱子硕 on 2020/5/30.
//  Copyright © 2020 邱子硕. All rights reserved.
//

#import "CustomAlertController.h"

@implementation CustomAlertController
+ (instancetype)showAlertWithTitle:(NSString*)title message:(NSString*)message preferredStyle:(UIAlertControllerStyle)style leftTitle:(NSString*)leftStr rightTitle:(NSString*)rightStr{
   
    //显示提示框
    CustomAlertController* alert = [CustomAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:style];
    
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:leftStr style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          
        alert.leftBlock();
        
    
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:rightStr style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //响应事件
                                                            
        alert.rightBlock();
                                                        
    }];
    if(![NSString isNULLString:leftStr])
    {
        [alert addAction:defaultAction];
    }
    
    [alert addAction:cancelAction];
    
//    [defaultAction setValue:defaultGreen forKey:@"titleTextColor"];
//    [cancelAction setValue:defaultGreen forKey:@"titleTextColor"];
       
    //修改title
//        NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"提示"];
//        [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 2)];
//        [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 2)];
//        [alert setValue:alertControllerStr forKey:@"attributedTitle"];
  
        //修改message
//        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
//        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#222222"] range:NSMakeRange(0, message.length)];
//        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:1.5] range:NSMakeRange(0, message.length)];
//        [alert setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
   
    UIViewController*vc= [KAppDelegate getCurrentVC];
    [vc presentViewController:alert animated:YES completion:nil];
    return alert;
}







@end
