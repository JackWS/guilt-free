//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface MockData : NSObject

+ (NSArray *) generateBalanceList;

+ (NSString *) generateCampaignURL;

+ (void) callAfterDelay:(CGFloat) delayInSeconds successBlock:(void (^)()) success failureBlock:(void (^)()) failure;

+ (void) callAfterDelay:(CGFloat) delayInSeconds successProbability:(CGFloat) prob successBlock:(void (^)()) success failureBlock:(void (^)()) failure;


@end