//
// Created by Kevin on 11/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Balance;
@class UserCheckIn;


typedef enum {
    ScanResultTypeCampaign,
    ScanResultTypeCheckIn,
    ScanResultTypeOutsideURL
} ScanResultType;

@interface ScanResult : NSObject

@property (nonatomic, assign) ScanResultType type;
@property (nonatomic, strong) Balance *balance;
@property (nonatomic, strong) UserCheckIn *checkIn;

@end