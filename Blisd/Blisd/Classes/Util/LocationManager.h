//
// Created by Kevin on 11/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kLocationManagerDidTimeOutNotification;
extern NSString *const kLocationManagerDidFindAccurateLocationNotification;

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *location;

+ (LocationManager *) instance;

- (void) findLocation;

- (void) stopFindingLocation;


@end