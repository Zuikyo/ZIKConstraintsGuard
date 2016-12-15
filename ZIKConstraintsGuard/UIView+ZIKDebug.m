//
//  UIView+ZIKDebug.m
//  ConstraintDebug
//
//  Created by zuik on 2016/12/15.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import "UIView+ZIKDebug.h"

///_autolayoutTrace
#define kAutolayoutTraceSelectorASCII (char *)(uint8_t[]){0x5f,0x61,0x75,0x74,0x6f,0x6c,0x61,0x79,0x6f,0x75,0x74,0x54,0x72,0x61,0x63,0x65,'\0'}

///recursiveDescription
#define kRecursiveDescriptionSelectorASCII (char *)(uint8_t[]){0x72,0x65,0x63,0x75,0x72,0x73,0x69,0x76,0x65,0x44,0x65,0x73,0x63,0x72,0x69,0x70,0x74,0x69,0x6f,0x6e,'\0'}

@implementation UIView (ZIKDebug)
- (UIView *)o_recursiveSearchSubviewWithClass:(Class)viewClass {
    UIView *resultView;
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:viewClass]) {
            resultView = subview;
            return resultView;
        } else {
            UIView *resultInSubview = [subview o_recursiveSearchSubviewWithClass:viewClass];
            if (resultInSubview) {
                return resultInSubview;
            }
        }
    }
    return resultView;
}

//http://stackoverflow.com/questions/1372977/given-a-view-how-do-i-get-its-viewcontroller
- (UIViewController *)o_viewController {
    UIViewController *viewController;
    
    UIResponder *responder = self;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    
    viewController = (UIViewController *)responder;
    return viewController;
}

- (NSString *)o_ambiguousLayoutInfo {
    SEL selector = selectorFromASCII(kAutolayoutTraceSelectorASCII);
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return nil;
}

- (NSString *)o_viewHierarchyInfo {
    SEL selector = selectorFromASCII(kRecursiveDescriptionSelectorASCII);
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return nil;
}
@end
