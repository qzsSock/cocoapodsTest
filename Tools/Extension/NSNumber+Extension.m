//
//  NSNumber+Extension.m
//  Procuratorate
//
//  Created by 邱子硕 on 2020/7/31.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "NSNumber+Extension.h"

@implementation NSNumber (Extension)


- (BOOL)isEqualToString:(NSString*)str
{
    NSString*num = [NSString stringWithFormat:@"%@",self];
  
    return [num isEqualToString:str];
}

@end
