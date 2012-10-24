//
// Created by Kevin on 10/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "ShareView.h"
#import "NSString+Pluralize.h"
#import "AppController.h"
#import "ShareHelper.h"

@implementation ShareView {

}

- (id) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }

    return self;
}

- (id) initWithCoder:(NSCoder *) aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }

    return self;
}

- (void) initialize {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(facebookSessionStateChanged:)
//                                                 name:kAppControllerDidChangeFacebookStatusNotification
//                                               object:nil];

    self.shareHelper = [[ShareHelper alloc] init];
}

- (void) dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction) shareFacebook:(id) sender {
    [self.shareHelper shareFacebook:sender];
//    // First try the native approach
//    if ([SLComposeViewController class] &&
//            [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        [controller setInitialText:@"This is the text"];
//       // [controller addImage:[UIImage imageNamed:@"blisd_logo_275.png"]];
//        [controller addURL:[NSURL URLWithString:@"http://www.blisd.com"]];
//        [self.ownerViewController presentModalViewController:controller animated:YES];
//    } else if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        // If that doesn't work, link them up with the PFUser and then present the old-style dialog
//        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:nil block:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                [self shareFacebookNonNative];
//            } else {
//                if (error) {
//                    [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"ERROR_TITLE", @"")
//                                                message:[[error userInfo] objectForKey:@"error"]
//                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
//                                      otherButtonTitles:nil
//                                                handler:nil];
//                }
//            }
//        }];
//    } else {
//        [self shareFacebookNonNative];
//    }
}

- (IBAction) shareTwitter:(id) sender {
    [self.shareHelper shareTwitter:sender];

//    if ([SLComposeViewController class] &&
//            [SLComposeViewController respondsToSelector:@selector(isAvailableForServiceType:)]) {
//            // && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
//        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//        [controller setInitialText:@"This is the text"];
//        [controller addImage:[UIImage imageNamed:@"blisd_logo_275.png"]];
//        [controller addURL:[NSURL URLWithString:@"http://www.blisd.com"]];
//        [self.ownerViewController presentModalViewController:controller animated:YES];
//    } else if ([TWTweetComposeViewController class]) {
//        TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
//        [controller setInitialText:@"This is the text"];
//        //[controller addImage:[UIImage imageNamed:@"blisd_logo_275.png"]];
//        [controller addURL:[NSURL URLWithString:@"http://www.blisd.com"]];
//        [self.ownerViewController presentModalViewController:controller animated:YES];
//    }
//
//    else {
//        // If that doesn't work, link them up with the PFUser and then present the old-style dialog
//        [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"NO_TWITTER_ACCOUNT_TITLE", @"")
//                                    message:NSLocalizedString(@"NO_TWITTER_ACCOUNT_MESSAGE", @"")
//                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
//                          otherButtonTitles:nil
//                                    handler:nil];
//    }
}

- (IBAction) shareEmail:(id) sender {
    [self.shareHelper shareEmail:sender];
}

//#pragma mark Helpers
//
//- (void) shareFacebookNonNative {
//    PF_Facebook *fb = [PFFacebookUtils facebook];
//    fb.accessToken = [PF_FBSession activeSession].accessToken;
//    fb.expirationDate = [PF_FBSession activeSession].expirationDate;
//
//    NSMutableDictionary *params =
//            $mdict(
//            NSLocalizedString(@"FACEBOOK_SHARE_NAME", @""), @"name",
//            NSLocalizedString(@"FACEBOOK_SHARE_CAPTION", @""), @"caption",
//            NSLocalizedString(@"FACEBOOK_SHARE_DESCRIPTION", @""), @"description",
//            NSLocalizedString(@"FACEBOOK_SHARE_LINK", @""), @"link",
//            @"https://www.google.com/images/srpr/logo3w.png", @"picture");
//
//    [fb dialog:@"feed"
//                                    andParams:params
//                                  andDelegate:self];
//}
//
//#pragma mark Notifications
//
//- (void) facebookSessionStateChanged:(NSNotification *) notification {
//    NSLog(@"STATE CHANGED!");
//    if (PF_FBSession.activeSession.isOpen) {
//        [self shareFacebookNonNative];
//    }
//}

#pragma mark UIView Over-Rides

- (void) layoutSubviews {
    [super layoutSubviews];

    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 8.0f;

    self.statusLabel.text =
            $str(@"%@ %@.", NSLocalizedString(@"BALANCE_STATUS", @""),
            [NSLocalizedString(@"BALANCE_PLURALIZABLE", @"") pluralize:self.progress]);
}

@end