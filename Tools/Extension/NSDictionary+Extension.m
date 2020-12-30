//
//  NSDictionary+Extension.m
//  WebXHSDK
//
//  Created by HeLiulin on 16/3/18.
//  Copyright © 2016年 zzz003. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary(Extension)

- (NSString*) toJsonString
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}




+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
if (jsonString == nil) {
return nil;
}

NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
NSError *err;
NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
options:NSJSONReadingMutableContainers error:&err];

if(err) {
NSLog(@"json解析失败：%@",err);
return nil;
}
return dic;
}


//字典转json格式字符串：

+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
NSError *parseError = nil;
NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];

return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


+ (id )ObjeckWithJsonString:(NSString *)jsonString
{
if (jsonString == nil) {
return nil;
}

NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
NSError *err;
id  json = [NSJSONSerialization JSONObjectWithData:jsonData
options:NSJSONReadingMutableContainers error:&err];

if(err) {
NSLog(@"json解析失败：%@",err);
return nil;
}
return json;
}

@end
