//
// Created by Kevin on 11/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"

@class Customer;
@class CheckIn;


@interface UserCheckIn : BlisdModel

@property (nonatomic, retain) CheckIn *checkIn;
@property (nonatomic, assign) NSInteger count;

+ (void) getByCheckInID:(NSString *) checkInID response:(ResponseBlock) response;

+ (void) createUserCheckInFromCheckIn:(CheckIn *) checkIn response:(ResponseBlock) response;

+ (UserCheckIn *) userCheckInFromPFObject:(PFObject *) object;

@end