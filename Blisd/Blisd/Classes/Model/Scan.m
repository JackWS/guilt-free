//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Scan.h"
#import "BlissBalance.h"
#import "Campaign.h"
#import "NSError+App.h"
#import "BlissScanLog.h"
#import "User.h"
#import "OutsideURL.h"
#import "ScanResult.h"
#import "CheckInBalance.h"
#import "CheckIn.h"
#import "CheckInScanLog.h"


@implementation Scan {

}

static NSString *const kTriggerString = @"http://blisd.com/";

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
    [self processCheckInScanWithID:checkInID checkIn:nil isCampaign:NO response:response];
}

+ (void) processCheckInScanWithID:(NSString *) checkInID checkIn:(CheckIn *) checkIn isCampaign:(BOOL) isCampaign response:(ResponseBlock) response {
    [CheckInBalance getByCheckInID:checkInID response:^(CheckInBalance *userCheckIn, NSError *error) {
        if (userCheckIn) {
            NSLog(@"Found user check in: %@", userCheckIn);
            userCheckIn.count++;
            [userCheckIn saveInBackgroundWithBlock:^(id object, NSError *checkInError) {
                if (checkInError) {
                    response(nil, error);
                } else {
                    NSLog(@"Successfully incremented count for check in with id: %@", checkInID);
                    [self postCheckInScanWithUserCheckIn:userCheckIn response:response];
                }
            }];
        } else {
            NSLog(@"No user check in found");
            if (checkIn) {
                [self createBalanceForCheckIn:checkIn isCampaign:isCampaign response:response];
            } else {
                [CheckIn getCheckInWithID:checkInID response:^(CheckIn *retrievedCheckIn, NSError *checkInError) {
                    if (checkInError) {
                        response(nil, error);
                    } else if (!retrievedCheckIn) {
                        response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_INVALID_URL", @"")]);
                    } else {
                        [self createBalanceForCheckIn:retrievedCheckIn isCampaign:isCampaign response:response];
                    }
                }];
            }
        }
    }];
}

+ (void) processCampaignScanWithID:(NSString *) campaignNumber response:(ResponseBlock) response {
    [BlissBalance getByCampaignNumber:campaignNumber response:^(BlissBalance *balance, NSError *error) {
        if (error) {
            response(nil, error);
        } else if (balance) {
            NSLog(@"Found balance: %@", balance);
            // Must redeem before they can add to their balance
            if (balance.balance >= balance.campaign.buyX) {
                ScanResult *result = [[ScanResult alloc] init];
                result.type = ScanResultTypeCampaign;
                result.status = ScanResultStatusRedeemRequired;
                result.balance = balance;
                response(result, nil);
            } else {
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
            }
        } else {
            NSLog(@"No balance found.");
            [Campaign getByCampaignNumber:campaignNumber response:^(Campaign *campaign, NSError *errorCampaign) {
                if (errorCampaign) {
                    response(nil, errorCampaign);
                } else if (!campaign) {
                    response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_INVALID_CAMPAIGN", @"")]);
                } else {
                    NSLog(@"Successfully retrieved campaign with id: %@", campaignNumber);
                    [BlissBalance createBalanceFromCampaign:campaign response:^(BlissBalance *newBalance, NSError *errorBalance) {
                        if (errorBalance) {
                            response(nil, errorBalance);
                        } else {
                            NSLog(@"Successfully created balance for campaign with id: %@", campaignNumber);
                            [self postCampaignScanWithBalance:newBalance response:response];
                        }
                    }];
                }
            }];
        }
    }];
}

+ (void) processCheckInForCampaign:(Campaign *) campaign response:(ResponseBlock) response {
    [CheckIn getCheckInWithCustomer:campaign.customer location:campaign.location response:^(CheckIn *checkIn, NSError *error) {
        if (error) {
            response(nil, error);
        } else {
            [self processCheckInScanWithID:checkIn.id checkIn:checkIn isCampaign:NO response:response];
        }
    }];
}

+ (void) postCampaignScanWithBalance:(BlissBalance *) balance response:(ResponseBlock) response {
    // Create a check-in for every campaign scan
    [self processCheckInForCampaign:balance.campaign response:^(id object, NSError *error) {
        // An error is normal if there is no check-in associated with this location, so just ignore it

        ScanResult *result = [[ScanResult alloc] init];
        result.type = ScanResultTypeCampaign;
        result.balance = balance;
        result.status = ScanResultStatusSuccess;
        // Get back to the UI now, and save the log in the background.
        response(result, nil);
        [Scan logBlissScan:balance];
    }];
}

+ (void) postCheckInScanWithUserCheckIn:(CheckInBalance *) balance response:(ResponseBlock) response {
    ScanResult *result = [[ScanResult alloc] init];
    result.type = ScanResultTypeCheckIn;
    result.checkIn = balance;
    result.status = ScanResultStatusSuccess;
    // Get back to the UI now, and save the log in the background.
    response(result, nil);
    [Scan logCheckInScan:balance];
}

+ (void) createBalanceForCheckIn:(CheckIn *) checkIn isCampaign:(BOOL) isCampaign response:(ResponseBlock) response {
    [CheckInBalance createBalanceFromCheckIn:checkIn response:^(CheckInBalance *cib, NSError *errorCheckIn) {
        if (errorCheckIn) {
            response(nil, errorCheckIn);
        } else {
            NSLog(@"Successfully created user check in for check in with id: %@", checkIn.id);
            // If it's a campaign, we don't want to trigger the 'check-in' UI code, so just log it
            if (isCampaign) {
                [Scan logCheckInScan:cib];
            } else {
                // Otherwise, do standard post-check-in logic
                [self postCheckInScanWithUserCheckIn:cib response:response];
            }
        }
    }];
}

+ (void) logBlissScan:(BlissBalance *) balance {
    BlissScanLog *log = [[BlissScanLog alloc] init];
    log.balance = balance;
    [log saveInBackgroundWithBlock:^(id object, NSError *errorLog) {
        // Just log it and move on
        if (errorLog) {
            NSLog(@"Error saving Bliss scan log: %@", [errorLog description]);
        } else {
            NSLog(@"Successfully created Bliss scan log for campaign with id: %@", balance.campaign.campaignNumber);
        }
    }];
}

+ (void) logCheckInScan:(CheckInBalance *) balance {
    CheckInScanLog *log = [[CheckInScanLog alloc] init];
    log.balance = balance;
    [log saveInBackgroundWithBlock:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error saving check-in scan log: %@", [error description]);
        } else {
            NSLog(@"Successfully created check-in scan log for balance with id: %@", balance.id);
        }
    }];
}


@end