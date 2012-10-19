//
//  Created by Kevin on 4/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "HUDHelper.h"
#import "MBProgressHUD.h"
#import "NSObject+BlocksKit.h"


@implementation HUDHelper

- (id) initWithView:(UIView *) view {
    return [self initWithView:view delegate:nil];
}

- (id) initWithView:(UIView *) view delegate:(id <MBProgressHUDDelegate>) delegate {
    self = [super init];
    if (self) {
        self.view = view;
        self.delegate = delegate;
    }

    return self;
}

- (void) showWithText:(NSString *) text {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = text;
    self.hud.delegate = self;
}

- (void) hide {
    [self hideAnimated:YES];
}

- (void) hideWithCheckmarkAndText:(NSString *) text {
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.labelText = text;
    [self performBlock:^(id sender) {
        [self hide];
    } afterDelay:0.5];
}

- (void) hideAnimated:(BOOL) animated {
    [self.hud hide:animated];
}


#pragma mark MBProgressHUDDelegate

- (void) hudWasHidden:(MBProgressHUD *) hud {
    if ([self.delegate respondsToSelector:@selector(hudWasHidden:)]) {
        [self.delegate hudWasHidden:hud];
    }

    [self.hud removeFromSuperview];
}


@end