//
//  RWViewController.m
//  KnobControl
//
//  Created by Sam Davies on 14/11/2013.
//  Copyright (c) 2013 RayWenderlich. All rights reserved.
//

#import "RWViewController.h"
#import <RWUIControls/RWUIControls.h>
#import "WSDocInteractionTableViewController.h"

@interface RWViewController ()<UIDocumentInteractionControllerDelegate> {
    RWKnobControl *_knobControl;
}
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@end

@implementation RWViewController {
    NSTimer *_timer;
}
#pragma mark - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _knobControl = [[RWKnobControl alloc] initWithFrame:self.knobPlaceholder.bounds];
    [self.knobPlaceholder addSubview:_knobControl];
    
    _knobControl.lineWidth = 4.0;
    _knobControl.pointerLength = 8.0;
    self.view.tintColor = [UIColor redColor];
    
    [_knobControl addObserver:self forKeyPath:@"value" options:0 context:NULL];
    
  

    

    // Hooks up the knob control
    [_knobControl addTarget:self
                     action:@selector(handleValueChanged:)
           forControlEvents:UIControlEventValueChanged];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//    [_timer fire];
    // Do any additional setup after loading the view from its nib.
    [self addDocumentInteractionButton];
    [self addQLPreviewButton];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.chinanetcenter.Widget.Documents"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/good"];
    NSLog(@"containing:%@",containerURL);
    NSString *value = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&err];
    [self logAppPath];
    NSLog(@"%@", value);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIInit
- (void)addDocumentInteractionButton {
    UIButton *openPDF = [[UIButton alloc] initWithFrame:CGRectMake(0, 250, 160, 60)];
    [openPDF setTitle:@"open PDF" forState:UIControlStateNormal];
    [openPDF setBackgroundColor:[UIColor greenColor]];
    [openPDF addTarget:self action:@selector(openDocument) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openPDF];
}

- (void)addQLPreviewButton {
    UIButton * openPreview = [[UIButton alloc] initWithFrame:CGRectMake(0, 310, 160, 60)];
    [openPreview setTitle:@"open Preview" forState:UIControlStateNormal];
    [openPreview setBackgroundColor:[UIColor blueColor]];
    [openPreview addTarget:self action:@selector(openPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openPreview];
}
#pragma mark - UIConfig
#pragma mark - UIUpdate
#pragma mark - AppleDataSource and Delegate
#pragma mark - ThirdPartyDataSource and Delegate
#pragma mark - CustomDataSource and Delegate
#pragma mark - Target-Action Event
- (IBAction)handleValueChanged:(id)sender {
    if(sender == self.valueSlider) {
        _knobControl.value = self.valueSlider.value;
    } else if(sender == _knobControl) {
        self.valueSlider.value = _knobControl.value;
    }
}

- (IBAction)handleRandomButtonPressed:(id)sender {
    // Generate random value
    CGFloat randomValue = (arc4random() % 101) / 100.f;
    // Then set it on the two controls
    [_knobControl setValue:randomValue animated:self.animateSwitch.on];
    [self.valueSlider setValue:randomValue animated:self.animateSwitch.on];
}

- (void)openDocument {
    NSURL *documentUrl = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mov"];
    if (documentUrl) {
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:documentUrl];
        self.documentController.delegate = self;
        BOOL isCanOpen = [self.documentController presentOpenInMenuFromRect:[self.view frame] inView:self.view animated:YES];
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
}

- (void)openPreview {
    WSDocInteractionTableViewController *controller = [[WSDocInteractionTableViewController alloc] init];

    [self.navigationController pushViewController:controller animated:YES];
//    [self presentViewController:controller animated:YES completion:nil];

   
//    [controller dismissViewControllerAnimated:YES completion:^{
//        NSLog(@"关闭预览");
//    }];
}
#pragma mark - PublicMethod
#pragma mark - PrivateMethod
- (void)onTimer:(NSTimer *)timer {
    NSLog(@"Host timer:%@", timer);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == _knobControl && [keyPath isEqualToString:@"value"]) {
        self.valueLabel.text = [NSString stringWithFormat:@"%0.2f", _knobControl.value];
    }
}

- (void)logAppPath
{
    //app group路径
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.chinanetcenter.Widget.Documents"];
    NSLog(@"app group:\n%@",containerURL.path);
    
    //打印可执行文件路径
    NSLog(@"bundle:\n%@",[[NSBundle mainBundle] bundlePath]);
    
    //打印documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSLog(@"documents:\n%@",path);
}

@end
