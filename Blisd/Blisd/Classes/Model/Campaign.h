//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"


@interface Campaign : BlisdModel

@property (nonatomic, strong) NSString *campaignNumber;
@property (nonatomic, strong) NSString *campaignName;
@property (nonatomic, strong) NSString *customerNumber;
@property (nonatomic, strong) NSString *customerCompany;
@property (nonatomic, assign) NSInteger buyX;
@property (nonatomic, strong) NSString *buyY;
@property (nonatomic, strong) NSString *getX;

+ (void) getByCampaignNumber:(NSString *) campaignNumber response:(ResponseBlock) response;

@end