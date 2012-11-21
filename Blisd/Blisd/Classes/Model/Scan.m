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
#import "OutsideURL.h"
#import "ScanResult.h"
#import "UserCheckIn.h"
#import "CheckIn.h"


@implementation Scan {

}

static NSString *const kTriggerString = @"http://blisd.com/app/";

+ (void) processScanFromURL:(NSString *) url response:(ResponseBlock) response {
    NSLog(@"URL = %@", url);
    if ([[url lowercaseString] rangeOfString:kTriggerString].location != NSNotFound) {
        NSString *fragment = nil;
        if (url.length > kTriggerString.length) {
            fragment = [url substringFromIndex:kTriggerString.length];
        }

        if ([fragment rangeOfString:@"campaignNumber"].location != NSNotFound) {
            NSString *campaignId = nil;
            NSLog(@"result = %@", url);
            NSArray *components = [url $split:@"="];
            if (components.count >= 2 && components[1]) {
                campaignId = components[1];
            }
            [self processCampaignScanWithID:campaignId response:response];
        } else if ([fragment hasPrefix:@"C"]) {
            NSString *checkInID = nil;
            if (fragment.length > 1) {
                checkInID = [fragment substringFromIndex:1];
                [self processCheckInScanWithID:checkInID response:response];
            }
        } else {
            response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_INVALID_URL", @"")]);
        }
    } else {
        OutsideURL *outsideURL = [[OutsideURL alloc] init];
        outsideURL.url = url;
        outsideURL.user = [User currentUser].email;
        [outsideURL saveInBackgroundWithBlock:^(id object, NSError *error) {
            if (error) {
                NSLog(@"Error logging external URL: %@", [error description]);
                response(nil, error);
            } else {
                ScanResult *result = [[ScanResult alloc] init];
                result.type = ScanResultTypeOutsideURL;
                response(result, nil);
            }

            NSURL *externalURL = [NSURL URLWithString:url];
            [[UIApplication sharedApplication] openURL:externalURL];
        }];
    }
}

+ (void) processCheckInScanWithID:(NSString *) checkInID response:(ResponseBlock) response {
    [UserCheckIn getByCheckInID:checkInID response:^(UserCheckIn *userCheckIn, NSError *error) {
        if (userCheckIn) {
            NSLog(@"Found user check in: %@", userCheckIn);
            userCheckIn.count++;
            [userCheckIn saveInBackgroundWithBlock:^(id object, NSError *error) {
                if (error) {
                    response(nil, error);
                } else {
                    NSLog(@"Successfully incremented count for check in with id: %@", checkInID);
                    [self postCheckInScanWithUserCheckIn:userCheckIn response:response];
                }
            }];
        } else {
            NSLog(@"No user check in found");
            [CheckIn getCheckInWithID:checkInID response:^(CheckIn *checkIn, NSError *error) {
                if (error) {
                    response(nil, error);
                } else if (!checkIn) {
                    response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_INVALID_URL", @"")]);
                } else {
                    [UserCheckIn createUserCheckInFromCheckIn:checkIn response:^(UserCheckIn *uci, NSError *errorCheckIn) {
                        if (errorCheckIn) {
                            response(nil, errorCheckIn);
                        } else {
                            NSLog(@"Successfully created user check in for check in with id: %@", checkInID);
                            [self postCheckInScanWithUserCheckIn:uci response:response];
                        }
                    }];
                }
            }];
        }
    }];

}

+ (void) processCampaignScanWithID:(NSString *) campaignNumber response:(ResponseBlock) response {
    [Balance getByCampaignNumber:campaignNumber response:^(Balance *balance, NSError *error) {
        if (error) {
            response(nil, error);
        } else if (balance) {
            NSLog(@"Found balance: %@", balance);
            balance.balance++;
            [balance saveInBackgroundWithBlock:^(NSNumber *success, NSError *errorBalance) {
                if (errorBalance) {
                    response(nil, errorBalance);
                } else if (![success boolValue]) {
                    response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_GENERIC", @"")]);
                } else {
                    NSLog(@"Successfully incremented balance for campaign with id: %@", campaignNumber);
                    [self postCampaignScanWithBalance:balance response:response];
                }
            }];
        } else {
            NSLog(@"No balance found.");
            [Campaign getByCampaignNumber:campaignNumber response:^(Campaign *campaign, NSError *errorCampaign) {
                if (errorCampaign) {
                    response(nil, errorCampaign);
                } else if (!campaign) {
                    response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_INVALID_CAMPAIGN", @"")]);
                } else {
                    NSLog(@"Successfully retrieved campaign with id: %@", campaignNumber);
                    [Balance createBalanceFromCampaign:campaign response:^(Balance *newBalance, NSError *errorBalance) {
                        if (errorBalance) {
                            response(nil, errorBalance);
                        } else {
                            NSLog(@"Successfully created balance for campaign with id: %@", campaignNumber);
                            [self postCampaignScanWithBalance:balance response:response];
                        }
                    }];
                }
            }];
        }
    }];
}

+ (void) postCampaignScanWithBalance:(Balance *) balance response:(ResponseBlock) response {
    ScanResult *result = [[ScanResult alloc] init];
    result.type = ScanResultTypeCampaign;
    result.balance = balance;
    // Get back to the UI now, and save the log in the background.
    response(result, nil);
    [Scan logScan:balance.campaignNumber];
}

+ (void) postCheckInScanWithUserCheckIn:(UserCheckIn *) checkIn response:(ResponseBlock) response {
    ScanResult *result = [[ScanResult alloc] init];
    result.type = ScanResultTypeCheckIn;
    result.checkIn = checkIn;
    // Get back to the UI now, and save the log in the background.
    response(result, nil);


    // TODO: Implement
    // [Scan logScan:balance.campaignNumber];
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