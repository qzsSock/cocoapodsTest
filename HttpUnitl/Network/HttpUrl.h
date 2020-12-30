//
//  HttpUrl.h
//  Procuratorate
//
//  Created by luojiao on 2019/11/23.
//  Copyright © 2019 zjjcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


NS_ASSUME_NONNULL_BEGIN

typedef void (^postSuccess)(NSDictionary *dict);

typedef void (^postFailure)(NSString *Code);

typedef void (^getHeaderFileSuccess)(NSData *headerData);

@interface HttpUrl : NSObject
{
    MBProgressHUD *_HUD;
}

-(void)showMessageHUD:(NSString *)tipStr;
- (void)hiddenMessageHUD;


+ (id)shareHttpClient;

/** shortUrl ：接口访问连接地址 hud视图 用于显示MBProgressHUD uploadDictionary : 请求参数字典 postSuccess : 返回请求成功结果集**/
+ (void)postWithShortUrl:(NSString *)shortUrl hud:(UIView *)hud uploadDictionary:(NSMutableDictionary*) upDictionary postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode;


/// 没有加载框的post请求
/// @param shortUrl url
/// @param upDictionary 参数
/// @param postSuccess 成功回调
/// @param failCode 失败回调
+ (void) postWithUrl:(NSString *)shortUrl  uploadDictionary:(NSMutableDictionary*) upDictionary postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode;

/***图片上传请求 serviceDic 提交到那个服务模块**/ 
+ (void)uploadFileWithShortUrl:(NSString *)shortUrl serviceName:(NSDictionary *)serviceDic uploadImage:(UIImage *)img postSuccess:(postSuccess)postSuccess;

+ (NSString *)getVideoUrl:(NSString *)shortUrl;

//get请求获取天气情况接口
+ (void)getWithShortUrl:(NSString *)shortUrl hud:(UIView *)hud postSuccess:(postSuccess)postSuccess;
//根据头像文件code
+(void)getUserHeaderImgUrl:(NSString *)fileUrl imgInfo:(NSDictionary *)imgDict fileCode:(NSString *)fileCodeStr getFileSuccess:(getHeaderFileSuccess)getSuccess;

//获取加密配置
+ (void) getWithShortUrl:(NSString *)shortUrl hud:(UIView *)hud uploadDictionary:(NSMutableDictionary*) upDictionary postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode;

//上传图片加载框
+ (void)uploadFileWithShortUrl:(NSString *)shortUrl hud:(UIView *)view serviceName:(NSDictionary *)serviceDic uploadImage:(UIImage *)img postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode;



/// 上传文件 data
/// @param shortUrl url
/// @param view 显示加载框的视图
/// @param serviceDic @{@"serviceName":@"common"}
/// @param data 上传文件data
/// @param type 文件类型
/// @param postSuccess 成功回调
/// @param failCode 失败回调
+(void)uploadFileWithShortUrl:(NSString *)shortUrl hud:(UIView *)view serviceName:(NSDictionary *)serviceDic uploadData:(NSData *)data typeStr:(NSString*)type postSuccess:(postSuccess)postSuccess failureCode:(postFailure)failCode;

@end

NS_ASSUME_NONNULL_END
