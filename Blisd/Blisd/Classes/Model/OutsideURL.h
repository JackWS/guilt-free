//
// Created by Kevin on 10/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlisdModel.h"

@class PFObject;


@interface OutsideURL : BlisdModel

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *user;

- (PFObject *) toPFObject;

@end