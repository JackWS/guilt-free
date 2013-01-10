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
#import "BlissBalance.h"
#import "Scan.h"
#import "MockData.h"
#import "PostScanViewController.h"
#import "ScanResult.h"
#import "PostRedeemViewController.h"
#import "IntroState.h"
#import "IntroView.h"

@interface ScanViewController ()

@property (nonatomic, strong) ZBarCameraSimulator *cameraSim;
@property (nonatomic, strong) HUDHelper *hudHelper;
@property (nonatomic, strong) IntroView *introView;

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

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    if (![User currentUser].introState.scan) {
        if (!self.introView) {
            self.introView = [[IntroView alloc] initWithImage:[UIImage imageNamed:@"how_to_scan.png"]];
            [self.view addSubview:self.introView];
            self.introView.doneBlock = ^{
                [User currentUser].introState.scan = YES;
                [[User currentUser] saveState];
            };
        }
    }
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.introView.frame = self.view.bounds;
}


- (void) viewDidAppear:(BOOL) animated {
    [super viewDidAppear:animated];

    [self.readerView start];
}

- (void) viewWillDisappear:(BOOL) animated {
    [self.readerView stop];
}

#pragma mark Helpers

- (IBAction) redeemWithBalance:(BlissBalance *) balance {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REDEEM_TITLE", @"")
                                                        message:NSLocalizedString(@"REDEEM_MESSAGE", @"")];
    [alertView addButtonWithTitle:NSLocalizedString(@"REDEEM_CANCEL", @"")];
    [alertView addButtonWithTitle:NSLocalizedString(@"REDEEM_OK", @"")
                          handler:^{
                              [self.hudHelper showWithText:NSLocalizedString(@"LOADING", @"")];
                              [balance redeemResponse:^(NSNumber *success, NSError *error) {
                                  [self.hudHelper hide];
                                  if ([success boolValue]) {
                                      PostRedeemViewController *controller = [[PostRedeemViewController alloc] init];
                                      [self.navigationController pushViewController:controller animated:YES];

//                                      [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"REDEEMED_TITLE", @"")
//                                                                  message:NSLocalizedString(@"REDEEMED_MESSAGE", @"")
//                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"")
//                                                        otherButtonTitles:nil
//                                                                  handler:nil];
                                  } else {
                                      [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_REDEEMING", @"")];
                                  }
                              }];
                          }];
    [alertView show];
}


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
            if (result.status == ScanResultStatusSuccess) {
                PostScanViewController *controller = [[PostScanViewController alloc] initWithBalance:result.balance];
                controller.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:controller animated:YES];
            } else if (result.status == ScanResultStatusRedeemRequired) {
                [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"REDEEM_REQUIRED_TITLE", @"")
                                            message:NSLocalizedString(@"REDEEM_REQUIRED_MESSAGE", @"")
                                  cancelButtonTitle:NSLocalizedString(@"REDEEM_CANCEL", @"")
                                  otherButtonTitles:@[NSLocalizedString(@"REDEEM", @"")]
                                            handler:^(UIAlertView *view, NSInteger i) {
                    if (i != view.cancelButtonIndex) {
                        [self redeemWithBalance:result.balance];
                    }
                }];
            }
        } else if (result.type == ScanResultTypeCheckIn) {
            if (result.status == ScanResultStatusSuccess) {
                [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"CHECK_IN_TITLE", @"")
                                            message:NSLocalizedString(@"CHECK_IN_MESSAGE", @"")
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                  otherButtonTitles:nil
                                            handler:nil];
            }
        }
    }];
}

#if TARGET_IPHONE_SIMULATOR

- (void) fakeScan:(id) sender {
    NSString *url = [MockData generateCampaignURL]; //[MockData generateCheckInURL];
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
