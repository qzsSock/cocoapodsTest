//
//  NSDictionary+Extension.h
//  WebXHSDK
//
//  Created by HeLiulin on 16/3/18.
//  Copyright © 2016年 zzz003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(Extension)
/**
 *  转化为字符串
 *
 *  @return 字符串
 */
- (NSString*) toJsonString;


/// json转字典
/// @param jsonString json字符串
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


/// 字典转json
/// @param dic 字典
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;


+ (id )ObjeckWithJsonString:(NSString *)jsonString;
@end
