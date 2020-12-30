//
//  NoNetWorkView.h
//  Procuratorate
//
//  Created by luojiao on 2020/1/7.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoNetWorkView : UIView
//刷新按钮事件
@property(nonatomic,strong) void(^refreshButtonClick)(void);

@end

NS_ASSUME_NONNULL_END
