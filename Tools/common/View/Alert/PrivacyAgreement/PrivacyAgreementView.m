//
//  CivilShowRemindView.m
//  Procuratorate
//
//  Created by 邱子硕 on 2020/9/10.
//  Copyright © 2020 zjjcy. All rights reserved.
//



#import "PrivacyAgreementView.h"

@implementation PrivacyAgreementView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.2];
//        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
//        [self addGestureRecognizer:tap];
        
        self.backView = [[UIView alloc] initWithFrame:CGRectMake((kScreenW-305)/2, (kScreenH-420)/2, 305, 440)];
        self.backView.backgroundColor = [UIColor whiteColor];
        self.backView.layer.cornerRadius = 12;
        [self addSubview:self.backView];
        
        self.name = [UILabel initWithtextColor:[UIColor colorWithHexString:@"#151E26"] font:17 textAlignment:NSTextAlignmentCenter numberOfLines:1 text:@"隐私保护提示"];
        self.name.font = [UIFont systemFontOfSize:17 weight:1.3];
        [self.backView addSubview:self.name];
        
        self.sure = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sure.userInteractionEnabled = YES;
        self.sure.layer.cornerRadius = 22;
        self.sure.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.sure setTitle:@"确定" forState:UIControlStateNormal];
        [self.sure addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        self.sure.backgroundColor = [UIColor colorWithHexString:@"#3963D3"];
        [self.sure setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [self.backView addSubview:self.sure];
        
        
        self.signOut = [UIButton buttonWithType:UIButtonTypeCustom];
        self.signOut.userInteractionEnabled = YES;
        self.signOut.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.signOut setTitle:@"退出" forState:UIControlStateNormal];
        [self.signOut addTarget:self action:@selector(OutClick) forControlEvents:UIControlEventTouchUpInside];
        [self.signOut setTitleColor:[UIColor colorWithHexString:@"#4074E6"] forState:UIControlStateNormal];
        [self.backView addSubview:self.signOut];
       
        self.line = [[UIView alloc] init];
        self.line.hidden = YES;
        self.line.backgroundColor = [UIColor colorWithHexString:@"#E7E8E9"];
        [self.backView addSubview:self.line];
       
        
       NSString*str = @"感谢您信任并使用浙江检察APP！\n我们非常重视您的个人信息和隐私保护。为了更好的保障您的个人权益，在使用我们的产品前，请务必审慎阅读《隐私政策》内的所有条款，我们将严格按照经您同意的条款使用您的个人信息，以便为您提供更好的服务。 \n您点击 \"同意\" 的行为即表示您已阅读完毕并同意以上协议的全部内容。如您同意以上协议内容，请点击 \"同意\" 开始使用我们浙江检察APP。";
        
        self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 45, 275, 270)];
       CGSize size=   [str sizeWithFont:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(275, MAXFLOAT)];
       
        self.contentView.contentSize = CGSizeMake(0, size.height+35);
        [self.backView addSubview:self.contentView];
        
            self.textView = [[UITextView alloc] init];
            self.textView.editable = false;
            self.textView.scrollEnabled = false;
            self.textView.delegate = self;
            [self.contentView addSubview:self.textView];
            //设置段落样式
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            paragraphStyle.lineSpacing = 8.0;//段内行间距
//            paragraphStyle.paragraphSpacing = 5.0;//段落间距
            paragraphStyle.firstLineHeadIndent = 20.0;//段首行缩进
            NSMutableAttributedString *mutAttString = [[NSMutableAttributedString alloc] initWithString:str];
            [mutAttString addAttributes:@{
                                          NSParagraphStyleAttributeName:paragraphStyle,
                                          NSFontAttributeName:[UIFont systemFontOfSize:14]
                                          } range:NSMakeRange(0, mutAttString.length)];
        
            [mutAttString addAttributes:@{
                                          NSForegroundColorAttributeName:[UIColor blueColor],
                                          NSLinkAttributeName:@"abcd://",
                                          NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                          NSUnderlineColorAttributeName:[UIColor blueColor],
                                          } range:NSMakeRange(66, 6)];
            self.textView.attributedText = mutAttString;
        
       
        
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(20);
    }];
    
    [self.sure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-60);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(44);
    }];
    
    [self.signOut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(30);
    }];
    
    
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-45);
        make.height.mas_equalTo(1);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(275);
    
    }];
}




- (void)hide
{
    NSUserDefaults *roleDefault = [NSUserDefaults standardUserDefaults];
    [roleDefault setBool:YES forKey:@"hiddenPrivacyTips"];
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)OutClick
{
//    NSUserDefaults *roleDefault = [NSUserDefaults standardUserDefaults];
//    [roleDefault setBool:NO forKey:@"hiddenPrivacyTips"];
//
//    exit(0);
    self.hidden = YES;
    UIAlertController *showController = [UIAlertController alertControllerWithTitle:nil message:@"您需要同意本隐私政策才能继续使用" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cloaseAction = [UIAlertAction actionWithTitle:@"仍不同意" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        NSUserDefaults *roleDefault = [NSUserDefaults standardUserDefaults];
        [roleDefault setBool:NO forKey:@"hiddenPrivacyTips"];
        
        exit(0);
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"查看协议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.hidden = NO;
    }];
    [showController addAction:cloaseAction];
    [showController addAction:sureAction];
    [[KAppDelegate getCurrentVC] presentViewController:showController animated:YES completion:nil];
    
    
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
   
    NSLog(@"隐私申明");
    ZixunController *h5staticVC = [[ZixunController alloc] init];
    self.hidden = YES;
    h5staticVC.urlString = [NSString stringWithFormat:@"%@%@",StaticH5Url,@"privacy/agreement.html"];
    h5staticVC.isPresent = YES;
    h5staticVC.hidesBottomBarWhenPushed = YES;
    h5staticVC.type = @"隐私申明";
    h5staticVC.privacyView = self;
    
    h5staticVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [[KAppDelegate getCurrentVC] presentViewController:h5staticVC animated:YES completion:^{
        
    }];

    return NO;//这里返回NO可以避免长按连接弹出actionSheet框
}


@end
