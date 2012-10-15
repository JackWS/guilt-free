//
// Created by Kevin on 10/15/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "PostScanViewController.h"
#import "Balance.h"
#import "NSString+Pluralize.h"

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

    srandom((unsigned int) time(NULL));
    int num = random() % 7 + 1;
    self.flareImageView.image = [UIImage imageNamed:$str(@"redtag%d.png", num)];


    self.shareView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.shareView.layer.borderWidth = 1.0f;
    self.shareView.layer.cornerRadius = 8.0f;

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

    self.statusLabel.text =
            $str(@"%@ %@.", NSLocalizedString(@"BALANCE_STATUS", @""),
            [NSLocalizedString(@"BALANCE_PLURALIZABLE", @"") pluralize:self.balance.balance]);
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