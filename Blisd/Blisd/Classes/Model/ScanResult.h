//
// Created by Kevin on 11/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class BlissBalance;
@class CheckInBalance;


typedef enum {
    ScanResultTypeCampaign,
    ScanResultTypeCheckIn,
    ScanResultTypeOutsideURL
} ScanResultType;

typedef enum {
    ScanResultStatusUnknown,
    ScanResultStatusSuccess,
    ScanResultStatusRedeemRequired,
    ScanResultStatusError
} ScanResultStatus;

@interface ScanResult : NSObject

@property (nonatomic, assign) ScanResultType type;
@property (nonatomic, assign) ScanResultStatus status;
@property (nonatomic, strong) BlissBalance *balance;
@property (nonatomic, strong) CheckInBalance *checkIn;

@end