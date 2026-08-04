---
title: "读取本地plist"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 320
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
+ (TYFSITE)siteType{
    static NSInteger site = 6;
    static dispatch_once_t dispatchOnce;
    dispatch_once(&dispatchOnce, ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MetaData" ofType:@"plist"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath]) {
            NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:filePath];
            NSString *appTypeStr = config[@"appType"];
            site = appTypeStr.integerValue;
        }
    });return site;
}
```

