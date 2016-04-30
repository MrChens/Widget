//
//  TodayViewController.m
//  TodayWidget
//
//  Created by MrChens on 16/2/4.
//  Copyright © 2016年 chinanetcenter. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "WSDataBase.h"
NSString *const WSPXAPPConfigurationApplicationGroupsPrimary = @"group.com.chinanetcenter.Widget.Documents";

@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;
@property (nonatomic, weak) IBOutlet UIImageView *centerImageView;
@end

@implementation TodayViewController {
    NSTimer* _timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Chen:%s", __PRETTY_FUNCTION__);

    self.leftLabel.text = @"心\n想\n事\n成";
    self.rightLabel.text = @"万\n事\n如\n意";
    WSDataBase *dataBase = [[WSDataBase alloc] init];
    [dataBase createDB];
    
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:WSPXAPPConfigurationApplicationGroupsPrimary];
    NSString *nickName = [userDefault objectForKey:@"Title"];
    
    if (nickName) {
        self.titleLabel.text = nickName;
    }
    
    UIImage *image = [userDefault objectForKey:@"image"];
    if (image) {
        self.centerImageView.image = image;
    }
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//    [_timer fire];
    // Do any additional setup after loading the view from its nib.
}

- (void)onTimer:(NSTimer *)timer {
    NSLog(@"Widget timer:%@", timer);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Chen:%s", __PRETTY_FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self logAppPath];
    NSLog(@"Chen:%s", __PRETTY_FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"Chen:%s", __PRETTY_FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (IBAction)MenuPressed:(id)sender {
    NSLog(@"Chen:%s", __PRETTY_FUNCTION__);
    [self saveTextByNSFileManager];
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 100) {
        [self.extensionContext openURL:[NSURL URLWithString:@"ToDayWidget://action=LogOne"] completionHandler:^(BOOL success) {
            NSLog(@"hello one:%d", success);
        }];
    } else if (btn.tag == 200) {
        [self.extensionContext openURL:[NSURL URLWithString:@"ToDayWidget://action=LogTwo"] completionHandler:^(BOOL success) {
            NSLog(@"hello two:%d", success);
        }];
    }
    
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (BOOL)saveTextByNSFileManager {
//    NSError *err = nil;
//    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:WSPXAPPConfigurationApplicationGroupsPrimary];
//    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/good"];
//    NSLog(@"todayUrl:%@",containerURL);
//    NSString *value = @"test";
//    BOOL result = [value writeToURL:containerURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
//    
//    if (!result) {
//        NSLog(@"错误:%@", err);
//    } else {
//        NSLog(@"save value:%@ success", value);
//    }
//    
//    return result;
    return YES;
}
- (void)logAppPath
{
    //app group路径
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:WSPXAPPConfigurationApplicationGroupsPrimary];
    NSLog(@"app group:\n%@",containerURL.path);
    
    //打印可执行文件路径
    NSLog(@"bundle:\n%@",[[NSBundle mainBundle] bundlePath]);
    
    //打印documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSLog(@"documents:\n%@",path);
}

@end
