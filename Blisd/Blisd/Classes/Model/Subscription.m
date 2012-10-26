//
// Created by Kevin on 10/25/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Subscription.h"
#import "PFObject+NonNull.h"
#import "User.h"


@implementation Subscription {

}

static NSString *const kClassName = @"Usubscriptions";

static NSString *const kCampaignNumberKey = @"campaignNumber";
static NSString *const kCampaignNameKey = @"campaignName";
static NSString *const kStatusKey = @"status";
static NSString *const kUserIdKey = @"userUniqueId";
static NSString *const kCustomerCompanyKey = @"customerCompany";

- (PFObject *) toPFObject {
    PFObject *obj = [super toPFObject];
    if (!obj) {
        obj = [[PFObject alloc] initWithClassName:kClassName];
    }
    [obj setNonNullObject:self.userId forKey:kUserIdKey];
    [obj setNonNullObject:self.campaignName forKey:kCampaignNameKey];
    [obj setNonNullObject:self.campaignNumber forKey:kCampaignNumberKey];
    [obj setNonNullObject:$bool(self.status) forKey:kStatusKey];
    [obj setNonNullObject:self.customerCompany forKey:kCustomerCompanyKey];

    return obj;
}

- (void) saveInBackgroundWithBlock:(ResponseBlock) block {
    // Do in reverse order depending on whether this is a subscribe or un-subscribe
    if (!self.status) {
        [PFPush unsubscribeFromChannelInBackground:self.customerCompany
                                             block:^(BOOL succeeded, NSError *unSubscribeError) {
                                                 if (unSubscribeError) {
                                                     NSLog(@"Error unsubscribing to channel: %@, %@",
                                                             self.customerCompany, [unSubscribeError description]);
                                                     block(nil, unSubscribeError);
                                                 } else {
                                                     [super saveInBackgroundWithBlock:^(id object, NSError *saveError) {
                                                         if (saveError) {
                                                             NSLog(@"Error updating subscription for company: %@, %@",
                                                                     self.customerCompany, [unSubscribeError description]);
                                                             block(nil, unSubscribeError);
                                                         } else {
                                                             NSLog(@"Successfully unsubscribed to channel: %@", self.customerCompany);
                                                             block(object, nil);
                                                         }
                                                     }];
                                                 }
                                             }];
    } else {
        [super saveInBackgroundWithBlock:^(id object, NSError *error) {
            if (error) {
                NSLog(@"Error updating subscription tochannel: %@, %@",
                        self.customerCompany, [error description]);
                // Don't create the subscription
                block(object, error);
            } else {
                [PFPush subscribeToChannelInBackground:self.customerCompany
                                                 block:^(BOOL succeeded, NSError *subscribeError) {
                                                     if (subscribeError) {
                                                         NSLog(@"Error subscribing to channel: %@, %@",
                                                                 self.customerCompany, [subscribeError description]);
                                                     } else {
                                                         NSLog(@"Successfully subscribed to channel: %@", self.customerCompany);
                                                     }
                                                     // We still mostly succeeded, so don't forward this error
                                                     block(object, error);
                                                 }];
            }
        }];
    }
}

+ (void) getSubscriptionsForCurrentUser:(ResponseBlock) response {
    PFQuery *query = [PFQuery queryWithClassName:kClassName];
    [query whereKey:kUserIdKey equalTo:[User currentUser].userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            response(nil, error);
        } else {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *object in objects) {
                Subscription *subscription = [Subscription subscriptionWithPFObject:object];
                [array addObject:subscription];
            }
            response(array, nil);
        }
    }];
}

+ (Subscription *) subscriptionWithPFObject:(PFObject *) object {
    if (!object) {
        return nil;
    }

    Subscription *subscription = [[Subscription alloc] initWithPFObject:object];
    subscription.campaignNumber = [object nonNullObjectForKey:kCampaignNumberKey];
    subscription.customerCompany = [object nonNullObjectForKey:kCustomerCompanyKey];
    subscription.userId = [object nonNullObjectForKey:kUserIdKey];
    subscription.campaignName = [object nonNullObjectForKey:kCampaignNameKey];
    subscription.status = [[object nonNullObjectForKey:kStatusKey] boolValue];

    return subscription;
}


@end