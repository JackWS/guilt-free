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

@interface ScanViewController ()

@property (nonatomic, strong) ZBarCameraSimulator *cameraSim;
@property (nonatomic, strong) HUDHelper *hudHelper;

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

    self.hudHelper = [[HUDHelper alloc] initWithView:self.view];

    // the delegate receives decode results
    self.readerView.readerDelegate = self;

    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        self.cameraSim = [[ZBarCameraSimulator alloc]
                initWithViewController:self];
        self.cameraSim.readerView = self.readerView;

#if MOCK_DATA
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.view.frame;
        [button setTitle:@"FAKE SCAN" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(fakeScan:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
#endif
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

static NSString *const kTriggerString = @"blisd";

- (void) processURL:(NSString *) url {
    [self.hudHelper showWithText:NSLocalizedString(@"LOADING", @"")];
    NSLog(@"URL = %@", url);
    if ([[url lowercaseString] rangeOfString:kTriggerString].location != NSNotFound) {
        [Scan processScanFromURL:url response:^(Balance *balance, NSError *error) {
            [self.hudHelper hide];
            if (error) {
                [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_SCAN", @"")];
            } else {
                PostScanViewController *controller = [[PostScanViewController alloc] initWithBalance:balance];
                [self.navigationController pushViewController:controller animated:YES];

                [UIAlertView showAlertViewWithTitle:@"Hooray!"
                                            message:$str(@"Sucessfully created new balance. Number of scans: %d", balance.balance)
                                  cancelButtonTitle:@"Awesome!"
                                  otherButtonTitles:nil
                                            handler:nil];
            }
        }];
    } else {
        OutsideURL *outsideURL = [[OutsideURL alloc] init];
        outsideURL.url = url;
        outsideURL.user = [User currentUser].email;
        [outsideURL saveInBackgroundWithBlock:^(id object, NSError *error) {
            [self.hudHelper hide];
            if (error) {
                NSLog(@"Error logging external URL: %@", [error description]);
            }

            NSURL *externalURL = [NSURL URLWithString:url];
            [[UIApplication sharedApplication] openURL:externalURL];
        }];
    }
}

#if MOCK_DATA

- (void) fakeScan:(id) sender {
    NSString *url = [MockData generateCampaignURL];
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
