---
title: "定一行个数得出几行"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 390
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

```count:总个数
num：一排定多少个
得出的结论是目前多少排
```

```
推演：
count   num     结论
0       3   (2/3) = 0

1       3   (3/3) = 1
2       3   (4/3) = 1
3       3   (5/3) = 1

4       3   (6/3) = 2
5       3   (7/3) = 2
6       3   (8/3) = 2

7       3   (9/3) = 3
8       3   (10/3) = 3
9       3   (11/3) = 3
```

```
结论：
row = (count + (num - 1)) / num
```

