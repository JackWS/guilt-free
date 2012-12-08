//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"

@class Campaign;
@class Customer;
@class User;


@interface BlissBalance : BlisdModel

@property (nonatomic, strong) Campaign *campaign;
@property (nonatomic, readonly) Customer *customer;

//@property (nonatomic, strong) NSString *user;
//@property (nonatomic, strong) NSString *customerCompany;
//@property (nonatomic, strong) NSString *customerNumber;
//@property (nonatomic, strong) NSString *iconType;
@property (nonatomic, assign) NSInteger buyX;
@property (nonatomic, strong) NSString *buyY;
@property (nonatomic, strong) NSString *getX;
@property (nonatomic, assign) NSInteger balance;
@property (nonatomic, assign) NSInteger redeemedCount;
@property (nonatomic, assign) BOOL shared;
//@property (nonatomic, strong) NSString *campaignNumber;

+ (void) getBalancesForCurrentUser:(ResponseBlock) response;

+ (void) getBalancesForCurrentUserResponse:(ResponseBlock) response;

+ (void) getByCampaignNumber:(NSString *) campaignId response:(ResponseBlock) response;

+ (void) createBalanceFromCampaign:(Campaign *) campaign response:(ResponseBlock) response;

- (void) redeemResponse:(ResponseBlock) response;

- (void) recordShare:(ResponseBlock) response;

@end