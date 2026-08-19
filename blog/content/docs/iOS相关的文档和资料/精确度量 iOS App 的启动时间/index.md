---
title: "精确度量 iOS App 的启动时间"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 500
summary: "参考资料来源：https://www.jianshu.com/p/c14987eee107 方法一： Edit scheme --> Run --> Arguments 中将环境变量 DYLDPRINTSTATISTICS 设为 1，就可以看到 main 之前各个阶段的时间消耗。 方法二： Edit scheme --> Run --> Arguments "
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

参考资料来源：https://www.jianshu.com/p/c14987eee107
方法一：
Edit scheme --> Run --> Arguments 中将环境变量 DYLD_PRINT_STATISTICS 设为 1，就可以看到 main 之前各个阶段的时间消耗。
方法二：
Edit scheme --> Run --> Arguments 中将环境变量 DYLD_PRINT_STATISTICS_DETAILS 设为 1 就可以。

