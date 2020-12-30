//
//  NSDateEx.h
//  WebXHSDK
//
//  Created by HeLiulin on 15/11/17.
//  Copyright © 2015年 上海翔汇网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE    60
#define D_HOUR        3600
#define D_DAY        86400
#define D_WEEK        604800
#define D_YEAR        31556926

@interface NSDate (Extension)
/**
 *  格式化时间
 *
 *  @param format 格式（yyyy/MM/dd）
 *
 *  @return 字符串
 */
- (NSString*) formatWithString:(NSString *)format;

/**
 *  通过时间字符串创建一个NSDate对象
 *
 *  @param withFormat 时间字符串
 *  @param format     时间格式（默认:yyyy/MM/dd HH:mm:ss)
 *
 *  @return NSDate对象
 */
+ (NSDate*) dateWithString:(NSString*)dateString withFormat:(NSString*)format;

+ (NSCalendar *) currentCalendar; // avoid bottlenecks

// Adjusting dates
- (NSDate *) dateByAddingYears: (NSInteger) dYears;
- (NSDate *) dateBySubtractingYears: (NSInteger) dYears;
- (NSDate *) dateByAddingMonths: (NSInteger) dMonths;
- (NSDate *) dateBySubtractingMonths: (NSInteger) dMonths;
- (NSDate *) dateByAddingDays: (NSInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) dateByAddingHours: (NSInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateByAddingSeconds: (NSInteger) dMeconds;
- (NSDate *) dateBySubtractingSeconds: (NSInteger) dMeconds;


/// 根据 formatterStr获取当前时间字符串
/// @param formatterStr formatter格式字符串
+(NSString*)stringWithNowDateByFormatter:(NSString*)formatterStr;

+(NSDate*)getBeijinByDate:(NSDate*)date;

@end
