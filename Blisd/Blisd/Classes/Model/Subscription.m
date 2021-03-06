//
// Created by Kevin on 10/25/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Subscription.h"
#import "PFObject+NonNull.h"
#import "User.h"
#import "BlissBalance.h"
#import "Customer.h"


@implementation Subscription {

}

static NSString *const kClassName = @"Usubscriptions";

static NSString *const kCampaignNumberKey = @"campaignNumber";
static NSString *const kCampaignNameKey = @"campaignName";
static NSString *const kStatusKey = @"status";
static NSString *const kUserIdKey = @"userUniqueId";
static NSString *const kCustomerCompanyKey = @"customerCompany";

- (NSString *) channelName {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"( ,)|(,,)|( )|(-)"
                                                                                options:(NSRegularExpressionOptions) 0
                                                                                  error:nil];

    if (!self.customerCompany) {
        return nil;
    } else {
        return [expression stringByReplacingMatchesInString:self.customerCompany
                                                    options:(NSMatchingOptions) 0
                                                      range:NSMakeRange(0, self.customerCompany.length)
                                               withTemplate:@"_"];
    }
}

- (void) saveInBackgroundWithBlock:(ResponseBlock) block {
    // Do in reverse order depending on whether this is a subscribe or un-subscribe
    if (!self.status) {
        [PFPush unsubscribeFromChannelInBackground:self.customerCompany block:^(BOOL succeeded, NSError *unSubscribeError) {
            if (unSubscribeError) {
                NSLog(@"Error unsubscribing to channel: %@, %@",
                        self.customerCompany, [unSubscribeError description]);
                block(nil, unSubscribeError);
            } else {
                NSLog(@"Successfully unsubscribed to channel: %@", self.customerCompany);
                block(nil, nil);
            }
        }];
    } else {
        [PFPush subscribeToChannelInBackground:self.customerCompany block:^(BOOL succeeded, NSError *subscribeError) {
            if (subscribeError) {
                NSLog(@"Error subscribing to channel: %@, %@",
                        self.customerCompany, [subscribeError description]);
                block(nil, subscribeError);
            } else {
                NSLog(@"Successfully subscribed to channel: %@", self.customerCompany);
                // We still mostly succeeded, so don't forward this error
                block(nil, nil);
            }
        }];
    }
}

+ (void) getSubscriptionsForCurrentUser:(ResponseBlock) response {
    [BlissBalance getBalancesForCurrentUserResponse:^(NSArray *balances, NSError *balancesError) {
        if (balancesError) {
            response(nil, balancesError);
        } else {
            NSMutableDictionary *subscriptions = [NSMutableDictionary dictionary];
            for (BlissBalance *balance in balances) {
                Subscription *subscription = [[Subscription alloc] init];
                subscription.customerCompany = balance.customer.company;
                subscription.status = NO;
                subscriptions[subscription.channelName] = subscription;
            }

            [PFPush getSubscribedChannelsInBackgroundWithBlock:^(NSSet *channels, NSError *channelsError) {
                if (channelsError) {
                    // We don't have a push token, so not really an error
                    if ([channelsError code] == kPFErrorPushMisconfigured) {
                        response(nil, nil);
                    } else {
                        response(nil, channelsError);
                    }
                } else {
                    for (NSString *channel in channels) {
                        Subscription *subscription = subscriptions[channel];
                        if (subscription) {
                            subscription.status = YES;
                        }
                    }
                    response([subscriptions allValues], nil);
                }
            }];
        }
    }];
}


@end