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
#import "HUDHelper.h"
#import "OutsideURL.h"
#import "User.h"
#import "Balance.h"
#import "Scan.h"
#import "MockData.h"
#import "PostScanViewController.h"
#import "ScanResult.h"

@interface ScanViewController ()

@property (nonatomic, strong) ZBarCameraSimulator *cameraSim;
@property (nonatomic, strong) HUDHelper *hudHelper;

@end

@implementation ScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menubuttonscanpressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"menubuttonscan.png"]];
    }
    return self;
}

- (void) dealloc {
    [self cleanup];
}

#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    self.hudHelper = [[HUDHelper alloc] initWithView:self.view];

    // the delegate receives decode results
    self.readerView.readerDelegate = self;

    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        self.cameraSim = [[ZBarCameraSimulator alloc]
                initWithViewController:self];
        self.cameraSim.readerView = self.readerView;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.view.frame;
        [button setTitle:@"FAKE SCAN" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(fakeScan:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
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

- (void) processURL:(NSString *) url {
    [self.hudHelper showWithText:NSLocalizedString(@"LOADING", @"")];
    [Scan processScanFromURL:url response:^(ScanResult *result, NSError *error) {
        [self.hudHelper hide];
        if (error) {
            [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_SCAN", @"")];
        } else if (result.type == ScanResultTypeCampaign) {
            PostScanViewController *controller = [[PostScanViewController alloc] initWithBalance:result.balance];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
}

#if TARGET_IPHONE_SIMULATOR

- (void) fakeScan:(id) sender {
    NSString *url = [MockData generateCheckInURL]; // [MockData generateCampaignURL];
    [self processURL:url];
}

#endif

#pragma mark ZBarReaderViewDelegate

- (void) readerView:(ZBarReaderView*) view didReadSymbols:(ZBarSymbolSet*) syms fromImage:(UIImage*) img {
    // do something useful with results
    for(ZBarSymbol *sym in syms) {
        NSString *result = sym.data;
        [self processURL:result];
        break;
    }
}


@end
