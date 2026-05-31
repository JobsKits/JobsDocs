---
title: "关于RAC框架中的@符号进行宏定义唤起的探究"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 170
summary: "1、RAC地址 ## 2、关于仿写RAC@宏定义 ## 3、核心探究 宏定义 调用 来自GPT-3.5的回答"
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

## 1、RAC地址

```javascript
https://github.com/ReactiveCocoa/ReactiveObjC
```

## 2、关于仿写RAC@宏定义

```objective-c
#ifndef jobs_weakify
#if DEBUG
#if __has_feature(objc_arc)
#define jobs_weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define jobs_weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define jobs_weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define jobs_weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif
```

```objective-c
#ifndef jobs_strongify
#if DEBUG
#if __has_feature(objc_arc)
#define jobs_strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define jobs_strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define jobs_strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define jobs_strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif
```

## 3、核心探究

*宏定义*

```objective-c
#ifndef UIFontWeightBoldSize
#define UIFontWeightBoldSize(object) autoreleasepool{} UIFontWeightBoldSize(object);
#endif
```

*调用*

```objective-c
@UIFontWeightBoldSize(12);
```

*来自GPT-3.5的回答*

```
在你提供的宏定义中，@符号可以用于调用的原因是因为宏内部实际上不包含Objective-C代码块，而是包含了一个函数调用，这个函数调用是Objective-C代码中的一个有效表达式。
```

