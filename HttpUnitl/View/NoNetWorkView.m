//
//  NoNetWorkView.m
//  Procuratorate
//
//  Created by luojiao on 2020/1/7.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "NoNetWorkView.h"

@implementation NoNetWorkView


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
    netImg.image = [UIImage imageNamed:@"net"];
    [self addSubview:netImg];
    [netImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).multipliedBy(0.7);
        make.centerX.equalTo(self.mas_centerX);
        make.height.mas_equalTo(180);
        make.width.mas_equalTo(250);
    }];
    
    UILabel *showLabel = [[UILabel alloc] init];
    showLabel.text = @"网络信号貌似不太好";
    showLabel.font = [UIFont systemFontOfSize:15];
    showLabel.textColor = RGB(184, 187, 189);
    [self addSubview:showLabel];
    [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(netImg.mas_bottom).mas_offset(0);
        
    }];
    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setTitle:@"重新加载" forState:UIControlStateNormal];
    [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    refreshButton.backgroundColor = RGB(74, 119, 242);
    refreshButton.layer.masksToBounds = YES;
    refreshButton.layer.cornerRadius = 5.0;
    [refreshButton addTarget:self action:@selector(refreButotn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:refreshButton];
    [refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(showLabel.mas_bottom).mas_offset(10);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
    
}

//刷新网络
-(void)refreButotn{
    self.refreshButtonClick();
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
