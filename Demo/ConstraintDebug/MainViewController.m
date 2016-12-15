//
//  MainViewController.m
//  ConstraintDebug
//
//  Created by zuik on 2016/12/8.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import "MainViewController.h"
#import "Masonry.h"

@interface MainViewController ()<UITabBarDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *myView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addBadConstraints];
}

- (void)addBadConstraints {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor redColor];
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(@250);
        make.height.equalTo(@250);
        
        //conflicting constraint
        make.left.equalTo(self.view.mas_left);
    }];
    
    //add subview to UITableView will lead to crash in iOS6 and iOS7
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [tableView addSubview:indicator];
    [indicator startAnimating];
    
    [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tableView.mas_centerX);
        make.centerY.equalTo(tableView.mas_centerY);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
    
    return cell;
}

@end
