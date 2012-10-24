//
// Created by Kevin on 10/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "ShareView.h"
#import "NSString+Pluralize.h"
#import "AppController.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookSessionStateChanged:)
                                                 name:kAppControllerDidChangeFacebookStatusNotification
                                               object:nil];

}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction) shareFacebook:(id) sender {
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:nil block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self showFacebookDialog];
            } else {
                if (error) {
                    [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"ERROR_TITLE", @"")
                                                message:[[error userInfo] objectForKey:@"error"]
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                      otherButtonTitles:nil
                                                handler:nil];
                }
            }
        }];
    } else {
        [self showFacebookDialog];
    }
}

- (IBAction) shareTwitter:(id) sender {

}

- (IBAction) shareEmail:(id) sender {

}

#pragma mark Helpers

- (void) showFacebookDialog {
    if ([PF_FBNativeDialogs canPresentShareDialogWithSession:[PF_FBSession activeSession]]) {
        [PF_FBNativeDialogs presentShareDialogModallyFrom:self.ownerViewController
                                              initialText:@"This is the text"
                                                    image:[UIImage imageNamed:@"blisd_logo_275.png"]
                                                      url:@"http://www.blisd.com"
                                                  handler:^(PF_FBNativeDialogResult result, NSError *error) {

                                                  }];
    } else {
        PF_Facebook *fb = [PFFacebookUtils facebook];
        fb.accessToken = [PF_FBSession activeSession].accessToken;
        fb.expirationDate = [PF_FBSession activeSession].expirationDate;
        [self reallyShare];

        //[[AppController instance] openSessionWithAllowLoginUI:YES];
    }
}

- (void) reallyShare {
    NSMutableDictionary *params =
            $mdict(
            NSLocalizedString(@"FACEBOOK_SHARE_NAME", @""), @"name",
            NSLocalizedString(@"FACEBOOK_SHARE_CAPTION", @""), @"caption",
            NSLocalizedString(@"FACEBOOK_SHARE_DESCRIPTION", @""), @"description",
            NSLocalizedString(@"FACEBOOK_SHARE_LINK", @""), @"link",
            @"https://www.google.com/images/srpr/logo3w.png", @"picture");

    [[PFFacebookUtils facebook] dialog:@"feed"
                                    andParams:params
                                  andDelegate:self];
}

#pragma mark Notifications

- (void) facebookSessionStateChanged:(NSNotification *) notification {
    NSLog(@"STATE CHANGED!");
    if (PF_FBSession.activeSession.isOpen) {
        [self reallyShare];
    }
}

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

#pragma mark PF_FBDialogDelegate

- (void) dialogDidComplete:(PF_FBDialog *) dialog {

}

- (void) dialogCompleteWithUrl:(NSURL *) url {

}

- (void) dialog:(PF_FBDialog *) dialog didFailWithError:(NSError *) error {

}

- (void) dialogDidNotCompleteWithUrl:(NSURL *) url {

}

- (void) dialogDidNotComplete:(PF_FBDialog *) dialog {

}

- (BOOL) dialog:(PF_FBDialog *) dialog shouldOpenURLInExternalBrowser:(NSURL *) url {
    return NO;
}


@end