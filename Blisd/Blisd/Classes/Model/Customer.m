//
// Created by Kevin on 10/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Parse/Parse.h>
#import "Customer.h"
#import "BlissBalance.h"
#import "PFObject+NonNull.h"

@interface Customer ()

@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *address2;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;

@end

@implementation Customer {

}

static NSString *const kClassName = @"Customer";

static NSString *const kCustomerCompanyKey = @"customerCompany";
static NSString *const kImageKey = @"businessPicture";
static NSString *const kAddress1Key = @"customerAddressLine1";
static NSString *const kAddress2Key = @"customerAddressLine2";
static NSString *const kCityKey = @"customerCity";
static NSString *const kStateKey = @"customerState";
static NSString *const kZipKey = @"customerPostalCode";
static NSString *const kTagLineKey = @"customerTagline";
static NSString *const kTypeKey = @"customerType";
static NSString *const kWebsiteKey = @"customerWebsite";

- (NSString *) address {
    NSMutableString *addr = [NSMutableString string];
    if ([self nonEmpty:self.address1]) {
        [addr appendString:self.address1];
        [addr appendString:@"\n"];
    }
    if ([self nonEmpty:self.address2]) {
        [addr appendString:self.address2];
        [addr appendString:@"\n"];
    }
    if ([self nonEmpty:self.city]) {
        [addr appendString:self.city];
        if ([self nonEmpty:self.state]) {
            [addr appendString:@", "];
        }
    }
    if ([self nonEmpty:self.state]) {
        [addr appendString:self.state];
    }
    if ([self nonEmpty:self.zip]) {
        [addr appendString:@" "];
        [addr appendString:self.zip];
    }

    return addr;
}

- (BOOL) nonEmpty:(NSString *) str {
    return str && ![str isEqualToString:@""];
}

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
    customer.address1 = [obj nonNullObjectForKey:kAddress1Key];
    customer.address2 = [obj nonNullObjectForKey:kAddress2Key];
    customer.city = [obj nonNullObjectForKey:kCityKey];
    customer.state = [obj nonNullObjectForKey:kStateKey];
    customer.zip = [obj nonNullObjectForKey:kZipKey];
    customer.tagLine = [obj nonNullObjectForKey:kTagLineKey];
    customer.type = [obj nonNullObjectForKey:kTypeKey];
    customer.website = [obj nonNullObjectForKey:kWebsiteKey];

    return customer;
}


@end