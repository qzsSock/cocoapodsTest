//
//  NSStringEx.m
//  WeAct
//
//  Created by by Heliulin on 15/3/26.
//  Copyright (c) 2015年 上海翔汇网络技术有限公司. All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (Extension)



- (NSString*) sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

-(NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (CGSize) sizeWithFontSize:(UIFont*)font andMaxWidth:(CGFloat)maxWidth andMaxHeight:(CGFloat)maxHeight
{
    NSDictionary *attribute=@{NSFontAttributeName:font};
    CGRect contentRect=[self boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil];
    CGSize contentSize=CGSizeMake(contentRect.size.width, contentRect.size.height+2);
    return contentSize;
}

- (NSDictionary*) toDictionary
{
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSObject *object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSDictionary *dic=(NSDictionary*)object;
    return dic;
}

#pragma mark 计算字符串大小
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName: font};
    CGSize textSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return textSize;
}




//判断空
+(BOOL) isNULLString:(NSString *)string
{
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if (string == nil || string == NULL ) {
        return YES;
    }
   
    if ([string isEqualToString:@""] || [string isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([string isEqualToString:@"(null)"]||[string isEqualToString:@"<null>"] || [string isEqualToString:@"null"]) {
        return YES;
    }
    if (string.length==0) {
        return YES;
    }
    return NO;
}


+(NSString*)judgeNullWithStr:(NSString*)str
{
  return [NSString isNULLString:str] ? @"":str;
}


- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize resultSize = CGSizeZero;
    if (self.length <= 0) {
        return resultSize;
    }
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    resultSize = [self boundingRectWithSize:CGSizeMake(floor(size.width), floor(size.height))//用相对小的 width 去计算 height / 小 heigth 算 width
                                    options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                 attributes:@{NSFontAttributeName: font,
                                              NSParagraphStyleAttributeName: style}
                                    context:nil].size;
    resultSize = CGSizeMake(floor(resultSize.width + 1), floor(resultSize.height + 1));//上面用的小 width（height） 来计算了，这里要 +1
    return resultSize;
}
@end
