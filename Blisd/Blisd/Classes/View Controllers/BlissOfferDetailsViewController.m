//
// Created by Kevin on 10/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "BlissOfferDetailsViewController.h"
#import "BlissBalance.h"
#import "Customer.h"
#import "ShareView.h"
#import "NIBLoader.h"
#import "HUDHelper.h"
#import "Campaign.h"
#import "CheckInBalance.h"

@interface BlissOfferDetailsViewController ()

@property (nonatomic, strong) NSDictionary *text;
@property (nonatomic, strong) HUDHelper *hudHelper;
@property (nonatomic, assign) BOOL loaded;

@end

@implementation BlissOfferDetailsViewController {

}

- (id) init {
    self = [super initWithNibName:@"BlissOfferDetailsView" bundle:nil];
    if (self) {
        self.text = @{
            $int(ShareServiceFacebook) : @{
                $int(ShareItemText)         :    NSLocalizedString(@"OFFER_LIST_FACEBOOK_TEXT", @""),
                $int(ShareItemName)         :    NSLocalizedString(@"OFFER_LIST_FACEBOOK_NAME", @""),
                $int(ShareItemCaption)      :    NSLocalizedString(@"OFFER_LIST_FACEBOOK_CAPTION", @""),
                $int(ShareItemDescription)  :    NSLocalizedString(@"OFFER_LIST_FACEBOOK_DESCRIPTION", @"")
            },
            $int(ShareServiceTwitter) : @{
                $int(ShareItemText)         :    NSLocalizedString(@"OFFER_LIST_TWITTER_TEXT", @"")
            },
            $int(ShareServiceEmail) : @{
                $int(ShareItemText)         :    NSLocalizedString(@"OFFER_LIST_EMAIL_TEXT", @""),
                $int(ShareItemName)         :    NSLocalizedString(@"OFFER_LIST_EMAIL_NAME", @"")
            }
        };
    }
    return self;
}

#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    self.hudHelper = [[HUDHelper alloc] initWithView:self.view];

    self.detailsView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.detailsView.layer.borderWidth = 1.0f;
    self.detailsView.layer.cornerRadius = 8.0f;

    self.shareView = [NIBLoader loadFirstObjectFromNibNamed:@"ShareView"];
    self.shareView.shareHelper.delegate = self;
    [self.shareViewContainer addSubview:self.shareView];

    [self update];

    [self.balance.customer loadImageWithResponse:^(UIImage *image, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving image for business with name: %@, error: %@",
                    self.balance.customer.company, [error description]);
        } else {
           self.businessImageView.image = image;
        }
    }];

}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];

    if (!self.loaded) {
        [self.hudHelper showWithText:NSLocalizedString(@"LOADING", @"")];
    }
    [CheckInBalance getForLocation:self.balance.campaign.location response:^(CheckInBalance *balance, NSError *error) {
        [self.hudHelper hide];
        if (error) {
            NSLog(@"Error retrieving check-in for customer with id: %@, %@", self.balance.customer.id, [error description]);
        } else {
            self.shareView.balance = balance;
            [self.shareView setNeedsLayout];
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

- (IBAction) redeem:(id) sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REDEEM_TITLE", @"")
                                                        message:NSLocalizedString(@"REDEEM_MESSAGE", @"")];
    [alertView addButtonWithTitle:NSLocalizedString(@"REDEEM_CANCEL", @"")];
    [alertView addButtonWithTitle:NSLocalizedString(@"REDEEM_OK", @"")
                          handler:^{
                            [self.hudHelper showWithText:NSLocalizedString(@"LOADING", @"")];
                            [self.balance redeemResponse:^(NSNumber *success, NSError *error) {
                                [self.hudHelper hide];
                                if ([success boolValue]) {
                                    [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"REDEEMED_TITLE", @"")
                                                                message:NSLocalizedString(@"REDEEMED_MESSAGE", @"")
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil
                                                                handler:nil];
                                    [self.navigationController popViewControllerAnimated:YES];
                                } else {
                                    [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_REDEEMING", @"")];
                                }
                            }];
                          }];
    [alertView show];
}

#pragma mark Helpers

- (void) update {
    self.businessNameLabel.text = self.balance.customer.company;
    self.businessTagLineLabel.text = self.balance.customer.tagLine;
    self.businessTypeLabel.text = self.balance.customer.type;

    self.buyXLabel.text = $str(NSLocalizedString(@"OFFER_DETAILS_BUY_X", @""), self.balance.buyX, self.balance.buyY);
    self.getXLabel.text = $str(NSLocalizedString(@"OFFER_DETAILS_GET_X", @""), self.balance.getX);

    if (self.balance.balance >= self.balance.buyX) {
        [self.progressView addSubview:self.redeemProgressView];
    } else {
        [self.progressView addSubview:self.standardProgressView];
        self.countRemainingLabel.text = $str(@"%d", self.balance.buyX - self.balance.balance);
    }

    self.addressLabel.text = self.balance.customer.address;
    self.websiteLabel.text = self.balance.customer.website;
}

- (id) itemForService:(ShareService) shareService itemType:(ShareItem) item extraText:(NSString *) extraText {
    NSDictionary *serviceDict = self.text[$int(shareService)];
    if (!serviceDict) {
        return nil;
    }
    NSString *str = serviceDict[$int(item)];
    if (str && extraText) {
        return $str(str, extraText);
    } else {
        return str;
    }
}

#pragma mark ShareHelperDelegate

- (UIViewController *) viewControllerForShareHelper:(ShareHelper *) shareHelper {
    return self;
}

- (void) shareHelper:(ShareHelper *) shareHelper didStartShareWithService:(ShareService) shareService {

}

- (void) shareHelper:(ShareHelper *) shareHelper didCancelShareWithService:(ShareService) shareService {

}

- (void) shareHelper:(ShareHelper *) shareHelper didCompleteShareWithService:(ShareService) shareService {
    NSLog(@"Share did complete!");
    [self.balance recordShare:^(id object, NSError *error) {
        [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
    }];
}

- (void) shareHelper:(ShareHelper *) shareHelper didReceiveError:(NSError *) error forShareWithService:(ShareService) shareService {

}

- (NSString *) shareHelper:(ShareHelper *) shareHelper textForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemText extraText:self.balance.campaign.customerCompany];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper nameForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemName extraText:nil];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper captionForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemCaption extraText:self.balance.campaign.customerCompany];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper descriptionForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemDescription extraText:nil];
}

- (NSURL *) shareHelper:(ShareHelper *) shareHelper URLForShareWithService:(ShareService) shareService {
    return [NSURL URLWithString:$str(NSLocalizedString(@"SHARE_CUSTOMER_URL", @""), self.balance.campaign.customerNumber)];
}

- (UIImage *) shareHelper:(ShareHelper *) shareHelper imageForShareWithService:(ShareService) shareService {
    return nil;
}

- (NSURL *) shareHelper:(ShareHelper *) shareHelper imageURLForShareWithService:(ShareService) shareService {
    return nil;
}


@end