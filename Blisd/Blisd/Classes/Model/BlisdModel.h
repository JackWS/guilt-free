//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class PFObject;

#define MOCK_DATA 0

typedef void (^ResponseBlock) (id object, NSError *error);

@interface BlisdModel : NSObject

- (id) initWithPFObject:(PFObject *) pfObject;

- (void) saveInBackgroundWithBlock:(ResponseBlock) block;

// To be over-ridden by subclasses
- (PFObject *) toPFObject;

@end