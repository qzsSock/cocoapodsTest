//
//  NSObject+ExtensionQzs.h
//  Procuratorate
//
//  Created by 邱子硕 on 2020/8/25.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ExtensionQzs)
/**
 *  判断对象是否为空
 *  常见的：nil、NSNil、@""、@(0) 以上4种返回YES
 *  如果需要判断字典与数组，可以自行添加
 *  @return YES 为空  NO 为实例对象
 */
+ (BOOL)isEmpty:(id)object;
@end

NS_ASSUME_NONNULL_END
