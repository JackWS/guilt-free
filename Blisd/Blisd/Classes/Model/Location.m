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

static NSString *const kCustomerKey = @"cust_Relationship";
static NSString *const kCoordinateKey = @"location";

+ (Location *) locationFromPFObject:(PFObject *) obj {
    if (!obj) {
        return nil;
    }

    Location *location = [[Location alloc] initWithPFObject:obj];
    location.customer = [Customer customerFromPFObject:[obj nonNullObjectForKey:kCustomerKey]];

    PFGeoPoint *geoPoint = [obj nonNullObjectForKey:kCoordinateKey];
    location.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);

    return location;
}

@end