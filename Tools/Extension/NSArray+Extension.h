//
//  NSArray+Extension.h
//  Procuratorate
//
//  Created by 邱子硕 on 2020/7/3.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Extension)

//判断空
+(BOOL) isNULLString:(NSArray *)ary;

+ (NSString*)spacingByComma:(NSMutableArray*)arr;

@end

NS_ASSUME_NONNULL_END
