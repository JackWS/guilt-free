//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"

@interface Scan : BlisdModel

+ (void) processScanFromURL:(NSString *) url response:(ResponseBlock) response;

@end