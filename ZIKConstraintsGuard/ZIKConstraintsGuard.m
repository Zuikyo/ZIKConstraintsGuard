//
//  ZIKConstraintsGuard.m
//  ConstraintDebug
//
//  Created by zuik on 2016/12/8.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import "ZIKConstraintsGuard.h"
#import "ZIKMethodSwizzler.h"

///engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:
#define kOriginalUnsatisfiableConstraintHandleSelectorASCII (char *)(uint8_t[]){0x65,0x6e,0x67,0x69,0x6e,0x65,0x3a,0x77,0x69,0x6c,0x6c,0x42,0x72,0x65,0x61,0x6b,0x43,0x6f,0x6e,0x73,0x74,0x72,0x61,0x69,0x6e,0x74,0x3a,0x64,0x75,0x65,0x54,0x6f,0x4d,0x75,0x74,0x75,0x61,0x6c,0x6c,0x79,0x45,0x78,0x63,0x6c,0x75,0x73,0x69,0x76,0x65,0x43,0x6f,0x6e,0x73,0x74,0x72,0x61,0x69,0x6e,0x74,0x73,0x3a,'\0'}

///confuse the selector name,in case you want to use this in AppStore version
#define selectorFromASCII(ASCIIOfSelectorName) ({  \
    char *hex = ASCIIOfSelectorName;    \
    NSString *selectorName = [[NSString alloc] initWithCString:hex encoding:NSASCIIStringEncoding]; \
    SEL selector = NSSelectorFromString(selectorName);  \
    selector;   \
})

static ZIKUnsatisfiableConstraintHandler monitorHandler;

@implementation ZIKConstraintsGuard
+ (void)monitorUnsatisfiableConstraintWithHandler:(ZIKUnsatisfiableConstraintHandler)handler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL originalSelector = selectorFromASCII(kOriginalUnsatisfiableConstraintHandleSelectorASCII);
        replaceMethodWithMethod([UIView class],
                                originalSelector,
                                [self class],
                                @selector(o_engine:willBreakConstraint:currentConstraints:));
#pragma clang diagnostic pop
    });
    
    monitorHandler = handler;
}

+ (void)o_engine:(id)engine willBreakConstraint:(id)breakConstraint currentConstraints:(id)currentConstraints {
    UIView *view = (UIView *)self;
    UIViewController *viewController = o_viewControllerOfView(view);
    if (monitorHandler) {
        monitorHandler(view, viewController, breakConstraint, currentConstraints);
    }
    [self o_engine:engine willBreakConstraint:breakConstraint currentConstraints:currentConstraints];
}

//http://stackoverflow.com/questions/1372977/given-a-view-how-do-i-get-its-viewcontroller
UIViewController * o_viewControllerOfView(UIView *view) {
    UIViewController *viewController;

    UIResponder *responder = view;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    
    viewController = (UIViewController *)responder;
    return viewController;
}

@end
