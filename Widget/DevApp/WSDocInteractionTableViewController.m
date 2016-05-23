//
//  WSDocInteractionTableViewController.m
//  Widget
//
//  Created by MrChens on 16/5/23.
//  Copyright © 2016年 chinanetcenter. All rights reserved.
//

#import "WSDocInteractionTableViewController.h"
#import <QuickLook/QuickLook.h>
#import "DirectoryWatcher.h"

static NSString* documents[] = {
    @"Text Document.txt",
    @"Image Document.jpg",
    @"PDF Document.pdf",
    @"HTML Document.html",
    @"video.mov",
    @"pdf.pdf",
    @"music.mp3",
    @"image.png"
};

#define NUM_OF_EXAMPLE_DOCS 8

static  NSString* const cellIdentifier = @"cellIdentifier";
@interface WSDocInteractionTableViewController ()<UIDocumentInteractionControllerDelegate,
QLPreviewControllerDelegate,
QLPreviewControllerDataSource,
DirectoryWatcherDelegate>

@property (nonatomic, strong) NSMutableArray *documentURLs;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@property (nonatomic, strong) DirectoryWatcher *docWatcher;
@end

@implementation WSDocInteractionTableViewController
#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.docWatcher = [DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory] delegate:self];
    self.documentURLs = [NSMutableArray array];
    
    [self directoryDidChange:self.docWatcher];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    self.documentURLs = nil;
    self.docWatcher = nil;
}
#pragma mark - UIInit
#pragma mark - UIConfig
#pragma mark - UIUpdate
#pragma mark - AppleDataSource and Delegate
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return NUM_OF_EXAMPLE_DOCS;
    }else {
        return [self.documentURLs count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (section == 0) {
        title = @"Example Documents";
    }else {
        if (self.documentURLs.count > 0) {
            title = @"Documents folder";
        }
    }
    
    return title;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *fileURL;
    if (indexPath.section == 0) {
        fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[indexPath.row] ofType:nil]];
    } else {
        fileURL = [self.documentURLs objectAtIndex:indexPath.row];
    }
    
    [self setupDocumentControllerWithURL:fileURL];
    
    cell.textLabel.text = [[fileURL path] lastPathComponent];
    NSInteger iconCount = [self.docInteractionController.icons count];
    
    if (iconCount > 0) {
        cell.imageView.image = [self.docInteractionController.icons objectAtIndex:iconCount - 1];
    }
    
    NSString *fileURLString = [self.docInteractionController.URL path];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURLString error:nil];
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
    NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", fileSizeStr ,self.docInteractionController.UTI];
    
    //    cell.imageView.userInteractionEnabled = YES;
    //    cell.contentView.gestureRecognizers = self.docImteractionController.gestureRecognizers;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handLongGesture:)];
    [cell.imageView addGestureRecognizer:longPressGesture];
    cell.imageView.userInteractionEnabled = YES;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
   UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // three ways to present a preview:
    // 1. Don't implement this method and simply attach the canned gestureRecognizers to the cell
    //
    // 2. Don't use canned gesture recognizers and simply use UIDocumentInteractionController's
    //      presentPreviewAnimated: to get a preview for the document associated with this cell
    //
    // 3. Use the QLPreviewController to give the user preview access to the document associated
    //      with this cell and all the other documents as well.
    
    // for case 2 use this, allowing UIDocumentInteractionController to handle the preview:
    /*
     NSURL *fileURL;
     if (indexPath.section == 0)
     {
     fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[indexPath.row] ofType:nil]];
     }
     else
     {
     fileURL = [self.documentURLs objectAtIndex:indexPath.row];
     }
     [self setupDocumentControllerWithURL:fileURL];
     [self.docInteractionController presentPreviewAnimated:YES];
     */
    
    // for case 3 we use the QuickLook APIs directly to preview the document -
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    
    previewController.currentPreviewItemIndex = indexPath.row;
    [self.navigationController pushViewController:previewController animated:YES];
}

#pragma mark UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

#pragma mark QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    NSInteger numToPreview = 0;
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath.section == 0) {
        numToPreview = NUM_OF_EXAMPLE_DOCS;
    } else {
        numToPreview = self.documentURLs.count;
    }
    return numToPreview;
}
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSURL *fileURL = nil;
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath.section == 0) {
        fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[index] ofType:nil]];
    }
    else {
        fileURL = [self.documentURLs objectAtIndex:index];
    }
    return fileURL;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    
}
#pragma mark QLPreviewControllerDelegate
#pragma mark UIDocumentInteractionControllerDelegate
#pragma mark - ThirdPartyDataSource and Delegate
#pragma mark DirectoryWatcherDelegate
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher {
    [self.documentURLs removeAllObjects];
    
    NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
    
    NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:nil];
    
    for (NSString * curFileName in [documentsDirectoryContents objectEnumerator]) {
        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory && [curFileName isEqualToString:@"Inbox"])) {
            [self.documentURLs addObject:fileURL];
        }
    }
    
    [self.tableView reloadData];
}
#pragma mark - CustomDataSource and Delegate
#pragma mark - Target-Action Event
- (void)handLongGesture:(UILongPressGestureRecognizer *)longGesture {
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *cellIndexPath = [self.tableView indexPathForRowAtPoint:[longGesture locationInView:self.tableView]];
        NSURL *fileURL;
        if (cellIndexPath.section == 0) {
            fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[cellIndexPath.row] ofType:nil]];
        } else {
            fileURL = [self.documentURLs objectAtIndex:cellIndexPath.row];
        }
        
        self.docInteractionController.URL = fileURL;
        
        BOOL isCanOpen = [self.docInteractionController presentOptionsMenuFromRect:longGesture.view.frame
                                                          inView:longGesture.view
                                                        animated:YES];
        [self showAlertView:isCanOpen];
    }
}
#pragma mark - PublicMethod
#pragma mark - PrivateMethod
- (void)setupDocumentControllerWithURL:(NSURL *)fileUrl {
    if (self.docInteractionController == nil) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
        self.docInteractionController.delegate = self;
    } else {
        self.docInteractionController.URL = fileUrl;
    }
}
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)showAlertView:(BOOL)isCanOpen {
    if (!isCanOpen) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"opps!!!"
                                                                                 message:@"can not open the file of this type."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"fine" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"click fine button");
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    }
}
@end
