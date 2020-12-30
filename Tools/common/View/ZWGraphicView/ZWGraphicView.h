//
//  ZWGraphicView.h
//  TestDemo
//
//  Created by xzw on 16/10/26.
//  Copyright © 2016年 xzw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWGraphicView : UIView
{
    CGPoint _start;//起始点
    CGPoint _move;//移动点
    NSMutableArray * _pathArray;//保存路径信息
    CGFloat _lineWidth;//线宽
    UIColor * _lineColor;//线的颜色
    CGMutablePathRef _path;
//    BOOL _isDrawLine;
}
@property (nonatomic,strong)UILabel *line;
@property (nonatomic,strong)UILabel *signature;
@property (nonatomic,strong)UIView *backgroundView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UILabel *addressLabel;
@property (nonatomic,strong)UIImageView *nextImage;

@property (nonatomic,assign)BOOL isDrawLine;


/**
 *  线宽
 */
@property (nonatomic,assign) CGFloat  lineWidth;
/**
 *  线的颜色
 */
@property (nonatomic,strong) UIColor * lineColor;
/**
 *  画线路径
 */
@property (nonatomic,strong) NSMutableArray * pathArray;
/**
 *  获取画图
 */
-(UIImage*)getDrawingImg;

/**
 *  清空画板
 */
-(void)clearDrawBoard;

/**
 *  撤销上一次操作
 */
-(void)undoLastDraw;

/**
 *  保存图像至相册
 */
-(void)savePhotoToAlbum;


@end
