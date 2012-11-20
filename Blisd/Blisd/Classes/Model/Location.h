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

+ (Location *) locationFromPFObject:(PFObject *) obj;


@end