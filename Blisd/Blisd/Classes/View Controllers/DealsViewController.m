//
// Created by Kevin on 10/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "DealsViewController.h"
#import "LocationManager.h"
#import "HUDHelper.h"
#import "Deal.h"
#import "BlissTableViewCell.h"
#import "Customer.h"
#import "BlisdStyle.h"
#import "NIBLoader.h"
#import "DealDetailsViewController.h"

@interface DealsViewController ()

@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, retain) HUDHelper *hudHelper;
@property (nonatomic, retain) NSArray *deals;

@end

@implementation DealsViewController {

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menubuttondealspressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"menubuttondeals.png"]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationUpdated:)
                                                     name:kLocationManagerDidFindAccurateLocationNotification
                                                   object:self];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationUpdated:)
                                                     name:kLocationManagerDidTimeOutNotification
                                                   object:self];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = [BlisdStyle colorForBackground];
    
    self.hudHelper = [[HUDHelper alloc] initWithView:self.view];
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];

    if (!self.loaded) {
        [self.hudHelper showWithText:NSLocalizedString(@"LOADING", @"")];
    }
    [self loadNearbyDeals];
}

#pragma mark Notification Callbacks

- (void) locationUpdated:(NSNotification *) notification {
    [self loadNearbyDeals];
}

#pragma mark Helpers

- (void) loadNearbyDeals {
    CLLocationCoordinate2D location = [LocationManager instance].location.coordinate;
    [Deal getDealsNear:location response:^(NSArray *deals, NSError *error) {
        self.loaded = YES;
        [self.hudHelper hide];
        if (error) {
            [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_LOADING_DEALS", @"")];
        } else {
           self.deals = deals;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark UITableViewDataSource

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
    return self.deals.count == 0 && self.loaded ? 1 : self.deals.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {

    if (self.deals.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = NSLocalizedString(@"NO_DEALS", @"");
        cell.textLabel.numberOfLines = 0;
        return cell;
    }

    static NSString *CellIdentifier = @"CellIdentifier";

    BlissTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [NIBLoader loadFirstObjectFromNibNamed:@"DealTableViewCell"];
    }

    Deal *deal = [self.deals objectAtIndex:indexPath.row];
    cell.businessLabel.text = deal.customer.company;
    cell.rewardLabel.text = deal.shortDescription;
    if (!deal.customer.companyImage) {
        [deal.customer loadImageWithResponse:^(UIImage *image, NSError *error) {
            if (error) {
                NSLog(@"Error retrieving image for company with name: %@, error: %@", deal.customer.company, [error description]);
            } else {
                cell.logoImageView.image = image;
            }
        }];
    } else {
        cell.logoImageView.image = deal.customer.companyImage;
    }
    [cell.logoImageView loadInBackground];

    return cell;
}

#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.deals.count > 0) {
        Deal *deal = [self.deals objectAtIndex:indexPath.row];
        DealDetailsViewController *controller = [[DealDetailsViewController alloc] init];
        controller.deal = deal;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    return 95;
}

- (CGFloat) tableView:(UITableView *) tableView heightForFooterInSection:(NSInteger) section {
    return 0;
}


- (UIView *) tableView:(UITableView *) tableView viewForFooterInSection:(NSInteger) section {
    return [[UIView alloc] init];
}

- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
    cell.backgroundColor = [BlisdStyle colorForBackground];
}


@end