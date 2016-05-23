//
//  WSQLPreviewController.m
//  Widget
//
//  Created by MrChens on 16/5/23.
//  Copyright © 2016年 chinanetcenter. All rights reserved.
//

#import "WSQLPreviewController.h"



@interface WSQLPreviewController ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *previewItems;
@end

@implementation WSQLPreviewController
#pragma mark - ViewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    
    self.previewItems = [[NSMutableArray alloc] initWithCapacity:4];
    NSURL *imageUrl = [[NSBundle mainBundle] URLForResource:@"image" withExtension:@"png"];
    NSURL *pdfUrl = [[NSBundle mainBundle] URLForResource:@"pdf" withExtension:@"pdf"];
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mov"];
    NSURL *musicUrl = [[NSBundle mainBundle] URLForResource:@"music" withExtension:@"mp3"];
    if (imageUrl) {
        [self.previewItems addObject:imageUrl];
    }
    if (pdfUrl) {
        [self.previewItems addObject:pdfUrl];
    }
    if (videoUrl) {
        [self.previewItems addObject:videoUrl];
    }
    if (musicUrl) {
        [self.previewItems addObject:musicUrl];
    }
    
}
#pragma mark - UIInit
#pragma mark - UIConfig
#pragma mark - UIUpdate
#pragma mark - AppleDataSource and Delegate
#pragma mark QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return [self.previewItems count];
}

/*!
 * @abstract Returns the item that the preview controller should preview.
 * @param panel The Preview Controller.
 * @param index The index of the item to preview.
 * @result An item conforming to the QLPreviewItem protocol.
 */
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [self.previewItems objectAtIndex:index];
}
#pragma mark QLPreviewControllerDelegate
- (void)previewControllerWillDismiss:(QLPreviewController *)controller{
    
}

/*!
 * @abstract Invoked after the preview controller is closed.
 */
- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    
}

/*!
 * @abstract Invoked by the preview controller before trying to open an URL tapped in the preview.
 * @result Returns NO to prevent the preview controller from calling -[UIApplication openURL:] on url.
 * @discussion If not implemented, defaults is YES.
 */
- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item {
    return YES;
}

/*!
 * @abstract Invoked when the preview controller is about to be presented full screen or dismissed from full screen, to provide a zoom effect.
 * @discussion Return the origin of the zoom. It should be relative to view, or screen based if view is not set. The controller will fade in/out if the rect is CGRectZero.
 */
//- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView * __nullable * __nonnull)view {
//    
//}

/*!
 * @abstract Invoked when the preview controller is about to be presented full screen or dismissed from full screen, to provide a smooth transition when zooming.
 * @param contentRect The rect within the image that actually represents the content of the document. For example, for icons the actual rect is generally smaller than the icon itself.
 * @discussion Return an image the controller will crossfade with when zooming. You can specify the actual "document" content rect in the image in contentRect.
 */
//- (UIImage *)previewController:(QLPreviewController *)controller transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(CGRect *)contentRect {
//    
//}
#pragma mark - ThirdPartyDataSource and Delegate
#pragma mark - CustomDataSource and Delegate
#pragma mark - Target-Action Event
#pragma mark - PublicMethod
#pragma mark - PrivateMethod

@end
