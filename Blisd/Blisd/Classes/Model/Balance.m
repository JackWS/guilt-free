//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Balance.h"
#import "MockData.h"
#import "NSError+App.h"
#import "Campaign.h"
#import "User.h"
#import "PFObject+NonNull.h"
#import "Customer.h"
#import "Subscription.h"


@implementation Balance {

}

static NSString *const kClassName = @"UBal";

static NSString *const kUserKey = @"User";
static NSString *const kCustomerCompanyKey = @"customerCompany";
static NSString *const kCustomerNumberKey = @"customerNumber";
static NSString *const kCampaignNumberKey = @"campaignNumber";
static NSString *const kBuyXKey = @"buyx";
static NSString *const kBuyYKey = @"buyy";
static NSString *const kGetXKey = @"getx";
static NSString *const kCampaignBalanceKey = @"campaignBalance";
static NSString *const kIconTypeKey = @"iconType";
static NSString *const kShortMessageKey = @"shortMessage";

// TODO: This is a terrible name
static NSString *const kCustomerKey = @"relationShip";

+ (void) getBalancesForCurrentUser:(ResponseBlock) response {

#if MOCK_DATA
    [MockData callAfterDelay:1
            successBlock:^{
                response([MockData generateBalanceList], nil);
            } failureBlock:^{
        response(nil, [NSError appErrorWithDisplayText:@"OMG something horrible happened!"]);
    }];
#else
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query orderByAscending:kCustomerCompanyKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            response(nil, error);
        } else {
            NSMutableArray *balances = [NSMutableArray arrayWithCapacity:objects.count];
            NSMutableArray *companyNames = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *obj in objects) {
                Balance *bal = [Balance balanceFromPFObject:obj];
                [balances addObject:bal];
                [companyNames addObject:bal.customerCompany];
            }
            [Customer findWithNames:companyNames response:^(NSArray *customerObjects, NSError *companiesError) {
                if (companiesError) {
                    response(nil, companiesError);
                } else {
                    for (Balance *bal in balances) {
                        for (Customer *customer in customerObjects) {
                            if ([bal.customerCompany isEqualToString:customer.company]) {
                                bal.customer = customer;
                                break;
                            }
                        }
                    }
                    response(balances, nil);
                }
            }];
        }
    }];
#endif
}

+ (void) getByCampaignId:(NSString *) campaignId response:(ResponseBlock) response {
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query whereKey:kCampaignNumberKey equalTo:campaignId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving campaign id: %@", [error description]);
            response(nil, error);
        } else if (objects && objects.count >= 1) {
            Balance *balance = [Balance balanceFromPFObject:objects[0]];
            response(balance, nil);
        } else {
            response(nil,nil);
        }
    }];
}

+ (void) createBalanceFromCampaign:(Campaign *) campaign response:(ResponseBlock) response {
    PFObject *balance = [[PFObject alloc] initWithClassName:kClassName];
    [balance setNonNullObject:[User currentUser].email forKey:kUserKey];
    [balance setNonNullObject:@1 forKey:kCampaignBalanceKey];
    [balance setNonNullObject:campaign.campaignNumber forKey:kCampaignNumberKey];
    [balance setNonNullObject:$int(campaign.buyX) forKey:kBuyXKey];
    [balance setNonNullObject:campaign.buyY forKey:kBuyYKey];
    [balance setNonNullObject:campaign.getX forKey:kGetXKey];
    [balance setNonNullObject:campaign.customerCompany forKey:kCustomerCompanyKey];
    [balance setNonNullObject:campaign.customerNumber forKey:kCustomerNumberKey];
    [balance setNonNullObject:$str(@"%d %@ and get %@", campaign.buyX, campaign.buyY, campaign.getX) forKey:kShortMessageKey];
    [[User currentUser] addToACLForObject:balance];

    [balance saveInBackgroundWithBlock:^(BOOL succeeded, NSError *balanceError) {
        if (balanceError) {
            response(nil, balanceError);
        } else if (!succeeded) {
            response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_GENERIC", @"")]);
        } else {
            Balance *bal = [Balance balanceFromPFObject:balance];
            // Return this value, the rest can be done in the background.
            response(bal, nil);

            Subscription *subscription = [[Subscription alloc] init];
            subscription.userId = [User currentUser].userId;
            subscription.campaignNumber = campaign.campaignNumber;
            subscription.campaignName = campaign.campaignName;
            subscription.customerCompany = campaign.customerCompany;
            subscription.status = YES;
            [subscription saveInBackgroundWithBlock:^(id object, NSError *subscriptionError) {
                if (subscriptionError) {
                    NSLog(@"Error creating subscription for campaign number: %@, %@",
                            subscription.campaignNumber, [subscriptionError description]);
                } else {
                    NSLog(@"Succesfully created subscription for campaign number: %@", subscription.campaignNumber);
                }
            }];
        }
    }];
}

+ (Balance *) balanceFromPFObject:(PFObject *) object {
    if (!object) {
        return nil;
    }

    Balance *bal = [[Balance alloc] initWithPFObject:object];
    bal.customerCompany = [object nonNullObjectForKey:kCustomerCompanyKey];
    bal.buyX = [[object nonNullObjectForKey:kBuyXKey] intValue];
    bal.buyY = [object nonNullObjectForKey:kBuyYKey];
    bal.getX = [object nonNullObjectForKey:kGetXKey];
    bal.balance = [[object nonNullObjectForKey:kCampaignBalanceKey] intValue];
    bal.iconType = [object nonNullObjectForKey:kIconTypeKey];
    bal.user = [object nonNullObjectForKey:kUserKey];
    bal.customerNumber = [object nonNullObjectForKey:kCustomerNumberKey];

    return bal;
}

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];
    if (!obj) {
        obj = [[PFObject alloc] initWithClassName:kClassName];
    }
    [obj setNonNullObject:self.user forKey:kUserKey];
    [obj setNonNullObject:self.customerCompany forKey:kCustomerCompanyKey];
    [obj setNonNullObject:self.iconType forKey:kIconTypeKey];
    [obj setNonNullObject:$int(self.buyX) forKey:kBuyXKey];
    [obj setNonNullObject:self.buyY forKey:kBuyYKey];
    [obj setNonNullObject:self.getX forKey:kGetXKey];
    [obj setNonNullObject:$int(self.balance) forKey:kCampaignBalanceKey];

    return obj;
}


@end