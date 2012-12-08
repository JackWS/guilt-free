//
// Created by Kevin on 11/25/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"

@class CheckInBalance;


@interface CheckInScanLog : BlisdModel

@property (nonatomic, strong) CheckInBalance *balance;

@end