//
// Created by Kevin on 10/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "BlissOfferDetailsViewController.h"
#import "Balance.h"
#import "Customer.h"
#import "ShareView.h"
#import "NIBLoader.h"


@implementation BlissOfferDetailsViewController {

}

- (id) init {
    self = [super initWithNibName:@"BlissOfferDetailsView" bundle:nil];
    if (self) {
    }
    return self;
}

#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    self.detailsView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.detailsView.layer.borderWidth = 1.0f;
    self.detailsView.layer.cornerRadius = 8.0f;

    self.shareView = [NIBLoader loadFirstObjectFromNibNamed:@"ShareView"];
    self.shareView.ownerViewController = self;
    [self.shareViewContainer addSubview:self.shareView];

    self.businessNameLabel.text = self.balance.customer.company;
    self.businessTagLineLabel.text = self.balance.customer.tagLine;
    self.businessTypeLabel.text = self.balance.customer.type;

    self.buyXLabel.text = $str(NSLocalizedString(@"OFFER_DETAILS_BUY_X", @""), self.balance.buyX, self.balance.buyY);
    self.getXLabel.text = $str(NSLocalizedString(@"OFFER_DETAILS_GET_X", @""), self.balance.getX);
    self.countRemainingLabel.text = $str(@"%d", self.balance.buyX - self.balance.balance);

    self.addressLabel.text = self.balance.customer.address;
    self.websiteLabel.text = self.balance.customer.website;

    [self.balance.customer loadImageWithResponse:^(UIImage *image, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving image for business with name: %@, error: %@",
                    self.balance.customer.company, [error description]);
        } else {
           self.businessImageView.image = image;
        }
    }];

}


#pragma mark User Actions

- (IBAction) back:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) openWebsite:(id) sender {
    NSString *url = self.balance.customer.website;
    if (url && ![url isEqualToString:@""]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}


@end