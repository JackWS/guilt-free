//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Balance.h"
#import "MockData.h"
#import "NSError+App.h"


@implementation Balance {

}

+ (void) getBalancesForCurrentUser:(ResponseBlock) response {

#if MOCK_DATA
    [MockData callAfterDelay:1
            successBlock:^{
                response([MockData generateBalanceList], nil);
            } failureBlock:^{
        response(nil, [NSError appErrorWithDisplayText:@"OMG something horrible happened!"]);
    }];
#else
    PFQuery *query = [PFQuery queryWithClassName:@"UBal"];
    [query orderByAscending:@"customerCompany"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *balances = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *obj in objects) {
                [balances addObject:[Balance balanceFromPFObject:obj]];
            }
            response(balances, error);
        } else {
            response(nil, error);
        }
    }];
#endif
}

+ (Balance *) balanceFromPFObject:(PFObject *) object {
    if (!object) {
        return nil;
    }

    Balance *bal = [[Balance alloc] init];
    bal.customerCompany = [object objectForKey:@"customerCompany"];
    bal.buyX = [[object objectForKey:@"buyx"] intValue];
    bal.buyY = [object objectForKey:@"buyy"];
    bal.getX = [object objectForKey:@"getx"];
    bal.balance = [[object objectForKey:@"campaignBalance"] intValue];
    bal.iconType = [object objectForKey:@"iconType"];

    return bal;
}


@end