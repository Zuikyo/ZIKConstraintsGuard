//
//  ViewController.m
//  ConstraintDebug
//
//  Created by zuik on 2016/12/8.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import "ViewController.h"
#import "ZIKConstraintsGuard.h"

@interface ViewController ()
@property (nonatomic, strong) NSNotificationQueue *notificationQueue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ZIKConstraintsGuard monitorUnsatisfiableConstraintWithHandler:^(UIView *view, UIViewController *viewController, NSLayoutConstraint *constraintToBreak, NSArray<NSLayoutConstraint *> *currentConstraints) {
        NSLog(@"******************monitored constraint conflict!******************");
        NSString *className = NSStringFromClass([viewController class]);
        if ([className hasPrefix:@"UI"] && ![className isEqualToString:@"UIApplication"]) {//UIAlertController will occur conflict
            NSLog(@"ignore conflict in UIKit:%@",viewController);
            return;
        }
        NSLog(@"********conflict info*********\nconflict in viewController:\n%@ \nview:\n%@",viewController,view);
        NSLog(@"********conflict info*********\nview hierarchy:\n%@",[view valueForKeyPath:@"recursiveDescription"]);//recursiveDescription is a private API
        NSLog(@"********conflict info*********\ncurrent constraints:\n%@",currentConstraints);
        NSLog(@"********conflict info*********\ntry to break constraint:\n%@",constraintToBreak);
        
    }];
    
    [self addBadConstraints];
}

- (void)addBadConstraints {
    UITableView *subView = [[UITableView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    subView.backgroundColor = [UIColor redColor];
    [self.view addSubview:subView];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraints:@[leftConstraint, rightConstraint, topConstraint,bottomConstraint]];
    
    NSLayoutConstraint *badConstraint = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeTop multiplier:1 constant:10];
    [self.view addConstraint:badConstraint];
}

@end
