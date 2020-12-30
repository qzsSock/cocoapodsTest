//
//  Unitl.m
//  Procuratorate
//
//  Created by luojiao on 2019/11/27.
//  Copyright © 2019 zjjcy. All rights reserved.
//

#import "Unitl.h"
#import <sys/utsname.h>

@implementation Unitl

/**判断输入的数字还是名字**/
+(BOOL) judgeIsNumberByRegularExpressionWith:(NSString *)str
{
   if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

/**
*  生成图片
*
*  @param color  图片颜色
*  @param height 图片高度
*
*  @return 生成的图片
*/
+(UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+(void)customSearchBar:(UISearchBar *)searchBar
{
        UIImage* searchBarBg = [Unitl GetImageWithColor:RGB(243, 244, 244) andHeight:36.0f];
        //设置背景图片
    //      [_searchItiem setBackgroundImage:searchBarBg];
    //      //设置背景色
    //      [_searchItiem setBackgroundColor:[UIColor clearColor]];
          //设置文本框背景
          [searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
        
//        UITextField *searchField = [searchBar valueForKey:@"searchField"];
//        searchField.layer.masksToBounds = YES;
//        searchField.layer.cornerRadius = 5.0;
//        searchField.font = [UIFont systemFontOfSize:13];
//        [searchBar setValue:searchField forKeyPath:@"searchField"];

}

/**
 计算str的高度
 
 @param str 需要计算的str
 @return 高度
 */
+ (float)getHeightForText:(NSString *)str{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = 4;
    NSDictionary *dic = @{ NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:paraStyle };
    CGSize size = [str boundingRectWithSize:CGSizeMake(kScreenW - 200, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size.height;
}

/**
 根据文本算控件高度
 @param value 文本
 @param width 控件最大宽度
 @param font 字体大小
 @param height 控件最大高度
 @return 计算出的宽度
 */
+ (CGFloat)heightForString:(NSString *)value andWidth:(float)width font:(UIFont *)font height:(CGFloat)height
{
    CGRect sizeToFit = [value boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{                                                                       NSFontAttributeName:font} context:nil];
    return sizeToFit.size.height;
}


+ (NSString *)arrayToJSONString:(NSArray *)array
{
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
//    NSString *jsonS =  [jsonString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//    NSString *jsonTemp = [jsonS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    NSString *jsonResult = [jsonTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
        

    NSString *jsonTemp = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *jsonResult = [jsonTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
    
//    NSString*str = [NSString stringWithFormat:@"%@",[bodDic objectForKey:keyStr]];
//    NSString *valueStr = [jsonResult stringByReplacingOccurrencesOfString:@" " withString:@""];
    return jsonResult;
    
}


+(NSString*)signWithAry:(NSArray<NSDictionary*>*)ary
{
   NSString*aryStr = @"[";
    for (int i = 0; i < ary.count; ++i)
    {
        NSString*dicStr = @"{";
        for (int j = 0; j < ary[i].allKeys.count; ++j)
        {
            
          dicStr=  [dicStr stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\",",ary[i].allKeys[j],ary[i].allValues[j]]];
        }
        
        NSString*dicStrs =  [dicStr substringToIndex:[dicStr length] - 1];
        
         dicStrs=  [dicStrs stringByAppendingString:@"},"];
        aryStr=  [aryStr stringByAppendingString:dicStrs];
        
    }
    
   NSString*signStr =   [aryStr substringToIndex:[aryStr length] - 1];
   signStr=  [signStr stringByAppendingString:@"]"];
    
    NSLog(@"signStr = %@",signStr);
    
    return signStr;
    
}





//NSDictionary 转jsonString
+(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
//    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

//加载的Html的标签字符串 用于显示html标签内容 needStr 需要加载的HTML文本内容
+(NSString *)retunHtmlStr:(NSString *)needStr{

    NSString *path = [[NSBundle mainBundle] pathForResource:@"html" ofType:@"css"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSString *contentStr = [NSString stringWithFormat:@"%@%@</div></body></html>",htmlString,needStr];
    return contentStr;
}

//字符串转dic
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


#pragma 正则匹配用户身份证号15或18位
+ (BOOL)checkUserIdCard: (NSString*) idCard{
    
    NSString*pattern =@"(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)";

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];

    BOOL isMatch = [pred evaluateWithObject:idCard];

//    return isMatch;
    
     return YES;
}

//返回手机型号
+ (NSString *)getCurrentDeviceModel{
    struct utsname systemInfo;
   uname(&systemInfo);
   
   NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
   
if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
// 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    return deviceModel;
//    return @"未知设备";
}
 

//返回APP版本号
+(NSString *)returnAppVersion{
    
    NSDictionary *appInfoDct = [[NSBundle mainBundle] infoDictionary];
    
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

//    // 当前应用名称
//    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
//
//    NSLog(@"当前应用名称：%@",appCurName);
//
//    // 当前应用软件版本  比如：1.0.1
//
//    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//
//    NSLog(@"当前应用软件版本:%@",appCurVersion);

    // 当前应用版本号码   int类型

    //app 的版本号
    NSString *appVersionStr = [appInfoDct objectForKey:@"CFBundleShortVersionString"];

    
    return appVersionStr;

}

/// 将阿拉伯数字转成文字
+(NSString *)changeNumberToString:(NSInteger)number {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterRoundHalfDown;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    formatter.locale = locale;
    NSString *string = [formatter stringFromNumber:[NSNumber numberWithInteger:number]];
    return string;
}


@end
