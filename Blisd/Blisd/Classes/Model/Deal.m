//
// Created by Kevin on 11/29/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Deal.h"
#import "Customer.h"
#import "Location.h"
#import "PFObject+NonNull.h"


@implementation Deal

static NSString *const kClassName = @"DailyDeals";

static NSString *const kCustomerKey = @"cust_Pointer";
static NSString *const kLocationKey = @"loc_Pointer";
static NSString *const kLongDescriptionKey = @"longDescription";
static NSString *const kShortDescriptionKey = @"shortDescription";

+ (void) getDealsNear:(CLLocationCoordinate2D) coordinate response:(ResponseBlock) response {
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query includeKey:kLocationKey];
    [query includeKey:kCustomerKey];
    [query whereKey:kLocationKey matchesQuery:[Location queryForLocationNear:coordinate]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving nearby deals: %@", [error description]);
            response(nil, error);
        } else {
            NSMutableArray *deals = [NSMutableArray array];
            for (PFObject *object in objects) {
                Deal *deal = [Deal dealFromPFObject:object];
                [deals addObject:deal];
            }
            [deals sortUsingComparator:[Location comparatorForCoordinate:coordinate]];
            response(deals, nil);
        }
    }];
}

+ (Deal *) dealFromPFObject:(PFObject *) obj {
    if (!obj) {
        return nil;
    }

    Deal *deal = [[Deal alloc] initWithPFObject:obj];
    deal.customer = [Customer customerFromPFObject:[obj nonNullObjectForKey:kCustomerKey]];
    deal.location = [Location locationFromPFObject:[obj nonNullObjectForKey:kLocationKey]];
    deal.shortDescription = [obj nonNullObjectForKey:kShortDescriptionKey];
    deal.longDescription = [obj nonNullObjectForKey:kLongDescriptionKey];

    return deal;
}

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];
    if (!obj) {
        obj = [[PFObject alloc] initWithClassName:kClassName];
    }

    [obj setNonNullObject:[self.customer toPFObject] forKey:kCustomerKey];
    [obj setNonNullObject:[self.location toPFObject] forKey:kLocationKey];
    [obj setNonNullObject:self.longDescription forKey:kLongDescriptionKey];
    [obj setNonNullObject:self.shortDescription forKey:kShortDescriptionKey];

    return obj;
}


@end