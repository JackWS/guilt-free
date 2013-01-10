//
// Created by Kevin on 1/9/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface IntroState : NSObject

@property (nonatomic, assign) BOOL scan;
@property (nonatomic, assign) BOOL bliss;
@property (nonatomic, assign) BOOL deals;

- (NSDictionary *) toDictionary;

+ (IntroState *) fromDictionary:(NSDictionary *) dict;

@end