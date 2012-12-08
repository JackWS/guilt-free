//
// Created by Kevin on 11/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"

@class PFQuery;
@class PFObject;
@class Customer;
@class Location;


@interface CheckIn : BlisdModel

@property (nonatomic, strong) Customer *customer;
@property (nonatomic, strong) Location *location;

+ (CheckIn *) checkInFromPFObject:(PFObject *) pfObject;

+ (void) getCheckInWithID:(NSString *) checkInID response:(ResponseBlock) response;

+ (PFQuery *) queryForCheckInID:(NSString *) checkInID;

+ (PFQuery *) queryForCheckInAtLocation:(Location *) location;

@end