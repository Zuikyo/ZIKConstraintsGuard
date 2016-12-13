//
//  ZIKMethodSwizzler.h
//  ConstraintDebug
//
//  Created by zuik on 2016/12/9.
//  Copyright © 2016年 zuik. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 find the originalSelector method in originalClass,and the swizzledSelector method in swizzledClass.Then replace the original method with the swizzled method.When searching method in class,search the instance method first,if not exist,then class method.
 
 @return true if replace successfully,otherwise false.
 */
bool replaceMethodWithMethod(Class originalClass,
                             SEL originalSelector,
                             Class swizzledClass,
                             SEL swizzledSelector);
