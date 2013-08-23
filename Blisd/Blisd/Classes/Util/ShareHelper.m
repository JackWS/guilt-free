//
// Created by Kevin on 10/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Twitter/Twitter.h>
#import <Parse/Parse.h>
#import "ShareHelper.h"
#import "AppController.h"
#import "Facebook.h"


@implementation ShareHelper {

}

- (IBAction) shareFacebook:(id) sender {
    // First try the native approach
    if ([SLComposeViewController class]
            && [SLComposeViewController respondsToSelector:@selector(isAvailableForServiceType:)]
            && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]
            && [self.delegate respondsToSelector:@selector(viewControllerForShareHelper:)]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [self setParametersForController:controller shareService:ShareServiceFacebook];
        [[self.delegate viewControllerForShareHelper:self] presentModalViewController:controller animated:YES];
    } else if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // If that doesn't work, link them up with the PFUser and then present the old-style dialog
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:nil block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self shareFacebookNonNative];
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
        [self shareFacebookNonNative];
    }
}

- (IBAction) shareTwitter:(id) sender {
    if ([SLComposeViewController class] &&
            [SLComposeViewController respondsToSelector:@selector(isAvailableForServiceType:)]
            && [self.delegate respondsToSelector:@selector(viewControllerForShareHelper:)]){
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [self setParametersForController:controller shareService:ShareServiceTwitter];
        [[self.delegate viewControllerForShareHelper:self] presentModalViewController:controller animated:YES];
    } else if ([TWTweetComposeViewController class]
            && [self.delegate respondsToSelector:@selector(viewControllerForShareHelper:)]) {
        TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
        [self setParametersForController:controller shareService:ShareServiceTwitter];
        [[self.delegate viewControllerForShareHelper:self] presentModalViewController:controller animated:YES];
    } else {
        [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"NO_TWITTER_ACCOUNT_TITLE", @"")
                                    message:NSLocalizedString(@"NO_TWITTER_ACCOUNT_MESSAGE", @"")
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil
                                    handler:nil];
    }
}

- (IBAction) shareEmail:(id) sender {
    if ([MFMailComposeViewController canSendMail]) {
        if ([self.delegate respondsToSelector:@selector(shareHelper:textForShareWithService:)]
                && [self.delegate respondsToSelector:@selector(shareHelper:nameForShareWithService:)]) {

            MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:[self.delegate shareHelper:self nameForShareWithService:ShareServiceEmail]];
            [controller setMessageBody:[self.delegate shareHelper:self textForShareWithService:ShareServiceEmail] isHTML:NO];
            [[self.delegate viewControllerForShareHelper:self] presentModalViewController:controller animated:YES];
        }
    } else {
        [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"NO_EMAIL_ACCOUNT_TITLE", @"")
                                    message:NSLocalizedString(@"NO_EMAIL_ACCOUNT_MESSAGE", @"")
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil
                                    handler:nil];
    }

}

#pragma mark Helpers

- (void) setParametersForController:(id) controller shareService:(ShareService) shareService {
    SLComposeViewController *vc = (SLComposeViewController *) controller;
    if ([self.delegate respondsToSelector:@selector(shareHelper:textForShareWithService:)]) {
        [vc setInitialText:[self.delegate shareHelper:self textForShareWithService:shareService]];
    }
    if ([self.delegate respondsToSelector:@selector(shareHelper:imageForShareWithService:)]) {
        [vc addImage:[self.delegate shareHelper:self imageForShareWithService:shareService]];
    }
    if ([self.delegate respondsToSelector:@selector(shareHelper:URLForShareWithService:)]) {
        [vc addURL:[self.delegate shareHelper:self URLForShareWithService:shareService]];
    }
    vc.completionHandler = ^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone) {
            if ([self.delegate respondsToSelector:@selector(shareHelper:didCompleteShareWithService:)]) {
                [self.delegate shareHelper:self didCompleteShareWithService:shareService];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(shareHelper:didCancelShareWithService:)]) {
                [self.delegate shareHelper:self didCancelShareWithService:shareService];
            }
        }
        [[self.delegate viewControllerForShareHelper:self] dismissModalViewControllerAnimated:YES];
    };
}

- (void) shareFacebookNonNative {
    Facebook *fb = [AppController instance].facebook;

    NSString *name = nil;
    if ([self.delegate respondsToSelector:@selector(shareHelper:nameForShareWithService:)]) {
        name = [self.delegate shareHelper:self nameForShareWithService:ShareServiceFacebook];
    }
    NSString *caption = nil;
    if ([self.delegate respondsToSelector:@selector(shareHelper:captionForShareWithService:)]) {
        caption = [self.delegate shareHelper:self captionForShareWithService:ShareServiceFacebook];
    }
    NSString *description = nil;
    if ([self.delegate respondsToSelector:@selector(shareHelper:descriptionForShareWithService:)]) {
        description = [self.delegate shareHelper:self descriptionForShareWithService:ShareServiceFacebook];
    }
    NSString *link = nil;
    if ([self.delegate respondsToSelector:@selector(shareHelper:URLForShareWithService:)]) {
        link = [[self.delegate shareHelper:self URLForShareWithService:ShareServiceFacebook] absoluteString];
    }
    NSString *image = nil;
    if ([self.delegate respondsToSelector:@selector(shareHelper:imageURLForShareWithService:)]) {
        image = [[self.delegate shareHelper:self imageURLForShareWithService:ShareServiceFacebook] absoluteString];
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if  (name) {
        params[@"name"] = name;
    }
    if (caption) {
        params[@"caption"] = caption;
    }
    if (description) {
        params[@"description"] = description;
    }
    if (link) {
        params[@"link"] = link;
    }
    if (image) {
        params[@"picture"] = image;
    }

    [fb dialog:@"feed"
     andParams:params
   andDelegate:self];
}

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*) parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
                [[kv objectAtIndex:1]
                        stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

#pragma mark PF_FBDialogDelegate

// Handle the publish feed call back
- (void)dialogCompleteWithUrl:(NSURL *)url {
    // We get this callback even if the user cancels. Try to extract the post_id to determine if they actually shared.
    // Only proceed if they did share.
    NSDictionary *params = [self parseURLParams:[url query]];
    NSString *postId = [params valueForKey:@"post_id"];
    if (postId) {
        NSLog(@"FBDialog complete with url: %@", [url absoluteString]);
        if ([self.delegate respondsToSelector:@selector(shareHelper:didCompleteShareWithService:)]) {
            [self.delegate shareHelper:self didCompleteShareWithService:ShareServiceFacebook];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(shareHelper:didCancelShareWithService:)]) {
            [self.delegate shareHelper:self didCancelShareWithService:ShareServiceFacebook];
        }
    }
}

- (void) dialogDidNotCompleteWithUrl:(NSURL *) url {
    if ([self.delegate respondsToSelector:@selector(shareHelper:didCancelShareWithService:)]) {
        [self.delegate shareHelper:self didCancelShareWithService:ShareServiceFacebook];
    }
    NSLog(@"FBDialog did not complete.");
}


- (void) dialog:(FBDialog *) dialog didFailWithError:(NSError *) error {
    if ([self.delegate respondsToSelector:@selector(shareHelper:didCancelShareWithService:)]) {
        [self.delegate shareHelper:self didCancelShareWithService:ShareServiceFacebook];
    }
    NSLog(@"FBDialog error: %@", [error description]);
}

- (BOOL) dialog:(FBDialog *) dialog shouldOpenURLInExternalBrowser:(NSURL *) url {
    return NO;
}

#pragma mark MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *) controller didFinishWithResult:(MFMailComposeResult) result error:(NSError *) error {
    if (result == MFMailComposeResultSent) {
        if ([self.delegate respondsToSelector:@selector(shareHelper:didCompleteShareWithService:)]) {
            [self.delegate shareHelper:self didCompleteShareWithService:ShareServiceEmail];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(shareHelper:didCancelShareWithService:)]) {
            [self.delegate shareHelper:self didCancelShareWithService:ShareServiceEmail];
        }
    }
    [[self.delegate viewControllerForShareHelper:self] dismissModalViewControllerAnimated:YES];
}


@end