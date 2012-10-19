//
// Created by Kevin on 10/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "BlisdModel.h"

@interface BlisdModel()

@property (nonatomic, strong) PFObject *pfObject;

@end

@implementation BlisdModel {

}

- (id) initWithPFObject:(PFObject *) pfObject {
    self = [super init];
    if (self) {
        self.pfObject = pfObject;
    }
    return self;
}

- (void) saveInBackgroundWithBlock:(ResponseBlock) block {
    [[self toPFObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (block) {
            block($bool(succeeded), error);
        }
    }];
}

- (PFObject *) toPFObject {
    return self.pfObject;
}


@end