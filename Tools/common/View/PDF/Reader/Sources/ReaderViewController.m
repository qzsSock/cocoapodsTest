//
//	ReaderViewController.m
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2015 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"

#import <MessageUI/MessageUI.h>
#import "SubmitBottom.h"
#import "RemoteNotSignView.h"
#import "PdfGoToSignVC.h"
#import "TYSnapshotScroll.h"
#import <Photos/Photos.h>
#import "NSData+ImageContentType.h"

@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate,
									ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate>

@property (nonatomic,strong) RemoteNotSignView*signView;//未签字时展示的签字视图
@property (nonatomic,strong) UIImageView *signeImage;//已经签过字直接显示图片
@property (nonatomic,strong) SubmitBottom*bottom;//底部提交按钮
@property (nonatomic,strong) NSString *signUrl;//签字的url

@property (nonatomic,assign) CGFloat pdfW;
@property (nonatomic,assign) CGFloat pdfH;

@property (nonatomic,strong) ReaderContentView*currentContentView;

@end

@implementation ReaderViewController
{
	ReaderDocument *document;

	UIScrollView *theScrollView;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;

	NSMutableDictionary *contentViews;

	UIUserInterfaceIdiom userInterfaceIdiom;

	NSInteger currentPage, minimumPage, maximumPage;

	UIDocumentInteractionController *documentInteraction;//转发

	UIPrintInteractionController *printInteraction;

	CGFloat scrollViewOutset;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL ignoreDidScroll;
}

#pragma mark - Constants

//#define STATUS_HEIGHT 20.0f
//#define TOOLBAR_HEIGHT 44.0f

#define TOOLBAR_HEIGHT  ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 88.0 : 64.0)


#define STATUS_HEIGHT ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 44.0 : 20.0)

#define PAGEBAR_HEIGHT 48.0f

#define SCROLLVIEW_OUTSET_SMALL 1.0f
#define SCROLLVIEW_OUTSET_LARGE 1.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark - Properties

@synthesize delegate;

#pragma mark - ReaderViewController methods

- (void)updateContentSize:(UIScrollView *)scrollView
{
	CGFloat contentHeight = scrollView.bounds.size.height; // Height

	CGFloat contentWidth = (scrollView.bounds.size.width * maximumPage);

	scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateContentViews:(UIScrollView *)scrollView
{
    
	[self updateContentSize:scrollView]; // Update content size first

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
		{
			NSInteger page = [key integerValue]; // Page number value

			CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;

			viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X

			contentView.frame = CGRectInset(viewRect, scrollViewOutset, 0.0f);
        
//            DDLogInfo(@"contentView.frame = %@", NSStringFromCGRect(contentView.frame));
		}
	];

	NSInteger page = currentPage; // Update scroll view offset to current page

	CGPoint contentOffset = CGPointMake((scrollView.bounds.size.width * (page - 1)), 0.0f);

	if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false) // Update
	{
		scrollView.contentOffset = contentOffset; // Update content offset
	}

	[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

	[mainPagebar updatePagebar]; // Update page bar
}

- (void)addContentView:(UIScrollView *)scrollView page:(NSInteger)page
{
	CGRect viewRect = CGRectZero;
    viewRect.size = scrollView.bounds.size;

    
	viewRect.origin.x = (viewRect.size.width * (page - 1));
   
#warning 修改不签字
//    if(self.isProcurator)
//    {
//        viewRect.size.height = viewRect.size.height;
//    }else
//    {
//        //未签名底部有签名按钮
//        if ([self.isSign isEqualToString:@"1"]) {
//             viewRect.size.height = viewRect.size.height;
//        }else
//        {
//             viewRect.size.height = viewRect.size.height - 50;
//        }
//    }
//
    
   
    
    viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);

	NSURL *fileURL = document.fileURL;
    NSString *phrase = document.password;
    NSString *guid = document.guid; // Document properties

	ReaderContentView *contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:page password:phrase]; // ReaderContentView
	contentView.message = self;
    [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:page]];
    [scrollView addSubview:contentView];

	[contentView showPageThumb:fileURL page:page password:phrase guid:guid]; // Request page preview thumb
}

- (void)layoutContentViews:(UIScrollView *)scrollView
{
	CGFloat viewWidth = scrollView.bounds.size.width; // View width

	CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X

	NSInteger pageB = ((contentOffsetX + viewWidth - 1.0f) / viewWidth); // Pages

	NSInteger pageA = (contentOffsetX / viewWidth);
    pageB += 2; // Add extra pages
    
	if (pageA < minimumPage) pageA = minimumPage;
    if (pageB > maximumPage) pageB = maximumPage;

	NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];

	for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
	{
		NSInteger page = [key integerValue]; // Page number value

		if ([pageSet containsIndex:page] == NO) // Remove content view
		{
			ReaderContentView *contentView = [contentViews objectForKey:key];

			[contentView removeFromSuperview];
            [contentViews removeObjectForKey:key];
		}
		else // Visible content view - so remove it from page set
		{
			[pageSet removeIndex:page];
		}
	}

	NSInteger pages = pageSet.count;

	if (pages > 0) // We have pages to add
	{
		NSEnumerationOptions options = 0; // Default

		if (pages == 2) // Handle case of only two content views
		{
			if ((maximumPage > 2) && ([pageSet lastIndex] == maximumPage)) options = NSEnumerationReverse;
		}
		else if (pages == 3) // Handle three content views - show the middle one first
		{
			NSMutableIndexSet *workSet = [pageSet mutableCopy]; options = NSEnumerationReverse;

			[workSet removeIndex:[pageSet firstIndex]]; [workSet removeIndex:[pageSet lastIndex]];

			NSInteger page = [workSet firstIndex]; [pageSet removeIndex:page];

			[self addContentView:scrollView page:page];
		}

		[pageSet enumerateIndexesWithOptions:options usingBlock: // Enumerate page set
			^(NSUInteger page, BOOL *stop)
			{
				[self addContentView:scrollView page:page];
			}
		];
	}
}

- (void)handleScrollViewDidEnd:(UIScrollView *)scrollView
{
	CGFloat viewWidth = scrollView.bounds.size.width; // Scroll view width

	CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X

	NSInteger page = (contentOffsetX / viewWidth); page++; // Page number
    
    NSLog(@"111111111 page =  %zd",page);

	if (page != currentPage) // Only if on different page
	{
		currentPage = page;
        document.pageNumber = [NSNumber numberWithInteger:page];

		[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
			^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
			{
				if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
			}
		];

		[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

		[mainPagebar updatePagebar]; // Update page bar
	}
    
    NSLog(@"contentViews = %@",contentViews);
    [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
        ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
        {
           
        
//        contentView
        if([key isEqualToNumber: @(self.signIndex)])
            {
                self.signView.hidden = NO;
                NSLog(@"height = %f",contentView.sizeView.frame.size.height);
                NSLog(@"withd = %f",contentView.sizeView.frame.size.width);
                CGFloat pdfW = contentView.sizeView.frame.size.width;
                CGFloat pdfH = contentView.sizeView.frame.size.height;
                self.pdfW = contentView.sizeView.frame.size.width;
                self.pdfH = contentView.sizeView.frame.size.height;
                [self addSignView:pdfH withd:pdfW addBy:contentView];
               
                
            }else
            {
                if (currentPage != self.signIndex) {
                    self.signView.hidden = YES;
                    self.signView.backgroundColor = [UIColor clearColor];
//                    [self.signView removeFromSuperview];
                }
                                 
            }
        
        }
    ];
   
}

- (void)showDocumentPage:(NSInteger)page
{
	if (page != currentPage) // Only if on different page
	{
		if ((page < minimumPage) || (page > maximumPage)) return;

		currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];

		CGPoint contentOffset = CGPointMake((theScrollView.bounds.size.width * (page - 1)), 0.0f);

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == true)
			[self layoutContentViews:theScrollView];
		else
			[theScrollView setContentOffset:contentOffset];

		[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
			^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
			{
				if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
            
                 
            if([key isEqualToNumber: @(self.signIndex)])
            {
                NSLog(@"height = %f",contentView.sizeView.frame.size.height);
                NSLog(@"withd = %f",contentView.sizeView.frame.size.width);
                self.signView.hidden = NO;
                CGFloat pdfW = contentView.sizeView.frame.size.width;
                CGFloat pdfH = contentView.sizeView.frame.size.height;
                [self addSignView:pdfH withd:pdfW addBy:contentView];
                
            }else
            {
                if (currentPage != self.signIndex) {
                    self.signView.hidden = YES;
                    self.signView.backgroundColor = [UIColor clearColor];
//                    [self.signView removeFromSuperview];
                }
                                 
            }
            
            
			}
		];

		[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

		[mainPagebar updatePagebar]; // Update page bar
	}
}

- (void)showDocument
{
	[self updateContentSize:theScrollView]; // Update content size first
 
#warning 修改不签字
//    if (self.signIndex == 99999) {
//        [self showDocumentPage:[document.pageNumber integerValue]]; // Show page
//    }else
//    {
//        [self showDocumentPage:self.signIndex]; // Show page
//    }
	
    [self showDocumentPage:1]; // Show page

	document.lastOpen = [NSDate date]; // Update document last opened date
}

- (void)closeDocument
{
	if (printInteraction != nil) [printInteraction dismissAnimated:NO];

	[document archiveDocumentProperties]; // Save any ReaderDocument changes

	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];

	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache

	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
	}
	else // We have a "Delegate must respond to -dismissReaderViewController:" error
	{
		NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
	}
}

#pragma mark - UIViewController methods

- (instancetype)initWithReaderDocument:(ReaderDocument *)object
{
	if ((self = [super initWithNibName:nil bundle:nil])) // Initialize superclass
	{
		if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]])) // Valid object
		{
			userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom

			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; // Default notification center

			[notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillTerminateNotification object:nil];

			[notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillResignActiveNotification object:nil];

			scrollViewOutset = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL);

			[object updateDocumentProperties]; document = object; // Retain the supplied ReaderDocument object for our use

			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
		}
		else // Invalid ReaderDocument object
		{
			self = nil;
		}
	}

	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    

	assert(document != nil); // Must have a valid ReaderDocument

	self.view.backgroundColor = [UIColor grayColor]; // Neutral gray

	UIView *fakeStatusBar = nil; CGRect viewRect = self.view.bounds; // View bounds

	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) // iOS 7+
	{
		if ([self prefersStatusBarHidden] == NO) // Visible status bar
		{
			CGRect statusBarRect = viewRect; statusBarRect.size.height = STATUS_HEIGHT;
			fakeStatusBar = [[UIView alloc] initWithFrame:statusBarRect]; // UIView
			fakeStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			fakeStatusBar.backgroundColor = [UIColor blackColor];
			fakeStatusBar.contentMode = UIViewContentModeRedraw;
			fakeStatusBar.userInteractionEnabled = NO;

			viewRect.origin.y += STATUS_HEIGHT; viewRect.size.height -= STATUS_HEIGHT;
		}
	}

	CGRect scrollViewRect = CGRectInset(viewRect, -scrollViewOutset, 0.0f);
	theScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect]; // All
	theScrollView.autoresizesSubviews = NO; theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.showsHorizontalScrollIndicator = NO; theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.scrollsToTop = NO; theScrollView.delaysContentTouches = NO; theScrollView.pagingEnabled = YES;
	theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	theScrollView.backgroundColor = [UIColor grayColor];
    theScrollView.delegate = self;
	[self.view addSubview:theScrollView];

	CGRect toolbarRect = viewRect;
    toolbarRect.size.height = TOOLBAR_HEIGHT;
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document]; // ReaderMainToolbar
	mainToolbar.delegate = self; // ReaderMainToolbarDelegate
	[self.view addSubview:mainToolbar];

    [self addBottom];
	CGRect pagebarRect = self.view.bounds; pagebarRect.size.height = PAGEBAR_HEIGHT;
    pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
    
//     if(self.isProcurator)
//     {
//         pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
//         self.bottom.hidden = YES;
//     }else
//     {
//         if ([self.isSign isEqualToString:@"1"]) {
//                 pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
//                 self.bottom.hidden = YES;
//            }else
//            {
//                 pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height-50);
//                 self.bottom.hidden = NO;
//            }
//
//     }
//

	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // ReaderMainPagebar
	mainPagebar.delegate = self; // ReaderMainPagebarDelegate
	[self.view addSubview:mainPagebar];

	if (fakeStatusBar != nil) [self.view addSubview:fakeStatusBar]; // Add status bar background view

	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
	[self.view addGestureRecognizer:singleTapOne];

	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
	[self.view addGestureRecognizer:doubleTapOne];

	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
	[self.view addGestureRecognizer:doubleTapTwo];

	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail

	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];

	minimumPage = 1; maximumPage = [document.pageCount integerValue];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateContentViews:theScrollView]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}

    if (self.beingPresented) {
        return;
    }
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
//    [self horize];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == true)
	{
		[self performSelector:@selector(showDocument) withObject:nil afterDelay:0.0];
	}

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

#endif // end of READER_DISABLE_IDLE Option
    
    if (self.beingPresented) {
        return;
    }
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	mainToolbar = nil; mainPagebar = nil;

	theScrollView = nil; contentViews = nil; lastHideTime = nil;

	documentInteraction = nil; printInteraction = nil;

	lastAppearSize = CGSizeZero; currentPage = 0;

	[super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];

	ignoreDidScroll = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == false)
	{
		[self updateContentViews:theScrollView]; lastAppearSize = CGSizeZero;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	ignoreDidScroll = NO;
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
	if (ignoreDidScroll == NO) [self layoutContentViews:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self handleScrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self handleScrollViewDidEnd:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;

	return NO;
}

#pragma mark - UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if ((maximumPage > minimumPage) && (currentPage != minimumPage))
	{
		CGPoint contentOffset = theScrollView.contentOffset; // Offset

		contentOffset.x -= theScrollView.bounds.size.width; // View X--

		[theScrollView setContentOffset:contentOffset animated:YES];
	}
}

- (void)incrementPageNumber
{
	if ((maximumPage > minimumPage) && (currentPage != maximumPage))
	{
		CGPoint contentOffset = theScrollView.contentOffset; // Offset

		contentOffset.x += theScrollView.bounds.size.width; // View X++

		[theScrollView setContentOffset:contentOffset animated:YES];
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view]; // Point

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area rect

		if (CGRectContainsPoint(areaRect, point) == true) // Single tap is inside area
		{
			NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key]; // View

			id target = [targetView processSingleTap:recognizer]; // Target object

			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object

					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string

						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [[NSString alloc] initWithFormat:@"http://%@", www];

							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}

					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
						#ifdef DEBUG
							NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
						#endif
					}
				}
				else // Not a URL, so check for another possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger number = [target integerValue]; // Number

						[self showDocumentPage:number]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
					if ((mainToolbar.alpha < 1.0f) || (mainPagebar.alpha < 1.0f)) // Hidden
					{
						[mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
					}
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point) == true) // page++
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point) == true) // page--
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view]; // Point

		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area

		if (CGRectContainsPoint(zoomArea, point) == true) // Double tap is inside zoom area
		{
			NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key]; // View

			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom++
				{
					[targetView zoomIncrement:recognizer]; break;
				}

				case 2: // Two finger double tap: zoom--
				{
					[targetView zoomDecrement:recognizer]; break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point) == true) // page++
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point) == true) // page--
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark - ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
	if ((mainToolbar.alpha > 0.0f) || (mainPagebar.alpha > 0.0f))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		[mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // Hide

		lastHideTime = [NSDate date]; // Set last hide time
	}
}

#pragma mark - ReaderMainToolbarDelegate methods  监听点击

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option

	[self closeDocument]; // Close ReaderViewController

#endif // end of READER_STANDALONE Option
}

//切换展示
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
#if (READER_ENABLE_THUMBS == TRUE) // Option

	if (printInteraction != nil) [printInteraction dismissAnimated:NO];

	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];

	thumbsViewController.title = self.title; thumbsViewController.delegate = self; // ThumbsViewControllerDelegate

	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;

	[self presentViewController:thumbsViewController animated:NO completion:NULL];

#endif // end of READER_ENABLE_THUMBS Option
}

//分享
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar exportButton:(UIButton *)button
{
	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	NSURL *fileURL = document.fileURL; // Document file URL

	documentInteraction = [UIDocumentInteractionController interactionControllerWithURL:fileURL];

	documentInteraction.delegate = self; // UIDocumentInteractionControllerDelegate

	[documentInteraction presentOpenInMenuFromRect:button.bounds inView:button animated:YES];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
	if ([UIPrintInteractionController isPrintingAvailable] == YES)
	{
		NSURL *fileURL = document.fileURL; // Document file URL

		if ([UIPrintInteractionController canPrintURL:fileURL] == YES)
		{
			printInteraction = [UIPrintInteractionController sharedPrintController];

			UIPrintInfo *printInfo = [UIPrintInfo printInfo];
			printInfo.duplex = UIPrintInfoDuplexLongEdge;
			printInfo.outputType = UIPrintInfoOutputGeneral;
			printInfo.jobName = document.fileName;

			printInteraction.printInfo = printInfo;
			printInteraction.printingItem = fileURL;
			printInteraction.showsPageRange = YES;

			if (userInterfaceIdiom == UIUserInterfaceIdiomPad) // Large device printing
			{
				[printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
			else // Handle printing on small device
			{
				[printInteraction presentAnimated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
		}
	}
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
	if ([MFMailComposeViewController canSendMail] == NO) return;

	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	unsigned long long fileSize = [document.fileSize unsignedLongLongValue];

	if (fileSize < 15728640ull) // Check attachment size limit (15MB)
	{
		NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName;

		NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];

		if (attachment != nil) // Ensure that we have valid document file attachment data available
		{
			MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];

			[mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];

			[mailComposer setSubject:fileName]; // Use the document file name for the subject

			mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;

			mailComposer.mailComposeDelegate = self; // MFMailComposeViewControllerDelegate

			[self presentViewController:mailComposer animated:YES completion:NULL];
		}
	}
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
#if (READER_BOOKMARKS == TRUE) // Option

	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	if ([document.bookmarks containsIndex:currentPage]) // Remove bookmark
	{
		[document.bookmarks removeIndex:currentPage]; [mainToolbar setBookmarkState:NO];
	}
	else // Add the bookmarked page number to the bookmark index set
	{
		[document.bookmarks addIndex:currentPage]; [mainToolbar setBookmarkState:YES];
	}

#endif // end of READER_BOOKMARKS Option
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
	if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif

	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
	documentInteraction = nil;
}

#pragma mark - ThumbsViewControllerDelegate methods

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#if (READER_ENABLE_THUMBS == TRUE) // Option

	[self showDocumentPage:page];

#endif // end of READER_ENABLE_THUMBS Option
}

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#if (READER_ENABLE_THUMBS == TRUE) // Option

	[self dismissViewControllerAnimated:NO completion:NULL];

#endif // end of READER_ENABLE_THUMBS Option
}

#pragma mark - ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
	[self showDocumentPage:page];
}

#pragma mark - UIApplication notification methods

- (void)applicationWillResign:(NSNotification *)notification
{
	[document archiveDocumentProperties]; // Save any ReaderDocument changes

	if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];
}





#pragma mark-底部按钮
- (void)addBottom
{
    return;
    self.bottom = [[SubmitBottom alloc] initWithFrame:CGRectMake(0, kScreenH-54, kScreenW, 54)];
    [self.bottom.submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottom];
}



- (void)addSignView:(CGFloat)PdfH withd:(CGFloat)PdfW addBy:(ReaderContentView*)contentView
{
    
    self.signeImage.hidden = YES;
    self.signView.hidden = YES;
    return;
    
//    if(![NSString isNULLString:self.signUrl])
//    {
//        self.signView.hidden = NO;
//        return;
//    }
    
    
    
//    [self.signView removeFromSuperview];
    self.pdfW = self.model.widthRatio*kScreenW;
    self.pdfH = self.model.heightRatio*PdfH;
    
    if(self.isProcurator)
    {
        
    }else
    {
        
         //已经签字
            if([self.model.signStatus isEqualToString:@"1"])
            {

                [self.signeImage removeFromSuperview];
                self.signeImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenW*self.model.xRatio, PdfH*self.model.yRatio, self.model.widthRatio*kScreenW, self.model.heightRatio*PdfH)];
                [self getUrlByFileCode:self.model.signImg];
                [contentView addSubview:self.signeImage];
                

            }else//未签字
            {
                
                //    CGFloat scale = scaleW;
                CGFloat labelH =  [@"dd" sizeWithFont:[UIFont systemFontOfSize:40*self.model.widthRatio weight:1.3] maxSize:(CGSize)CGSizeMake(MAXFLOAT, MAXFLOAT)].height+4;
                self.signView = [RemoteNotSignView sharedSingleton];
                self.signView.frame = CGRectMake(kScreenW*self.model.xRatio, PdfH*self.model.yRatio, self.model.widthRatio*kScreenW, self.model.heightRatio*PdfH+labelH);
//                self.signView = [[RemoteNotSignView alloc] initWithFrame:CGRectMake(kScreenW*self.model.xRatio, PdfH*self.model.yRatio, self.model.widthRatio*kScreenW, self.model.heightRatio*PdfH+labelH)];
               
                self.signView.backgroundColor = [UIColor clearColor];
                self.signView .userInteractionEnabled = YES;
                UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sign)];
                [self.signView addGestureRecognizer:tap];
                [contentView addSubview:self.signView];
                [contentView bringSubviewToFront:self.signView];

               
                self.signView.timeStr.font = [UIFont systemFontOfSize:40*self.model.widthRatio weight:1.3];
                self.signView.timeStr.backgroundColor = [UIColor clearColor];
                [self setTodayStr];
                
                self.signView.icon.opaque = NO;
                if ([NSString isNULLString:self.signUrl])
                {
                    [self.signView.icon sd_setImageWithURL:[NSURL URLWithString:self.signUrl] placeholderImage:ImageWithName(@"签字占位图")];
                    
                }else
                {
                   
//                    self.signView.icon.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.signUrl]]];
                    [self.signView.icon sd_setImageWithURL:[NSURL URLWithString:self.signUrl] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.signUrl]]]];
                }
                
        
                [self.signView.icon mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.left.right.top.mas_equalTo(0);
                    make.height.mas_equalTo(self.model.heightRatio*PdfH);
                  
                }];
                   
                [self.signView.timeStr mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.signView.icon.mas_bottom).mas_offset(0);
                    make.left.mas_equalTo(self.signView.icon.mas_left);
                    make.right.mas_equalTo(self.signView.icon.mas_right);
                    make.bottom.mas_equalTo(0);
                       
                }];
                
            }

    }

}


//设置当天实际
- (void)setTodayStr
{
    NSDate *date =[NSDate date];//简书 FlyElephant
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];

    [formatter setDateFormat:@"yyyy"];
    NSInteger currentYear=[[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"MM"];
    NSInteger currentMonth=[[formatter stringFromDate:date]integerValue];
    [formatter setDateFormat:@"dd"];
    NSInteger currentDay=[[formatter stringFromDate:date] integerValue];
    
    self.signView.timeStr.text = [NSString stringWithFormat:@"%ld年%ld月%ld日",currentYear,currentMonth,currentDay];
//    NSLog(@"currentDate = %@ ,year = %ld ,month=%ld, day=%ld",date,currentYear,currentMonth,currentDay);
}


#pragma mark-根据code获取图片
-(void)getUrlByFileCode:(NSString *)fileCode
{
//    fileCode = @"8733787047337302207";
    
    //设置图片
    [HttpUrl getUserHeaderImgUrl:@"common/ossFile/downLoadInputStream" imgInfo:@{} fileCode:fileCode getFileSuccess:^(NSData * _Nonnull headerData) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *headerImg = [UIImage imageWithData:headerData];

           
            self.signeImage.image = headerImg;
            
        });
       
    }];
   
        
}



- (void)sign
{
    return;
    PdfGoToSignVC *signatureVC = [[PdfGoToSignVC alloc] init];
//    signatureVC.modalPresentationStyle = UIModalPresentationFullScreen;
    signatureVC.title = @"签字板";
    signatureVC.code = self.code;
    signatureVC.returnSiginUrl = ^(NSString * _Nonnull url, NSString * _Nonnull code) {
        self.signUrl = url;
        NSLog(@"url = %@",url);

       
        [self.signView.icon sd_setImageWithURL:[NSURL URLWithString:self.signUrl] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.signUrl]]]];
            
    };
   
//    [self.navigationController pushViewController:signatureVC animated:YES];
    [self presentViewController:signatureVC animated:YES completion:^{
        
    }];
    
}




#pragma mark-提交签名
- (void)submit
{
    return;
    if ([NSString isNULLString:self.signUrl])
    {
        [MBProgressHUD showTitle:@"请签字之后再提交"];
        return;
    }
    [TYSnapshotScroll screenSnapshot:self.signView finishBlock:^(UIImage *snapShotImage)
     {
       if(snapShotImage != nil)
       {
                     
           [self communicationImgUpload:snapShotImage];
           
       }
    }];
}


-(void)communicationImgUpload:(UIImage*)image
{
    return;
    [HttpUrl uploadFileWithShortUrl:@"common/ossFile/addFileInfo" serviceName:@{@"serviceName":@"common"} uploadImage:image  postSuccess:^(NSDictionary * _Nonnull dict)
    {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([dict[@"success"] boolValue] == YES)
        {
//           NSString *imgUrlStr = dict[@"data"][@"imgUrl"];
            NSString *fileCode =[NSString stringWithFormat:@"%@",dict[@"data"][@"fileCode"]];
            if ([NSString isNULLString:fileCode]) {
                [MBProgressHUD showError:@"上传图片失败"];
            }else
            {
                [self updataSignInformBook:fileCode code:self.code];
            }
        
        }
    }];

}


//嫌疑人告知书签字
-(void)updataSignInformBook:(NSString *)fileCode code:(NSString *)code{
    NSDictionary *upDict = @{@"code":code,@"signImg":fileCode};
    return;
    [HttpUrl postWithShortUrl:@"cases/remoteNotification/updateUserSign" hud:self.view uploadDictionary:[upDict mutableCopy] postSuccess:^(NSDictionary * _Nonnull dict) {
        if ([dict[@"success"] boolValue] == YES) {

            [MBProgressHUD showSuccess:@"上传签名成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }

    } failureCode:^(NSString * _Nonnull Code) {
        if ([Code isEqualToString:@"7000023"] || [Code isEqualToString:@"7000018"]) {
            ZJLoginViewController *vc = [[ZJLoginViewController alloc] init];
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:vc];
            navc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navc animated:YES completion:nil];
        }

    }];
}




#pragma makr----保存图片

//保存图片
-(void)savePhotoMethod:(UIImage*)myImage{
    
    [self loadImageFinished:myImage];

}

//实现该方法
- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    //因为需要知道该操作的完成情况，即保存成功与否，所以此处需要一个回调方法image:didFinishSavingWithError:contextInfo:
}
//回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        [MBProgressHUD showError:@"保存图片失败"];
    }else{
        [MBProgressHUD showSuccess:@"保存图片成功"];
    }
    
}

- (void)loadImageFinished:(UIImage *)image
{
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        //写入图片到相册
        
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
       
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"success = %d, error = %@", success, error);
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showTitle:@"保存成功"];
            });
        }
    }];
}




#pragma mark-改变图片背景颜色
- (UIImage *)maskImage:(UIImage *)image
{
//    const double colorMasking[6] = {219.0, 255.0, 219.0, 255.0, 219.0, 255.0};
    const double colorMasking[6] = {250.0, 255.0, 250.0, 255.0, 250.0, 255.0};//去除这个范围内的颜色变成透明
    CGImageRef sourceImage = image.CGImage;
    
    CGImageAlphaInfo info = CGImageGetAlphaInfo(sourceImage);
    if (info != kCGImageAlphaNone) {
//        NSData *buffer = UIImagePNGRepresentation(image);
        NSData *buffer = UIImageJPEGRepresentation(image, 1);
        UIImage *newImage = [UIImage imageWithData:buffer];
        sourceImage = newImage.CGImage;
    }

    CGImageRef masked = CGImageCreateWithMaskingColors(sourceImage, colorMasking);
    UIImage *retImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
   
    return retImage;
}
  


- (void)update:(UIImage*)image
{
    [HttpUrl uploadFileWithShortUrl:@"common/ossFile/addFileInfo" serviceName:@{@"serviceName":@"common"} uploadImage:image postSuccess:^(NSDictionary * _Nonnull dict)
        {
           NSLog(@"上传单次图片成功%@",dict[@"data"][@"imgUrl"]);
          
   
        [self.signeImage sd_setImageWithURL:dict[@"data"][@"imgUrl"]];
        
       } ];
}



//- (void)horize
//{
//    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.allowRotation = NO;//(以上2行代码,可以理解为打开横屏开关)
//    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
//    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//    [UIViewController attemptRotationToDeviceOrientation];
//
//}

@end
