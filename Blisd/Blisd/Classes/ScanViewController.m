//
//  ScanViewController.m
//  Blisd
//
//  Created by JStack on 9/21/12.
//  Copyright (c) 2012 Blisd LLC All rights reserved.
//

#import <iphone/include/ZBarSDK/ZBarReaderView.h>
#import "ScanViewController.h"
#import "ZBarCameraSimulator.h"

@interface ScanViewController ()

@property(nonatomic, strong) ZBarCameraSimulator *cameraSim;

@end

@implementation ScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"SCAN_TAB", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"first.png"];
    }
    return self;
}

- (void) dealloc {
    [self cleanup];
}

#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    // the delegate receives decode results
    self.readerView.readerDelegate = self;

    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        self.cameraSim = [[ZBarCameraSimulator alloc]
                initWithViewController:self];
        self.cameraSim.readerView = self.readerView;
    }
}

- (void) viewDidUnload {
    [self cleanup];
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) orient {
    // auto-rotation is supported
    return(YES);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation) orient duration:(NSTimeInterval) duration {
    // compensate for view rotation so camera preview is not rotated
    [self.readerView willRotateToInterfaceOrientation:orient
                                        duration:duration];
}

- (void) viewDidAppear:(BOOL) animated {
    // run the reader when the view is visible
    [self.readerView start];
}

- (void) viewWillDisappear:(BOOL) animated {
    [self.readerView stop];
}

#pragma mark Helpers

- (void) cleanup {
    self.cameraSim = nil;
    self.readerView.readerDelegate = nil;
    self.readerView = nil;
}

#pragma mark ZBarReaderViewDelegate

- (void) readerView:(ZBarReaderView*) view didReadSymbols:(ZBarSymbolSet*) syms fromImage:(UIImage*) img {
    // do something useful with results
    for(ZBarSymbol *sym in syms) {
        NSString *result = sym.data;
        NSLog(@"result = %@", result);
        break;
    }
}


@end
