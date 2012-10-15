//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Campaign.h"


@implementation Campaign {

}

static NSString *const kClassName = @"Campaign";

static NSString *const kCampaignNumberKey = @"campaignNumber";
static NSString *const kCustomerNumberKey = @"customerNumber";
static NSString *const kCustomerCompanyKey = @"customerCompany";
static NSString *const kBuyXKey = @"buyx";
static NSString *const kBuyYKey = @"buyy";
static NSString *const kGetXKey = @"getx";

+ (void) getByCampaignNumber:(NSString *) campaignNumber response:(ResponseBlock) response {
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query whereKey:@"campaignNumber" equalTo:campaignNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving campaign with number: %@", campaignNumber);
            response(nil, error);
        } else if (!objects || objects.count <= 0) {
            NSLog(@"Invalid campaign returned.");
            response(nil, nil);
        } else {
            response([Campaign campaignFromPFObject:objects[0]], nil);
        }
    }];
}

+ (Campaign *) campaignFromPFObject:(PFObject *) obj {
    if (!obj) {
        return nil;
    }

    Campaign *campaign = [[Campaign alloc] initWithPFObject:obj];
    campaign.customerNumber = [obj objectForKey:kCustomerNumberKey];
    campaign.customerCompany = [obj objectForKey:kCustomerCompanyKey];
    campaign.buyX = [[obj objectForKey:kBuyXKey] intValue];
    campaign.buyY = [obj objectForKey:kBuyYKey];
    campaign.getX = [obj objectForKey:kGetXKey];
    campaign.campaignNumber = [obj objectForKey:kCampaignNumberKey];

    return campaign;
}


@end