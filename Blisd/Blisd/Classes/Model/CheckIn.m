//
// Created by Kevin on 11/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "CheckIn.h"
#import "Customer.h"
#import "PFObject+NonNull.h"


@implementation CheckIn

static NSString *const kClassName = @"CheckIns";

static NSString *const kObjectIDKey = @"objectId";
static NSString *const kCustomerKey = @"relationShip";

+ (void) getCheckInWithID:(NSString *) checkInID response:(ResponseBlock) response {
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query includeKey:kCustomerKey];
    [query getObjectInBackgroundWithId:checkInID block:^(PFObject *object, NSError *error) {
        if (error) {
            response(nil, error);
        } else {
            CheckIn *checkIn = [CheckIn checkInFromPFObject:object];
            response(checkIn, nil);
        }
    }];
}

+ (PFQuery *) queryForCheckInID:(NSString *) checkInID {
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query whereKey:kObjectIDKey equalTo:checkInID];
    return query;
}

+ (CheckIn *) checkInFromPFObject:(PFObject *) pfObject {
    if (!pfObject) {
        return nil;
    }

    CheckIn *checkIn = [[CheckIn alloc] initWithPFObject:pfObject];
    checkIn.customer = [Customer customerFromPFObject:[pfObject nonNullObjectForKey:kCustomerKey]];

    return checkIn;
}

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];

    [obj setNonNullObject:[self.customer toPFObject] forKey:kCustomerKey];

    return obj;
}


@end