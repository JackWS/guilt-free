//
// Created by Kevin on 8/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface UIUtil : NSObject

+ (void) displayFatalError:(NSError *) error defaultText:(NSString *) defaultText retryBlock:(void (^)()) retryBlock;

+ (void) displayError:(NSError *) error defaultText:(NSString *) defaultText;

@end