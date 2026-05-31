---
title: "iOS 状态栏颜色的修改"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 310
summary: "全局修改 局部修改"
bookCollapseSection: false
---


<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

*全局修改*

```objective-c
 1、在Info.plist里面加入如下键值对：
    1.1、View controller-based status bar appearance : NO
    1.2、Status bar style : Light Content

 2、[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;// iOS 13 后方法被标注废弃

1.2 和 2 任意选一个即可
```

*局部修改*

```objective-c
1、在Info.plist里面加入如下键值对：
 View controller-based status bar appearance ： YES //全局是NO、局部是YES 
  
2、@interface BaseNavigationVC : UINavigationController
	2.1、在 BaseNavigationVC.m里面写入：
	- (UIViewController *)childViewControllerForStatusBarStyle {
				return self.topViewController;
	}
  2.2、在具体的需要修改的VC.m里面写入：
  -(UIStatusBarStyle)preferredStatusBarStyle{
      return UIStatusBarStyleLightContent;
  }
```

