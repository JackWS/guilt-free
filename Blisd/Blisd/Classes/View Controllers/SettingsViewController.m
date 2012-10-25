//
// Created by Kevin on 10/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SettingsViewController.h"


@implementation SettingsViewController {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menubuttonsettingspressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"menubuttonsettings.png"]];
    }
    return self;
}

@end