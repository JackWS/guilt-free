//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Scan.h"
#import "Balance.h"
#import "Campaign.h"
#import "NSError+App.h"
#import "ScanLog.h"
#import "User.h"


@implementation Scan {

}
+ (void) processScanFromURL:(NSString *) url response:(ResponseBlock) response {

    NSString *campaignId = nil;

    NSLog(@"result = %@", url);
    NSArray *components = [url $split:@"="];
    if (components.count >= 2 && components[1]) {
        campaignId = components[1];
    }

    [Balance getByCampaignId:campaignId response:^(Balance *balance, NSError *error) {
        if (error) {
            response(nil, error);
        } else if (balance) {
            NSLog(@"Found balance: %@", balance);
            balance.balance += 1;
            [balance saveInBackgroundWithBlock:^(NSNumber *success, NSError *errorBalance) {
                if (errorBalance) {
                    response(nil, errorBalance);
                } else if (![success boolValue]) {
                    response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_GENERIC", @"")]);
                } else {
                    NSLog(@"Successfully incremented balance for campaign with id: %@", campaignId);
                    response(balance, nil);
                    [Scan logScan:campaignId];
                }
            }];
        } else {
            NSLog(@"No balance found.");
            [Campaign getByCampaignNumber:campaignId response:^(Campaign *campaign, NSError *errorCampaign) {
                if (errorCampaign) {
                    response(nil, errorCampaign);
                } else if (!campaign) {
                    response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_INVALID_CAMPAIGN", @"")]);
                } else {
                    NSLog(@"Successfully retrieved campaign with id: %@", campaignId);
                    [Balance createBalanceFromCampaign:campaign response:^(Balance *newBalance, NSError *errorBalance) {
                        if (errorBalance) {
                            response(nil, errorBalance);
                        } else {
                            NSLog(@"Successfully created balance for campaign with id: %@", campaignId);
                            // Get back to the UI now, and save the log in the background.
                            response(newBalance, nil);
                            [Scan logScan:campaign.campaignNumber];
                        }
                    }];
                }
            }];
        }
    }];

}

+ (void) logScan:(NSString *) campaignId {
    ScanLog *log = [[ScanLog alloc] init];
    log.user = [User currentUser].email;
    log.campaignNumber = campaignId;
    [log saveInBackgroundWithBlock:^(id object, NSError *errorLog) {
        // Just log it and move on
        if (errorLog) {
            NSLog(@"Error saving scan log: %@", [errorLog description]);
        } else {
            NSLog(@"Successfully created scan log for campaign with id: %@", campaignId);
        }
    }];
}


@end