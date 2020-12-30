//
//  Unitl.h
//  Procuratorate
//
//  Created by luojiao on 2019/11/27.
//  Copyright © 2019 zjjcy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Unitl : NSObject
/**判断输入的数字还是名字**/
+ (BOOL) judgeIsNumberByRegularExpressionWith:(NSString *)str;
/**
*  生成图片
*
*  @param color  图片颜色
*  @param height 图片高度
*
*  @return 生成的图片
*/
+(UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height;
/****自定义searchBar*/
+(void)customSearchBar:(UISearchBar *)searchBar;
/**
 计算str的高度
 
 @param str 需要计算的str
 @return 高度
 */
+ (float)getHeightForText:(NSString *)str;
/**
 根据文本算控件高度
 @param value 文本
 @param width 控件最大宽度
 @param font 字体大小
 @param height 控件最大高度
 @return 计算出的宽度
 */
+ (CGFloat)heightForString:(NSString *)value andWidth:(float)width font:(UIFont *)font height:(CGFloat)height;

//数组转jsonsting
+ (NSString *)arrayToJSONString:(NSArray *)array;


/// 解决签名空格问题
/// @param ary 签名字典数组
+ (NSString*)signWithAry:(NSArray<NSDictionary*>*)ary;

//NSDictionary 转jsonstring
+(NSString *)convertToJsonData:(NSDictionary *)dict;

//加载的Html的标签字符串 用于显示html标签内容 needStr 需要加载的HTML文本内容
+(NSString *)retunHtmlStr:(NSString *)needStr;
//字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//验证身份证ID
+ (BOOL)checkUserIdCard: (NSString*) idCard;
//返回手机型号
+ (NSString *)getCurrentDeviceModel;
//返回APP版本号
+(NSString *)returnAppVersion;

/// 将阿拉伯数字转成文字
+(NSString *)changeNumberToString:(NSInteger)number;

@end

NS_ASSUME_NONNULL_END
