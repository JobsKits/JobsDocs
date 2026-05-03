---
title: "iOS 锁的使用"
date: 2025-08-18T12:32:42+07:00
draft: false
weight: 110
summary: ""
bookCollapseSection: false
---




```objective-c
/// 获取颜色值
- (UIColor *)colorForKey:(NSString *)key {
  pthread_rwlock_rdlock(&_rwlock);// 读写锁
  UIColor *color = UIColor.redCor;
  pthread_rwlock_unlock(&_rwlock);// 读写锁
  return color;
}
```

