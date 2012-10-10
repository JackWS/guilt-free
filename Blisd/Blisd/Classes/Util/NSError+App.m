//
// Created by Kevin on 8/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "NSError+App.h"

NSString *const kErrorDomain                        =   @"com.blisd.blisd";
NSString *const kErrorDisplayTextKey                =   @"errorDisplay";
NSString *const kErrorDetailsKey                    =   @"errorDetails";

@implementation NSError (App)

+ (NSError *) appErrorWithDisplayText:(NSString *) text {
    return [NSError appErrorWithDisplayText:text errorCode:-1];
}

+ (NSError *) appErrorWithDisplayText:(NSString *) text errorCode:(NSInteger) code {
    return [NSError appErrorWithDisplayText:text detailText:nil errorCode:code];
}

+ (NSError *) appErrorWithDisplayText:(NSString *) text detailText:(NSString *) detailText errorCode:(NSInteger) code {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:text, kErrorDisplayTextKey,
    detailText, kErrorDetailsKey, nil];
    return [NSError errorWithDomain:kErrorDomain code:code userInfo:userInfo];
}

- (NSString *) appDisplayText {
    return [self.userInfo objectForKey:kErrorDisplayTextKey];
}

- (NSString *) appDetailsText {
    return [self.userInfo objectForKey:kErrorDetailsKey];
}

@end