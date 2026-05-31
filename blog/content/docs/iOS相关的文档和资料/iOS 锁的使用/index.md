---
title: "iOS 锁的使用"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 130
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



```objective-c
/// 获取颜色值
- (UIColor *)colorForKey:(NSString *)key {
  pthread_rwlock_rdlock(&_rwlock);// 读写锁
  UIColor *color = UIColor.redCor;
  pthread_rwlock_unlock(&_rwlock);// 读写锁
  return color;
}
```

