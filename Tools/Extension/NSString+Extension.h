//
//  NSStringEx.h
//  WeAct
//
//  Created by by Heliulin on 15/3/26.
//  Copyright (c) 2015年 上海翔汇网络技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSString (Extension)
- (NSString *) md5;
- (NSString *) sha1;
- (CGSize) sizeWithFontSize:(UIFont*)font andMaxWidth:(CGFloat)maxWidth andMaxHeight:(CGFloat)maxHeight;

- (NSDictionary*) toDictionary;





/// 计算字符串高度
/// @param font 字体
/// @param maxSize size
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

/**
 *  字符串是否null 不包含为0的情况
 *
 *  @param string 比较的字符串
 *
 *  @return 是否null
 */
+(BOOL) isNULLString:(NSString *)string;



/// 为空就返回 @""
/// @param str 需要判断的字符串
+(NSString*)judgeNullWithStr:(NSString*)str;

- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
@end
