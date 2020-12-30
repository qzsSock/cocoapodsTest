//
//  ZWGraphicView.m
//  TestDemo
//
//  Created by xzw on 16/10/26.
//  Copyright © 2016年 xzw. All rights reserved.
//

#import "ZWGraphicView.h"

@implementation ZWGraphicView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _start = CGPointMake(0, 0);
        _move = CGPointMake(0, 0);
        _lineWidth = 10;
        _lineColor = [UIColor blackColor];
        _pathArray = [NSMutableArray array];
        self.isDrawLine = NO;
//        [self addSubview:self.line];
        [self addSubview:self.signature];
        [self addSubview:self.backgroundView];
//        [self.backgroundView addSubview:self.nameLabel];
        [self.backgroundView addSubview:self.timeLabel];
//        [self.backgroundView addSubview:self.addressLabel];
//        [self.backgroundView addSubview:self.nextImage];
//        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

//画图
-(void)drawRect:(CGRect)rect
{
    //获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画图
    [self drawPicture:context];
    
}

-(void)drawPicture:(CGContextRef)context
{
    
    if (_pathArray.count)
    {
        
        for (NSArray * attribute in _pathArray) {
            if (attribute.count) {
                //将路径添加到上下文
                CGPathRef pathRef = (__bridge CGPathRef)attribute[0];
                CGContextAddPath(context, pathRef);
                
                //设置上下文属性
                [attribute[1] setStroke];//设置边框颜色
                CGContextSetLineWidth(context, [attribute[2] floatValue]);
                
                //绘制线条
                CGContextDrawPath(context, kCGPathStroke);
            }
            
        }

    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    
    //创建路径
    _path = CGPathCreateMutable();
    
    NSArray * attributeArry = @[(__bridge id)(_path),_lineColor,[NSNumber numberWithFloat:_lineWidth]];
    [_pathArray addObject:attributeArry];//路径及属性数组
    
    _start = [touch locationInView:self];//起始点
    
    CGPathMoveToPoint(_path, NULL, _start.x, _start.y);//将画笔移动到某点
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPathRelease(_path);//释放路径
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch* touch = [touches anyObject];
    _move = [touch locationInView:self];
    NSLog(@"%@ %@",NSStringFromCGPoint(_start),NSStringFromCGPoint(_move));
    if(self.isDrawLine == NO)
    {
        if(_move.x == _start.x  && _move.y == _start.y)
        {
            _move.x +=10;
            _move.y +=10;
        }
    }
    
    
    self.isDrawLine = YES;//确保画板不是空白
    //将点添加到路径上
    CGPathAddLineToPoint(_path, NULL, _move.x, _move.y);
    
   
    
    [self setNeedsDisplay];//自动调用drawRect:(CGRect)rect
    
}


/**
 *  保存图像至相册
 */
-(void)savePhotoToAlbum
{
    if (_pathArray.count) {
        
        UIGraphicsBeginImageContext(self.frame.size);//创建一个基于位图的上下文，并设置当前上下文
        CGContextRef contex = UIGraphicsGetCurrentContext();//获取图形上下文
        UIRectClip(CGRectMake(0, 30, self.frame.size.width, self.frame.size.height-30));
        [self.layer renderInContext:contex];
        
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
        
    }
}

/**
 *  撤销上一次操作
 */
-(void)undoLastDraw
{
    [_pathArray removeLastObject];
    [self setNeedsDisplay];
}

/**
 *  清空画板
 */
-(void)clearDrawBoard
{
    self.isDrawLine = NO;
    [_pathArray removeAllObjects];
    [self setNeedsDisplay];
}

-(UIImage *)getDrawingImg
{
    if (self.isDrawLine) {
        
        if (_pathArray.count) {
//   这个方法是获取模糊图片
//            UIGraphicsBeginImageContext(self.frame.size);
//   这个是获取高清图片
            UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            UIRectClip(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
            [self.layer renderInContext:context];
            
            UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
            return image;
            
        }
    }
    return nil;
}
//-(UILabel *)line
//{
//    if (!_line) {
//        _line = [FactoryUI createLableWithFrame:CGRectMake(19*KDeviceWidth, 395*KDeviceHeight, 173*KDeviceWidth, 0.5*KDeviceHeight) text:nil font:nil];
//        _line.backgroundColor = RGB(218, 222, 230, 1);
//    }
//    return _line;
//}
//-(UILabel *)signature
//{
//    if (!_signature) {
//        _signature = [FactoryUI createLableWithFrame:CGRectMake(200*KDeviceWidth, 390*KDeviceHeight, 170*KDeviceWidth, 10*KDeviceHeight) text:@"sign your signature above here" font:[UIFont systemFontOfSize:11*KDeviceHeight]];
//        _signature.backgroundColor = [UIColor whiteColor];
//        _signature.textColor  = RGB(179, 179, 179, 1);
//    }
//    return _signature;
//}
//-(UIView *)backgroundView
//{
//    if (!_backgroundView) {
//        _backgroundView = [FactoryUI createViewWithFrame:CGRectMake(17.5*KDeviceWidth, 420*KDeviceHeight, 340*KDeviceWidth, 90*KDeviceHeight)];
//        _backgroundView.backgroundColor = RGB(184, 191, 204, 1);
//        _backgroundView.layer.masksToBounds = YES;
//        _backgroundView.layer.cornerRadius = 5*KDeviceHeight;
//        UIImageView *logo = [FactoryUI createImageViewWithFrame:CGRectMake(319*KDeviceWidth, 0, 13*KDeviceWidth, 12*KDeviceHeight) imageName:@"tagHer"];
//        UIImageView *my = [FactoryUI createImageViewWithFrame:CGRectMake(12*KDeviceWidth, 9*KDeviceHeight, 12*KDeviceWidth, 12*KDeviceHeight) imageName:@"sinature_my"];
//        UIImageView *time = [FactoryUI createImageViewWithFrame:CGRectMake(12*KDeviceWidth, 39*KDeviceWidth, 12*KDeviceWidth, 12*KDeviceHeight) imageName:@"calendar"];
//        UIImageView *address = [FactoryUI createImageViewWithFrame:CGRectMake(12*KDeviceWidth, 68*KDeviceHeight, 10*KDeviceWidth, 13*KDeviceHeight) imageName:@"location"];
//        [_backgroundView addSubview:time];
//        [_backgroundView addSubview:my];
//        [_backgroundView addSubview:logo];
//        [_backgroundView addSubview:address];
//    }
//    return _backgroundView;
//}

//-(UILabel *)timeLabel
//{
//    if(!_timeLabel)
//    {
//        _timeLabel = [FactoryUI createLableWithFrame:CGRectMake(28*KDeviceWidth, 30*KDeviceHeight, 300*KDeviceWidth, 30*KDeviceHeight) text:@"2017/10/24 16:30 星期五" font:[UIFont systemFontOfSize:13*KDeviceHeight]];
//        _timeLabel.textAlignment = NSTextAlignmentLeft;
//        _timeLabel.textColor = [UIColor whiteColor];
//        _timeLabel.backgroundColor = RGB(184, 191, 204);
//    }
//    return _timeLabel;
//}
//-(UILabel *)addressLabel
//{
//    if(!_addressLabel)
//    {
//        _addressLabel = [FactoryUI createLableWithFrame:CGRectMake(28*KDeviceWidth, 60*KDeviceHeight, 300*KDeviceWidth, 30*KDeviceHeight) text:@"" font:[UIFont systemFontOfSize:13*KDeviceHeight]];
//        _addressLabel.textAlignment = NSTextAlignmentLeft;
//        _addressLabel.textColor = [UIColor whiteColor];
//        _addressLabel.backgroundColor = RGB(184, 191, 204);
//    }
//    return _addressLabel;
//}

//-(UIImageView *)nextImage
//{
//    if (!_nextImage) {
//        _nextImage = [FactoryUI createImageViewWithFrame:CGRectMake(_backgroundView.frame.size.width - 27*KDeviceWidth, _addressLabel.frame.origin.y + 7*KDeviceHeight , 17*KDeviceWidth, 17*KDeviceHeight) imageName:@"jiantou-baise"];
//    }
//    return _nextImage;
//}

@end
