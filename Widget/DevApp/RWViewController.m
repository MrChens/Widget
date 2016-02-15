//
//  RWViewController.m
//  KnobControl
//
//  Created by Sam Davies on 14/11/2013.
//  Copyright (c) 2013 RayWenderlich. All rights reserved.
//

#import "RWViewController.h"
#import <RWUIControls/RWUIControls.h>

@interface RWViewController () {
    RWKnobControl *_knobControl;
}

@end

@implementation RWViewController {
    NSTimer *_timer;
}

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
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.chinanetcenter.Widget.Documents"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/good"];
    NSLog(@"containing:%@",containerURL);
    NSString *value = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&err];
    [self logAppPath];
    NSLog(@"%@", value);
}

- (void)onTimer:(NSTimer *)timer {
    NSLog(@"Host timer:%@", timer);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
