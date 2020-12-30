//
//  NSObject+ExtensionQzs.m
//  Procuratorate
//
//  Created by 邱子硕 on 2020/8/25.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "NSObject+ExtensionQzs.h"
#import <objc/runtime.h>

@implementation NSObject (ExtensionQzs)
+ (BOOL)isEmpty:(id)object{
    if (object == nil || [object isEqual:[NSNull null]]) {
        return YES;
    } else if ([object isKindOfClass:[NSString class]]) {
        return [object isEqualToString:@""];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [object isEqualToNumber:@(0)];
    }
    return NO;
}



+ (void)load {

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        if ([[UIDevice currentDevice].systemVersion floatValue]< 8.0) {

            return;

        }



        Class WKContentViewCls = objc_getClass("WKContentView");

        if (!WKContentViewCls) { return;}



        SEL isSecureTextEntrySel = @selector(isSecureTextEntry);

        if (![WKContentViewCls instancesRespondToSelector:isSecureTextEntrySel]) {

            BOOL isSecureTextEntryAdded = class_addMethod(WKContentViewCls, isSecureTextEntrySel, class_getMethodImplementation(self, isSecureTextEntrySel), "B@:");

            if (!isSecureTextEntryAdded) {

                NSLog(@"isSecureTextEntry 添加失败");

            }

        }

        SEL secureTextEntrySel = @selector(secureTextEntry);

        if (![WKContentViewCls instancesRespondToSelector:secureTextEntrySel]) {

            BOOL secureTextEntryAdded = class_addMethod(WKContentViewCls, secureTextEntrySel, class_getMethodImplementation(self, secureTextEntrySel), "B@:");

            if (!secureTextEntryAdded) {

                NSLog(@"isSecureTextEntry 添加失败");

            }

        }

    });

}

- (BOOL)isSecureTextEntry {

    return NO;

}

- (BOOL)secureTextEntry  {

    return NO;

}
@end
