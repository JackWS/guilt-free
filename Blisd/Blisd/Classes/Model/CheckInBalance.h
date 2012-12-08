//
// Created by Kevin on 11/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"
#import "Location.h"

@class Customer;
@class CheckIn;


@interface CheckInBalance : BlisdModel

@property (nonatomic, retain) CheckIn *checkIn;
@property (nonatomic, assign) NSInteger count;

+ (void) getByCheckInID:(NSString *) checkInID response:(ResponseBlock) response;

+ (void) getForLocation:(Location *) location response:(ResponseBlock) response;

+ (void) createBalanceFromCheckIn:(CheckIn *) checkIn response:(ResponseBlock) response;

+ (CheckInBalance *) checkInBalanceFromPFObject:(PFObject *) object;

@end