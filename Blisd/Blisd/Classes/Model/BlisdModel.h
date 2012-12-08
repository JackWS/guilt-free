//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class PFObject;
@class PFQuery;

#define MOCK_DATA 0

typedef void (^ResponseBlock) (id object, NSError *error);

@interface BlisdModel : NSObject

@property (nonatomic, readonly) NSString *id;

- (id) initWithPFObject:(PFObject *) pfObject;

- (void) saveInBackgroundWithBlock:(ResponseBlock) block;

// To be over-ridden by subclasses
- (PFObject *) toPFObject;

@end