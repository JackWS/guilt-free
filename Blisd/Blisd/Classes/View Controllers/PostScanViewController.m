//
// Created by Kevin on 10/15/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "PostScanViewController.h"
#import "Balance.h"
#import "NSString+Pluralize.h"
#import "ShareView.h"
#import "NIBLoader.h"

@interface PostScanViewController ()

@property (nonatomic, strong) Balance *balance;

@end

@implementation PostScanViewController {

}

- (id) initWithBalance:(Balance *) balance {
    self = [super initWithNibName:@"PostScanView" bundle:nil];
    if (self) {
        self.balance = balance;
    }

    return self;
}

#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    self.shareView = [NIBLoader loadFirstObjectFromNibNamed:@"ShareView"];
    self.shareView.ownerViewController = self;
    [self.shareViewContainer addSubview:self.shareView];

    srandom((unsigned int) time(NULL));
    int num = random() % 7 + 1;
    self.flareImageView.image = [UIImage imageNamed:$str(@"redtag%d.png", num)];

    BOOL earned = self.balance.balance >= self.balance.buyX;
    BOOL almostEarned = self.balance.balance + 1 == self.balance.buyX;
    if (earned) {
        self.redeemButton.hidden = NO;
        self.progressView.hidden = YES;
    } else {
        self.redeemButton.hidden = YES;
        self.progressView.hidden = NO;
        if (almostEarned) {
            self.buyXLabel.text = NSLocalizedString(@"NEXT_VISIT_GET", @"");
            self.earnLabel.text = nil;
        } else {
            self.buyXLabel.text = $str(NSLocalizedString(@"N_MORE_PURCHASES", @""), self.balance.buyX - self.balance.balance);
            self.earnLabel.text = NSLocalizedString(@"UNTIL_YOU_EARN", @"");
        }
        self.getXLabel.text = self.balance.getX;
    }

    self.shareView.progress = self.balance.balance;
}


#pragma mark User Actions

- (IBAction) back:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) redeem:(id) sender {

}


- (IBAction) shareFacebook:(id) sender {

}

- (IBAction) shareTwitter:(id) sender {

}

- (IBAction) shareEmail:(id) sender {

}


@end