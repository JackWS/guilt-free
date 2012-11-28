//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BlisdModel.h"
#import "Location.h"

@class PFObject;
@class PFQuery;

@interface Campaign : BlisdModel

@property (nonatomic, strong) NSString *campaignNumber;
@property (nonatomic, strong) NSString *campaignName;
@property (nonatomic, strong) NSString *customerNumber;
@property (nonatomic, strong) NSString *customerCompany;
@property (nonatomic, assign) NSInteger buyX;
@property (nonatomic, strong) NSString *buyY;
@property (nonatomic, strong) NSString *getX;

@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) Customer *customer;

+ (void) getCampaignsNear:(CLLocationCoordinate2D) coordinate response:(ResponseBlock) response;

+ (void) getByCampaignNumber:(NSString *) campaignNumber response:(ResponseBlock) response;

+ (Campaign *) campaignFromPFObject:(PFObject *) obj;

+ (PFQuery *) queryForCampaignNumber:(NSString *) campaignNumber;


@end