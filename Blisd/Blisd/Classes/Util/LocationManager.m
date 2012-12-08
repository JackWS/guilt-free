//
// Created by Kevin on 11/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

NSString *const kLocationManagerDidTimeOutNotification                  = @"LocationManagerDidTimeOutNotification";
NSString *const kLocationManagerDidFindAccurateLocationNotification     = @"LocationManagerDidFindAccurateLocationNotification";

@interface LocationManager()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL findingLocation;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, strong) NSTimer *updateTimer;

@end

static NSTimeInterval const kTimeoutInterval = 5.0f;
static NSTimeInterval const kUpdateLocationInterval =
#ifdef DEBUG
    10;
#else
        60 * 5; // 5 minutes
#endif

static CGFloat const kDesiredAccuracy = 100.0f;

@implementation LocationManager {

}

+ (LocationManager *) instance {
    static LocationManager *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id) init {
    self = [super init];
    if (self) {
        NSLog(@"LocationManager - initialize");
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }

    return self;
}


- (void) dealloc {
    [self.timeoutTimer invalidate];
    [self.updateTimer invalidate];
}

- (void) findLocation {
    @synchronized (self) {
        NSLog(@"LocationManager - findLocation");
        if (self.findingLocation) {
            return;
        } else {
            self.findingLocation = YES;
        }
        [self.locationManager startUpdatingLocation];
        __block LocationManager *lm = self;
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeoutInterval
                block:^(NSTimeInterval time)
                {
                    NSLog(@"LocationManager - timeout");
                    [lm stopFindingLocation];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidTimeOutNotification
                                                                        object:lm];
                } repeats:NO];
    }
}

- (void) stopFindingLocation {
    @synchronized (self) {
        NSLog(@"LocationManager - stopFindingLocation");
        [self.locationManager stopUpdatingLocation];
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
        self.findingLocation = NO;
    }
}

#pragma mark Helpers

- (void) scheduleUpdateTimer {
    if (self.updateTimer) {
        return;
    }

    NSLog(@"LocationManager - scheduleUpdateTimer for %f seconds from now.", kUpdateLocationInterval);
    __block LocationManager *lm = self;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:kUpdateLocationInterval
            block:^(NSTimeInterval time) {
                [self.updateTimer invalidate];
                self.updateTimer = nil;
                [lm findLocation];
            } repeats:NO];
}

#pragma mark CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *) manager didUpdateToLocation:(CLLocation *) newLocation fromLocation:(CLLocation *) oldLocation {
    @synchronized (self) {
        NSLog(@"Received new location, <lat: %f, long: %f, acc: %f>",
                newLocation.coordinate.latitude,
                newLocation.coordinate.longitude,
                newLocation.horizontalAccuracy);
        self.location = newLocation;
        if (self.location.horizontalAccuracy <= kDesiredAccuracy) {
            [self stopFindingLocation];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidFindAccurateLocationNotification
                                                                object:self];
        }
        [self scheduleUpdateTimer];
    }
}

- (void) locationManager:(CLLocationManager *) manager didFailWithError:(NSError *) error {
    @synchronized (self) {
        NSLog(@"Error getting location information: %@", [error description]);
        [self stopFindingLocation];
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            // Only schedule the timer if we're authorized. Otherwise we'll rely on the didChangeAuthorizationStatus callback
            [self scheduleUpdateTimer];
        }
    }
}

- (void) locationManager:(CLLocationManager *) manager didChangeAuthorizationStatus:(CLAuthorizationStatus) status {
    if (status == kCLAuthorizationStatusAuthorized) {
        [self findLocation];
    } else {
        [self stopFindingLocation];
    }
}

@end