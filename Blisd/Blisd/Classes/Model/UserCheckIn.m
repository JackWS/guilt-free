//
// Created by Kevin on 11/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "UserCheckIn.h"
#import "Customer.h"
#import "CheckIn.h"
#import "User.h"
#import "PFObject+NonNull.h"
#import "NSError+App.h"
#import "Balance.h"
#import "Subscription.h"

@implementation UserCheckIn

static NSString *const kClassName = @"CBal";

static NSString *const kCheckInKey = @"checkIn_Relationship";
static NSString *const kCustomerKey = @"checkIn_Relationship.relationShip";
static NSString *const kUserKey = @"user_Relationship";
static NSString *const kCountKey = @"count";

- (id) initWithPFObject:(PFObject *) pfObject {
    self = [super initWithPFObject:pfObject];
    if (self) {

    }

    return self;
}

+ (void) getByCheckInID:(NSString *) checkInID response:(ResponseBlock) response {
    PFQuery *cBalQuery = [PFQuery queryWithClassName:kClassName];
    [cBalQuery includeKey:kCheckInKey];
    [cBalQuery includeKey:kCustomerKey];

    PFQuery *checkInQuery = [CheckIn queryForCheckInID:checkInID];
    [cBalQuery whereKey:kCheckInKey matchesQuery:checkInQuery];

    [cBalQuery whereKey:kUserKey equalTo:[PFUser currentUser]];

    [cBalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            response(nil, error);
        } else if (objects && objects.count >= 1) {
            UserCheckIn *userCheckIn = [UserCheckIn userCheckInFromPFObject:objects[0]];
            response(userCheckIn, nil);
        } else {
            response(nil, nil);
        }
    }];
}

+ (void) createUserCheckInFromCheckIn:(CheckIn *) checkIn response:(ResponseBlock) response {
    PFObject *userCheckIn = [[PFObject alloc] initWithClassName:kClassName];
    [userCheckIn setNonNullObject:[PFUser currentUser] forKey:kUserKey];
    [userCheckIn setNonNullObject:[checkIn toPFObject] forKey:kCheckInKey];
    [userCheckIn setNonNullObject:@1 forKey:kCountKey];
    [[User currentUser] addToACLForObject:userCheckIn];

    [userCheckIn saveInBackgroundWithBlock:^(BOOL succeeded, NSError *balanceError) {
        if (balanceError) {
            response(nil, balanceError);
        } else if (!succeeded) {
            response(nil, [NSError appErrorWithDisplayText:NSLocalizedString(@"ERROR_GENERIC", @"")]);
        } else {
            UserCheckIn *uci = [UserCheckIn userCheckInFromPFObject:userCheckIn];
            // Return this value, the rest can be done in the background.
            response(uci, nil);

            Subscription *subscription = [[Subscription alloc] init];
            subscription.customerCompany = uci.checkIn.customer.company;
            subscription.status = YES;
            [subscription saveInBackgroundWithBlock:^(id object, NSError *subscriptionError) {
                if (subscriptionError) {
                    NSLog(@"Error creating subscription for customer: %@, %@",
                            subscription.customerCompany, [subscriptionError description]);
                } else {
                    NSLog(@"Succesfully created subscription for campaign number: %@", subscription.customerCompany);
                }
            }];
        }
    }];
}

+ (UserCheckIn *) userCheckInFromPFObject:(PFObject *) object {
    if (!object) {
        return nil;
    }

    UserCheckIn *userCheckIn = [[UserCheckIn alloc] initWithPFObject:object];
    userCheckIn.count = [[object nonNullObjectForKey:kCountKey] intValue];
    userCheckIn.checkIn = [CheckIn checkInFromPFObject:[object nonNullObjectForKey:kCheckInKey]];

    return userCheckIn;
}


- (PFObject *) toPFObject {
    PFObject *object = [super toPFObject];
    if (!object) {
        object = [PFObject objectWithClassName:kClassName];
    }

    [object setNonNullObject:$int(self.count) forKey:kCountKey];
    [object setNonNullObject:[self.checkIn toPFObject] forKey:kCheckInKey];

    return object;
}


@end