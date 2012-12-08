//
// Created by Kevin on 11/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Location.h"
#import "Customer.h"
#import "PFObject+NonNull.h"
#import "HasLocation.h"


@implementation Location {

}

static NSString *const kClassName = @"Location";

static NSString *const kCustomerKey = @"cust_Pointer";
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

+ (PFQuery *) queryForLocationNear:(CLLocationCoordinate2D) coordinate {
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query whereKey:kCoordinateKey
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude]
        withinMiles:100];
    return query;
}

+ (NSComparator) comparatorForCoordinate:(CLLocationCoordinate2D) coordinate {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    return ^NSComparisonResult(id obj1, id obj2) {
        id<HasLocation> hasLoc1 = nil;
        id<HasLocation> hasLoc2 = nil;

        if ([obj1 respondsToSelector:@selector(location)]) {
            hasLoc1 = (id<HasLocation>) obj1;
        }
        if ([obj2 respondsToSelector:@selector(location)]) {
            hasLoc2 = (id<HasLocation>) obj2;
        }

        CLLocationCoordinate2D coord1 = hasLoc1.location.coordinate;
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:coord1.latitude
                                                           longitude:coord1.longitude];
        CLLocationDistance distance1 = [location1 distanceFromLocation:location];

        CLLocationCoordinate2D coord2 = hasLoc2.location.coordinate;
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:coord2.latitude
                                                           longitude:coord2.longitude];
        CLLocationDistance distance2 = [location2 distanceFromLocation:location];

        if (distance1 > distance2) {
            return NSOrderedDescending;
        } else if (distance1 < distance2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }

    };
}


@end