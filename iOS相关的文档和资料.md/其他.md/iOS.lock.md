# iOS 锁的使用

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

