# ZIKConstraintsGuard
a tool for debugging iOS view constraint conflict

##Feature

* monitor constraint conflict.
* callback with more information: the UIView where conflict happened, the view controller, all current constraints, the constraint to be breaked.

Catch the view and view controller,then you can quickly find out the exactly wrong constraint and which view it came from.

If your app need to support iOS7,this will offer a great help,since Xcode8 can't debug iOS7 device any more.

___

一个调试iOS约束冲突的工具

##功能
* 监控约束冲突。
* 发生冲突时，回调附带更多关键信息：冲突所在的view和view controller，目前所有的约束，系统将要打破的约束。

通过捕捉到的view和view controller，就可以快速地找到是哪个界面的哪个控件的哪个约束出现了问题。

当你的app需要支持iOS7时，这个工具会提供很大帮助。因为Xcode8已经不支持iOS7的调试了。