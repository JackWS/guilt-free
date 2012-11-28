//
//  BlissViewController.m
//  Blisd
//
//  Created by JStack on 9/21/12.
//  Copyright (c) 2012 Blisd LLC All rights reserved.
//

#import <Parse/Parse.h>
#import "BlissViewController.h"
#import "HUDHelper.h"
#import "BlissBalance.h"
#import "NIBLoader.h"
#import "BlissTableViewCell.h"
#import "Customer.h"
#import "BlissOfferDetailsViewController.h"
#import "BlisdStyle.h"
#import "Campaign.h"
#import "LocationManager.h"

@interface BlissViewController ()

@property (nonatomic, retain) HUDHelper *hudHelper;
@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic, assign) BOOL balancesLoaded;
@property (nonatomic, assign) BOOL campaignsLoaded;

@end

@implementation BlissViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menubuttonblisspressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"menubuttonbliss.png"]];

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


- (void)viewDidLoad {
    [super viewDidLoad];

    self.hudHelper = [[HUDHelper alloc] initWithView:self.view];
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];

    if (!self.loaded) {
        [self.hudHelper showWithText:NSLocalizedString(@"LOADING", @"")];
    }

    [BlissBalance getBalancesForCurrentUser:^(NSArray *balances, NSError *error) {
        self.balancesLoaded = YES;
        [self update];
        if (!error) {
            self.balances = balances;
            [self removeDuplicates];
            NSLog(@"Received balances: %@", self.balances);
            [self update];
        } else {
            [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_LOADING_BLISS", @"")];
        }
    }];
    [self loadNearbyCampaigns];
}


#pragma mark Getters/Setters

- (BOOL) loaded {
    return self.balancesLoaded && self.campaignsLoaded;
}

#pragma mark Helpers

- (void) removeDuplicates {
    if (self.nearbyCampaigns && self.nearbyCampaigns.count > 0) {

        NSMutableArray *itemsToDiscard = [NSMutableArray array];
        for (Campaign *campaign in self.nearbyCampaigns) {
            for (BlissBalance *balance in self.balances) {
                if ([balance.campaign.campaignNumber isEqualToString:campaign.campaignNumber]) {
                    [itemsToDiscard addObject:campaign];
                    break;
                }
            }
        }

        NSMutableArray *newCampaigns = [self.nearbyCampaigns mutableCopy];
        [newCampaigns removeObjectsInArray:itemsToDiscard];
        self.nearbyCampaigns = newCampaigns;
    }
}

- (void) update {
    [self.tableView reloadData];

    if (self.loaded) {
        [self.hudHelper hide];
    }
}

- (void) loadNearbyCampaigns {
    if ([LocationManager instance].location) {
        [Campaign getCampaignsNear:[LocationManager instance].location.coordinate
                          response:^(NSArray *campaigns, NSError *error) {
                              self.campaignsLoaded = YES;
                              if (!error) {
                                  self.nearbyCampaigns = campaigns;
                                  [self removeDuplicates];
                              } else {
                                  //[UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_LOADING_NEARBY_CAMPAIGNS", @"")];
                              }
                              [self update];
                          }];
    } else {
        self.campaignsLoaded = YES;
        [self update];
    }
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForBalanceAtIndex:(NSInteger) index {
    static NSString *const CellIdentifier = @"BalanceCellIdentifier";

    BlissTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [NIBLoader loadFirstObjectFromNibNamed:@"BlissTableViewCell"];
    }

    BlissBalance *balance = [self.balances objectAtIndex:(NSUInteger) index];
    cell.businessLabel.text = balance.customer.company;
    cell.rewardLabel.text = balance.getX;
    if (!balance.customer.companyImage) {
        [balance.customer loadImageWithResponse:^(UIImage *image, NSError *error) {
            if (error) {
                NSLog(@"Error retrieving image for company with name: %@, error: %@", balance.customer.company, [error description]);
            } else {
                cell.logoImageView.image = image;
            }
        }];
    } else {
        cell.logoImageView.image = balance.customer.companyImage;
    }
    [cell.logoImageView loadInBackground];

    cell.progressView.progress = (CGFloat) balance.balance / (CGFloat) balance.buyX;

    return cell;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForCampaignAtIndex:(NSInteger) index {
    static NSString *const CellIdentifier = @"CampaignCellIdentifier";

    BlissTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [NIBLoader loadFirstObjectFromNibNamed:@"BlissTableViewCell"];
    }

    Campaign *campaign = [self.nearbyCampaigns objectAtIndex:index];
    cell.businessLabel.text = campaign.customerCompany;
    cell.rewardLabel.text = campaign.getX;
    if (!campaign.location.customer.companyImage) {
        [campaign.location.customer loadImageWithResponse:^(UIImage *image, NSError *error) {
            if (error) {
                NSLog(@"Error retrieving image for company with name: %@, error: %@", campaign.location.customer.company, [error description]);
            } else {
                cell.logoImageView.image = image;
            }
        }];
    } else {
        cell.logoImageView.image = campaign.location.customer.companyImage;
    }
    [cell.logoImageView loadInBackground];

    cell.progressView.progress = 0;

    return cell;
}

#pragma mark Notification Callbacks

- (void) locationUpdated:(NSNotification *) notification {
    [self loadNearbyCampaigns];
}

#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
    if ([LocationManager instance].location) {
        return 2;
    } else {
        return 1;
    }
}


- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
    if (section == 0) {
        return self.balances.count == 0 && self.loaded ? 1 : self.balances.count;
    } else {
        return self.nearbyCampaigns.count;
    }
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
    if (indexPath.section == 0) {
        if (self.balances.count == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = NSLocalizedString(@"NO_BLISS", @"");
            cell.textLabel.numberOfLines = 0;
            return cell;
        } else {
            return [self tableView:tableView cellForBalanceAtIndex:indexPath.row];
        }
    } else {
        return [self tableView:tableView cellForCampaignAtIndex:indexPath.row];
    }
}

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    return 95;
}

- (CGFloat) tableView:(UITableView *) tableView heightForFooterInSection:(NSInteger) section {
    return 0;
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
    if (section == 0) {
        return NSLocalizedString(@"MY_BLISS_TITLE", @"");
    } else {
        return NSLocalizedString(@"NEARBY_BLISS_TITLE", @"");
    }
}


#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    BlissBalance *balance = nil;
    if (indexPath.section == 0) {
        balance = [self.balances objectAtIndex:(NSUInteger) indexPath.row];
    } else {
        Campaign *campaign = [self.nearbyCampaigns objectAtIndex:indexPath.row];

        // No balance yet, so just fake one out
        balance = [[BlissBalance alloc] init];
        balance.balance = 0;
        balance.campaign = campaign;
        balance.buyX = campaign.buyX;
        balance.buyY = campaign.buyY;
        balance.getX = campaign.getX;
    }

    BlissOfferDetailsViewController *controller = [[BlissOfferDetailsViewController alloc] init];
    controller.balance = balance;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];

}

- (UIView *) tableView:(UITableView *) tableView viewForFooterInSection:(NSInteger) section {
    return [[UIView alloc] init];
}

- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
    cell.backgroundColor = [BlisdStyle colorForBackground];
}


@end
