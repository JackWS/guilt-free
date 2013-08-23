//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "BlissBalance.h"
#import "MockData.h"
#import "NSError+App.h"
#import "Campaign.h"
#import "User.h"
#import "PFObject+NonNull.h"
#import "Customer.h"
#import "Subscription.h"


@implementation BlissBalance {

}

static NSString *const kClassName = @"UBal";

static NSString *const kUserKey = @"user_Pointer";

//static NSString *const kCustomerCompanyKey = @"customerCompany";
//static NSString *const kCustomerNumberKey = @"customerNumber";
//static NSString *const kCampaignNumberKey = @"campaignNumber";
static NSString *const kBuyXKey = @"buyx";
static NSString *const kBuyYKey = @"buyy";
static NSString *const kGetXKey = @"getx";
static NSString *const kCampaignBalanceKey = @"campaignBalance";
//static NSString *const kIconTypeKey = @"iconType";
//static NSString *const kShortMessageKey = @"shortMessage";
static NSString *const kRedeemedCountKey = @"redeemedCount";
static NSString *const kSharedKey = @"shared";

static NSString *const kCampaignKey = @"camp_Pointer";
//static NSString *const kCustomerKey = @"cust_Pointer";
static NSString *const kCampaignCustomerKey = @"camp_Pointer.cust_Pointer";
static NSString *const kLocationKey = @"camp_Pointer.loc_Pointer";

+ (void) getBalancesForCurrentUser:(ResponseBlock) response {
    [self getBalancesForCurrentUserResponse:response];
}

+ (void) getBalancesForCurrentUserResponse:(ResponseBlock) response {
#if MOCK_DATA
    [MockData callAfterDelay:1
            successBlock:^{
                response([MockData generateBalanceList], nil);
            } failureBlock:^{
        response(nil, [NSError appErrorWithDisplayText:@"OMG something horrible happened!"]);
    }];
#else
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
//    [query orderByAscending:kCustomerCompanyKey];
    [query includeKey:kCampaignKey];
    [query includeKey:kCampaignCustomerKey];
    [query includeKey:kLocationKey];

    // Make sure there is a valid campaign
    [query whereKeyExists:kCampaignKey];

    // Make sure the campaign has both a customer and location
    [query whereKey:kCampaignKey matchesQuery:[Campaign queryForValidCustomerAndLocation]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            response(nil, error);
        } else {
            NSMutableArray *balances = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *obj in objects) {
                BlissBalance *bal = [BlissBalance balanceFromPFObject:obj];
                [balances addObject:bal];
            }
            response(balances, nil);
        }
    }];

//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (error) {
//            response(nil, error);
//        } else {
//            NSMutableArray *balances = [NSMutableArray arrayWithCapacity:objects.count];
//            NSMutableArray *companyNames = [NSMutableArray arrayWithCapacity:objects.count];
//            for (PFObject *obj in objects) {
//                BlissBalance *bal = [BlissBalance balanceFromPFObject:obj];
//                [balances addObject:bal];
//                [companyNames addObject:bal.customerCompany];
//            }
//            if (includeCompanies) {
//                [Customer findWithNames:companyNames response:^(NSArray *customerObjects, NSError *companiesError) {
//                    if (companiesError) {
//                        response(nil, companiesError);
//                    } else {
//                        for (BlissBalance *bal in balances) {
//                            for (Customer *customer in customerObjects) {
//                                if ([bal.customerCompany isEqualToString:customer.company]) {
//                                    bal.customer = customer;
//                                    break;
//                                }
//                            }
//                        }
//                        response(balances, nil);
//                    }
//                }];
//            } else {
//                response(balances, nil);
//            }
//        }
//    }];
#endif
}


+ (void) getByCampaignNumber:(NSString *) campaignId response:(ResponseBlock) response {
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query includeKey:kCampaignKey];
    [query includeKey:kCampaignCustomerKey];

    PFQuery *campaignQuery = [Campaign queryForCampaignNumber:campaignId];
    [query whereKey:kCampaignKey matchesQuery:campaignQuery];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving campaign id: %@", [error description]);
            response(nil, error);
        } else if (objects && objects.count >= 1) {
            BlissBalance *balance = [BlissBalance balanceFromPFObject:objects[0]];
            response(balance, nil);
        } else {
            response(nil, nil);
        }
    }];
}

+ (void) createBalanceFromCampaign:(Campaign *) campaign response:(ResponseBlock) response {
    BlissBalance *balance = [[BlissBalance alloc] init];
    balance.campaign = campaign;
    balance.balance = 1;
    balance.buyX = campaign.buyX;
    balance.buyY = campaign.buyY;
    balance.getX = campaign.getX;

    [balance saveInBackgroundWithBlock:^(NSNumber *succeeded, NSError *error) {
        if (error) {
            response(nil, error);
        } else if (![succeeded boolValue]) {
            response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_GENERIC", @"")]);
        } else {
            // Return this value, the rest can be done in the background.
            response(balance, nil);

            Subscription *subscription = [[Subscription alloc] init];
            subscription.customerCompany = campaign.customerCompany;
            subscription.status = YES;
            [subscription saveInBackgroundWithBlock:^(id object, NSError *subscriptionError) {
                if (subscriptionError) {
                    NSLog(@"Error creating subscription for customer: %@, %@",
                            subscription.customerCompany, [subscriptionError description]);
                } else {
                    NSLog(@"Succesfully created subscription for campaign number: %@", subscription.customerCompany);
                }
            }];
        }
    }];

//    [balance setNonNullObject:campaign.campaignNumber forKey:kCampaignNumberKey];
//    [balance setNonNullObject:$int(campaign.buyX) forKey:kBuyXKey];
//    [balance setNonNullObject:campaign.buyY forKey:kBuyYKey];
//    [balance setNonNullObject:campaign.getX forKey:kGetXKey];
//    [balance setNonNullObject:campaign.customerCompany forKey:kCustomerCompanyKey];
//    [balance setNonNullObject:campaign.customerNumber forKey:kCustomerNumberKey];
//    [balance setNonNullObject:$str(@"%d %@ and get %@", campaign.buyX, campaign.buyY, campaign.getX) forKey:kShortMessageKey];


//    [balance saveInBackgroundWithBlock:^(BOOL succeeded, NSError *balanceError) {
//        if (balanceError) {
//            response(nil, balanceError);
//        } else if (!succeeded) {
//            response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_GENERIC", @"")]);
//        } else {
//            BlissBalance *bal = [BlissBalance balanceFromPFObject:balance];
//            // Return this value, the rest can be done in the background.
//            response(bal, nil);
//
//            Subscription *subscription = [[Subscription alloc] init];
//            subscription.customerCompany = campaign.customerCompany;
//            subscription.status = YES;
//            [subscription saveInBackgroundWithBlock:^(id object, NSError *subscriptionError) {
//                if (subscriptionError) {
//                    NSLog(@"Error creating subscription for customer: %@, %@",
//                            subscription.customerCompany, [subscriptionError description]);
//                } else {
//                    NSLog(@"Succesfully created subscription for campaign number: %@", subscription.customerCompany);
//                }
//            }];
//        }
//    }];
}

- (Customer *) customer {
    return self.campaign.customer;
}


- (void) redeemResponse:(ResponseBlock) response {
    if (!self.balance >= self.campaign.buyX) {
        response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_CANNOT_REDEEM", @"")]);
    } else {
        self.balance = 0;
        self.redeemedCount += 1;
        [self saveInBackgroundWithBlock:response];
    }
}

- (void) recordShare:(ResponseBlock) response {
    if (self.shared) {
        // Can't get bonus more than once for the same offer
        response($bool(NO), nil);
    } else {
        self.balance++;
        self.shared = YES;
        NSLog(@"Recording share for balance with ID: %@, balance = %d, shared = %d", self.id, self.balance, self.shared);
        [self saveInBackgroundWithBlock:response];
    }
}


+ (BlissBalance *) balanceFromPFObject:(PFObject *) object {
    if (!object) {
        return nil;
    }

    BlissBalance *bal = [[BlissBalance alloc] initWithPFObject:object];

    bal.campaign = [Campaign campaignFromPFObject:[object nonNullObjectForKey:kCampaignKey]];

//    bal.customerCompany = [object nonNullObjectForKey:kCustomerCompanyKey];
    bal.buyX = [[object nonNullObjectForKey:kBuyXKey] intValue];
    bal.buyY = [object nonNullObjectForKey:kBuyYKey];
    bal.getX = [object nonNullObjectForKey:kGetXKey];
//    bal.iconType = [object nonNullObjectForKey:kIconTypeKey];
//    bal.user = [object nonNullObjectForKey:kUserKey];
//    bal.customerNumber = [object nonNullObjectForKey:kCustomerNumberKey];
    bal.balance = [[object nonNullObjectForKey:kCampaignBalanceKey] intValue];
    bal.redeemedCount = [[object nonNullObjectForKey:kRedeemedCountKey] intValue];
    bal.shared = [[object nonNullObjectForKey:kSharedKey] boolValue];
//    bal.campaignNumber = [object nonNullObjectForKey:kCampaignNumberKey];

    return bal;
}

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];
    if (!obj) {
        obj = [[PFObject alloc] initWithClassName:kClassName];
        [[User currentUser] addToACLForObject:obj];
    }

    [obj setNonNullObject:[PFUser currentUser] forKey:kUserKey];
    [obj setNonNullObject:[self.campaign toPFObject] forKey:kCampaignKey];

//    [obj setNonNullObject:self.user forKey:kUserKey];
//    [obj setNonNullObject:self.customerCompany forKey:kCustomerCompanyKey];
//    [obj setNonNullObject:self.iconType forKey:kIconTypeKey];
    [obj setNonNullObject:$int(self.buyX) forKey:kBuyXKey];
    [obj setNonNullObject:self.buyY forKey:kBuyYKey];
    [obj setNonNullObject:self.getX forKey:kGetXKey];
    [obj setNonNullObject:$int(self.balance) forKey:kCampaignBalanceKey];
    [obj setNonNullObject:$int(self.redeemedCount) forKey:kRedeemedCountKey];
    [obj setNonNullObject:$bool(self.shared) forKey:kSharedKey];
//    [obj setNonNullObject:self.campaignNumber forKey:kCampaignNumberKey];

    return obj;
}


@end