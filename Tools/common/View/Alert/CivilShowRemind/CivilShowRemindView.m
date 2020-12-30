//
//  CivilShowRemindView.m
//  Procuratorate
//
//  Created by 邱子硕 on 2020/9/10.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#define TIMECOUNT 15

#import "CivilShowRemindView.h"

@implementation CivilShowRemindView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithHexString:@"#5D5F5F" alpha:0.7];
//        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
//        [self addGestureRecognizer:tap];
        
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(20, kNaHeight+40, kScreenW-40, kScreenH-40-kNaHeight-kNaHeight)];
        self.backView.backgroundColor = [UIColor whiteColor];
        self.backView.layer.cornerRadius = 12;
        [self addSubview:self.backView];
        
        self.name = [UILabel initWithtextColor:[UIColor colorWithHexString:@"#151E26"] font:17 textAlignment:NSTextAlignmentCenter numberOfLines:1 text:@"申请民事检察监督告知书"];
        self.name.font = [UIFont systemFontOfSize:17 weight:1.3];
        [self.backView addSubview:self.name];
        
        self.sure = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sure.userInteractionEnabled = NO;
       
        [self.sure setTitle:@"确定" forState:UIControlStateNormal];
        [self.sure addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
//        [self.sure setTitleColor:[UIColor colorWithHexString:@"#4074E6"] forState:UIControlStateNormal];
        [self.sure setTitleColor:[UIColor colorWithHexString:@"#AAAAAA"] forState:UIControlStateNormal];
        [self.backView addSubview:self.sure];
        
        
       
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor colorWithHexString:@"#E7E8E9"];
        [self.backView addSubview:self.line];
       
        
       NSString*str = @"一、当事人或诉讼代理人向人民检察院申请监督应当遵循诚信原则，如实陈述事实，有意捏造、歪曲事实的应当承担相应的法律责任。同意进入申请监督页面后，在本平台发表的所有文字、语音、视频、图片均视为本人操作，由本人承担相应的法律责任。\n二、通过本平台向人民检察院申请监督与线下通过快递、信函或直接到人民检察院申请监督具有相同效力，线上电子签名与线下签名具有同等效力\n三、当事人及其诉讼代理人可通过平台联系检察官、提供证据、参与听证、调解\n四、当事人及其诉讼代理人进入平台后的言行应合法，不得发表与申请监督的案件无关的言论、视频、图片等。对在本平台所形成的文字、语音、视频、图片等内容不得用于与申请监督事项无关的任何其他用途，不得外传、扩散、截屏、转发他人\n五、当事人及其诉讼代理人应保持手机畅通，若在申请监督期间发生手机遗失、微信被盗等特殊情形时，应及时告知承办人，并采取补救措施，在此期间所产生的一切法律后果均由当事人本人承担。\n附：民事检察监督案件类型及注意事项\n一、对生效判决、裁定、调解书的监督\n1、根据《中华人民共和国民事诉讼法》、《人民检察院民事诉讼监督规则（试行）》相关规定，当事人对人民法院生效的民事判决、裁定、调解书不服的，可以向人民检察院申请监督\n2、当事人应当就生效的民事判决、裁定、调解书先向人民法院申请再审，在人民法院作出驳回再审裁定或人民法院超过三个月未对再审申请作出裁定情形下，再向人民检察院申请监督。如系对人民法院再审判决、裁定、调解书不服的，可直接向人民检察院申请监督\n3、当事人及其诉讼代理人向人民检察院申请监督，应当提交监督申请书、身份证明、相关法律文书及证据材料。提交证据材料的，应当附证据清单。申请监督材料不齐备且在人民检察院通知的期限内仍未补齐的，视为撤回监督申请。\n（一）监督申请书应当记明下列事项：\n1.申请人的姓名、性别、年龄、民族、职业、工作单位、住所、有效联系方式，法人或者其他组织的名称、住所和法定代表人或者主要负责人的姓名、职务、有效联系方式；\n2.其他当事人的姓名、性别、工作单位、住所、有效联系方式等信息，法人或者其他组织的名称、住所、负责人、有效联系方式等信息；\n3.申请监督请求和所依据的事实与理由。\n（二）身份证明包括：\n1.自然人的居民身份证、军官证、士兵证、护照或者公安机关核发的居住、暂住证明等能够证明本人身份的有效证明；\n2.法人或其他组织的营业执照副本、组织机构代码证书和法定代表人或者主要负责人的身份证明等有效证照\n（三）相关法律文书包括人民法院历次审理作出的判决书、裁定书、调解书或在执行活动中作出的裁定书、决定书等。当事人应尽量提供人民法院历次审理的全部案卷材料。\n5、当事人及其诉讼代理人应当向作出生效判决、裁定、调解书的人民法院所在地同级人民检察院申请监督。\n6、人民检察院受理当事人提出的监督申请后，依法对当事人的申请是否符合监督条件进行审查，并结合案件事实和相关法律法规决定是否监督以及监督的方式。人民检察院作出监督决定，并不必然导致案件改判。\n7、人民检察院经审查认为当事人的申请符合监督条件的，将案件处理结果以《通知书》方式告知当事人；不符合监督条件的，作出《不支持监督申请决定书》发送当事人。人民检察院已经审查终结作出决定的案件，当事人再次申请监督的，人民检察院不予受理。\n8、人民检察院受理监督申请并对案件进行审查，不影响人民法院对原生效判决、裁定和调解书的执行。\n二、对审判程序中审判人员违法行为的监督\n1、当事人可以就人民法院审判人员在诉讼中的违法行为向检察机关申请监督。\n2、当事人及其诉讼代理人应当向检察机关提供审判人员违法行为的初步证据。\n3、人民检察院认为当事人申请监督的审判程序中审判人员违法行为存在或者构成的，作出监督决定并将案件处理结果以《通知书》方式告知当事人。人民检察院认为当事人申请监督的审判程序中审判人员违法行为不存在或者不构成的，作出《不支持监督申请决定书》发送当事人。\n三、对执行活动的监督\n1、当事人可就人民法院在民事执行活动中违反法律规定的情形向人民检察院申请监督。\n2、当事人及其诉讼代理人应当向检察机关提供人民法院民事执行活动违法的初步证据。\n3、人民检察院认为当事人申请监督的人民法院执行活动存在违法情形的，作出相应监督决定并将案件处理结果以《通知书》方式告知当事人。人民检察院认为当事人申请监督的人民法院执行活动不存在违法情形的，作出《不支持监督申请决定书》发送当事人。";
        
        self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, kScreenH-40, kScreenH-40-100-kNaHeight*2)];
       CGSize size=   [str sizeWithFont:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(kScreenW-60, MAXFLOAT)];
       
        self.contentView.contentSize = CGSizeMake(0, size.height+30);
        [self.backView addSubview:self.contentView];
        
        self.content = [UILabel initWithtextColor:[UIColor colorWithHexString:@"#303030"] font:14 textAlignment:NSTextAlignmentLeft numberOfLines:0 text:str];
        self.content.numberOfLines =0;
        [self.contentView addSubview:self.content];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self beginTime];
        });
        
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
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(30);
    }];
    
    
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-45);
        make.height.mas_equalTo(1);
    }];
    
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(kScreenW-60);
    
    }];
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    [self hide];
//}



- (void)hide
{
    self.hidden = YES;
    [self removeFromSuperview];
}





//------------***第三种方法***------------
/**
 *  1、获取或者创建一个队列，一般情况下获取一个全局的队列
 *  2、创建一个定时器模式的事件源
 *  3、设置定时器的响应间隔
 *  4、设置定时器事件源的响应回调，当定时事件发生时，执行此回调
 *  5、启动定时器事件
 *  6、取消定时器dispatch源，【必须】
 *
 */
#pragma mark GCD实现
- (void)beginTime{
    __block NSInteger second = TIMECOUNT;
    //(1)
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //(2)
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
    //(3)
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //(4)
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (second == 0) {
                

               
                self.sure.userInteractionEnabled = YES;
                [self.sure setTitleColor:[UIColor colorWithHexString:@"#4074E6"] forState:UIControlStateNormal];
                [self.sure setTitle:@"确定" forState:UIControlStateNormal];
                second = TIMECOUNT;
                //(6)
                dispatch_cancel(timer);
            } else {

                self.sure.userInteractionEnabled = NO;
               
                
//                [self.thirdBtn setTitle:[NSString stringWithFormat:@"%ld秒后重新获取",second] forState:UIControlStateNormal];
                [self.sure setTitle:[NSString stringWithFormat:@"确定 (%zds)",second] forState:UIControlStateNormal];
                [self.sure setTitleColor:[UIColor colorWithHexString:@"#AAAAAA"] forState:UIControlStateNormal];
                second--;
            }
        });
    });
    //(5)
    dispatch_resume(timer);
}
@end
