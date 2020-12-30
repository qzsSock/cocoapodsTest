//
//  OpenFileController.m
//  Procuratorate
//
//  Created by 邱子硕 on 2020/8/6.
//  Copyright © 2020 zjjcy. All rights reserved.
//

#import "OpenFileController.h"
#import <QuickLook/QuickLook.h>

@interface OpenFileController () <QLPreviewControllerDataSource,QLPreviewControllerDelegate>
@property (strong, nonatomic)QLPreviewController *previewController;
@end

@implementation OpenFileController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
//    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    QLPreviewController *qlVC = [[QLPreviewController alloc]init];
    qlVC.delegate = self;
    qlVC.dataSource = self;
    self.previewController = qlVC;
    
    [self.navigationController pushViewController:qlVC animated:YES];
    
    
    
}

#pragma mark -
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
//    return   [NSURL fileURLWithPath:self.fileURL];
    
    return  self.fileURL;
    
  
    
}
- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    NSLog(@"previewControllerWillDismiss");
    
}
- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    NSLog(@"previewControllerDidDismiss");
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item{
    return YES;
}
- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView * __nullable * __nonnull)view{
    return CGRectZero;
}

//- (void)backAction
//{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}



@end
