//
// Created by Kevin on 10/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"


@interface Customer : BlisdModel

@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) UIImage *companyImage;

+ (void) findWithNames:(NSArray *) names response:(ResponseBlock) response;

- (void) loadImageWithResponse:(ResponseBlock) response;

@end