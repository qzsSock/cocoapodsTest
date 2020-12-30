//
//  CivilShowRemindView.h
//  Procuratorate
//
//  Created by 邱子硕 on 2020/9/10.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CivilShowRemindView : UIView
@property (nonatomic,strong) UIView*backView;
@property (nonatomic,strong) UILabel*name;
@property (nonatomic,strong) UILabel*content;
@property (nonatomic,strong) UIScrollView*contentView;

@property (nonatomic,strong) UIButton*sure;
@property (nonatomic,strong) UIView*line;

@end

NS_ASSUME_NONNULL_END
