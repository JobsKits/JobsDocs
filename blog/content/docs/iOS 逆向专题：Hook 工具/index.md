---
title: "iOS 逆向专题：Hook 工具"
date: 2026-08-19T12:45:49+08:00
draft: false
weight: 210
summary: "## 🔥 前言 > Hook 是让调用在到达原目标前后经过观察或替代逻辑。Objective-C 消息替换、Mach-O 符号重绑定和 ARM64 Inline Hook 原理不同。MobileSubstrate、fishhook、HookZz、Dobby、Substitute 也不是同一层工具。本专题只在自有 Lab 中讲机制与检测，不提供修改第三方 Ap"
bookCollapseSection: false
---


![Jobs出品，必属精品](https://picsum.photos/1500/400)


---

## 🔥 <font id=前言>前言</font>

> Hook 是让调用在到达原目标前后经过观察或替代逻辑。Objective-C 消息替换、Mach-O 符号重绑定和 ARM64 Inline Hook 原理不同。MobileSubstrate、fishhook、HookZz、Dobby、Substitute 也不是同一层工具。本专题只在自有 Lab 中讲机制与检测，不提供修改第三方 App 行为或绕过安全判断的操作链。

## 一、先按被改变的位置分类 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1.1、四类常见 Hook

| 类型 | 改变的位置 | 典型目标 | 主要限制 |
| --- | --- | --- | --- |
| Objective-C Method Swizzling | Runtime 方法实现映射 | Objective-C 实例 / 类方法 | 只覆盖动态派发且可见的方法 |
| Symbol Rebinding | 导入符号指针 | C 函数、动态符号调用 | 内联、直接调用或特殊 Section 可能不经过绑定表 |
| Inline Hook | 函数入口机器指令 | Native 函数 | 指令重定位、页权限、PAC、并发安全复杂 |
| 调试器断点 | 调试异常 / 软件断点 | 授权调试目标 | 性能、时序和反调试环境影响 |

### 1.2、Hook、注入和动态调试的关系

- 注入回答“代码怎样进入目标进程”。
- Hook 回答“进入后怎样拦截某条调用路径”。
- 动态调试可以只观察，不必加载自定义 dylib。

因此“会 Hook”不等于“能注入”，能注入也不代表可以安全重写任意函数。

## 二、工具地图

### 2.1、MobileSubstrate / Cydia Substrate

[**Cydia Substrate**](https://www.cydiasubstrate.com/) 是越狱生态中长期使用的扩展平台，提供 Objective-C 消息和原生函数替换能力。它是一整套运行环境，不是单独的 `method_exchangeImplementations`。

### 2.2、Substitute

[**Substitute**](https://github.com/comex/substitute) 也是进程修改与 Hook 框架，常与特定越狱发行版和历史兼容讨论一起出现。评估时要看目标系统、架构、Rootless 环境和项目维护状态，不能只比较 API 名字。

### 2.3、fishhook

[**fishhook**](https://github.com/facebook/fishhook) 通过重新绑定 Mach-O 导入符号表中的指针，适合学习 C 函数动态符号调用。它不是通用 Inline Hook，也不会自动拦截编译器内联、静态链接或不经懒 / 非懒符号指针的调用。

### 2.4、HookZz 与 Dobby

[**HookZz**](https://github.com/jmpews/HookZz) 是较早的跨平台 Hook 项目；[**Dobby**](https://github.com/jmpews/Dobby) 是同一作者生态中更现代的轻量级 Hook 框架。二者涉及指令级改写和 Trampoline，使用前必须核对当前架构、系统版本、PAC 与仓库维护状态。

## 三、为什么 Inline Hook 最难

### 3.1、不只是覆盖一条跳转

Inline Hook 通常要：

1、解析函数入口足够长度的完整指令。

2、保存并重定位被覆盖的指令。

3、构造 Trampoline，使原函数仍可继续。

4、处理 PC-relative 寻址、分支范围和寄存器。

5、修改页面权限并刷新指令缓存。

6、在多线程执行时避免看到半写入状态。

arm64e Pointer Authentication、Branch Target Identification 和系统代码页策略会进一步影响可行性。复制一段固定字节模板不是可靠实现。

## 四、自有 Lab 的低风险学习顺序

### 4.1、第一阶段：源码级包装

先给自己的纯函数加一层 Wrapper，记录输入、输出和耗时。这建立了“前置逻辑 → 原函数 → 后置逻辑”的 Hook 心智模型，却没有运行时改写风险。

### 4.2、第二阶段：Objective-C Runtime

在自有 Demo 中比较：直接调用、动态派发、继承覆盖和 Method Swizzling。重点记录：

- 交换发生前后的 IMP。
- 类方法与实例方法所在的元类差异。
- `dispatch_once` 保证只安装一次的原因。
- 多次交换或多方交换为什么导致顺序不可预测。

只 Hook 自己声明的测试类，不碰系统安全、支付、登录、证书或隐私 API。

### 4.3、第三阶段：fishhook 原理阅读

在 macOS / iOS 自有测试 Target 中阅读 fishhook 源码，观察它如何遍历 Image、Symbol Table、String Table 和间接符号表。学习重点是 Mach-O 绑定关系，不是把日志函数替换带进生产。

### 4.4、第四阶段：Inline Hook 只做原理验证

如果确实需要研究 Dobby：只对无敏感行为的自有函数，在隔离设备、固定版本和可恢复环境进行；同时用反汇编核对原始指令、Trampoline 和返回路径。结果必须标注工具版本与架构，不能泛化为“所有 iOS 都可用”。

## 五、Hook 的工程风险

### 5.1、正确性风险

- 函数签名、ABI 或寄存器保存不一致。
- 递归进入 Hook 本身。
- 多个框架同时 Hook 同一目标，顺序不可控。
- App 或系统升级后函数实现改变。
- Release 优化、内联或 LTO 让目标消失。

### 5.2、安全与合规风险

Hook 能观察敏感参数，也能改变授权、交易和身份逻辑。未经许可使用会触及隐私、合同、反规避和计算机安全法律风险。本专题不提供隐藏 Hook、绕过检测、持久化或第三方 App 行为篡改方法。

### 5.3、生产代码优先用显式机制

如果源码可控，优先考虑：

- Protocol / Dependency Injection。
- Wrapper / Decorator。
- `URLProtocol` 等公开测试接口。
- Logger、Metric、Signpost 和 Instruments。
- 编译期开关与测试替身。

运行时 Hook 应是明确授权的诊断或研究工具，不应成为正常业务架构的默认依赖。

## 六、学完标准与资料

### 6.1、学完应该会什么

你应能按 Objective-C 派发、符号绑定、Inline 指令和调试器断点区分 Hook，解释五类工具各自位置，并能为自有 Lab 设计从源码 Wrapper 到只读验证的渐进实验。

### 6.2、资料

- [**Objective-C Runtime**](https://developer.apple.com/documentation/objectivec/objective-c_runtime)
- [**Cydia Substrate**](https://www.cydiasubstrate.com/)
- [**fishhook**](https://github.com/facebook/fishhook)
- [**Dobby**](https://github.com/jmpews/Dobby)
- [**HookZz**](https://github.com/jmpews/HookZz)
- [**Substitute**](https://github.com/comex/substitute)

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
