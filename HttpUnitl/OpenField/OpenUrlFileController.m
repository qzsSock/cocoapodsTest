//
//  LawsBookDetailVC.m
//  Procuratorate
//
//  Created by luojiao on 2020/1/15.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "OpenUrlFileController.h"
#import <QuickLook/QuickLook.h>


@interface OpenUrlFileController ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property (strong, nonatomic) UIProgressView *progressView;

@property (strong, nonatomic) NSURLSession *session;

@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;

@property (strong, nonatomic)QLPreviewController *previewController;


@end

@implementation OpenUrlFileController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.urlStr = @"https://mail.qq.com/cgi-bin/download?mailid=ZL3012-2kdNnUITWxsoHThn8zMxJa8&filename=%C7%F1%D7%D3%CB%B6-iOS.pdf&sid=Ibxtcq3jYCATXXgn";
 

    self.view.backgroundColor = [UIColor whiteColor];
    QLPreviewController *qlVC = [[QLPreviewController alloc]init];
    qlVC.delegate = self;
    qlVC.dataSource = self;
    self.previewController = qlVC;
   

    [self filerExists];
    BOOL isFile = [self fileExistWithName:self.fileName];
    if (isFile) {
        self.progressView.hidden = YES;
        NSString *fileName = [NSString stringWithFormat:@"/DownloadFile/%@",self.fileName];
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
        NSString *path = [document stringByAppendingString:fileName];
        NSLog(@"path = %@",path);
        
       //  file:///private/var
        NSString*url =  [NSString stringWithFormat:@"file:///private%@",path];
        self.fileURL = [NSURL URLWithString:url];
        [self.navigationController pushViewController:self.previewController animated:YES];

        
    } else {
        self.progressView.hidden = NO;
        // 创建下载任务
        self.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:self.urlStr]];
        // 执行任务
        [self.downloadTask resume];
    }
    
    
    
}




//判断下载的文件夹是否存在
-(void)filerExists{
    // 1、获取Document文件夹路径
       NSString * DocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
       
       // 2、创建DownloadImages文件夹
       NSString * downloadImagesPath = [DocumentsPath stringByAppendingPathComponent:@"DownloadFile"];

       // 3、创建文件管理器对象
       NSFileManager * fileManager = [NSFileManager defaultManager];
       
       // 4、判断文件夹是否存在
       if (![fileManager fileExistsAtPath:downloadImagesPath])
       {
           [fileManager createDirectoryAtPath:downloadImagesPath withIntermediateDirectories:YES attributes:nil error:nil];
       }
}
//文件是否下载
-(BOOL)fileExistWithName:(NSString *)name{
    // 取得沙盒目录
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"DownloadFile/%@",name];
    // 要检查的文件目录
    NSString *filePath = [localPath  stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSLog(@"文件%@存在",name);
        return YES;
    }else {
        NSLog(@"文件%@不存在",name);
        return NO;
    }
}



#pragma mark Getters & Setters
- (NSURLSession *)session
{
    if (! _session)
    {
        // 创建会话配置
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // 创建会话
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    
    return _session;
}


#pragma mark Session Download Delegate Method
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.hidden = YES;     // 下载完成后隐藏进度条
        NSString *fileName = [NSString stringWithFormat:@"/DownloadFile/%@",self.fileName];
        // 获取沙盒路径
           NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
           // 写入
           [[NSFileManager defaultManager] createFileAtPath:fullPath contents:data attributes:nil];
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
        NSString *path = [document stringByAppendingString:fileName];
        NSLog(@"path = %@",path);
      
        //  file:///private/var
        NSString*url =  [NSString stringWithFormat:@"file:///private%@",path];
        self.fileURL = [NSURL URLWithString:url];
        [self.navigationController pushViewController:self.previewController animated:YES];
    });
    
    // 销毁会话
    [session finishTasksAndInvalidate];
    session = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // 输出NSLog所在行和方法名称
    NSLog(@"%d %s",__LINE__ ,__PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (double) totalBytesWritten / totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
}





#pragma mark -
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
//    return   [NSURL fileURLWithPath:self.fileURL];
    
    return  self.fileURL;
}

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
    {
        return YES;
    }
    
- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    NSLog(@"previewControllerWillDismiss");
    
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    NSLog(@"previewControllerDidDismiss");
    [self.navigationController popViewControllerAnimated:YES];
}
    

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView * __nullable * __nonnull)view{
//    return CGRectZero;
    return CGRectMake(200, 200, 100, 100);
}

    //签名
//- (QLPreviewItemEditingMode)previewController:(QLPreviewController *)controller editingModeForPreviewItem:(id <QLPreviewItem>)previewItem API_AVAILABLE(ios(13.0))
//{
//    return QLPreviewItemEditingModeCreateCopy;
//
//}

    
    //直接改变原本
//    - (void)previewController:(QLPreviewController *)controller didUpdateContentsOfPreviewItem:(id<QLPreviewItem>)previewItem API_AVAILABLE(ios(13.0))
//    {
//        NSLog(@"didUpdateContentsOfPreviewItem");
//    }
//

    //生成临时文件 不改变原本
//    - (void)previewController:(QLPreviewController *)controller didSaveEditedCopyOfPreviewItem:(id <QLPreviewItem>)previewItem atURL:(NSURL *)modifiedContentsURL API_AVAILABLE(ios(13.0))
//    {
//         NSLog(@"didSaveEditedCopyOfPreviewItem");
//    }
    
    
    


/* 在收到响应后，决定是否跳转 */


- (void)leftBarButtonPressed:(UIButton *)sender
{

   [self.navigationController  popViewControllerAnimated:YES];
      
    
}



@end
