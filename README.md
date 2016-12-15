# ZIKConstraintsGuard
A tool for debugging iOS view constraint.Monitor constraint conflict and crash problem below iOS7.

## Features

* monitor constraint conflict.
* monitor crash below iOS7 causing by layoutSubviews.
* callback with more information: 
	* the UIView where conflict happened
	* the view controller
	* all current constraints
	* the constraint to be breaked
	* ambiguous layout
	* view hierarchy

With the view and view controller, you can quickly find out the exactly wrong constraint and which view it came from.

## Apple's bug below iOS7

When implementation your custom view's `layoutSubviews`, remember:
 
* Call `[super layoutSubviews]`.
 
* Don't add constraints in `layoutSubviews`.
 
If not, adding subview to this view in iOS6 or iOS7 will crash you app with `'Auto Layout still required after executing - layoutSubviews..'` printed in console.Apple fixed this after iOS8.
 
Some system view like `UITableView`,`UITableViewCell` doesn't call `[super layoutSubviews]`. So don't add subview to them in iOS6 and iOS7, or you can use method swizzling to fix them.

If your app need to support iOS7,this will offer a great help,since Xcode8 can't debug iOS7 device any more.

## CocoaPods

To your podspec add:

```
pod 'ZIKConstraintsGuard'
```

## <a name="how-to-use"></a>How to use

```
//monitor constraint conflict
[ZIKConstraintsGuard monitorUnsatisfiableConstraintWithHandler:^(UIView *view, 
																 UIViewController *viewController, 
																 NSLayoutConstraint *constraintToBreak, 
																 NSArray<NSLayoutConstraint *> *currentConstraints, 
																 NSString *description) {
        
    NSString *className = NSStringFromClass([viewController class]);
    if ([className hasPrefix:@"UI"] && ![className isEqualToString:@"UINavigationController"]) {
        NSLog(@"ignore conflict in system view:%@",viewController);
        return;
    }
    
    //formatted description with enough debugging info, write to your log file
    NSLog(@"%@",description);
}];
```

```
//monitor crash below iOS7
[ZIKConstraintsGuard monitorErrorFromLayoutviewsWithHandler:^(UIView * _Nonnull view, UIViewController * _Nullable viewController, NSString * _Nonnull description) {
        
    //write error info to your log file before crash
    NSLog(@"%@",description);
}];
```

## How it works

Hook private API to get the UIView.Then get other informations from the UIView.

API when meet unsatisfiable constraint:

```
-[UIView engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:]
```

API when system checking if view miss to call super layoutSubviews:

```
-[UIView _wantsWarningForMissingSuperLayoutSubviews]
```
These private API names were encrypted when using,in case you want to use this tool in an AppStore app.
___

一个调试iOS约束的工具。可以检测约束冲突和iOS7以下的crash问题。

## 功能
* 监控约束冲突。
* 监控iOS7以下系统UIView中的layoutSubviews导致的crash。
* 发生冲突时，回调附带更多关键信息：
	* 冲突所在的view
	* 冲突所在的view controller
	* 目前所有的约束
	* 系统将要打破的约束
	* 有歧义的layout
	* view层级

通过捕捉到的view和view controller，就可以快速地找到是哪个界面的哪个控件的哪个约束出现了问题。

## 自动布局在iOS7以下的bug

当你在实现自定义view的`layoutSubviews`方法时，记住：

* 调用`[super layoutSubviews]`
* 不要在`layoutSubviews`里增加约束

如果不遵守这两条，当你向这个view上增加子view时，在iOS6和iOS7上会crash，控制台会输出提示：`'Auto Layout still required after executing - layoutSubviews..'` 。iOS8开始则不会crash。

某些系统控件，例如`UITableView`，`UITableViewCell`没有调用`[super layoutSubviews]`，所以在iOS6和iOS7上不能在它们上面增加子view，除非你用method swizlling修复它们的`layoutSubviews`方法。

当你的app需要支持iOS7时，这个工具会提供很大帮助。因为Xcode8已经不支持iOS7的调试了。

## CocoaPods

添加:

```
pod 'ZIKConstraintsGuard'
```

## 使用方法
见英文部分：
[使用方法](#how-to-use)

## 实现原理

替换了两个私有API，获取对应的view，再从view里获取其他相关信息。

当遇到约束冲突时的API:

```
-[UIView engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:]
```

系统用于检测当前view是否调用了`[super layoutSubviews]`的API:

```
-[UIView _wantsWarningForMissingSuperLayoutSubviews]
```
这些私有API名字已经经过混淆。

