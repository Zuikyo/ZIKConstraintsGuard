//
//  ZIKConstraintsGuard.m
//  ConstraintDebug
//
//  Created by zuik on 2016/12/8.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import "ZIKConstraintsGuard.h"
#import "ZIKMethodSwizzler.h"
#import "UIView+ZIKDebug.h"

///engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:
#define kOriginalUnsatisfiableConstraintHandleSelectorASCII (char *)(uint8_t[]){0x65,0x6e,0x67,0x69,0x6e,0x65,0x3a,0x77,0x69,0x6c,0x6c,0x42,0x72,0x65,0x61,0x6b,0x43,0x6f,0x6e,0x73,0x74,0x72,0x61,0x69,0x6e,0x74,0x3a,0x64,0x75,0x65,0x54,0x6f,0x4d,0x75,0x74,0x75,0x61,0x6c,0x6c,0x79,0x45,0x78,0x63,0x6c,0x75,0x73,0x69,0x76,0x65,0x43,0x6f,0x6e,0x73,0x74,0x72,0x61,0x69,0x6e,0x74,0x73,0x3a,'\0'}
///_wantsWarningForMissingSuperLayoutSubviews
#define kWantsWarningForMissingSuperLayoutSubviewsSelectorASCII (char *)(uint8_t[]){0x5f,0x77,0x61,0x6e,0x74,0x73,0x57,0x61,0x72,0x6e,0x69,0x6e,0x67,0x46,0x6f,0x72,0x4d,0x69,0x73,0x73,0x69,0x6e,0x67,0x53,0x75,0x70,0x65,0x72,0x4c,0x61,0x79,0x6f,0x75,0x74,0x53,0x75,0x62,0x76,0x69,0x65,0x77,0x73,'\0'}
///UIViewControllerWrapperView
#define kUIViewControllerWrapperViewASCII (char *)(uint8_t[]){0x55,0x49,0x56,0x69,0x65,0x77,0x43,0x6f,0x6e,0x74,0x72,0x6f,0x6c,0x6c,0x65,0x72,0x57,0x72,0x61,0x70,0x70,0x65,0x72,0x56,0x69,0x65,0x77,'\0'}


static ZIKUnsatisfiableConstraintHandler unsatisfiableConstraintHandler;
static ZIKErrorFromLayoutviewsHandler errorFromLayoutviewsHandler;

@implementation ZIKConstraintsGuard

+ (void)monitorUnsatisfiableConstraintWithHandler:(ZIKUnsatisfiableConstraintHandler)handler {
    float systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    if (systemVersion < 6.0) {
        return;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL originalSelector = selectorFromASCII(kOriginalUnsatisfiableConstraintHandleSelectorASCII);
        Class originalClass;
        if (systemVersion < 7.0) {
            originalClass = [UIWindow class];
        } else {
            originalClass = [UIView class];
        }
        
        BOOL success = replaceMethodWithMethod(originalClass, originalSelector, [self class], @selector(o_engine:willBreakConstraint:currentConstraints:));
        if (!success) {
            NSLog(@"monitor unsatisfiable constraint failed!");
        }
#pragma clang diagnostic pop
    });
    
    unsatisfiableConstraintHandler = handler;
}

+ (void)monitorErrorFromLayoutviewsWithHandler:(ZIKErrorFromLayoutviewsHandler)handler {
    float systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    if (systemVersion >= 8.0 || systemVersion < 6.0) {
        return;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL originalSelector = selectorFromASCII(kWantsWarningForMissingSuperLayoutSubviewsSelectorASCII);
        BOOL success = replaceMethodWithMethod([UIView class], originalSelector, [self class], @selector(o_hasErrorInLayoutSubviews));
        if (!success) {
            NSLog(@"monitor error from -layoutviews failed!");
        }
#pragma clang diagnostic pop
    });
    errorFromLayoutviewsHandler = handler;
}

+ (void)o_engine:(id)engine willBreakConstraint:(id)breakConstraint currentConstraints:(id)currentConstraints {
    UIView *view = (UIView *)self;
    if ([view isKindOfClass:[UIWindow class]]) {
        NSString *WrapperViewName = [[NSString alloc] initWithCString:kUIViewControllerWrapperViewASCII encoding:NSASCIIStringEncoding];
        UIView *viewControllerWrapperView = [view o_recursiveSearchSubviewWithClass:NSClassFromString(WrapperViewName)];
        NSArray<UIView *> *subviews = [viewControllerWrapperView subviews];
        if (subviews && subviews.count > 0) {
            view = [subviews firstObject];
        }
    }
    UIViewController *viewController = [view o_viewController];
    if (unsatisfiableConstraintHandler) {
        NSString *description = [ZIKConstraintsGuard o_descriptionForUnsatisfiableConstraintWithView:view viewController:viewController constraintToBreak:breakConstraint currentConstraints:currentConstraints];
        unsatisfiableConstraintHandler(view, viewController, breakConstraint, currentConstraints, description);
    }
    
    [self o_engine:engine willBreakConstraint:breakConstraint currentConstraints:currentConstraints];
}

+ (BOOL) o_hasErrorInLayoutSubviews {
    BOOL hasError = [self o_hasErrorInLayoutSubviews];
    
    if (hasError && errorFromLayoutviewsHandler) {
        UIView *view = (UIView *)self;
        NSString *description = [ZIKConstraintsGuard o_descriptionForErrorFromLayoutviewsWithView:view viewController:[view o_viewController]];
        errorFromLayoutviewsHandler(view, [view o_viewController] , description);
    }
    return hasError;
}

+ (NSString *)o_descriptionForUnsatisfiableConstraintWithView:(UIView *)view viewController:(UIViewController *)viewController constraintToBreak:(NSLayoutConstraint *)constraintToBreak currentConstraints:(NSArray<NSLayoutConstraint*> *)currentConstraints {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"constraint conflict in viewController:\n%@\nview:\n%@\n",viewController,view];
    [description appendFormat:@"ambiguous layout:\n%@\n",[view o_ambiguousLayoutInfo]];
    [description appendFormat:@"view hierarchy:\n%@\n",[view o_viewHierarchyInfo]];
    [description appendFormat:@"current constraints:\n%@\n",currentConstraints];
    [description appendFormat:@"try to break constraint:\n%@",constraintToBreak];
    return description;
}

+ (NSString *)o_descriptionForErrorFromLayoutviewsWithView:(UIView *)view viewController:(UIViewController *)viewController {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"Check %@'s implementation of -layoutSubviews:\n1.Call [super layoutSubviews](if not, add subview to %@ in iOS6 or iOS7 system will crash) 2.Don't add constraints in -layoutSubviews.Some system view like UITableView,UITableViewCell doesn't call [super layoutSubviews],so don't add subview to them in iOS6 and iOS7, or you can use method swizzling to fix them.\n",[view class],[view class]];
    [description appendFormat:@"error in viewController:\n%@ \nview:\n%@\n",viewController,view];
    [description appendFormat:@"view hierarchy:\n%@",[view o_viewHierarchyInfo]];
    return description;
}

@end
