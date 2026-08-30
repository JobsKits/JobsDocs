---
title: "iOS 逆向专题：静态分析"
date: 2026-08-19T12:45:49+08:00
draft: false
weight: 80
summary: "## 🔥 前言 > 静态分析是在不运行目标程序的前提下读取 App Bundle、Mach-O、符号、字符串、元数据、控制流和伪代码。本专题只分析自己编译、开源教学或明确授权的样本；重点是建立证据链，不是获取第三方业务秘密。 ## 一、静态分析究竟在回答什么 🔼 🔽 ### 1.1、四类核心问题 1、身份：这个 Mach-O 面向什么平台、架构和最低系统版本"
bookCollapseSection: false
---


![Jobs出品，必属精品](https://picsum.photos/1500/400)


---

## 🔥 <font id=前言>前言</font>

> 静态分析是在不运行目标程序的前提下读取 App Bundle、Mach-O、符号、字符串、元数据、控制流和伪代码。本专题只分析自己编译、开源教学或明确授权的样本；重点是建立证据链，不是获取第三方业务秘密。

## 一、静态分析究竟在回答什么 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1.1、四类核心问题

1、身份：这个 Mach-O 面向什么平台、架构和最低系统版本？

2、结构：有哪些 Segment、Section、动态库、导入和导出？

3、线索：哪些类、方法、字符串、协议或资源值得继续追踪？

4、行为：某个函数可能做什么，调用关系怎样，哪些结论还需要动态验证？

### 1.2、证据强度不要混在一起

| 证据 | 能说明什么 | 不能单独说明什么 |
| --- | --- | --- |
| Load Command | 二进制声明的平台、依赖和映射布局 | 某条业务路径一定执行 |
| 导出 / 符号 | 某些函数或对象可被定位 | 函数在当前场景被调用 |
| 字符串 | 存在一段文本或常量线索 | 一定存在对应网络行为 |
| 交叉引用 | 某处引用了目标 | 运行时分支必然到达 |
| 伪代码 | 反编译器对机器码的高层重建 | 原始源码、变量名和类型完全正确 |

报告中应明确写“静态证据”“推断”“待动态验证”，不要把反编译器猜测写成事实。

## 二、IDA Pro 与 Hopper 怎样选

### 2.1、工具定位

| 工具 | 优势 | 代价 | 适合场景 |
| --- | --- | --- | --- |
| [**IDA**](https://hex-rays.com/ida-pro) | 处理器支持广、交叉引用与插件生态成熟、团队分析能力强 | 商业授权成本高，学习曲线陡 | 专业安全团队、复杂固件和多架构研究 |
| [**Hopper Disassembler**](https://www.hopperapp.com/) | macOS 原生体验、Mach-O 与 Objective-C 导航直观、上手快 | 自动分析和生态深度通常不及 IDA | iOS 开发者第一次建立静态阅读视角 |

二者都不是“打开就得到源码”。先用 Apple / LLVM 命令确认二进制身份，再让 GUI 工具辅助命名、导航和记录。

### 2.2、同一份样本的标准打开顺序

1、确认主可执行文件，不要把 Framework、Extension 或资源误当主程序。

2、确认 Slice、平台、最低系统版本和 UUID。

3、查看依赖库、入口和 [**Objective-C**](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html) / [**Swift**](https://www.swift.org/) 元数据。

4、从自己预埋的唯一字符串或已知符号进入，建立第一个交叉引用。

5、沿调用图上下各走一层，给函数写“事实型注释”。

6、记录静态结论，交给 LLDB 或测试日志验证。

## 三、自有 Lab 的只读命令

### 3.1、准备路径

下面的 `APP_PATH` 和 `BIN_PATH` 必须替换成自己构建产物的实际路径：

```shell
APP_PATH="/path/to/ReverseLab.app"
BIN_PATH="$APP_PATH/ReverseLab"
```

### 3.2、确认身份与依赖

```shell
file "$BIN_PATH"
xcrun vtool -show-build "$BIN_PATH"
xcrun otool -l "$BIN_PATH"
xcrun otool -L "$BIN_PATH"
xcrun dwarfdump --uuid "$BIN_PATH"
```

### 3.3、查看符号与字符串

```shell
xcrun nm -nm "$BIN_PATH" | head -n 80
strings -a "$BIN_PATH" | head -n 80
xcrun swift-demangle '$s...'
```

`strings` 只是搜索入口。若字符串没有交叉引用、位于未使用资源或被优化残留，不能证明功能存在。

## 四、在反编译器里读函数

### 4.1、先看控制流，再看伪代码

推荐顺序：

1、确认函数地址属于哪个 Segment / Section。

2、看基本块和条件跳转，找成功、失败、提前返回三类路径。

3、观察调用前参数落入哪些 ARM64 寄存器。

4、识别 Objective-C 消息发送、Swift Runtime 调用和系统 API。

5、最后才读伪代码，并用汇编反证关键判断。

### 4.2、ARM64 最小词汇

| 指令 | 人话理解 |
| --- | --- |
| `BL` | 调用函数，并保存返回位置 |
| `RET` | 返回调用方 |
| `B` | 无条件跳转 |
| `CBZ` / `CBNZ` | 值为零 / 不为零时跳转 |
| `CMP` + `B.cond` | 比较后按条件跳转 |
| `LDR` / `STR` | 从内存读取 / 写入 |
| `ADRP` + `ADD` | 组合出某个页附近的地址 |

### 4.3、Objective-C 与 Swift 的差异

- Objective-C 元数据通常保留类、Selector 和协议，导航更直观，但 Release 优化仍会改变结构。
- Swift 有名称修饰、泛型、Witness Table 和较强优化；反编译结果更容易失去源代码边界。
- `@objc`、动态派发和导出符号能增加可见线索，但不是所有 Swift 方法都会留下易读名字。

## 五、练习：建立一条可审计证据链

### 5.1、Lab 设计

在自己的 `ReverseLab` 中创建：一个唯一字符串、一个有真假分支的纯函数、一个 Swift 类型和一个 `@objc` 方法。分别构建 Debug 与 Release。

### 5.2、交付记录模板

| 项目 | 记录 |
| --- | --- |
| 样本来源 | 自有工程、分支、提交 |
| 文件哈希 | `shasum -a 256` 结果 |
| 构建身份 | 架构、平台、最低系统、UUID |
| 静态证据 | 地址、Section、调用者、被调用者 |
| 推断 | 用“可能”“疑似”表达 |
| 动态验证 | 断点、日志或测试结果 |
| 未验证项 | 明确列出，不补想象 |

## 六、常见误区与完成标准

### 6.1、常见误区

- 把伪代码当原始源码。
- 只搜字符串，不看引用和分支。
- 忽略 ASLR，把运行时地址直接抄回文件偏移。
- 混淆主 App、Extension、Framework 和 dSYM。
- 只看一个工具输出，不用系统命令交叉验证。

### 6.2、学完应该会什么

你应能独立确认 Mach-O 身份，在 IDA 或 Hopper 中定位一个已知函数，画出一层调用关系，区分事实与推断，并设计一个低风险动态实验验证核心结论。

## 七、官方资料

- [**IDA 官方文档**](https://docs.hex-rays.com/)
- [**Hopper Disassembler**](https://www.hopperapp.com/)
- [**Apple：Mach-O Programming Topics**](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/MachOTopics/0-Introduction/introduction.html)
- [**LLVM Command Guide**](https://llvm.org/docs/CommandGuide/)

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
