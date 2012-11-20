//
// Created by Kevin on 11/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Location.h"
#import "Customer.h"
#import "PFObject+NonNull.h"


@implementation Location {

}

static NSString *const kClassName = @"Location";

static NSString *const kCustomerKey = @"customer";

+ (Location *) locationFromPFObject:(PFObject *) obj {
    if (!obj) {
        return nil;
    }

    Location *location = [[Location alloc] initWithPFObject:obj];
    location.customer = [Customer customerFromPFObject:[obj nonNullObjectForKey:kCustomerKey]];

    return location;
}

@end