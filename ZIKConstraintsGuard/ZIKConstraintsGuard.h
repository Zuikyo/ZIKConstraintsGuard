//
//  ZIKConstraintsGuard.h
//  ConstraintDebug
//
//  Created by zuik on 2016/12/8.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 callback when monitored constraint conflict

 @param view               the view where conflict happened,always the top view of current viewController;use UIView's private API -(id)recursiveDescription to debug
 @param viewController     the viewController where conflict happened
 @param constraintToBreak  constraint which will be breaked by system to recover from the conflict
 @param currentConstraints all current constraints;probably the middle
 */
typedef void(^ZIKUnsatisfiableConstraintHandler)(UIView *view, UIViewController *viewController, NSLayoutConstraint *constraintToBreak, NSArray<NSLayoutConstraint*> *currentConstraints);

///monitor constraint conflict problem
@interface ZIKConstraintsGuard : NSObject

/**
 start monitor

 @param handler     called from main thread
 */
+ (void)monitorUnsatisfiableConstraintWithHandler:(ZIKUnsatisfiableConstraintHandler)handler;

@end
