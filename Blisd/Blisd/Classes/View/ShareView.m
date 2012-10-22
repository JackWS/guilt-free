//
// Created by Kevin on 10/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "ShareView.h"
#import "NSString+Pluralize.h"


@implementation ShareView {

}

- (IBAction) shareFacebook:(id) sender {

}

- (IBAction) shareTwitter:(id) sender {

}

- (IBAction) shareEmail:(id) sender {

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


@end