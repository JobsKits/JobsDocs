---
title: "iOS禁用返回手势"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 530
summary: ""
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

```
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}// 与FD相互作用下 不起作用

#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIScrollView+FDFullscreenPopGesture.h"

- (void)viewDidLoad {
  [super viewDidLoad];
  self.fd_interactivePopDisabled = YES;
}
```

