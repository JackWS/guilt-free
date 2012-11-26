//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"

@class Campaign;
@class Customer;


@interface BlissBalance : BlisdModel

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *customerCompany;
@property (nonatomic, strong) NSString *customerNumber;
@property (nonatomic, strong) NSString *iconType;
@property (nonatomic, assign) NSInteger buyX;
@property (nonatomic, strong) NSString *buyY;
@property (nonatomic, strong) NSString *getX;
@property (nonatomic, assign) NSInteger balance;
@property (nonatomic, assign) NSInteger redeemedCount;
@property (nonatomic, assign) BOOL shared;
@property (nonatomic, strong) NSString *campaignNumber;

@property (nonatomic, strong) Customer *customer;

+ (void) getBalancesForCurrentUser:(ResponseBlock) response;

+ (void) getBalancesForCurrentUserWithCompanies:(BOOL) includeCompanies response:(ResponseBlock) response;

+ (void) getByCampaignNumber:(NSString *) campaignId response:(ResponseBlock) response;

+ (void) createBalanceFromCampaign:(Campaign *) campaign response:(ResponseBlock) response;

- (void) redeemResponse:(ResponseBlock) response;

- (void) recordShare:(ResponseBlock) response;

@end