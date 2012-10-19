//
// Created by Kevin on 8/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIUtil.h"
#import "NSError+App.h"


@implementation UIUtil {

}

+ (void) displayFatalError:(NSError *) error defaultText:(NSString *) defaultText retryBlock:(void (^)()) retryBlock {
    NSString *display = [UIUtil getDisplayText:error defaultText:defaultText];

    [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"ERROR_TITLE", @"Title for error alert view")
                                message:display
                      cancelButtonTitle:NSLocalizedString(@"RETRY", @"")
                      otherButtonTitles:nil
                                handler:^(UIAlertView *view, NSInteger i) {
                                    retryBlock();
                                }];
}

+ (void) displayError:(NSError *) error defaultText:(NSString *) defaultText {
    NSString *display = [UIUtil getDisplayText:error defaultText:defaultText];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_TITLE", @"Title for error alert view")
                                                                 message:display
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil];
    [alertView show];

}

+ (NSString *) getDisplayText:(NSError *) error defaultText:(NSString *) defaultText {
    NSString *details = [error appDetailsText];
    if (!details) {
        details = [error appDisplayText];
    }
    NSLog(@"%@", details);

    NSString *display = [error appDisplayText];
    if (!display) {
        display = defaultText;
    }
    if (!display) {
        display = NSLocalizedString(@"ERROR_GENERIC", @"Generic error");
    }
    return display;
}

@end