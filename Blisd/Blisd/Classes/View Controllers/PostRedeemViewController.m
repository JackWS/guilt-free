//
// Created by Kevin on 11/26/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PostRedeemViewController.h"
#import "ShareView.h"
#import "HUDHelper.h"
#import "NIBLoader.h"
#import "BlissBalance.h"
#import "Customer.h"
#import "Campaign.h"

@interface PostRedeemViewController ()

@property (nonatomic, strong) HUDHelper *hudHelper;
@property (nonatomic, strong) NSDictionary *text;

@end


@implementation PostRedeemViewController {

}

- (id) init {
    self = [super initWithNibName:@"PostRedeemView" bundle:nil];
    if (self) {
        self.text = @{
                $int(ShareServiceFacebook) : @{
                        $int(ShareItemText)         :    NSLocalizedString(@"POST_REDEEM_FACEBOOK_TEXT", @""),
                        $int(ShareItemName)         :    NSLocalizedString(@"POST_REDEEM_FACEBOOK_NAME", @""),
                        $int(ShareItemCaption)      :    NSLocalizedString(@"POST_REDEEM_FACEBOOK_CAPTION", @""),
                        $int(ShareItemDescription)  :    NSLocalizedString(@"POST_REDEEM_FACEBOOK_DESCRIPTION", @"")
                },
                $int(ShareServiceTwitter) : @{
                        $int(ShareItemText)         :    NSLocalizedString(@"POST_REDEEM_TWITTER_TEXT", @"")
                },
                $int(ShareServiceEmail) : @{
                        $int(ShareItemText)         :    NSLocalizedString(@"POST_REDEEM_EMAIL_TEXT", @""),
                        $int(ShareItemName)         :    NSLocalizedString(@"POST_REDEEM_EMAIL_NAME", @"")
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
}

#pragma mark User Actions

- (IBAction) back:(id) sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark Helpers

- (id) itemForService:(ShareService) shareService itemType:(ShareItem) item extraText1:(NSString *) extraText1 extraText2:(NSString *) extraText2 {
    NSDictionary *serviceDict = self.text[$int(shareService)];
    if (!serviceDict) {
        return nil;
    }
    NSString *str = serviceDict[$int(item)];
    if (str && extraText1) {
        return $str(str, extraText1);
    } else if (str && extraText1 && extraText2) {
        return $str(str, extraText1, extraText2);
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) shareHelper:(ShareHelper *) shareHelper didReceiveError:(NSError *) error forShareWithService:(ShareService) shareService {

}

- (NSString *) shareHelper:(ShareHelper *) shareHelper textForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemText extraText1:self.balance.campaign.getX extraText2:self.balance.customer.company];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper nameForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemName extraText1:nil extraText2:nil];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper captionForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemCaption extraText1:self.balance.campaign.getX extraText2:nil];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper descriptionForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemDescription extraText1:nil extraText2:nil];
}

- (NSURL *) shareHelper:(ShareHelper *) shareHelper URLForShareWithService:(ShareService) shareService {
    return [NSURL URLWithString:$str(NSLocalizedString(@"SHARE_CUSTOMER_URL", @""), self.balance.customer.customerNumber)];
}

- (UIImage *) shareHelper:(ShareHelper *) shareHelper imageForShareWithService:(ShareService) shareService {
    return nil;
}

- (NSURL *) shareHelper:(ShareHelper *) shareHelper imageURLForShareWithService:(ShareService) shareService {
    return nil;
}


@end