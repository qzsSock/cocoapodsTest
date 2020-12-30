//
//  OpenUrlFileController.h
//  Procuratorate
//
//  Created by 邱子硕 on 2020/8/12.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenUrlFileController : UIViewController

//下载的url
@property (nonatomic,copy) NSString *urlStr;
//文件名
@property (nonatomic,copy) NSString *fileName;

@property (nonatomic,strong) NSURL*fileURL;

@end

NS_ASSUME_NONNULL_END
