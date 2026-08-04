---
title: "3D@Demo"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 790
summary: "这个示例给你一个不需要 3D 素材、不需要模型文件、不需要外部 JS 库的 3D 效果图。 它用： - HTML - CSS 3D - 原生 JavaScript 实现了： - 鼠标拖动旋转 - 鼠标滚轮缩放 - 点击节点查看说明 - 细胞教材模式 - 代码地图模式 ## 立刻查看 直接双击打开： ## 在 Markdown 里放入口 普通 Markdown"
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

这个示例给你一个**不需要 3D 素材、不需要模型文件、不需要外部 JS 库**的 3D 效果图。

它用：

- HTML
- CSS 3D
- 原生 JavaScript

实现了：

- 鼠标拖动旋转
- 鼠标滚轮缩放
- 点击节点查看说明
- 细胞教材模式
- 代码地图模式

## 立刻查看

直接双击打开：

```text
index.html
```

## 在 Markdown 里放入口

普通 Markdown 文件不适合直接运行复杂 JS。更稳的做法是：

```md
## 3D 交互演示

[打开 3D 演示](./index.html)
```

如果你的 Markdown 渲染器支持 `iframe`，也可以写：

```html
<iframe
  src="./index.html"
  width="100%"
  height="720"
  style="border:0;border-radius:16px;overflow:hidden;">
</iframe>
```

## 放到 GitHub README 的现实做法

GitHub README 会限制 JS，所以不要指望 README 里面直接拖动。

更稳的结构是：

```text
README.md
docs/
  3d/
    index.html
```

README 里写：

```md
## 3D 代码关系图

[打开 3D 代码关系图](./docs/3d/index.html)
```

如果你开了 GitHub Pages，就把链接改成 Pages 地址。
