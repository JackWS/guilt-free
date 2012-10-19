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
#import "Balance.h"
#import "NIBLoader.h"
#import "BlissTableViewCell.h"
#import "Customer.h"

@interface BlissViewController ()

@property (nonatomic, retain) HUDHelper *hudHelper;
@property (nonatomic, assign) BOOL loaded;

@end

@implementation BlissViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"BLISS_TAB", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
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
    [Balance getBalancesForCurrentUser:^(NSArray *balances, NSError *error) {
        [self.hudHelper hide];
        if (!error) {
            self.balances = balances;
            self.loaded = YES;
            NSLog(@"Received balances: %@", self.balances);
            [self.tableView reloadData];
        } else {
            [UIUtil displayError:error defaultText:NSLocalizedString(@"ERROR_LOADING_BLISS", @"")];
        }
    }];
}

#pragma mark UITableViewDatasource

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
    return self.balances.count;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {

    static NSString *const CellIdentifier = @"CellIdentifier";

    BlissTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [NIBLoader loadFirstObjectFromNibNamed:@"BlissTableViewCell"];
    }

    Balance *balance = [self.balances objectAtIndex:(NSUInteger) indexPath.row];
    cell.businessLabel.text = balance.customerCompany;
    cell.rewardLabel.text = balance.getX;
    if (!balance.customer.companyImage) {
        [balance.customer loadImageWithResponse:^(UIImage *image, NSError *error) {
            if (error) {
                NSLog(@"Error retrieving image for company with name: %@, error: %@", balance.customerCompany, [error description]);
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

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    return 95;
}


@end