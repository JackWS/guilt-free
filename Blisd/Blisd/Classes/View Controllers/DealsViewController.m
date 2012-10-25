//
// Created by Kevin on 10/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DealsViewController.h"


@implementation DealsViewController {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menubuttondealspressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"menubuttondeals.png"]];
    }
    return self;
}

@end