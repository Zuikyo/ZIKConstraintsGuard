//
//  ZIKConstraintsGuard.h
//  ConstraintDebug
//
//  Created by zuik on 2016/12/8.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 callback when meet constraint conflict.

 @param view               the view where conflict happened,always the top view of current viewController;use API in UIView+ZIKDebug to get detail info
 @param viewController     the viewController where conflict happened
 @param constraintToBreak  constraint which will be breaked by system to recover from the conflict
 @param currentConstraints all current constraints
 @param description        formatted description contains enough debug information
 */
typedef void(^ZIKUnsatisfiableConstraintHandler)(UIView *view, UIViewController *viewController, NSLayoutConstraint *constraintToBreak, NSArray<NSLayoutConstraint*> *currentConstraints, NSString *description);

/**
 callback when meet problem about 'Auto Layout still required after executing...'.

 @param view               the view where baddly implementation it's -layoutSubviews
 @param viewController     view controller of view
 @param description        formatted description contains enough debug information
 */
typedef void(^ZIKErrorFromLayoutviewsHandler)(UIView *view,  UIViewController *_Nullable viewController, NSString *description);

///monitor constraint problem
@interface ZIKConstraintsGuard : NSObject

/**
 start monitor constraint conflict. Only take affect after iOS6.
 
 @note          Some system view like UIAlertController has constraint conflict,you should manually ignore them by checking [viewController class]

 @param handler     called from main thread
 */
+ (void)monitorUnsatisfiableConstraintWithHandler:(ZIKUnsatisfiableConstraintHandler)handler NS_AVAILABLE_IOS(6_0);


/**
 monitor crash problem about 'Auto Layout still required after executing - layoutSubviews'. Only take affect in iOS6 and iOS7.
 
 @note          When implementation your custom view's -layoutSubviews, remember:
 
 1.Call [super layoutSubviews] (if not, add subview to this view in iOS6 or iOS7 system will crash).
 
 2.Don't add constraints in -layoutSubviews.
 
 Some system view like UITableView,UITableViewCell doesn't call [super layoutSubviews]. So don't add subview to them in iOS6 and iOS7, or you can use method swizzling to fix them.

 @param handler     called from main thread
 */
+ (void)monitorErrorFromLayoutviewsWithHandler:(ZIKErrorFromLayoutviewsHandler)handler NS_AVAILABLE_IOS(6_0);

@end

NS_ASSUME_NONNULL_END
