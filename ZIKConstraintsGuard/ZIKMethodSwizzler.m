//
//  ZIKMethodSwizzler.m
//  ConstraintDebug
//
//  Created by zuik on 2016/12/9.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import "ZIKMethodSwizzler.h"
#import <objc/runtime.h>

bool replaceMethodWithMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    if (!originalMethod) {
        originalMethod = class_getClassMethod(originalClass, originalSelector);
//        originalClass = objc_getMetaClass(object_getClassName(originalClass));
    }
    if (!originalMethod) {
        NSLog(@"替换方法失败，找不到原方法:%@",NSStringFromSelector(originalSelector));
        return false;
    }
    
    if (!swizzledMethod) {
        swizzledMethod = class_getClassMethod(swizzledClass, swizzledSelector);
    }
    if (!swizzledMethod) {
        NSLog(@"替换方法失败，找不到用于替换的方法:%@",NSStringFromSelector(swizzledSelector));
        return false;
    }
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP swizzledIMP = method_getImplementation(swizzledMethod);
    const char *originalType = method_getTypeEncoding(originalMethod);
    const char *swizzledType = method_getTypeEncoding(swizzledMethod);
    int cmpResult = strcmp(originalType, swizzledType);
    if (cmpResult != 0) {
        NSLog(@"警告：用于替换的方法和原方法的方法签名不匹配，请确认！原方法：%@\n签名：%s\n用于替换的方法:%@\n签名：%s",NSStringFromSelector(originalSelector),originalType,NSStringFromSelector(swizzledSelector),swizzledType);
        swizzledType = originalType;
    }
    
    class_replaceMethod(originalClass,swizzledSelector,originalIMP,originalType);
    class_replaceMethod(originalClass,originalSelector,swizzledIMP,swizzledType);
    return true;
}
