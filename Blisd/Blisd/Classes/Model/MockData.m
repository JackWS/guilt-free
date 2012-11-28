//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MockData.h"
#import "BlissBalance.h"
#import "Campaign.h"


@implementation MockData {

}
+ (MockData *) instance {
    static MockData *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

+ (NSArray *) generateBalanceList {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        BlissBalance *balance = [[BlissBalance alloc] init];

        Campaign *campaign = [[Campaign alloc] init];
        balance.campaign = campaign;

        campaign.buyX = 5;
        campaign.buyY = @"cups of coffee";
        campaign.getX = @"a coupon for a free hug";
        campaign.customerCompany = @"ACME, Ltd.";
        balance.balance = 3;

        [array addObject:balance];
    }

    return array;
}

#pragma mark Debugging/Testing

+ (void) callAfterDelay:(CGFloat) delayInSeconds block:(void (^)()) block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC)), dispatch_get_current_queue(),
            ^{block();});
}

+ (NSString *) generateCampaignURL {
    return @"http://blisd.com/app/tickone.php?campaignNumber=121111lUyGCyZKKn";
}

+ (NSString *) generateCheckInURL {
    return @"http://blisd.com/app/CUzVxYDwKzM";
}

+ (void) callAfterDelay:(CGFloat) delayInSeconds successBlock:(void (^)()) success failureBlock:(void (^)()) failure {
    [MockData callAfterDelay:delayInSeconds successProbability:0.95 successBlock:success failureBlock:failure];
}

+ (void) callAfterDelay:(CGFloat) delayInSeconds successProbability:(CGFloat) prob successBlock:(void (^)()) success failureBlock:(void (^)()) failure {
    srand((unsigned int) time(NULL));
    int percent = rand() % 100;

    if (percent < prob * 100) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC)), dispatch_get_current_queue(),
                ^{success();});
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC)), dispatch_get_current_queue(),
                ^{failure();});
    }
}


@end