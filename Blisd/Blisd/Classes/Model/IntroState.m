//
// Created by Kevin on 1/9/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "IntroState.h"
#import "NSDictionary+Helpers.h"


@implementation IntroState {

}

static NSString *const kScanKey = @"scan";
static NSString *const kBlissKey = @"bliss";
static NSString *const kDealsKey = @"deals";

- (NSDictionary *) toDictionary {
    return @{
            kScanKey    : @(self.scan),
            kBlissKey   : @(self.bliss),
            kDealsKey   : @(self.deals)
    };
}

+ (IntroState *) fromDictionary:(NSDictionary *) dict {
    IntroState *state = [[IntroState alloc] init];
    state.scan = [[dict nonNullObjectForKey:kScanKey] boolValue];
    state.bliss = [[dict nonNullObjectForKey:kBlissKey] boolValue];
    state.deals = [[dict nonNullObjectForKey:kDealsKey] boolValue];

    return state;
}


@end