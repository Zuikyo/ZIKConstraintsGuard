//
//  UIView+ZIKDebug.h
//  ConstraintDebug
//
//  Created by zuik on 2016/12/15.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import <UIKit/UIKit.h>

///decrypt the selector name,in case you want to use private API in AppStore version
#define selectorFromASCII(ASCIIOfSelectorName) ({  \
char *hex = ASCIIOfSelectorName;    \
NSString *selectorName = [[NSString alloc] initWithCString:hex encoding:NSASCIIStringEncoding]; \
SEL selector = NSSelectorFromString(selectorName);  \
selector;   \
})

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZIKDebug)
///return the first subview in hierarchy tree for specific kind of class
- (nullable UIView *)o_recursiveSearchSubviewWithClass:(Class)viewClass;
///view controller of the view
- (UIViewController *)o_viewController;
///get info about ambiguous layout; use private API -[UIView _autolayoutTrace].Selector name encrypted
- (NSString *)o_ambiguousLayoutInfo;
///get view hierarchy; use private API -[UIView recursiveDescription].Selector name encrypted
- (NSString *)o_viewHierarchyInfo;
@end

NS_ASSUME_NONNULL_END
