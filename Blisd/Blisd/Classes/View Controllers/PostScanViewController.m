//
// Created by Kevin on 10/15/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "PostScanViewController.h"
#import "ShareView.h"
#import "NIBLoader.h"
#import "HUDHelper.h"
#import "PostRedeemViewController.h"
#import "Campaign.h"
#import "Customer.h"

typedef enum {
    PostScanStateProgress,
    PostScanStateAlmostEarned,
    PostScanStateEarned
} PostScanState;

@interface PostScanViewController ()

@property (nonatomic, strong) BlissBalance *balance;
@property (nonatomic, assign) PostScanState state;
@property (nonatomic, retain) NSDictionary *text;
@property (nonatomic, strong) HUDHelper *hudHelper;


@end

@implementation PostScanViewController {

}

- (id) initWithBalance:(BlissBalance *) balance {
    self = [super initWithNibName:@"PostScanView" bundle:nil];
    if (self) {
        self.balance = balance;

        BOOL earned = self.balance.balance >= self.balance.buyX;
        BOOL almostEarned = self.balance.balance + 1 == self.balance.buyX;
        if (earned) {
            self.state = PostScanStateEarned;
        } else if (almostEarned) {
            self.state = PostScanStateAlmostEarned;
        } else {
            self.state = PostScanStateProgress;
        }

        self.text = @{
            $int(PostScanStateProgress) : @{
                $int(ShareServiceFacebook) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_FACEBOOK_PROGRESS_TEXT", @""),
                    $int(ShareItemName)         :    NSLocalizedString(@"POST_SCAN_FACEBOOK_PROGRESS_NAME", @""),
                    $int(ShareItemCaption)      :    NSLocalizedString(@"POST_SCAN_FACEBOOK_PROGRESS_CAPTION", @""),
                    $int(ShareItemDescription)  :    NSLocalizedString(@"POST_SCAN_FACEBOOK_PROGRESS_DESCRIPTION", @"")
                },
                $int(ShareServiceTwitter) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_TWITTER_PROGRESS_TEXT", @"")
                },
                $int(ShareServiceEmail) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_EMAIL_PROGRESS_TEXT", @""),
                    $int(ShareItemName)         :    NSLocalizedString(@"POST_SCAN_EMAIL_PROGRESS_NAME", @"")
                }
            },
            $int(PostScanStateAlmostEarned) : @{
                $int(ShareServiceFacebook) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_FACEBOOK_ALMOST_TEXT", @""),
                    $int(ShareItemName)         :    NSLocalizedString(@"POST_SCAN_FACEBOOK_ALMOST_NAME", @""),
                    $int(ShareItemCaption)      :    NSLocalizedString(@"POST_SCAN_FACEBOOK_ALMOST_CAPTION", @""),
                    $int(ShareItemDescription)  :    NSLocalizedString(@"POST_SCAN_FACEBOOK_ALMOST_DESCRIPTION", @"")
                },
                $int(ShareServiceTwitter) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_TWITTER_ALMOST_TEXT", @"")
                },
                $int(ShareServiceEmail) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_EMAIL_ALMOST_TEXT", @""),
                    $int(ShareItemName)         :    NSLocalizedString(@"POST_SCAN_EMAIL_ALMOST_NAME", @"")
                }
            },
            $int(PostScanStateEarned) :@{
                $int(ShareServiceFacebook) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_FACEBOOK_EARNED_TEXT", @""),
                    $int(ShareItemName)         :    NSLocalizedString(@"POST_SCAN_FACEBOOK_EARNED_NAME", @""),
                    $int(ShareItemCaption)      :    NSLocalizedString(@"POST_SCAN_FACEBOOK_EARNED_CAPTION", @""),
                    $int(ShareItemDescription)  :    NSLocalizedString(@"POST_SCAN_FACEBOOK_EARNED_DESCRIPTION", @"")
                },
                $int(ShareServiceTwitter) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_TWITTER_EARNED_TEXT", @"")
                },
                $int(ShareServiceEmail) : @{
                    $int(ShareItemText)         :    NSLocalizedString(@"POST_SCAN_EMAIL_EARNED_TEXT", @""),
                    $int(ShareItemName)         :    NSLocalizedString(@"POST_SCAN_EMAIL_EARNED_NAME", @"")
                }
            }
        };
    }

    return self;
}

#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    self.hudHelper = [[HUDHelper alloc] initWithView:self.view];

    self.shareView = [NIBLoader loadFirstObjectFromNibNamed:@"ShareView"];
    self.shareView.shareHelper.delegate = self;
    [self.shareViewContainer addSubview:self.shareView];

    srandom((unsigned int) time(NULL));
    int num = random() % 7 + 1;
    self.flareImageView.image = [UIImage imageNamed:$str(@"redtag%d.png", num)];

    if (self.state == PostScanStateEarned) {
        self.redeemButton.hidden = NO;
        self.progressView.hidden = YES;
    } else {
        self.redeemButton.hidden = YES;
        self.progressView.hidden = NO;
        if (self.state == PostScanStateAlmostEarned) {
            self.buyXLabel.text = NSLocalizedString(@"NEXT_VISIT_GET", @"");
            self.earnLabel.text = nil;
        } else {
            self.buyXLabel.text = $str(NSLocalizedString(@"N_MORE_PURCHASES", @""), self.balance.campaign.buyX - self.balance.balance);
            self.earnLabel.text = NSLocalizedString(@"UNTIL_YOU_EARN", @"");
        }
        self.getXLabel.text = self.balance.campaign.getX;
    }
}


#pragma mark User Actions

- (IBAction) back:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
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
                                      PostRedeemViewController *controller = [[PostRedeemViewController alloc] init];
                                      [self.navigationController pushViewController:controller animated:YES];

//                                      [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"REDEEMED_TITLE", @"")
//                                                                  message:NSLocalizedString(@"REDEEMED_MESSAGE", @"")
//                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"")
//                                                        otherButtonTitles:nil
//                                                                  handler:nil];
//                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                  } else {
                                      [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_REDEEMING", @"")];
                                  }
                              }];
                          }];
    [alertView show];
}


- (IBAction) shareFacebook:(id) sender {

}

- (IBAction) shareTwitter:(id) sender {

}

- (IBAction) shareEmail:(id) sender {

}

#pragma mark Helpers

- (id) itemForService:(ShareService) shareService itemType:(ShareItem) item extraText:(NSString *) extraText {
    NSDictionary *stateDict = self.text[$int(self.state)];
    if (!stateDict) {
        return nil;
    }
    NSDictionary *serviceDict = stateDict[$int(shareService)];
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

- (void) shareHelper:(ShareHelper *) shareHelper didCompleteShareWithService:(ShareService) shareService {
    NSLog(@"Share did complete!");
    [self.balance recordShare:^(id object, NSError *error) {
        if (error) {
            // I guess they just don't get it...
            NSLog(@"Error recording share: %@", [error description]);
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void) shareHelper:(ShareHelper *) shareHelper didCancelShareWithService:(ShareService) shareService {

}

- (void) shareHelper:(ShareHelper *) shareHelper didReceiveError:(NSError *) error forShareWithService:(ShareService) shareService {

}

- (NSString *) shareHelper:(ShareHelper *) shareHelper textForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemText extraText:self.balance.customer.company];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper nameForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemName extraText:nil];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper captionForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemCaption extraText:self.balance.customer.company];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper descriptionForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemDescription extraText:nil];
}

- (NSURL *) shareHelper:(ShareHelper *) shareHelper URLForShareWithService:(ShareService) shareService {
    return [NSURL URLWithString:$str(NSLocalizedString(@"SHARE_CUSTOMER_URL", @""), self.balance.customer.company)];
}

- (UIImage *) shareHelper:(ShareHelper *) shareHelper imageForShareWithService:(ShareService) shareService {
    return nil;
}

- (NSURL *) shareHelper:(ShareHelper *) shareHelper imageURLForShareWithService:(ShareService) shareService {
    return nil;
}


@end