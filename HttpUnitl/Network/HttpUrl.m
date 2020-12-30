//
//  HttpUrl.m
//  Procuratorate
//  Created by luojiao on 2019/11/23.
//  Copyright © 2019 zjjcy. All rights reserved.


#import "HttpUrl.h"
#import "MBProgressHUD+YY.h"
#import "Reachability.h"
#import <RPSDK/RPSDK.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import<CommonCrypto/CommonDigest.h>//sha1 md5加密需要导入的文件
#import <AFNetworking/AFNetworking.h>
#import "GMSm4Utils.h"//SM4
#import "NSData+GZIP.h"//推荐使用的gizp
#import "ANTPathMatching.h"

static  NSString*pathSeparator = @"/";

@implementation HttpUrl

+(id)shareHttpClient
{
    static HttpUrl *httpClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpClient = [[self alloc] init];
    });
    return httpClient;
}

-(void)showMessageHUD:(NSString *)tipStr
{
    if (!_HUD)
    {
        _HUD = [[MBProgressHUD alloc] initWithView:KAppDelegate.window];
//        _HUD.dimBackground = YES;
//        _HUD.activityIndicatorColor = [UIColor blackColor];
        _HUD.contentColor = [UIColor clearColor];
        _HUD.label.font = [UIFont systemFontOfSize:12];
    }
    if (tipStr == nil){
        _HUD.label.text = @"正在加载，请稍等...";
    }else{
        _HUD.label.text = tipStr;
    }
    
    [KAppDelegate.window.rootViewController.view addSubview:_HUD];
    [KAppDelegate.window.rootViewController.view bringSubviewToFront:_HUD];
    [_HUD showAnimated:YES];
}

- (void)hiddenMessageHUD
{
    _HUD.removeFromSuperViewOnHide = YES;
    [_HUD hideAnimated:YES afterDelay:0];
}


+ (BOOL) isConnectionAvailable:(NSString*)serverAddr{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:serverAddr];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            NSLog(@"无法连接");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            NSLog(@"WIFI网络");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES ;
            NSLog(@"PHONE网络");
            break;
    }
    if (!isExistenceNetwork) {
        return NO;
    }
    return isExistenceNetwork;
}

+ (NSString *)getCurrentTimestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970]*1000;// *1000 是精确到毫秒(13位),不乘就是精确到秒(10位)
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+ (NSString *)randomStringWithLen: (int)len {
    char ch[len];
    for (int index=0; index<len; index++) {
        int num = arc4random_uniform(75)+48;
        if (num>57 && num<65) { num = num%57+48; }
        else if (num>90 && num<97) { num = num%90+65;}
        ch[index] = num;
    }
    return [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
}

//sign 签名方法
+ (NSString *)signCalc:(NSString *)appKey getTimeStamp:(NSString*)timeStamp nonce:(NSString*)nonce  bodyDict:(NSDictionary*)bodyDict {
    
    NSString *queryString = [NSString stringWithFormat:@"appKey=%@&nonce=%@&timestamp=%@",appKey,nonce,timeStamp];
    
    NSString *bodyStr = [self retunBodyArr:bodyDict];
    
    NSString *signString = [NSString stringWithFormat:@"%@%@%@",queryString,bodyStr,AppSecret];;
    if (bodyStr == nil || [bodyStr isEqual:[NSNull null]] || [bodyStr isEqualToString:@""]) {
        signString = [NSString stringWithFormat:@"%@%@",queryString,AppSecret];
    }

    NSLog(@"signString = %@",signString);
    NSString *md5Sign = [self md5:signString];
    return md5Sign;
}

//MD5 加密
+ (NSString *) md5 : (NSString *) str {
    // 判断传入的字符串是否为空
    if (! str) return nil;
    // 转成utf-8字符串
    const char *cStr = str.UTF8String;
    // 设置一个接收数组
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    // 对密码进行加密
    CC_MD5(cStr, (CC_LONG) strlen(cStr), result);
    NSMutableString *md5Str = [NSMutableString string];
    // 转成32字节的16进制
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    
    return md5Str;
}

//返回body字符串
+(NSString *)retunBodyArr:(NSDictionary *)bodDic
{
    NSArray *bodyDictAllKey = bodDic.allKeys;
    NSArray *bodyDealArr = [bodyDictAllKey sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
        
    NSLog(@"bodyDealArr = %@ bodDic = %@",bodyDealArr,bodDic);
    
    NSString *bodyString = @"";
    
    if (bodyDealArr != nil && ![bodyDealArr isEqual:[NSNull null]] && bodyDealArr.count > 0)
    {
        
        for (int i = 0; i < bodyDealArr.count; i++) {
            NSString *keyStr = bodyDealArr[i];
          
            NSString *valueStr = [NSString stringWithFormat:@"%@",[bodDic objectForKey:keyStr]];
            //如果上传的数据中有数组，将array转jsonString 上传
            if ([[bodDic objectForKey:keyStr] isKindOfClass:[NSArray class]])
            {
                
                NSArray *valueArr = [bodDic objectForKey:keyStr];
                //如果数组参数有内容
                if(valueArr.count)
                {
                    //是字典就需要控制空格
                    if ([valueArr[0]  isKindOfClass:[NSDictionary class]]) {
                        valueStr = [Unitl signWithAry:valueArr];
                    }else//数组就用系统的
                    {
                        valueStr = [Unitl arrayToJSONString:valueArr];
                    }
                  
                    
                    
                }else
                {
                    valueStr = @"";
                }

            }

            if (valueStr == nil || [valueStr isEqualToString:@""] || [valueStr isEqual:[NSNull null]]) {
                valueStr = @"";
            }
            bodyString = [bodyString stringByAppendingFormat:@"%@",[NSString stringWithFormat:@"%@=%@&",keyStr,[NSString stringWithFormat:@"%@",valueStr]]];
        }
        
        if (bodyString.length > 0) {
            bodyString = [bodyString substringToIndex:bodyString.length - 1];
        }
    }
    NSLog(@"bodyString = %@",bodyString);
    
//    NSString *strUrl = [bodyString stringByReplacingOccurrencesOfString:@" " withString:@""];
//     NSLog(@"strUrl = %@",strUrl);

    return bodyString;

}


+ (void) postWithShortUrl:(NSString *)shortUrl hud:(UIView *)hud uploadDictionary:(NSMutableDictionary*) upDictionary postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode{
        
    [MBProgressHUD showHUDAddedTo:hud animated:YES];
    if ([self isConnectionAvailable:SubBaseUrl] == NO) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",@"网络不能连接到服务器"]];
        [MBProgressHUD hideHUDForView:hud animated:YES];
        return;
    }
    if(!upDictionary)
       {
           [MBProgressHUD showError:@"请求参数错误"];
           [MBProgressHUD hideHUDForView:hud animated:YES];
           return;
       }
    
    NSError *SerialError = nil;
   
   
  
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:upDictionary options:NSJSONWritingPrettyPrinted error:&SerialError];
    if (SerialError) {
        NSLog(@"\ndict-json:%@",SerialError);
    }
        
    NSString *timeStamp = [[NSString alloc] init];
    timeStamp = [self getCurrentTimestamp];
    NSLog(@"timeStamp = %@",timeStamp);
    NSString *randomStr = [[NSString alloc] init];
    randomStr = [self randomStringWithLen:30];
    NSString *signStr = [[NSString alloc] init];
    /**签名**/
    signStr = [self signCalc:KAppDelegate.pubAppkey getTimeStamp:timeStamp nonce:randomStr bodyDict:upDictionary];
    NSLog(@"signStr md5 = %@",signStr);
    NSString *str_urlA = BaseUrl;
    NSString *str_url = [str_urlA stringByAppendingFormat:@"%@?appKey=%@&timestamp=%@&nonce=%@&sign=%@",shortUrl,KAppDelegate.pubAppkey,timeStamp,randomStr,signStr];
    
    NSURL *url = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSLog(@"post url %@",url);
    [request setHTTPMethod:@"POST"];
    NSString *head = [NSString stringWithFormat:@"application/json"];
    [request setValue:head forHTTPHeaderField:@"Content-Type"];
    NSString *head2 = [NSString stringWithFormat:@"%@", KAppDelegate.pubDeviceNumber];
    [request setValue:head2 forHTTPHeaderField:@"deviceNumber"];
        
    NSString *head3 = [NSString stringWithFormat:@"%@", KAppDelegate.pubAcessToken];
    [request setValue:head3 forHTTPHeaderField:@"accessToken"];
    
    
    //判断是否要进行加密和压缩  encryptPattern 或者 platforms 为空就不需要加密
    if ([NSString isNULLString:KAppDelegate.configModel.encryptPattern] || [NSString isNULLString: KAppDelegate.configModel.platforms])
    {
         [request setHTTPBody:jsonData];
        
        
    }else //encryptPattern 和 platforms 都不为空 需要进行判断是否要加密
    {
        //shortUrl 拼接 /api/ 再进行匹配
        NSString*qzsPath = [NSString stringWithFormat:@"/api/%@",shortUrl];
        //根据逗号分隔 平台
        NSArray *array = [ KAppDelegate.configModel.platforms componentsSeparatedByString:@","];
        //根据逗号分隔 ANT路径
        NSArray *pattDirs = [KAppDelegate.configModel.encryptPattern componentsSeparatedByString:@","];
        
        BOOL isMatchingANT = NO;//默认不符合
        for (int i = 0; i < pattDirs.count; ++i)//遍历ANT路径
        {
          //如果有一个匹配就匹配
          if ([ANTPathMatching doMatchPattern:pattDirs[i] path:qzsPath fullMatch:YES]) {
              
              isMatchingANT = YES;
          }
              
        }
    
        //如果包含我们平台 并且path满足ANT的规则就就行加密
        if([array containsObject: @"2"] && isMatchingANT)
        {
            NSLog(@"qzsPath = %@符合ANT进行加密=%@KAppDelegate.configModel.encryptPattern",qzsPath,KAppDelegate.configModel.encryptPattern);
            //需要加密的json字符串
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *sM4Str = [GMSm4Utils ecbEncryptText:jsonStr key:DevelopmentSM4];
            NSString *randomStr = [self randomStringWithLen:4];
            //判断是否需要压缩
           if(sM4Str.length > KAppDelegate.configModel.gzipThreshold)
            {
                //gizp压缩
                NSData *sM4Data =   [sM4Str dataUsingEncoding:NSUTF8StringEncoding];
                NSData *gizpData =   [sM4Data gzippedData];
                NSString *baseStr =  [gizpData base64EncodedStringWithOptions:0];
//                NSLog(@"baseStr =   %@",baseStr);
                NSString *heardStr = [NSString stringWithFormat:@"1400%@",randomStr];
                NSString *heardSM4Str =  [GMSm4Utils ecbEncryptText:heardStr key:DevelopmentSM4];
                
                NSString *encryptionStr = [NSString stringWithFormat:@"%@%@",heardSM4Str,baseStr];
//                NSLog(@"encryptionStr = %@",encryptionStr);
                NSData *encryptionData = [encryptionStr dataUsingEncoding:NSUTF8StringEncoding];
                 [request setHTTPBody:encryptionData];

            }else
            {
                
                NSLog(@"无压缩加密");
                NSString *heardStr = [NSString stringWithFormat:@"0400%@",randomStr];
                NSString *heardSM4Str =  [GMSm4Utils ecbEncryptText:heardStr key:DevelopmentSM4];
                NSString *encryptionStr = [NSString stringWithFormat:@"%@%@",heardSM4Str,sM4Str];
//                NSLog(@"无encryptionStr = %@",encryptionStr);
                NSData *encryptionData = [encryptionStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:encryptionData];
            }
            
            
        }else //平台不符合 或者 ANT不符合就不进行加密
        {
             [request setHTTPBody:jsonData];
        }
    }
    
    NSLog(@"%@%@\n\n\n",@"\n\n\nURL:",request.URL);
    NSLog(@"%@%@\n\n\n",@"\n\n\nHead:",request.allHTTPHeaderFields);
    NSLog(@"%@%@\n\n\n",@"\n\n\nBody:",upDictionary);
    request.timeoutInterval = 30;
    request.cachePolicy = 1;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *retError = nil;
        NSLog(@"data =  %@",data);
        if (data == nil || [data isEqual:[NSNull null]])//无数据
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"error url = %@",shortUrl);
                    if ([shortUrl isEqualToString:@"common/pushMessage/pushReadCount"] || [shortUrl isEqualToString:@"cases/approvalStatistics/queryApprovalStatistics"])
                    {
                       
                        [MBProgressHUD hideHUDForView:hud animated:YES];
                    }else
                    {
                        [MBProgressHUD showError:@"请求失败"];
                        [MBProgressHUD hideHUDForView:hud animated:YES];
                    }
                    
                }];
            });

        } else//有数据
        {
//            NSLog(@"data = %@",data);
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&retError];
            NSLog(@"jsonObject = %@",jsonObject);
            if (jsonObject != nil && retError == nil)//判断是否是json
            {
                NSLog(@"\n\n\nJson Ok");
                if ([jsonObject isKindOfClass:[NSDictionary class]]){
                    NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                    NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                    NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
//                    NSString *success = [NSString stringWithFormat:@"%@",deserializedDictionary[@"success"]];
                    if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"] ||[resultCode isEqualToString:@"1120047"] || [resultCode isEqualToString:@"1120048"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [MBProgressHUD hideHUDForView:hud animated:YES];
                                if (postSuccess) {
                                    postSuccess(deserializedDictionary);
                                }
                            }];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                
                        if ([shortUrl isEqualToString:@"common/pushMessage/pushReadCount"] || [shortUrl isEqualToString:@"cases/approvalStatistics/queryApprovalStatistics"])
                           {
                              
                              [MBProgressHUD hideHUDForView:hud animated:YES];
                           }else
                           {
                                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                                                             NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);
                                                             [MBProgressHUD hideHUDForView:hud animated:YES];
                           }
                                
                                
                                if (failCode) {
                                    failCode(resultCode);
                                }
                                NSLog(@"error url = %@",shortUrl);
                            }];
                        });
                    }
                    
                } else if ([jsonObject isKindOfClass:[NSArray class]]){
                    NSArray *deserializedArray = (NSArray *)jsonObject;
                    NSLog(@"\n\n\nJson is Arr = %@", deserializedArray);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
        if ([shortUrl isEqualToString:@"common/pushMessage/pushReadCount"] || [shortUrl isEqualToString:@"cases/approvalStatistics/queryApprovalStatistics"])
        {
            [MBProgressHUD hideHUDForView:hud animated:YES];
        }else
        {
             [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedArray]];
             [MBProgressHUD hideHUDForView:hud animated:YES];
        }
                                                           
                            
NSLog(@"error message = %@",[deserializedArray[1] stringByRemovingPercentEncoding]);
NSLog(@"error url = %@",shortUrl);
                           
                        }];
                    });

                } else {
                    NSLog(@"\n\n\nJson isn't Dict+Arr = %@", jsonObject);
                    NSArray *deserializedArray = (NSArray *)jsonObject;
                    NSLog(@"error message = %@",[deserializedArray[1] stringByRemovingPercentEncoding]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [MBProgressHUD hideHUDForView:hud animated:YES];
                            NSLog(@"error url = %@",shortUrl);
                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",jsonObject]];
                        }];
                    });
                }
            }else //不是json 是密文
            {
                NSLog(@"不是json 需要解密或者解压");
                
                NSString * result = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"result = %@",result);
                //解密解压
                NSDictionary *deserializedDictionary = [self  decryptSM4:result];
                if(!deserializedDictionary)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                       NSLog(@"error url = %@",shortUrl);
                                       [MBProgressHUD showError:@"请求失败"];
                                       [MBProgressHUD hideHUDForView:hud animated:YES];
                                   }];
                               });
                    return;
                }
                NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
                if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [MBProgressHUD hideHUDForView:hud animated:YES];
                if (postSuccess) {
                postSuccess(deserializedDictionary);
                }
                }];
                });
                } else
                {
                dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);
                [MBProgressHUD hideHUDForView:hud animated:YES];

                if (failCode) {
                failCode(resultCode);
                }
                NSLog(@"error url = %@",shortUrl);
                }];
                });
                }
                
            }

        }
    }];
    [task resume];
}


+ (void) getWithShortUrl:(NSString *)shortUrl hud:(UIView *)hud uploadDictionary:(NSMutableDictionary*) upDictionary postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode{
        
    if ([self isConnectionAvailable:SubBaseUrl] == NO) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",@"网络不能连接到服务器"]];
//        [MBProgressHUD hideHUDForView:hud animated:YES];
        return;
    }
    NSError *SerialError = nil;
    //get 请求不需要body放参数 而且这个请求也没用参数
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:upDictionary options:NSJSONWritingPrettyPrinted error:&SerialError];
    if (SerialError) {
        NSLog(@"\ndict-json:%@",SerialError);
    }
        
    NSString *timeStamp = [[NSString alloc] init];
    timeStamp = [self getCurrentTimestamp];
    NSLog(@"timeStamp = %@",timeStamp);
    NSString *randomStr = [[NSString alloc] init];
    randomStr = [self randomStringWithLen:30];
    NSString *signStr = [[NSString alloc] init];
    /**签名**/
    signStr = [self signCalc:KAppDelegate.pubAppkey getTimeStamp:timeStamp nonce:randomStr bodyDict:upDictionary];
    NSLog(@"signStr md5 = %@",signStr);
    NSString *str_urlA = BaseUrl;
    NSString *str_url = [str_urlA stringByAppendingFormat:@"%@?appKey=%@&timestamp=%@&nonce=%@&sign=%@",shortUrl,KAppDelegate.pubAppkey,timeStamp,randomStr,signStr];
    
    NSURL *url = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSLog(@"get url %@",url);

    NSString *head = [NSString stringWithFormat:@"application/json"];
    [request setValue:head forHTTPHeaderField:@"Content-Type"];
    NSString *head2 = [NSString stringWithFormat:@"%@", KAppDelegate.pubDeviceNumber];
    [request setValue:head2 forHTTPHeaderField:@"deviceNumber"];
    NSString *head3 = [NSString stringWithFormat:@"%@", KAppDelegate.pubAcessToken];
    [request setValue:head3 forHTTPHeaderField:@"accessToken"];

    NSLog(@"%@%@\n\n\n",@"\n\n\nURL:",request.URL);
    NSLog(@"%@%@\n\n\n",@"\n\n\nHead:",request.allHTTPHeaderFields);
    NSLog(@"%@%@\n\n\n",@"\n\n\nBody:",upDictionary);
    request.timeoutInterval = 30;
    request.cachePolicy = 1;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *retError = nil;
        
        if (data == nil || [data isEqual:[NSNull null]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"error url = %@",shortUrl);
                    [MBProgressHUD showError:@"请求失败"];
                }];

            });

        } else
        {
            NSLog(@"data = %@",data);
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&retError];
            NSLog(@"jsonObject = %@",jsonObject);
            if (jsonObject != nil && retError == nil)
            {
                NSLog(@"\n\n\nJson Ok");
              
                    NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                    NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                    NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
                    if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [MBProgressHUD hideHUDForView:hud animated:YES];
                                if (postSuccess) {
                                    postSuccess(deserializedDictionary);
                                }
                            }];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                                NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);

                                if (failCode) {
                                    failCode(resultCode);
                                }
                                NSLog(@"error url = %@",shortUrl);
                            }];
                        });
                    }
                    
            }else
            {
                NSLog(@"不是json 需要解密或者解压");
                NSString * result = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"result = %@",result);
                NSDictionary *deserializedDictionary = [self  decryptSM4:result];
                if(!deserializedDictionary)//如果解析为空直接返回请求失败
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                           NSLog(@"error url = %@",shortUrl);
                           [MBProgressHUD showError:@"请求失败"];
                         }];
                     });
                    return;
                }
                
                NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
                if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"])
                {
                dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if (postSuccess)
                        {
                           postSuccess(deserializedDictionary);
                        }
                   }];
                });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                    NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);
                      
                        if (failCode)
                        {
                           failCode(resultCode);
                        }
                        NSLog(@"error url = %@",shortUrl);
                    }];
        });
     }
   }
}
}];
       [task resume];

}


+ (void)uploadFileWithShortUrl:(NSString *)shortUrl serviceName:(NSDictionary *)serviceDic uploadImage:(UIImage *)img postSuccess:(postSuccess)postSuccess{
    UIWindow*window = [UIApplication sharedApplication].keyWindow;
//    [MBProgressHUD showHUDAddedTo:window animated:YES];
    if ([self isConnectionAvailable:SubBaseUrl] == NO) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",@"网络不能连接到服务器"]];
//        [MBProgressHUD hideHUDForView:window animated:YES];
        return;
    }
    if(!serviceDic)
    {
         [MBProgressHUD showError:@"请求参数错误"];
//         [MBProgressHUD hideHUDForView:window animated:YES];
      
        return;
    }
    
    NSError *SerialError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serviceDic options:NSJSONWritingPrettyPrinted error:&SerialError];
    if (SerialError) {
        NSLog(@"\ndict-json:%@",SerialError);
    }

    
    NSString *timeStamp = [[NSString alloc] init];
    timeStamp = [self getCurrentTimestamp];
    NSString *randomStr = [[NSString alloc] init];
    randomStr = [self randomStringWithLen:30];
    NSString *signStr = [[NSString alloc] init];
    /**签名**/
    signStr = [self signCalc:KAppDelegate.pubAppkey getTimeStamp:timeStamp nonce:randomStr bodyDict:nil];
    NSString *str_urlA = BaseUrl;
    NSString *str_url = [str_urlA stringByAppendingFormat:@"%@?appKey=%@&timestamp=%@&nonce=%@&sign=%@",shortUrl,KAppDelegate.pubAppkey,timeStamp,randomStr,signStr];

    NSURL *url = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
   
  //UIImage *img = [UIImage imageNamed:@"敬请期待.png"]; //debug
    NSData *imageData;
    NSString *imageFormat;
    if (UIImagePNGRepresentation(img) != nil) {
        imageFormat = @"Content-Type: image/png \r\n";
        imageData = UIImagePNGRepresentation(img);
//        imageData = UIImageJPEGRepresentation(img, 1.0);
      
    }else{
        imageFormat = @"Content-Type: image/jpeg \r\n";
//         imageData = UIImagePNGRepresentation(img);
        imageData = UIImageJPEGRepresentation(img, 1.0);
     
    }

    //图片名称
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat =@"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    #pragma mark -[NSUUID UUID] UUIDString]可能为空
    NSString *fileName;
    if([[NSUUID UUID] UUIDString].length>=8)
    {
         fileName = [NSString stringWithFormat:@"%@%@", str, [[[NSUUID UUID] UUIDString] substringToIndex:8]];
    }else
    {
        fileName = [NSString stringWithFormat:@"%@%@", str, [self randomStringWithLen:8]];
    }
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[self getDataWithString:@"--BOUNDARY\r\n" ]];
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.png\"\r\n",@"file",fileName];
    [body appendData:[self getDataWithString:disposition]];
    [body appendData:[self getDataWithString:imageFormat]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:imageData];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"--BOUNDARY\r\n" ]];
    NSString *dispositions = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",@"serviceName"];
    [body appendData:[self getDataWithString:dispositions ]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"cases"]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"--BOUNDARY--\r\n"]];
    request.HTTPBody = body;
    
//    NSLog(@"result = %@",[self hexStringFromString:body]);
    NSInteger length = [body length];
    [request setValue:[NSString stringWithFormat:@"%ld",(long)length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"multipart/form-data; boundary=BOUNDARY" forHTTPHeaderField:@"Content-Type"];
    NSString *head2 = [NSString stringWithFormat:@"%@", KAppDelegate.pubDeviceNumber];
    [request setValue:head2 forHTTPHeaderField:@"deviceNumber"];
    NSString *head3 = [NSString stringWithFormat:@"%@", KAppDelegate.pubAcessToken];
    [request setValue:head3 forHTTPHeaderField:@"accessToken"];
    
    request.timeoutInterval = 30;
    request.cachePolicy = 1;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        
        if (data == nil || [data isEqual:[NSNull null]]  )//没有数据
        {
           dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"error url = %@",shortUrl);
                    [MBProgressHUD showError:@"请求失败"];
//                    [MBProgressHUD hideHUDForView:window animated:YES];
                }];
           });

        }
        else//有数据
        {
            
            NSError *retError = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&retError];
          if (jsonObject != nil && retError == nil) //json不为空
          {
            NSLog(@"\n\n\nJson Ok");
            if ([jsonObject isKindOfClass:[NSDictionary class]])//是不是字典
            {
                NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                NSString *resultCode = deserializedDictionary[@"code"];
                if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            if (postSuccess) {
                                if(deserializedDictionary != nil && ![deserializedDictionary isKindOfClass:[NSURL class]])
                                {
                                    NSLog(@"上传成功");
                                     postSuccess(deserializedDictionary);
                                }else
                                {
                                    postSuccess([NSDictionary new]);
                                }
                               
                            }
                        }];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
//                            [MBProgressHUD hideHUDForView:window animated:YES];
                        }];
                    });
                }
                
            }else if([jsonObject isKindOfClass:[NSArray class]])
            {
                NSArray *deserializedArray = (NSArray *)jsonObject;
                NSLog(@"\n\n\nJson is Arr = %@", deserializedArray);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedArray]];
//                        [MBProgressHUD hideHUDForView:window animated:YES];
                    }];

                });
                
            } else
            {
                NSLog(@"\n\n\nJson isn't Dict+Arr = %@", jsonObject);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",jsonObject]];
//                        [MBProgressHUD hideHUDForView:window animated:YES];
                    }];

                });
            }
        } else if (jsonData == nil)
        {
             NSLog(@"不是json 需要解密或者解压");
             NSString *result = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"result = %@",result);
             
             NSDictionary *deserializedDictionary = [self  decryptSM4:result];
             NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
             NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
             if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"])
             {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                         if (postSuccess)
                         {
                             
                            if(deserializedDictionary != nil && ![deserializedDictionary isKindOfClass:[NSURL class]])
                            {
                                NSLog(@"上传成功");
                                 postSuccess(deserializedDictionary);
                            }else
                            {
                                postSuccess([NSDictionary new]);
                            }
                         }
                  }];
            
              });
            }
            else
            {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                         [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                         NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);

                         NSLog(@"error url = %@",shortUrl);
//                         [MBProgressHUD hideHUDForView:window animated:YES];
                     }];
                 });
           }
        
        }else if (retError){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",retError]];
//                    [MBProgressHUD hideHUDForView:window animated:YES];
                }];
            });
        }
             
        }
    }];
    [task resume];
}


+ (void) postWithUrl:(NSString *)shortUrl  uploadDictionary:(NSMutableDictionary*) upDictionary postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode{
        
    if ([self isConnectionAvailable:SubBaseUrl] == NO) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",@"网络不能连接到服务器"]];
      
        return;
    }
    if(!upDictionary)
       {
           [MBProgressHUD showError:@"请求参数错误"];
           
           return;
       }
    
    NSError *SerialError = nil;
   
   
  
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:upDictionary options:NSJSONWritingPrettyPrinted error:&SerialError];
    if (SerialError) {
        NSLog(@"\ndict-json:%@",SerialError);
    }
        
    NSString *timeStamp = [[NSString alloc] init];
    timeStamp = [self getCurrentTimestamp];
    NSLog(@"timeStamp = %@",timeStamp);
    NSString *randomStr = [[NSString alloc] init];
    randomStr = [self randomStringWithLen:30];
    NSString *signStr = [[NSString alloc] init];
    /**签名**/
    signStr = [self signCalc:KAppDelegate.pubAppkey getTimeStamp:timeStamp nonce:randomStr bodyDict:upDictionary];
    NSLog(@"signStr md5 = %@",signStr);
    NSString *str_urlA = BaseUrl;
    NSString *str_url = [str_urlA stringByAppendingFormat:@"%@?appKey=%@&timestamp=%@&nonce=%@&sign=%@",shortUrl,KAppDelegate.pubAppkey,timeStamp,randomStr,signStr];
    
    NSURL *url = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSLog(@"post url %@",url);
    [request setHTTPMethod:@"POST"];
    NSString *head = [NSString stringWithFormat:@"application/json"];
    [request setValue:head forHTTPHeaderField:@"Content-Type"];
    NSString *head2 = [NSString stringWithFormat:@"%@", KAppDelegate.pubDeviceNumber];
    [request setValue:head2 forHTTPHeaderField:@"deviceNumber"];
        
    NSString *head3 = [NSString stringWithFormat:@"%@", KAppDelegate.pubAcessToken];
    [request setValue:head3 forHTTPHeaderField:@"accessToken"];
    
    
    //判断是否要进行加密和压缩  encryptPattern 或者 platforms 为空就不需要加密
    if ([NSString isNULLString:KAppDelegate.configModel.encryptPattern] || [NSString isNULLString: KAppDelegate.configModel.platforms])
    {
         [request setHTTPBody:jsonData];
        
        
    }else //encryptPattern 和 platforms 都不为空 需要进行判断是否要加密
    {
        //shortUrl 拼接 /api/ 再进行匹配
        NSString*qzsPath = [NSString stringWithFormat:@"/api/%@",shortUrl];
        //根据逗号分隔 平台
        NSArray *array = [ KAppDelegate.configModel.platforms componentsSeparatedByString:@","];
        //根据逗号分隔 ANT路径
        NSArray *pattDirs = [KAppDelegate.configModel.encryptPattern componentsSeparatedByString:@","];
        
        BOOL isMatchingANT = NO;//默认不符合
        for (int i = 0; i < pattDirs.count; ++i)//遍历ANT路径
        {
          //如果有一个匹配就匹配
          if ([ANTPathMatching doMatchPattern:pattDirs[i] path:qzsPath fullMatch:YES]) {
              
              isMatchingANT = YES;
          }
              
        }
    
        //如果包含我们平台 并且path满足ANT的规则就就行加密
        if([array containsObject: @"2"] && isMatchingANT)
        {
            NSLog(@"qzsPath = %@符合ANT进行加密=%@KAppDelegate.configModel.encryptPattern",qzsPath,KAppDelegate.configModel.encryptPattern);
            //需要加密的json字符串
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *sM4Str = [GMSm4Utils ecbEncryptText:jsonStr key:DevelopmentSM4];
            NSString *randomStr = [self randomStringWithLen:4];
            //判断是否需要压缩
           if(sM4Str.length > KAppDelegate.configModel.gzipThreshold)
            {
                //gizp压缩
                NSData *sM4Data =   [sM4Str dataUsingEncoding:NSUTF8StringEncoding];
                NSData *gizpData =   [sM4Data gzippedData];
                NSString *baseStr =  [gizpData base64EncodedStringWithOptions:0];
//                NSLog(@"baseStr =   %@",baseStr);
                NSString *heardStr = [NSString stringWithFormat:@"1400%@",randomStr];
                NSString *heardSM4Str =  [GMSm4Utils ecbEncryptText:heardStr key:DevelopmentSM4];
                
                NSString *encryptionStr = [NSString stringWithFormat:@"%@%@",heardSM4Str,baseStr];
//                NSLog(@"encryptionStr = %@",encryptionStr);
                NSData *encryptionData = [encryptionStr dataUsingEncoding:NSUTF8StringEncoding];
                 [request setHTTPBody:encryptionData];

            }else
            {
                
                NSLog(@"无压缩加密");
                NSString *heardStr = [NSString stringWithFormat:@"0400%@",randomStr];
                NSString *heardSM4Str =  [GMSm4Utils ecbEncryptText:heardStr key:DevelopmentSM4];
                NSString *encryptionStr = [NSString stringWithFormat:@"%@%@",heardSM4Str,sM4Str];
//                NSLog(@"无encryptionStr = %@",encryptionStr);
                NSData *encryptionData = [encryptionStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:encryptionData];
            }
            
            
        }else //平台不符合 或者 ANT不符合就不进行加密
        {
             [request setHTTPBody:jsonData];
        }
    }
    
    NSLog(@"%@%@\n\n\n",@"\n\n\nURL:",request.URL);
    NSLog(@"%@%@\n\n\n",@"\n\n\nHead:",request.allHTTPHeaderFields);
    NSLog(@"%@%@\n\n\n",@"\n\n\nBody:",upDictionary);
    request.timeoutInterval = 30;
    request.cachePolicy = 1;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *retError = nil;
        
        if (data == nil || [data isEqual:[NSNull null]])//无数据
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"error url = %@",shortUrl);
                    [MBProgressHUD showError:@"请求失败"];
                  
                }];
            });

        } else//有数据
        {
//            NSLog(@"data = %@",data);
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&retError];
            NSLog(@"jsonObject = %@",jsonObject);
            if (jsonObject != nil && retError == nil)//判断是否是json
            {
                NSLog(@"\n\n\nJson Ok");
                if ([jsonObject isKindOfClass:[NSDictionary class]]){
                    NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                    NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                    NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
                    if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                              
                                if (postSuccess) {
                                    postSuccess(deserializedDictionary);
                                }
                            }];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                                NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);
                              

                                if (failCode) {
                                    failCode(resultCode);
                                }
                                NSLog(@"error url = %@",shortUrl);
                            }];
                        });
                    }
                    
                } else if ([jsonObject isKindOfClass:[NSArray class]]){
                    NSArray *deserializedArray = (NSArray *)jsonObject;
                    NSLog(@"\n\n\nJson is Arr = %@", deserializedArray);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedArray]];
                            NSLog(@"error message = %@",[deserializedArray[1] stringByRemovingPercentEncoding]);
                            NSLog(@"error url = %@",shortUrl);
                          
                        }];
                    });

                } else {
                    NSLog(@"\n\n\nJson isn't Dict+Arr = %@", jsonObject);
                    NSArray *deserializedArray = (NSArray *)jsonObject;
                    NSLog(@"error message = %@",[deserializedArray[1] stringByRemovingPercentEncoding]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                          
                            NSLog(@"error url = %@",shortUrl);
//                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",jsonObject]];
                        }];
                    });
                }
            }else //不是json 是密文
            {
                NSLog(@"不是json 需要解密或者解压");
                
                NSString * result = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"result = %@",result);
                //解密解压
                NSDictionary *deserializedDictionary = [self  decryptSM4:result];
                if(!deserializedDictionary)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                       NSLog(@"error url = %@",shortUrl);
                                       [MBProgressHUD showError:@"请求失败"];
                                     
                                   }];
                               });
                    return;
                }
                NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
                if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               
                    if (postSuccess)
                    {
                      postSuccess(deserializedDictionary);
                    }
                    }];
                    
                });
                }
                else
                {
                dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);
               

                if (failCode) {
                failCode(resultCode);
                }
                NSLog(@"error url = %@",shortUrl);
                }];
                });
                }
                
            }

        }
    }];
    [task resume];
}


#pragma mark-funtion
+ (NSData *)getDataWithString:(NSString *)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

+ (NSString *)getVideoUrl:(NSString *)shortUrl {
        
    NSString *timeStamp = [[NSString alloc] init];
    timeStamp = [self getCurrentTimestamp];
    NSString *randomStr = [[NSString alloc] init];
    randomStr = [self randomStringWithLen:30];
    NSString *signStr = [[NSString alloc] init];
    signStr = [self signCalc:KAppDelegate.pubAppkey getTimeStamp:timeStamp nonce:randomStr bodyDict:nil];
    
    NSString *str_urlA = BaseUrl;
    NSString *str_url = [str_urlA stringByAppendingFormat:@"%@?appKey=%@&timestamp=%@&nonce=%@&sign=%@&deviceNumber=81491238471293",shortUrl,KAppDelegate.pubAppkey,timeStamp,randomStr,signStr];
    //NSLog(@"str_url = %@", str_url);
    
    return str_url;
}

//获取天气数据请求
+ (void)getWithShortUrl:(NSString *)shortUrl hud:(UIView *)hud postSuccess:(postSuccess)postSuccess{
        
    [MBProgressHUD showHUDAddedTo:hud animated:YES];
    if ([self isConnectionAvailable:SubBaseUrl] == NO) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",@"网络不能连接到服务器"]];
        [MBProgressHUD hideHUDForView:hud animated:YES];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:shortUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = 30;
    request.cachePolicy = 1;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *retError = nil;
        
        if (data == nil || [data isEqual:[NSNull null]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"error url = %@",shortUrl);
                    [MBProgressHUD showError:@"请求失败"];
                    [MBProgressHUD hideHUDForView:hud animated:YES];
                }];
            });

        } else {
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&retError];
            if (jsonObject != nil && retError == nil){
                NSLog(@"\n\n\nJson Ok");
                if ([jsonObject isKindOfClass:[NSDictionary class]]){
                    NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                    NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [MBProgressHUD hideHUDForView:hud animated:YES];
                            if (postSuccess) {
                                postSuccess(deserializedDictionary);
                            }
                        }];
                    });
                } else if ([jsonObject isKindOfClass:[NSArray class]]){
                    NSArray *deserializedArray = (NSArray *)jsonObject;
                    NSLog(@"\n\n\nJson is Arr = %@", deserializedArray);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedArray]];
                            NSLog(@"error message = %@",[deserializedArray[1] stringByRemovingPercentEncoding]);
                            NSLog(@"error url = %@",shortUrl);
                            [MBProgressHUD hideHUDForView:hud animated:YES];

                        }];
                    });

                } else {
                    NSLog(@"\n\n\nJson isn't Dict+Arr = %@", jsonObject);
                    NSArray *deserializedArray = (NSArray *)jsonObject;
                    NSLog(@"error message = %@",[deserializedArray[1] stringByRemovingPercentEncoding]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [MBProgressHUD hideHUDForView:hud animated:YES];
                            NSLog(@"error url = %@",shortUrl);
                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",jsonObject]];
                        }];
                    });
                }
            }
        }
    }];
    [task resume];
}


+(void)getUserHeaderImgUrl:(NSString *)fileUrl imgInfo:(NSDictionary *)imgDict fileCode:(NSString *)fileCodeStr getFileSuccess:(getHeaderFileSuccess)getSuccess{
    
    if ([self isConnectionAvailable:SubBaseUrl] == NO) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",@"网络不能连接到服务器"]];
        return;
    }
    
        
    NSString *timeStamp = [[NSString alloc] init];
    timeStamp = [self getCurrentTimestamp];
    NSLog(@"timeStamp = %@",timeStamp);
    NSString *randomStr = [[NSString alloc] init];
    randomStr = [self randomStringWithLen:30];
    NSString *signStr = [[NSString alloc] init];
    /**签名**/
    signStr = [self signCalc:KAppDelegate.pubAppkey getTimeStamp:timeStamp nonce:randomStr bodyDict:imgDict];
    NSLog(@"signStr md5 = %@",signStr);
    NSString *str_urlA = BaseUrl;
    NSString *str_url = [str_urlA stringByAppendingFormat:@"%@?appKey=%@&timestamp=%@&nonce=%@&sign=%@&fileCode=%@",fileUrl,KAppDelegate.pubAppkey,timeStamp,randomStr,signStr,fileCodeStr];

    
    NSURL *url = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = 30;
    request.cachePolicy = 1;
    
    NSString *head = [NSString stringWithFormat:@"application/json"];
    [request setValue:head forHTTPHeaderField:@"Content-Type"];
    NSString *head2 = [NSString stringWithFormat:@"%@", KAppDelegate.pubDeviceNumber];
    [request setValue:head2 forHTTPHeaderField:@"deviceNumber"];
        
    NSString *head3 = [NSString stringWithFormat:@"%@", KAppDelegate.pubAcessToken];
    [request setValue:head3 forHTTPHeaderField:@"accessToken"];
//    [request setHTTPBody:jsonData];
    request.timeoutInterval = 30;
    request.cachePolicy = 1;


    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil || [data isEqual:[NSNull null]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"error url = %@",fileUrl);
                    [MBProgressHUD showError:@"请求失败"];
                }];
            });

        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (getSuccess) {
                        getSuccess(data);
                    }
                }];
            });
        }
    }];
    [task resume];
  

}


/// 对密文进行解压解密处理
/// @param ciphertext 密文
+ (NSDictionary*)decryptSM4:(NSString *)ciphertext
{
    NSString *sm4Key = DevelopmentSM4; // 32 字节 Hex 编码格式字符串密钥
    
    //获取头部信息 和密文
    if ([NSString isNULLString:ciphertext] || ciphertext.length<32) {
        return nil;
    }
    NSString *heardStr = [ciphertext substringWithRange:NSMakeRange(0, 32)];
    NSString *contentStr = [ciphertext substringWithRange:NSMakeRange(32, ciphertext.length-32)];
    
    //加密压缩信息
    NSString *message = [GMSm4Utils ecbDecryptText:heardStr key:sm4Key];
   
    if([NSString isNULLString:message])
    {
         return nil;
    }
    
    //截取第一位 和第2到4位
    NSString *gzipFlag = [message substringWithRange:NSMakeRange(0, 1)];
    //加密模式 暂时用SM4  400
//    NSString *encryptionType = [message substringWithRange:NSMakeRange(1, 3)];
    if([gzipFlag isEqualToString:@"1"] )
    {
        // 1.先64解码 然后解压缩
        NSData *decodeData =   [self resultNSdataToBase64:contentStr];
        NSData *ungzipData = [decodeData gunzippedData];
        //必须转出字符串才能解密 直接data解密为空
        NSString *name =  [[NSString alloc] initWithData:ungzipData encoding:NSUTF8StringEncoding];
        //字典字符串
        NSString *dataStr =  [GMSm4Utils ecbDecryptText:name key:sm4Key];
//        NSLog(@"dataStr = %@",dataStr);
        NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];

         if (!jsonData) {
                    return nil;
                }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"解压解密dic = %@",dic);
        return dic;
      
    }else
    {
         
            NSString *dataStr =  [GMSm4Utils ecbDecryptText:contentStr key:sm4Key];
//            NSLog(@"dataStr = %@",dataStr);
            NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            if (!jsonData) {
                return nil;
            }
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//            NSLog(@"未解压解密dic = %@", dic);
            return dic;
    }
    
}

//64解码
+ (NSData *)resultNSdataToBase64:(NSString *)baseStr
{
    // Base64解码
    NSData *data = [[NSData alloc]initWithBase64EncodedString:baseStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
    
}




//#pragma mark-ANT路径识别
//- (BOOL)doMatchPattern:(NSString*)pattern path:(NSString*)path fullMatch:(BOOL)fullMatch
//{
//
//    if ([path hasPrefix:pathSeparator] !=  [pattern hasPrefix:pathSeparator]) {
//       return false;
//    }
//
//    NSArray *pattDirs = [pattern componentsSeparatedByString:pathSeparator];
//    NSArray *pathDirs = [path componentsSeparatedByString:pathSeparator];
//
//
//    NSInteger pattIdxStart = 0;
//    NSInteger pattIdxEnd = pattDirs.count - 1;
//    NSInteger pathIdxStart = 0;
//    NSInteger pathIdxEnd = pathDirs.count - 1;
//
//
//    // Match all elements up to the first **
//    while (pattIdxStart <= pattIdxEnd && pathIdxStart <= pathIdxEnd)
//    {
//        NSString* patDir = pattDirs[pattIdxStart];
//
//        if ([@"**" isEqualToString:patDir]) {
//            break;
//        }
//
//        if (![self matchStrings:patDir str:pathDirs[pathIdxStart]]) {
//            return NO;
//        }
//        pattIdxStart++;
//        pathIdxStart++;
//
//    }
//
//
//    if (pathIdxStart > pathIdxEnd) {
//         // Path is exhausted, only match if rest of pattern is * or **'s
//         if (pattIdxStart > pattIdxEnd)
//         {
//
//             return ( [pattern hasSuffix:pathSeparator] ?
//                     [path hasSuffix:pathSeparator] :![path hasSuffix:pathSeparator]);
//         }
//         if (!fullMatch) {
//             return YES;
//         }
//
//        if (pattIdxStart == pattIdxEnd && [pattDirs[pattIdxStart] isEqualToString:@"*"] && [path hasSuffix:pathSeparator]) {
//             return true;
//        }
//
//        for (NSInteger i = pattIdxStart; i < pattIdxEnd; ++i) {
//            if (![pattDirs[i] isEqualToString:@"**"]) {
//                return NO;
//            }
//
//        }
//
//         return YES;
//     } else if (pattIdxStart > pattIdxEnd)
//     {
//         // String not exhausted, but pattern is. Failure.
//         return NO;
//
//     } else if (!fullMatch && [@"" isEqualToString:pattDirs[pattIdxStart]])
//     {
//         // Path start definitely matches due to "**" part in pattern.
//         return YES;
//     }
//
//
//        // up to last '**'
//        while (pattIdxStart <= pattIdxEnd && pathIdxStart <= pathIdxEnd) {
//        NSString* patDir = pattDirs[pattIdxEnd];
//
//        if ([patDir isEqualToString:@"**"])
//        {
//           break;
//        }
//
//        if (![self matchStrings:patDir str:pathDirs[pathIdxEnd]])
//        {
//           return NO;
//        }
//        pattIdxEnd--;
//        pathIdxEnd--;
//        }
//        if (pathIdxStart > pathIdxEnd) {
//        // String is exhausted
//        for (NSInteger i = pattIdxStart; i <= pattIdxEnd; i++)
//        {
//
//           if (! [pattDirs[i] isEqualToString:@"**"]) {
//               return NO;
//           }
//        }
//        return YES;
//        }
//
//    while (pattIdxStart != pattIdxEnd && pathIdxStart <= pathIdxEnd) {
//               NSInteger patIdxTmp = -1;
//               for (NSInteger i = pattIdxStart + 1; i <= pattIdxEnd; i++)
//               {
//
//                   if ([pattDirs[i] isEqualToString:@"**"])
//                   {
//                       patIdxTmp = i;
//                       break;
//                   }
//               }
//               if (patIdxTmp == pattIdxStart + 1) {
//                   // '**/**' situation, so skip one
//                   pattIdxStart++;
//                   continue;
//               }
//               // Find the pattern between padIdxStart & padIdxTmp in str between
//               // strIdxStart & strIdxEnd
//               NSInteger patLength = (patIdxTmp - pattIdxStart - 1);
//               NSInteger strLength = (pathIdxEnd - pathIdxStart + 1);
//               NSInteger foundIdx = -1;
//
//               strLoop:
//               for (int i = 0; i <= strLength - patLength; i++)
//                {
//                   for (int j = 0; j < patLength; j++) {
//                       NSString*subPat = (NSString*) pattDirs[pattIdxStart + j + 1];
//                       NSString* subStr = (NSString*) pathDirs[pathIdxStart + i + j];
//
//                       if (![self matchStrings:subPat str:subStr]) {
//                           goto  strLoop;
//                       }
//                   }
//                   foundIdx = pathIdxStart + i;
//                   break;
//               }
//
//               if (foundIdx == -1) {
//                   return NO;
//               }
//
//               pattIdxStart = patIdxTmp;
//               pathIdxStart = foundIdx + patLength;
//           }
//
//    for (int i = pattIdxStart; i <= pattIdxEnd; i++)
//    {
//
//        if (![pattDirs[i] isEqualToString:@"**"]) {
//            return NO;
//        }
//    }
//
//    return YES;
//}
//
//
//
//
//
//
//- (BOOL)matchStrings:(NSString*)pattern  str:(NSString*)str
//{
//
//    unsigned char patArr[pattern.length];
//    memcpy(patArr, [pattern cStringUsingEncoding:NSUTF8StringEncoding], pattern.length);
//
//
//    unsigned char strArr[str.length];
//       memcpy(strArr, [str cStringUsingEncoding:NSUTF8StringEncoding], str.length);
//
//        NSInteger patIdxStart = 0;
//        NSInteger patIdxEnd = sizeof(patArr) - 1;
//        NSInteger strIdxStart = 0;
//        NSInteger strIdxEnd = sizeof(strArr) - 1;
//        char ch;
//
//        BOOL containsStar = NO;
//
//    for (int i = 0; i < sizeof(patArr); i++) {
//
//        if ( patArr[i] == '*') {
//           containsStar = true;
//           break;
//        }
//
//    }
//
//
//        if (!containsStar) {
//            // No '*'s, so we make a shortcut
//            if (patIdxEnd != strIdxEnd) {
//                return NO; // Pattern and string do not have the same size
//            }
//            for (int i = 0; i <= patIdxEnd; i++) {
//                ch = patArr[i];
//                if (ch != '?') {
//                    if (ch != strArr[i]) {
//                        return NO;// Character mismatch
//                    }
//                }
//            }
//            return YES; // String matches against pattern
//        }
//
//
//        if (patIdxEnd == 0) {
//            return YES; // Pattern contains only '*', which matches anything
//        }
//
//        // Process characters before first star 先找到不是*的位置开始，进行原始的比较
//        while ((ch = patArr[patIdxStart]) != '*' && strIdxStart <= strIdxEnd) {
//            if (ch != '?') {
//                if (ch != strArr[strIdxStart]) {
//                    return NO;// Character mismatch
//                }
//            }
//            patIdxStart++;
//            strIdxStart++;
//        }
//        if (strIdxStart > strIdxEnd) {
//            // All characters in the string are used. Check if only '*'s are
//            // left in the pattern. If so, we succeeded. Otherwise failure.
//            for (NSInteger i = patIdxStart; i <= patIdxEnd; i++) {
//                if (patArr[i] != '*') {
//                    return NO;
//                }
//            }
//            return YES;
//        }
//
//        // Process characters after last star
//        while ((ch = patArr[patIdxEnd]) != '*' && strIdxStart <= strIdxEnd) {
//            if (ch != '?') {
//                if (ch != strArr[strIdxEnd]) {
//                    return NO;// Character mismatch
//                }
//            }
//            patIdxEnd--;
//            strIdxEnd--;
//        }
//        if (strIdxStart > strIdxEnd) {
//            // All characters in the string are used. Check if only '*'s are
//            // left in the pattern. If so, we succeeded. Otherwise failure.
//            for (NSInteger i = patIdxStart; i <= patIdxEnd; i++) {
//                if (patArr[i] != '*') {
//                    return NO;
//                }
//            }
//            return YES;
//        }
//
//        // process pattern between stars. padIdxStart and patIdxEnd point
//        // always to a '*'.
//        while (patIdxStart != patIdxEnd && strIdxStart <= strIdxEnd) {
//            NSInteger patIdxTmp = -1;
//            for (NSInteger i = patIdxStart + 1; i <= patIdxEnd; i++) {
//                if (patArr[i] == '*') {
//                    patIdxTmp = i;
//                    break;
//                }
//            }
//            if (patIdxTmp == patIdxStart + 1) {
//                // Two stars next to each other, skip the first one.
//                patIdxStart++;
//                continue;
//            }
//            // Find the pattern between padIdxStart & padIdxTmp in str between
//            // strIdxStart & strIdxEnd
//             // Find the pattern between padIdxStart & padIdxTmp in str between
//                       // strIdxStart & strIdxEnd
//           NSInteger patLength = (patIdxTmp - patIdxStart - 1);
//           NSInteger strLength = (strIdxEnd - strIdxStart + 1);
//           NSInteger foundIdx = -1;
//
//         strLoop:  for (NSInteger i = 0; i <= (strLength - patLength); i++)
//           {
//               for (NSInteger j = 0; j < patLength; j++)
//               {
//                   ch = patArr[patIdxStart + j + 1];
//                   if (ch != '?') {
//                       if (ch != strArr[strIdxStart + i + j]) {
//                           goto strLoop;
//                       }
//                   }
//               }
//
//               foundIdx = strIdxStart + i;
//               break;
//           }
//
//            if (foundIdx == -1) {
//                return NO;
//            }
//
//            patIdxStart = patIdxTmp;
//            strIdxStart = foundIdx + patLength;
//        }
//
//        // All characters in the string are used. Check if only '*'s are left
//        // in the pattern. If so, we succeeded. Otherwise failure.
//        for (NSInteger i = patIdxStart; i <= patIdxEnd; i++) {
//            if (patArr[i] != '*') {
//                return NO;
//            }
//        }
//
//        return true;
//
//}



+(void)uploadFileWithShortUrl:(NSString *)shortUrl hud:(UIView *)view serviceName:(NSDictionary *)serviceDic uploadImage:(UIImage *)img postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode

{

    if ([self isConnectionAvailable:SubBaseUrl] == NO) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",@"网络不能连接到服务器"]];
        [MBProgressHUD hideHUDForView:view animated:YES];
        return;
    }
    if(!serviceDic)
    {
         [MBProgressHUD showError:@"请求参数错误"];
         [MBProgressHUD hideHUDForView:view animated:YES];
      
        return;
    }
    
    NSError *SerialError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serviceDic options:NSJSONWritingPrettyPrinted error:&SerialError];
    if (SerialError) {
        NSLog(@"\ndict-json:%@",SerialError);
    }

    
    NSString *timeStamp = [[NSString alloc] init];
    timeStamp = [self getCurrentTimestamp];
    NSString *randomStr = [[NSString alloc] init];
    randomStr = [self randomStringWithLen:30];
    NSString *signStr = [[NSString alloc] init];
    /**签名**/
    signStr = [self signCalc:KAppDelegate.pubAppkey getTimeStamp:timeStamp nonce:randomStr bodyDict:nil];
    NSString *str_urlA = BaseUrl;
    NSString *str_url = [str_urlA stringByAppendingFormat:@"%@?appKey=%@&timestamp=%@&nonce=%@&sign=%@",shortUrl,KAppDelegate.pubAppkey,timeStamp,randomStr,signStr];

    NSURL *url = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
   
  //UIImage *img = [UIImage imageNamed:@"敬请期待.png"]; //debug
    NSData *imageData;
    NSString *imageFormat;
    if (UIImagePNGRepresentation(img) != nil) {
        imageFormat = @"Content-Type: image/png \r\n";
//        imageData = UIImagePNGRepresentation(img);
        imageData = UIImageJPEGRepresentation(img, 1.0);
        
    }else{
        imageFormat = @"Content-Type: image/jpeg \r\n";
//         imageData = UIImagePNGRepresentation(img);
        imageData = UIImageJPEGRepresentation(img, 1.0);
     
    }

    //图片名称
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat =@"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    #pragma mark -[NSUUID UUID] UUIDString]可能为空
    NSString *fileName;
    if([[NSUUID UUID] UUIDString].length>=8)
    {
         fileName = [NSString stringWithFormat:@"%@%@", str, [[[NSUUID UUID] UUIDString] substringToIndex:8]];
    }else
    {
        fileName = [NSString stringWithFormat:@"%@%@", str, [self randomStringWithLen:8]];
    }
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[self getDataWithString:@"--BOUNDARY\r\n" ]];
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.png\"\r\n",@"file",fileName];
    [body appendData:[self getDataWithString:disposition]];
    [body appendData:[self getDataWithString:imageFormat]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:imageData];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"--BOUNDARY\r\n" ]];
    NSString *dispositions = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",@"serviceName"];
    [body appendData:[self getDataWithString:dispositions ]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"cases"]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"--BOUNDARY--\r\n"]];
    request.HTTPBody = body;
    
    NSInteger length = [body length];
    [request setValue:[NSString stringWithFormat:@"%ld",(long)length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"multipart/form-data; boundary=BOUNDARY" forHTTPHeaderField:@"Content-Type"];
    NSString *head2 = [NSString stringWithFormat:@"%@", KAppDelegate.pubDeviceNumber];
    [request setValue:head2 forHTTPHeaderField:@"deviceNumber"];
    NSString *head3 = [NSString stringWithFormat:@"%@", KAppDelegate.pubAcessToken];
    [request setValue:head3 forHTTPHeaderField:@"accessToken"];
    
    request.timeoutInterval = 30;
    request.cachePolicy = 1;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        
        if (data == nil || [data isEqual:[NSNull null]]  )//没有数据
        {
           dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"error url = %@",shortUrl);
                    [MBProgressHUD showError:@"请求失败"];
                    [MBProgressHUD hideHUDForView:view animated:YES];
                    failCode(@"0");
                }];
           });

        }
        else//有数据
        {
            
            NSError *retError = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&retError];
          if (jsonObject != nil && retError == nil) //json不为空
          {
            NSLog(@"\n\n\nJson Ok");
            if ([jsonObject isKindOfClass:[NSDictionary class]])//是不是字典
            {
                NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                NSString *resultCode = deserializedDictionary[@"code"];
                if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            if (postSuccess) {
                                if(deserializedDictionary != nil && ![deserializedDictionary isKindOfClass:[NSURL class]])
                                {
                                    NSLog(@"上传成功");
                                     postSuccess(deserializedDictionary);
                                }else
                                {
                                    postSuccess([NSDictionary new]);
                                }
                               
                            }
                        }];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                            [MBProgressHUD hideHUDForView:view animated:YES];
                            failCode([NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]);
                        }];
                    });
                }
                
            }else if([jsonObject isKindOfClass:[NSArray class]])
            {
                NSArray *deserializedArray = (NSArray *)jsonObject;
                NSLog(@"\n\n\nJson is Arr = %@", deserializedArray);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedArray]];
                        [MBProgressHUD hideHUDForView:view animated:YES];
                        failCode([NSString stringWithFormat:@"%@",deserializedArray]);
                        
                    }];

                });
                
            } else
            {
                NSLog(@"\n\n\nJson isn't Dict+Arr = %@", jsonObject);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",jsonObject]];
                        [MBProgressHUD hideHUDForView:view animated:YES];
                        failCode([NSString stringWithFormat:@"%@",jsonObject]);
                    }];

                });
            }
        } else if (jsonData == nil)
        {
             NSLog(@"不是json 需要解密或者解压");
             NSString *result = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"result = %@",result);
             
             NSDictionary *deserializedDictionary = [self  decryptSM4:result];
             NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
             NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
             if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"])
             {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                         if (postSuccess)
                         {
                             
                            if(deserializedDictionary != nil && ![deserializedDictionary isKindOfClass:[NSURL class]])
                            {
                                NSLog(@"上传成功");
                                 postSuccess(deserializedDictionary);
                            }else
                            {
                                postSuccess([NSDictionary new]);
                            }
                         }
                  }];
            
              });
            }
            else
            {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                         [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                         NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);

                         NSLog(@"error url = %@",shortUrl);
                         [MBProgressHUD hideHUDForView:view animated:YES];
                         
                         failCode([NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]);
                         
                     }];
                 });
           }
        
        }else if (retError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",retError]];
                    [MBProgressHUD hideHUDForView:view animated:YES];
                    failCode([NSString stringWithFormat:@"%@",retError]);
                    
                }];
            });
        }
             
        }
    }];
    [task resume];
}


+ (NSString *)hexStringFromString:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    //下面是Byte转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++){
        @autoreleasepool {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}





+(void)uploadFileWithShortUrl:(NSString *)shortUrl hud:(UIView *)view serviceName:(NSDictionary *)serviceDic uploadData:(NSData *)data typeStr:(NSString*)type postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode

{

    if ([self isConnectionAvailable:SubBaseUrl] == NO) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",@"网络不能连接到服务器"]];
        [MBProgressHUD hideHUDForView:view animated:YES];
        return;
    }
    if(!serviceDic)
    {
         [MBProgressHUD showError:@"请求参数错误"];
         [MBProgressHUD hideHUDForView:view animated:YES];
      
        return;
    }
    
    NSError *SerialError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serviceDic options:NSJSONWritingPrettyPrinted error:&SerialError];
    if (SerialError) {
        NSLog(@"\ndict-json:%@",SerialError);
    }

    
    NSString *timeStamp = [[NSString alloc] init];
    timeStamp = [self getCurrentTimestamp];
    NSString *randomStr = [[NSString alloc] init];
    randomStr = [self randomStringWithLen:30];
    NSString *signStr = [[NSString alloc] init];
    /**签名**/
    signStr = [self signCalc:KAppDelegate.pubAppkey getTimeStamp:timeStamp nonce:randomStr bodyDict:nil];
    NSString *str_urlA = BaseUrl;
    NSString *str_url = [str_urlA stringByAppendingFormat:@"%@?appKey=%@&timestamp=%@&nonce=%@&sign=%@",shortUrl,KAppDelegate.pubAppkey,timeStamp,randomStr,signStr];

    NSURL *url = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
   
  //UIImage *img = [UIImage imageNamed:@"敬请期待.png"]; //debug
    NSData *imageData;
    NSString *imageFormat;
//    if (UIImagePNGRepresentation(img) != nil) {
//        imageFormat = @"Content-Type: image/png \r\n";
//
//        imageData = UIImageJPEGRepresentation(img, 1.0);
//
//    }else{
//        imageFormat = @"Content-Type: image/jpeg \r\n";
//        imageData = UIImageJPEGRepresentation(img, 1.0);
//
//    }
    imageFormat = @"Content-Type: multipart/form-data \r\n";
    imageData = data;

    //图片名称
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat =@"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    #pragma mark -[NSUUID UUID] UUIDString]可能为空
    NSString *fileName;
    if([[NSUUID UUID] UUIDString].length>=8)
    {
         fileName = [NSString stringWithFormat:@"%@%@", str, [[[NSUUID UUID] UUIDString] substringToIndex:8]];
    }else
    {
        fileName = [NSString stringWithFormat:@"%@%@", str, [self randomStringWithLen:8]];
    }
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[self getDataWithString:@"--BOUNDARY\r\n" ]];
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.%@\"\r\n",@"file",fileName,type];
    [body appendData:[self getDataWithString:disposition]];
    [body appendData:[self getDataWithString:imageFormat]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:imageData];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"--BOUNDARY\r\n" ]];
    NSString *dispositions = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",@"serviceName"];
    [body appendData:[self getDataWithString:dispositions ]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"cases"]];
    [body appendData:[self getDataWithString:@"\r\n"]];
    [body appendData:[self getDataWithString:@"--BOUNDARY--\r\n"]];
    request.HTTPBody = body;
    
    NSInteger length = [body length];
    [request setValue:[NSString stringWithFormat:@"%ld",(long)length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"multipart/form-data; boundary=BOUNDARY" forHTTPHeaderField:@"Content-Type"];
    NSString *head2 = [NSString stringWithFormat:@"%@", KAppDelegate.pubDeviceNumber];
    [request setValue:head2 forHTTPHeaderField:@"deviceNumber"];
    NSString *head3 = [NSString stringWithFormat:@"%@", KAppDelegate.pubAcessToken];
    [request setValue:head3 forHTTPHeaderField:@"accessToken"];
    
    request.timeoutInterval = 30;
    request.cachePolicy = 1;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        
        if (data == nil || [data isEqual:[NSNull null]]  )//没有数据
        {
           dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"error url = %@",shortUrl);
                    [MBProgressHUD showError:@"请求失败"];
                    [MBProgressHUD hideHUDForView:view animated:YES];
                    failCode(@"0");
                }];
           });

        }
        else//有数据
        {
            
            NSError *retError = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&retError];
          if (jsonObject != nil && retError == nil) //json不为空
          {
            NSLog(@"\n\n\nJson Ok");
            if ([jsonObject isKindOfClass:[NSDictionary class]])//是不是字典
            {
                NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
                NSString *resultCode = deserializedDictionary[@"code"];
                if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            if (postSuccess) {
                                if(deserializedDictionary != nil && ![deserializedDictionary isKindOfClass:[NSURL class]])
                                {
                                    NSLog(@"上传成功");
                                     postSuccess(deserializedDictionary);
                                }else
                                {
                                    postSuccess([NSDictionary new]);
                                }
                               
                            }
                        }];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                            [MBProgressHUD hideHUDForView:view animated:YES];
                            failCode([NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]);
                        }];
                    });
                }
                
            }else if([jsonObject isKindOfClass:[NSArray class]])
            {
                NSArray *deserializedArray = (NSArray *)jsonObject;
                NSLog(@"\n\n\nJson is Arr = %@", deserializedArray);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedArray]];
                        [MBProgressHUD hideHUDForView:view animated:YES];
                        failCode([NSString stringWithFormat:@"%@",deserializedArray]);
                        
                    }];

                });
                
            } else
            {
                NSLog(@"\n\n\nJson isn't Dict+Arr = %@", jsonObject);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",jsonObject]];
                        [MBProgressHUD hideHUDForView:view animated:YES];
                        failCode([NSString stringWithFormat:@"%@",jsonObject]);
                    }];

                });
            }
        } else if (jsonData == nil)
        {
             NSLog(@"不是json 需要解密或者解压");
             NSString *result = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"result = %@",result);
             
             NSDictionary *deserializedDictionary = [self  decryptSM4:result];
             NSLog(@"\n\n\nJson-Dict = %@", deserializedDictionary);
             NSString *resultCode = [NSString stringWithFormat:@"%@",deserializedDictionary[@"code"]];
             if ([resultCode isEqualToString:@"1000000"] || [resultCode isEqualToString:@"1"] || [resultCode isEqualToString:@"200"])
             {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                         if (postSuccess)
                         {
                             
                            if(deserializedDictionary != nil && ![deserializedDictionary isKindOfClass:[NSURL class]])
                            {
                                NSLog(@"上传成功");
                                 postSuccess(deserializedDictionary);
                            }else
                            {
                                postSuccess([NSDictionary new]);
                            }
                         }
                  }];
            
              });
            }
            else
            {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                         [MBProgressHUD showError:[NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]];
                         NSLog(@"error message = %@",[deserializedDictionary[@"message"] stringByRemovingPercentEncoding]);

                         NSLog(@"error url = %@",shortUrl);
                         [MBProgressHUD hideHUDForView:view animated:YES];
                         
                         failCode([NSString stringWithFormat:@"%@",deserializedDictionary[@"message"]]);
                         
                     }];
                 });
           }
        
        }else if (retError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",retError]];
                    [MBProgressHUD hideHUDForView:view animated:YES];
                    failCode([NSString stringWithFormat:@"%@",retError]);
                    
                }];
            });
        }
             
        }
    }];
    [task resume];
}


@end
