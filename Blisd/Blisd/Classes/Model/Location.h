//
// Created by Kevin on 11/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BlisdModel.h"


@class Customer;


@interface Location : BlisdModel

@property (nonatomic, strong) Customer *customer;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+ (Location *) locationFromPFObject:(PFObject *) obj;

+ (PFQuery *) queryForLocationNear:(CLLocationCoordinate2D) coordinate;

+ (NSComparator) comparatorForCoordinate:(CLLocationCoordinate2D) coordinate;

@end