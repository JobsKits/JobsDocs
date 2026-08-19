---
title: "unknown class viewcontroller in interface builder file"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 590
summary: "资料来源：https://blog.csdn.net/CC1991_/article/details/100803193 原因 解决方案"
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

资料来源：https://blog.csdn.net/CC1991_/article/details/100803193

*原因*

```
因为新建项目中删掉了系统自动创建的那个ViewController，新建并使用了开发者自定义的ViweController， 但是项目工程main.storyboard中还是使用原来的ViewController
```

*解决方案*

```
Main.storyboard 第四个选项卡 👉🏻 Custom Class 置空
```



