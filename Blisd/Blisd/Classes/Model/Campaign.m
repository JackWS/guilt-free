//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Campaign.h"
#import "PFObject+NonNull.h"


@implementation Campaign {

}

static NSString *const kClassName = @"Campaign";

static NSString *const kCampaignNumberKey = @"campaignNumber";
static NSString *const kCampaignNameKey = @"campaignName";
static NSString *const kCustomerNumberKey = @"customerNumber";
static NSString *const kCustomerCompanyKey = @"customerCompany";
static NSString *const kBuyXKey = @"buyx";
static NSString *const kBuyYKey = @"buyy";
static NSString *const kGetXKey = @"getx";
static NSString *const kCustomerKey = @"customer";
static NSString *const kLocationKey = @"location";

+ (void) getCampaignsNear:(CLLocationCoordinate2D) coordinate response:(ResponseBlock) response {
    PFQuery *campaignQuery = [PFQuery queryWithClassName:@"Campaign"];
    [campaignQuery includeKey:@"location"];
    [campaignQuery includeKey:@"location.customer"];

    PFQuery *locationQuery = [PFQuery queryWithClassName:@"Location"];
    [locationQuery whereKey:@"location"
               nearGeoPoint:[PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude]
                withinMiles:100];
    [campaignQuery whereKey:@"location" matchesQuery:locationQuery];

    [campaignQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving nearby campaigns: %@", [error description]);
            response(nil, error);
        } else {
            NSMutableArray *campaigns = [NSMutableArray array];
            for (PFObject *object in objects) {
                Campaign *campaign = [Campaign campaignFromPFObject:object];
                [campaigns addObject:campaign];
            }
            response(campaigns, nil);
        }
    }];
}

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
    campaign.customerNumber = [obj nonNullObjectForKey:kCustomerNumberKey];
    campaign.customerCompany = [obj nonNullObjectForKey:kCustomerCompanyKey];
    campaign.buyX = [[obj nonNullObjectForKey:kBuyXKey] intValue];
    campaign.buyY = [obj nonNullObjectForKey:kBuyYKey];
    campaign.getX = [obj nonNullObjectForKey:kGetXKey];
    campaign.campaignNumber = [obj nonNullObjectForKey:kCampaignNumberKey];
    campaign.campaignName = [obj nonNullObjectForKey:kCampaignNameKey];
    campaign.location = [Location locationFromPFObject:[obj nonNullObjectForKey:kLocationKey]];

    return campaign;
}


@end