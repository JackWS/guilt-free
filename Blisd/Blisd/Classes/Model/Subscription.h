//
// Created by Kevin on 10/25/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"


@interface Subscription : BlisdModel

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *campaignNumber;
@property (nonatomic, strong) NSString *campaignName;
@property (nonatomic, strong) NSString *customerCompany;
@property (nonatomic, assign) BOOL status;

+ (void) getSubscriptionsForCurrentUser:(ResponseBlock) response;

+ (Subscription *) subscriptionWithPFObject:(PFObject *) object;

@end