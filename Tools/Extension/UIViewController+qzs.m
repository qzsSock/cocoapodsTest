//
//  UIViewController+qzs.m
//  Procuratorate
//
//  Created by 邱子硕 on 2020/6/25.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "UIViewController+qzs.h"

@implementation UIViewController (qzs)
//pop 到新建群界面
- (void)popViewControllerWithClassString:(NSString *)ClassString{
    if (self.navigationController) {
        Class class = NSClassFromString(ClassString);
        UIViewController *viewController;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:class]) {
                viewController = vc;
                break;
            }
        }
        if (viewController) {
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}

@end
