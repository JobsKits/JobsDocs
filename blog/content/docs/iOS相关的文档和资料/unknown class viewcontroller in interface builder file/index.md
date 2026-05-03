---
title: "unknown class viewcontroller in interface builder file"
date: 2025-08-18T12:32:42+07:00
draft: false
weight: 170
summary: "资料来源：https://blog.csdn.net/CC1991_/article/details/100803193 原因 解决方案"
bookCollapseSection: false
---

# unknown class viewcontroller in interface builder file


资料来源：https://blog.csdn.net/CC1991_/article/details/100803193

*原因*

```
因为新建项目中删掉了系统自动创建的那个ViewController，新建并使用了开发者自定义的ViweController， 但是项目工程main.storyboard中还是使用原来的ViewController
```

*解决方案*

```
Main.storyboard 第四个选项卡 👉🏻 Custom Class 置空
```



