//
// Created by Kevin on 11/29/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"
#import "HasLocation.h"

@class PFObject;
@class Customer;
@class Location;


@interface Deal : BlisdModel<HasLocation>

@property (nonatomic, strong) Customer *customer;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) NSString *shortDescription;
@property (nonatomic, strong) NSString *longDescription;

+ (void) getDealsNear:(CLLocationCoordinate2D) coordinate response:(ResponseBlock) response;

+ (Deal *) dealFromPFObject:(PFObject *) obj;

@end