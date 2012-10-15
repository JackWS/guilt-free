//
//  BlissViewController.h
//  Blisd
//
//  Created by JStack on 9/21/12.
//  Copyright (c) 2012 Blisd LLC All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlissViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *balances;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
