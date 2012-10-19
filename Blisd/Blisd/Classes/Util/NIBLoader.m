//
// Created by Kevin on 10/2/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NIBLoader.h"


@implementation NIBLoader {

}

+ (id)loadFirstObjectFromNibNamed:(NSString *)nibName {
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    if (objects && objects.count >= 1) {
        return [objects objectAtIndex:0];
    } else {
        return nil;
    }
}


@end