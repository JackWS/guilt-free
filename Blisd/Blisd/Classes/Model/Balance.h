//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"


@interface Balance : BlisdModel

@property (nonatomic, strong) NSString *customerCompany;
@property (nonatomic, strong) NSString *iconType;
@property (nonatomic, assign) NSInteger buyX;
@property (nonatomic, strong) NSString *buyY;
@property (nonatomic, strong) NSString *getX;
@property (nonatomic, assign) NSInteger balance;

+ (void) getBalancesForCurrentUser:(ResponseBlock) response;

@end