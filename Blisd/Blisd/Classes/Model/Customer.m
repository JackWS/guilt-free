//
// Created by Kevin on 10/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Customer.h"
#import "Balance.h"
#import "PFObject+NonNull.h"

@interface Customer ()

@property (nonatomic, strong) PFFile *imageFile;

@end

@implementation Customer {

}

static NSString *const kClassName = @"Customer";

static NSString *const kCustomerCompanyKey = @"customerCompany";
static NSString *const kImageKey = @"businessPicture";

+ (void) findWithNames:(NSArray *) names response:(ResponseBlock) response {
    PFQuery *innerQuery = [PFQuery queryWithClassName:kClassName];
    [innerQuery whereKey:@"customerCompany" containedIn:names];
    [innerQuery findObjectsInBackgroundWithBlock:^(NSArray *companyObjects, NSError *error) {
        if (error) {
            response(nil, error);
        } else if (!companyObjects) {
            response(nil, nil);
        } else {
            NSMutableArray *companies = [NSMutableArray arrayWithCapacity:companyObjects.count];
            for (PFObject *object in companyObjects) {
                [companies addObject:[Customer customerFromPFObject:object]];
            }
            response(companies, nil);
        }
    }];
}

- (void) loadImageWithResponse:(ResponseBlock) response {
    [self.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            response(nil, error);
        } else {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                self.companyImage = image;
            }
            response(self.companyImage, nil);
        }
    }];
}


+ (Customer *) customerFromPFObject:(PFObject *) obj {
    if (!obj) {
        return nil;
    }

    Customer *customer = [[Customer alloc] initWithPFObject:obj];
    customer.company = [obj nonNullObjectForKey:kCustomerCompanyKey];
    customer.imageFile = [obj nonNullObjectForKey:kImageKey];

    return customer;
}


@end