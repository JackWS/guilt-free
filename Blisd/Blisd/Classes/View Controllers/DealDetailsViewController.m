//
// Created by Kevin on 11/29/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "DealDetailsViewController.h"
#import "Deal.h"
#import "Customer.h"
#import "ShareView.h"
#import "NIBLoader.h"


@interface DealDetailsViewController ()

@property (nonatomic, strong) NSDictionary *text;

@end

@implementation DealDetailsViewController {

}

- (id) init {
    self = [super initWithNibName:@"DealDetailsView" bundle:nil];
    if (self) {
        self.text = @{
                $int(ShareServiceFacebook) : @{
                        $int(ShareItemText)         :    NSLocalizedString(@"DEAL_FACEBOOK_TEXT", @""),
                        $int(ShareItemName)         :    NSLocalizedString(@"DEAL_FACEBOOK_NAME", @""),
                        $int(ShareItemCaption)      :    NSLocalizedString(@"DEAL_FACEBOOK_CAPTION", @""),
                        $int(ShareItemDescription)  :    NSLocalizedString(@"DEAL_FACEBOOK_DESCRIPTION", @"")
                },
                $int(ShareServiceTwitter) : @{
                        $int(ShareItemText)         :    NSLocalizedString(@"DEAL_TWITTER_TEXT", @"")
                },
                $int(ShareServiceEmail) : @{
                        $int(ShareItemText)         :    NSLocalizedString(@"DEAL_EMAIL_TEXT", @""),
                        $int(ShareItemName)         :    NSLocalizedString(@"DEAL_EMAIL_NAME", @"")
                }
        };
    }

    return self;
}


- (void) viewDidLoad {
    [super viewDidLoad];

    self.businessNameLabel.text = self.deal.customer.company;

    self.detailsView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.detailsView.layer.borderWidth = 1.0f;
    self.detailsView.layer.cornerRadius = 8.0f;

    self.shareView = [NIBLoader loadFirstObjectFromNibNamed:@"ShareView"];
    self.shareView.shareHelper.delegate = self;
    [self.shareViewContainer addSubview:self.shareView];

    [self update];

    [self.deal.customer loadImageWithResponse:^(UIImage *image, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving image for business with name: %@, error: %@",
                    self.deal.customer.company, [error description]);
        } else {
            self.logoImageView.image = image;
        }
    }];

}

#pragma mark User Actions

- (IBAction) back:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) openLink:(id) sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.deal.customer.website]];
}

#pragma mark Helpers

- (void) update {
    self.businessNameLabel.text = self.deal.customer.company;
    self.businessTagLineLabel.text = self.deal.customer.tagLine;
    self.businessTypeLabel.text = self.deal.customer.type;

    self.descriptionLabel.text = self.deal.longDescription;

    self.addressLabel.text = self.deal.customer.address;
    self.websiteLabel.text = self.deal.customer.website;
}

- (id) itemForService:(ShareService) shareService itemType:(ShareItem) item extraText1:(NSString *) extraText1 extraText2:(NSString *) extraText2 {
    NSDictionary *serviceDict = self.text[$int(shareService)];
    if (!serviceDict) {
        return nil;
    }
    NSString *str = serviceDict[$int(item)];

    if (str && extraText1 && extraText2) {
        return $str(str, extraText1, extraText2);
    } else if (str && extraText1) {
        return $str(str, extraText1);
    } else {
        return str;
    }
}

#pragma mark ShareViewDelegate

- (UIViewController *) viewControllerForShareHelper:(ShareHelper *) shareHelper {
    return self;
}

- (void) shareHelper:(ShareHelper *) shareHelper didStartShareWithService:(ShareService) shareService {

}

- (void) shareHelper:(ShareHelper *) shareHelper didCancelShareWithService:(ShareService) shareService {

}

- (void) shareHelper:(ShareHelper *) shareHelper didCompleteShareWithService:(ShareService) shareService {
    NSLog(@"Share did complete!");
}

- (void) shareHelper:(ShareHelper *) shareHelper didReceiveError:(NSError *) error forShareWithService:(ShareService) shareService {

}

- (NSString *) shareHelper:(ShareHelper *) shareHelper textForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemText extraText1:self.deal.customer.company extraText2:self.deal.shortDescription];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper nameForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemName extraText1:nil extraText2:nil];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper captionForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemCaption extraText1:self.deal.customer.company extraText2:self.deal.shortDescription];
}

- (NSString *) shareHelper:(ShareHelper *) shareHelper descriptionForShareWithService:(ShareService) shareService {
    return [self itemForService:shareService itemType:ShareItemDescription extraText1:nil extraText2:nil];
}

- (NSURL *) shareHelper:(ShareHelper *) shareHelper URLForShareWithService:(ShareService) shareService {
    NSString *str = $str(NSLocalizedString(@"SHARE_CUSTOMER_URL", @""), self.deal.customer.customerNumber);
    NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [NSURL URLWithString:url];
}

- (UIImage *) shareHelper:(ShareHelper *) shareHelper imageForShareWithService:(ShareService) shareService {
    return nil;
}

- (NSURL *) shareHelper:(ShareHelper *) shareHelper imageURLForShareWithService:(ShareService) shareService {
    return nil;
}

@end