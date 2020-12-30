//
//  NoDataView.m
//  Procuratorate
//
//  Created by 罗交 on 2020/4/27.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "NoDataView.h"

@implementation NoDataView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatNoNetWorkingView];
    }
    return self;
}

-(void)creatNoNetWorkingView
{
    UIImageView *netImg = [[UIImageView alloc] init];
    netImg.image = [UIImage imageNamed:@"noData"];
    [self addSubview:netImg];
    [netImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).multipliedBy(0.7);
        make.centerX.equalTo(self.mas_centerX);
        make.height.mas_equalTo(180);
        make.width.mas_equalTo(250);
    }];
    
    UILabel *showLabel = [[UILabel alloc] init];
    showLabel.text = @"暂无任何数据";
    showLabel.font = [UIFont systemFontOfSize:15];
    showLabel.textColor = RGB(184, 187, 189);
    [self addSubview:showLabel];
    [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(netImg.mas_bottom).mas_offset(0);
        
    }];
        
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
