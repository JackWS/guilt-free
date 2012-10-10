//
// Created by Kevin on 8/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

extern NSString *const kErrorDomain;
extern NSString *const kErrorDisplayTextKey;
extern NSString *const kErrorDetailsKey;

#import <Foundation/Foundation.h>

@interface NSError (App)

+ (NSError *) appErrorWithDisplayText:(NSString *) text;

+ (NSError *) appErrorWithDisplayText:(NSString *) text errorCode:(NSInteger) code;

+ (NSError *) appErrorWithDisplayText:(NSString *) text detailText:(NSString *) detailText errorCode:(NSInteger) code;

- (NSString *) appDisplayText;

- (NSString *) appDetailsText;


@end