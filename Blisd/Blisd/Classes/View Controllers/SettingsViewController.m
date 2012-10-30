//
// Created by Kevin on 10/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SettingsViewController.h"
#import "User.h"
#import "AppController.h"
#import "HUDHelper.h"
#import "Subscription.h"
#import "SwitchCell.h"

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray *subscriptions;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *userTypeCell;
@property (nonatomic, strong) UITableViewCell *logoutCell;

@property (nonatomic, retain) HUDHelper *hudHelper;
@property (nonatomic, assign) BOOL loaded;

@end

@implementation SettingsViewController {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id) init {
    self = [super init];
    if (self) {
        [self initialize];
    }

    return self;
}

- (void) initialize {
    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menubuttonsettingspressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"menubuttonsettings.png"]];
}


- (void) loadView {
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = self.tableView;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    self.hudHelper = [[HUDHelper alloc] initWithView:self.view];
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];

    if (!self.loaded) {
        [self.hudHelper showWithText:NSLocalizedString(@"LOADING", @"")];
    }
    [Subscription getSubscriptionsForCurrentUser:^(id object, NSError *error) {
        if (error) {
            [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_LOADING_SUBSCRIPTIONS", @"")];
        } else {
            self.subscriptions = object;
            [self.tableView reloadData];
            self.loaded = YES;
        }
        [self.hudHelper hide];
    }];
}

#pragma mark Helpers

- (void) switchValueChanged:(id) sender {
    UISwitch *view = (UISwitch *) sender;
    Subscription *sub = self.subscriptions[(NSUInteger) view.tag];
    BOOL status = view.on;
    sub.status = status;
    [sub saveInBackgroundWithBlock:^(id object, NSError *error) {
        if (error) {
            view.on = status;
            [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_SAVING_SUBSCRIPTION", @"")];
        }
    }];
}

#pragma mark UITableViewDataSource

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
    if (section == 0) {
        return 2;
    } else {
        return self.subscriptions.count;
    }
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
    UITableViewCell *cell = nil;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (!self.userTypeCell) {
                self.userTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                self.userTypeCell.backgroundColor = [UIColor blackColor];
                self.userTypeCell.textLabel.textColor = [UIColor whiteColor];
                self.userTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            switch ([User currentUser].userType) {
                case UserTypePassword:
                    self.userTypeCell.imageView.image = [UIImage imageNamed:@"useremail.png"];
                    self.userTypeCell.textLabel.text = NSLocalizedString(@"SETTINGS_LOGGED_IN_EMAIL", @"");
                    break;
                case UserTypeFacebook:
                    self.userTypeCell.imageView.image = [UIImage imageNamed:@"userfacebook.png"];
                    self.userTypeCell.textLabel.text = NSLocalizedString(@"SETTINGS_LOGGED_IN_FACEBOOK", @"");
                    break;
                case UserTypeTwitter:
                    self.userTypeCell.imageView.image = [UIImage imageNamed:@"usertwitter.png"];
                    self.userTypeCell.textLabel.text = NSLocalizedString(@"SETTINGS_LOGGED_IN_TWITTER", @"");
                    break;
            }
            cell =  self.userTypeCell;
        } else {
            if (!self.logoutCell) {
                self.logoutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                self.logoutCell.backgroundColor = [UIColor blackColor];
                self.logoutCell.textLabel.textColor = [UIColor whiteColor];
                self.logoutCell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.logoutCell.imageView.image = [UIImage imageNamed:@"iconlogout.png"];
                self.logoutCell.textLabel.text = NSLocalizedString(@"SETTINGS_LOGOUT", @"");
            }
            cell = self.logoutCell;
        }
    } else {
        static NSString *CellIdentifier = @"CellIdentifier";

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[SwitchCell alloc] initWithReuseIdentifier:CellIdentifier switchTarget:self switchSelector:@selector(switchValueChanged:)];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        Subscription *sub = self.subscriptions[(NSUInteger) indexPath.row];
        cell.textLabel.text = sub.customerCompany;

        UISwitch *aSwitch = ((SwitchCell *) cell).aSwitch;
        aSwitch.on = sub.status;
        aSwitch.tag = indexPath.row;
    }

    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
    if (self.subscriptions && self.subscriptions.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
    if (section == 0) {
        return NSLocalizedString(@"USER_SETTINGS_TITLE", @"");
    } else {
        return NSLocalizedString(@"SUBSCRIPTION_SETTINGS_TITLE", @"");
    }
}


#pragma mark UITableViewDelegate

- (UIView *) tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger) section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        view.backgroundColor = COLOR(50, 50, 50);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, view.frame.size.width - 10, view.frame.size.height - 10)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:17.0f];

        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 29, tableView.frame.size.width, 1)];
        bottom.backgroundColor = [UIColor whiteColor];
        [view addSubview:bottom];

        label.text = NSLocalizedString(@"USER_SETTINGS_TITLE", @"");

        [view addSubview:label];
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 70)];

        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        backgroundView.backgroundColor = COLOR(50, 50, 50);
        [view addSubview:backgroundView];

        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, backgroundView.frame.size.height - 1, tableView.frame.size.width, 1)];
        bottom.backgroundColor = [UIColor whiteColor];
        [view addSubview:bottom];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, view.frame.size.width - 10, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = NSLocalizedString(@"SUBSCRIPTION_SETTINGS_TITLE", @"");
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        [view addSubview:titleLabel];

        UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(titleLabel.frame) + 10, view.frame.size.width - 10, 20)];
        headingLabel.backgroundColor = [UIColor clearColor];
        headingLabel.textColor = [UIColor whiteColor];
        headingLabel.text = NSLocalizedString(@"LOCATIONS_FOR_NOTIFICATION", @"");
        [view addSubview:headingLabel];

        UILabel *subHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(headingLabel.frame) + 10, view.frame.size.width - 10, 12)];
        subHeadingLabel.backgroundColor = [UIColor clearColor];
        subHeadingLabel.textColor = [UIColor whiteColor];
        subHeadingLabel.text = NSLocalizedString(@"SUBSCRIPTION_SUBHEADING", @"");
        subHeadingLabel.font = [UIFont systemFontOfSize:12.0f];
        [view addSubview:subHeadingLabel];



        return view;
    }
}

- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section {
    if (section == 0) {
        return 30;
    } else {
        return 82;
    }
}


- (UIView *) tableView:(UITableView *) tableView viewForFooterInSection:(NSInteger) section {
    return [[UIView alloc] init];
}

- (NSIndexPath *) tableView:(UITableView *) tableView willSelectRowAtIndexPath:(NSIndexPath *) indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return nil;
        }
    }
    return indexPath;
}


- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [[AppController instance] logOut];
        }
    }

}


@end