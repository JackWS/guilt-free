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
    [query includeKey:kCustomerCompanyKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *balances = [NSMutableArray arrayWithCapacity:objects.count];
            NSMutableArray *companies = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *obj in objects) {
                Balance *bal = [Balance balanceFromPFObject:obj];
                [balances addObject:bal];
                [companies addObject:bal.customerCompany];
            }
            PFQuery *innerQuery = [PFQuery queryWithClassName:@"Customer"];
            [innerQuery whereKey:@"customerCompany" containedIn:companies];
            [innerQuery findObjectsInBackgroundWithBlock:^(NSArray *companyObjects, NSError *companiesError) {
                for (PFObject *object in companyObjects) {
                    for (Balance *bal in balances) {
                        if ([bal.customerCompany isEqualToString:[object objectForKey:@"customerCompany"]]) {

                        }
                    }

                }
                response(balances, error);
            }];

        } else {
            response(nil, error);
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
    [balance setObject:[User currentUser].email forKey:kUserKey];
    [balance setObject:@1 forKey:kCampaignBalanceKey];
    [balance setObject:campaign.campaignNumber forKey:kCampaignNumberKey];
    [balance setObject:$int(campaign.buyX) forKey:kBuyXKey];
    [balance setObject:campaign.buyY forKey:kBuyYKey];
    [balance setObject:campaign.getX forKey:kGetXKey];
    [balance setObject:campaign.customerCompany forKey:kCustomerCompanyKey];
    [balance setObject:campaign.customerNumber forKey:kCustomerNumberKey];
    [balance setObject:$str(@"%d %@ and get %@", campaign.buyX, campaign.buyY, campaign.getX) forKey:kShortMessageKey];
    [[User currentUser] addToACLForObject:balance];

    [balance saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            response(nil, error);
        } else if (!succeeded) {
            response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_GENERIC", @"")]);
        } else {
            Balance *bal = [Balance balanceFromPFObject:balance];
            response(bal, nil);
        }
    }];
}


+ (void) findByCampaign:(NSString *) campaign responeBlock:(ResponseBlock) response {


}


+ (Balance *) balanceFromPFObject:(PFObject *) object {
    if (!object) {
        return nil;
    }

    Balance *bal = [[Balance alloc] initWithPFObject:object];
    bal.customerCompany = [object objectForKey:kCustomerCompanyKey];
    bal.buyX = [[object nonNullObjectForKey:kBuyXKey] intValue];
    bal.buyY = [object nonNullObjectForKey:kBuyYKey];
    bal.getX = [object nonNullObjectForKey:kGetXKey];
    bal.balance = [[object nonNullObjectForKey:kCampaignBalanceKey] intValue];
    bal.iconType = [object nonNullObjectForKey:kIconTypeKey];
    bal.user = [object nonNullObjectForKey:kUserKey];

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