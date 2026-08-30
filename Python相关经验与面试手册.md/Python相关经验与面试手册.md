# [**Python**](https://www.python.org) 相关经验与面试手册

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

> 写给已经会 [**Swift**](https://www.swift.org/) / [**Objective-C**](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)，但还不熟悉 Python 的 Jobs。目标是看懂脚本、自己改工具、知道库怎么安装、界面怎么做、产物怎么交付，并能把关键原理在面试中讲清楚。

本文参考《Swift相关经验》《OC相关经验》的专题、对比表、短 Demo 与选型方式；采用“**问题 → 期望回答 → 短 Demo 与预期结果 → 使用场景与边界 → 追问答案**”的阅读路径。语言之间的对应关系只是理解桥梁，不代表实现完全相同。

**版本与运行约定：** 基础示例面向 Python 3.11 及以上；涉及 3.13 / 3.14 的能力单独标记。资料核对日期为 **2026-08-30**，本机验证解释器为 **CPython 3.14.7**。第三方库、打包工具、系统 SDK 的兼容范围需要按实际项目重新确认，不能把本文当作所有版本的兼容承诺。

**读代码的约定：** `python` 代码块是 Python；`shell` 是 macOS / Linux 终端命令；`powershell` 是 Windows PowerShell 命令。代码中 `#` 后面是注释，`>>>` 是交互解释器提示符而不是源码，本文可复制的片段不带 `>>>`。普通短 Demo 默认独立运行；需要保存文件、安装依赖、联网、打开窗口的示例会明确说明。

**执行边界：** 阅读文档不会自动安装任何东西。涉及安装依赖、创建环境、构建、发布的命令只供你按需执行。先在练习目录和虚拟环境中操作，不改系统 Python，不用 `sudo pip`，不把证书、密码、Token 写进源码或文档。

**快速入口：** [安装依赖](#ch17) · [常用库](#ch18) · [并发](#ch20) · [打包](#ch23) · [GUI](#ch26) · [40 道面试 FAQ](#ch30) · [报错速查](#ch31)。

## 一、先建立 iOS 开发者的 Python 地图 <a id="ch01"></a>

### 1.1、Python 适合替我做什么

**问题：我已有 Swift / OC，为什么还需要 Python？**

**期望回答：** Python 适合把文件、数据、网络接口和外部工具串起来。它能快速做批处理、报表、自动化测试、服务端接口和桌面工具。是否选择它，主要看生态和交付要求；不是看到“跨平台”就认为一份源码能无条件运行在所有设备上。

| 任务 | 推荐起点 | 选择理由 / 边界 |
| --- | --- | --- |
| 检查工程目录、生成 JSON、批量统计文件 | 标准库脚本 | 依赖少，容易部署；写文件前先预览范围 |
| 处理 Excel、CSV 和数据分析 | pandas / openpyxl 等 | 利用现成数据能力；不要把格式保真与数据分析混为一谈 |
| 给命令行工具加一个桌面控制面板 | Tkinter 或 PySide6 | 适合表单、按钮、日志；耗时任务不能堵住 UI |
| 做 HTTP API 服务 | FastAPI / Django 等 | 需要服务部署，不是打一个 EXE 就自动上线 |
| 高性能音视频、图像或矩阵计算 | Python 调用成熟原生库 | 热点通常在 C / C++ / GPU，不是靠 Python 循环硬算 |
| 高度依赖 iOS 原生交互与系统 SDK 的 App | 继续优先 Swift / OC | Python 可以辅助构建与数据处理，不必替代主 App |

### 1.2、把熟悉概念对上号

| Swift / OC 经验 | Python 中接近的概念 | 不能直接照搬的地方 |
| --- | --- | --- |
| 变量引用对象 | 名字绑定对象 | 不声明 `let` / `var`；赋值通常不复制对象 |
| `Array`、`Dictionary`、`Set` | `list`、`dict`、`set` | Python 的这些容器可变，赋值会共享同一个容器 |
| `nil` / Optional | `None` / `T \| None` | 注解不强制运行时检查，访问 `None` 的属性会报错 |
| Struct 数据模型 | `@dataclass` | dataclass 仍是类，不自动获得 Swift 值语义 |
| Closure / Block | 函数对象、闭包、`lambda` | 闭包常按名字取值，要注意循环变量的晚绑定 |
| Protocol | 鸭子类型、`typing.Protocol`、ABC | 静态结构检查与运行时抽象基类是不同机制 |
| ARC | CPython 引用计数 + 循环垃圾回收 | 不保证所有实现都有同样析构时机；资源用 `with` |
| `defer`、作用域清理 | `try/finally`、`with` | `with` 是资源协议，不是通用文本替换 |
| CocoaPods 包仓库 | PyPI | 分发包名称和导入模块名称可能不同 |
| Podfile / podspec | `pyproject.toml` 的不同部分 | 项目依赖与发布元数据都可放这里，但不是逐项同构 |
| Podfile.lock | `uv.lock` 等锁文件 | `pip freeze` 是环境快照，不等于完整锁定工作流 |
| `import` / `#import` | `import` | Python 导入会执行模块顶层代码，且有模块缓存 |
| GCD / NSOperation / Task | 线程池、进程池、`asyncio` | `asyncio` Task 通常在一个事件循环线程中协作运行 |
| Actor | `Lock`、队列、单一状态所有者 | 标准 Python 没有 Swift Actor 那套语言级隔离检查 |
| `.framework` / `.xcframework` | Python 包、wheel、扩展模块 | `.whl` 不是给普通用户双击的应用程序 |
| `.app` / `.ipa` | 冻结应用 / 平台应用工程 | 需要按目标平台构建、签名与验证 |

### 1.3、怎样查这篇文档最快

| 你现在的问题 | 去哪里 |
| --- | --- |
| 连代码都读不懂 | 第 2—8 章：运行、变量、容器、函数、闭包 |
| 想做业务模型或理解 `@xxx` | 第 9—14 章：类、协议、生成器、装饰器、异常、类型 |
| 要安装别人写的库 | 第 16—18 章：导入、依赖管理、库选型 |
| 要跑网络、并发、自动化 | 第 15、19—22 章 |
| 想发布自己的库 / 打包给别人 | 第 23—25 章 |
| 想画桌面界面、图表或网页工具 | 第 26—29 章 |
| 明天要面试 / 现在遇到报错 | 第 30—32 章 |

## 二、解释器、脚本入口与最小语法 <a id="ch02"></a>

### 2.1、`.py` 文件怎样变成运行中的程序

**期望回答：** Python 是语言，CPython 是最常见的实现。CPython 通常先把源码编译成字节码，再由解释器执行；“解释型”不表示没有编译步骤。`.pyc` 是字节码缓存，不是独立原生可执行文件。实现背景见 [**Python 执行与模块教程**](https://docs.python.org/3/tutorial/modules.html#compiled-python-files)。

```text
源码 .py → 解析 / 编译 → 代码对象与字节码 → 解释器执行
第三方原生扩展 → .so / .pyd 等二进制模块 → 被 Python 加载
```

**追问：Python 慢，是不是所有 Python 库都慢？**

不。Python 层逐项循环可能开销较大，但 NumPy 等库的主要计算可在原生代码里执行。先定位热点，再决定优化算法、批处理、用原生库还是换实现。

### 2.2、先确定究竟在运行哪一个 Python

macOS / Linux：

```shell
python3 --version
python3 -c "import sys; print(sys.executable)"
python3 -m pip --version
```

Windows（已安装 Python 启动器时）：

```powershell
py -3 --version
py -3 -c "import sys; print(sys.executable)"
py -3 -m pip --version
```

如果提示找不到 Python，先从 [**Python 官方下载**](https://www.python.org/downloads/) 或已选定的环境管理工具安装。系统附带的版本、Homebrew 版本、IDE 版本、虚拟环境版本可能同时存在；**安装包和运行代码必须指向同一个环境**。进入虚拟环境后，后文统一使用 `python`。

### 2.3、第一个完整脚本

保存成 `hello.py`，执行 `python hello.py`。

<!-- demo: run -->
```python
def greet(name: str) -> str:
    """返回一句问候，不负责打印。"""
    return f"你好，{name}"


def main() -> None:
    print(greet("Jobs"))


if __name__ == "__main__":
    main()
```

| 写法 | 含义 |
| --- | --- |
| `def greet(...)` | 定义函数，函数名推荐 `snake_case` |
| `name: str` | 参数类型提示；不是运行时类型闸门 |
| `-> str` | 返回类型提示 |
| 冒号与后续缩进 | 形成代码块，通常每层 4 个空格 |
| `f"你好，{name}"` | 在字符串中插入表达式 |
| 三引号字符串 | 位于函数开头时成为文档字符串 `__doc__` |
| `if __name__ == "__main__"` | 只在作为入口执行时启动业务，不在被导入时启动 |

**边界：** 不用 `{}` 包函数体，不要求行尾分号，不混用 Tab 和空格。`pass` 是暂时不做事，`...` 是 Ellipsis 对象，不代表 Python 会自动补全逻辑。

### 2.4、`python file.py` 与 `python -m package.module`

前者直接执行文件；后者按模块查找规则找到模块再执行，适合有包结构的项目。它们影响导入上下文，不能随意互换。`python -m pip` 的意思是“让当前 Python 执行 pip 模块”，避免调用到别的环境中的 `pip`。

**面试回答：** `__name__` 是模块的名字；作为主入口时通常是 `"__main__"`。入口保护既减少导入副作用，也是跨平台多进程代码的重要约定。

## 三、变量、对象、可变性与复制 <a id="ch03"></a>

### 3.1、赋值不是给变量装一份副本

**问题：为什么改 `b`，`a` 也跟着变？**

**期望回答：** Python 的赋值把名字绑定到对象。`b = a` 让两个名字指向同一个对象；如果对象可变，经其中一个名字修改它，另一个名字也能看到变化。重新绑定某个名字则不会自动改变另一个名字。

<!-- demo: run -->
```python
a = ["Swift"]
b = a
b.append("Python")
print(a)          # ['Swift', 'Python']
print(a is b)     # True：同一个对象

b = ["OC"]
print(a, b)       # a 没被重新绑定

x = 10
y = x
y += 1
print(x, y)       # 10 11：整数不可变，y 绑定到新结果
```

与 Swift `Array` 的值语义不同，这里的列表不是写时复制数组。对象身份、可变性与实现细节见 [**Python 数据模型**](https://docs.python.org/3/reference/datamodel.html#objects-values-and-types)。

### 3.2、最常用类型

| 类型 | 示例 | 可变吗 | 常见用途 |
| --- | --- | --- | --- |
| `int` | `42` | 否 | 计数、索引；精度受可用内存约束，不是固定 64 位 |
| `float` | `3.14` | 否 | 浮点近似计算 |
| `bool` | `True`、`False` | 否 | 条件，注意大小写 |
| `str` | `"Jobs"` | 否 | Unicode 文本 |
| `bytes` | `b"abc"` | 否 | 网络、文件原始字节 |
| `list` | `[1, 2]` | 是 | 有序可变序列 |
| `tuple` | `(1, 2)` | 元素引用不可替换 | 固定组合；里面引用的对象可能仍可变 |
| `dict` | `{"name": "Jobs"}` | 是 | 键值查找，保持插入顺序 |
| `set` | `{1, 2}` | 是 | 去重与成员判断，不承诺迭代顺序 |
| `frozenset` | `frozenset({1, 2})` | 否 | 不可变集合，可在元素可哈希时作为键 |
| `NoneType` | `None` | 否 | 明确表示无值 |

**追问：动态类型是不是没有类型？**

不是。对象有类型，名字不被声明永久绑定为一种类型。`"1" + 2` 会报错，不会像某些弱类型语言那样自动拼接；“动态”与“弱类型”不是同义词。

### 3.3、浅复制与深复制

<!-- demo: run -->
```python
from copy import deepcopy

original = [[1], [2]]
shallow = original.copy()
deep = deepcopy(original)

shallow[0].append(9)
print(original)   # [[1, 9], [2]]
print(deep)       # [[1], [2]]
print(shallow is original)       # False
print(shallow[0] is original[0]) # True
```

**选型：** 只需独立外层容器用浅复制；嵌套数据确实也要独立时再考虑深复制。文件、锁、网络连接等资源不是随便深复制就有合理语义。复杂业务更适合明确构造新模型或返回只读快照。

### 3.4、`==`、`is`、`None` 与真假值

<!-- demo: run -->
```python
left = [1, 2]
right = [1, 2]
print(left == right)  # True：值相等
print(left is right)  # False：不是同一个对象

value = None
if value is None:
    print("没有提供值")

count = 0
print(count or 10)                    # 10：按真假判断
print(10 if count is None else count) # 0：只把 None 当缺省
```

`None`、`False`、数值零、空字符串和空容器通常为假；自定义对象也可定义真假规则。`and` / `or` 短路求值并返回操作数，不保证返回 `bool`。数值和字符串比较用 `==`，不要依赖小整数缓存或字符串驻留去用 `is`。

### 3.5、引用计数、循环引用和 `del`

`del name` 删除绑定，不等于立即销毁对象。常见 CPython 使用引用计数并配合循环垃圾回收；其它实现及 free-threaded 构建的细节可能不同。不要用 `__del__` 承担必须及时完成的关文件、解锁、提交事务等任务，优先 `with` / `finally`。相关机制见 [**gc 模块**](https://docs.python.org/3/library/gc.html)。

**面试短答：** Python 管内存不等于程序不会泄漏。全局列表、缓存、回调闭包持续持有对象，就可能造成业务意义上的内存增长。

## 四、数字、字符串、字节与运算符 <a id="ch04"></a>

### 4.1、先掌握这组运算

<!-- demo: run -->
```python
print(7 / 2)        # 3.5：真除法
print(7 // 2)       # 3：向下取整
print(-7 // 2)      # -4：不是向零截断
print(7 % 2)        # 1
print(2 ** 3)       # 8：幂
print(1 < 2 < 3)    # True：链式比较
print("a" in "cat") # True：成员 / 包含判断
```

`/`、`//`、`%` 的负数语义要与 C / Swift 区分。位运算用 `&`、`|`、`^`、`~`、`<<`、`>>`；逻辑判断用 `and`、`or`、`not`，不能把二者混写。

### 4.2、文本最常见的处理

<!-- demo: run -->
```python
name = "  Jobs  ".strip()
languages = "Swift,OC,Python".split(",")
print(" / ".join(languages))
print(f"{name}: {len(languages)} 门语言")
print("report.py".endswith(".py"))
print("abcdef"[1:4])   # bcd：左闭右开
print("abcdef"[-2:])   # ef
print("abcdef"[::-1])  # fedcba
```

**边界：** `str` 索引按 Unicode 码点，不是按用户看到的完整字形；组合字符和 Emoji 不能简单当一个索引单位。大量拼接片段优先列表收集后 `join`，不要依赖循环 `+=` 的具体优化。

### 4.3、`str` 与 `bytes` 为什么必须分开

<!-- demo: run -->
```python
text = "你好"
payload = text.encode("utf-8")
print(len(text), len(payload)) # 2 6
print(payload.decode("utf-8"))
```

**期望回答：** `str` 表示文本，`bytes` 表示字节。编码把文本转成字节，解码把字节解释成文本。网络响应、二进制文件、加密输入需要先明确编码和格式，不能把 `str(bytes_value)` 当解码。

### 4.4、金额、时间与随机数的选择

<!-- demo: run -->
```python
from decimal import Decimal
from datetime import datetime, timezone
from math import isclose

print(0.1 + 0.2 == 0.3)       # False
print(isclose(0.1 + 0.2, 0.3))# True
print(Decimal("0.1") + Decimal("0.2")) # 0.3
print(datetime.now(timezone.utc).isoformat())
```

| 需求 | 推荐 | 边界 |
| --- | --- | --- |
| 金额运算 | 整数最小货币单位或 `Decimal` | `Decimal` 优先从字符串构造，并明确舍入规则 |
| 持久化时间 | 带时区的时间 / 约定 UTC | 不把本地无时区时间当全球同一时刻 |
| 计时 / 性能测量 | `time.perf_counter()` | 不用会被校时影响的墙上时间计算耗时 |
| 模拟、洗牌 | `random` | 不用于密码或安全令牌 |
| 安全随机值 | `secrets` | 不打印或提交真实凭据 |

## 五、容器与数据结构选型 <a id="ch05"></a>

### 5.1、`list`：有序、可变、允许重复

<!-- demo: run -->
```python
items = ["Swift", "OC"]
items.append("Python")
items.extend(["SQL", "Shell"])
last = items.pop()
print(items, last)

numbers = [3, 1, 2]
ordered = sorted(numbers)
result = numbers.sort()
print(ordered, numbers, result) # [1, 2, 3] [1, 2, 3] None
```

`append(x)` 放入一个对象，`extend(xs)` 逐项放入；`sort()` 原地修改并返回 `None`，`sorted()` 返回新列表。很多原地修改方法不会返回自身，不能机械套用 Jobs DSL 的链式调用习惯。

### 5.2、`tuple`：固定组合与解包

<!-- demo: run -->
```python
point = (10, 20)
x, y = point
single = (42,)  # 逗号才使它成为单元素元组
first, *middle, last = [1, 2, 3, 4]
print(x, y, single, middle)

record = (["Swift"], "Jobs")
record[0].append("Python")
print(record)   # 元组中的列表仍可变
```

固定的两个返回值可以用元组；字段多、需要名称和校验时用 dataclass / 具名模型。元组是否可哈希取决于全部元素，不是所有元组都能当字典键。

### 5.3、`dict`：查找、默认值和更新

<!-- demo: run -->
```python
profile = {"name": "Jobs", "level": 1}
print(profile["name"])
print(profile.get("city", "未填写"))
profile.update(level=2)

for key, value in profile.items():
    print(key, value)

counts = {}
for word in ["swift", "python", "python"]:
    counts[word] = counts.get(word, 0) + 1
print(counts)
```

**边界：** `d[key]` 在缺键时抛 `KeyError`，`get()` 可以给默认值。如果“缺失”和“显式为 None”含义不同，用 `key in d` 或哨兵对象区分。迭代字典时不要改变它的键集合；先构造新字典或迭代键快照。

### 5.4、`set` 与“保序去重”

<!-- demo: run -->
```python
values = ["Swift", "OC", "Swift", "Python"]
unique = set(values)
ordered_unique = list(dict.fromkeys(values))
print("OC" in unique)
print(ordered_unique) # ['Swift', 'OC', 'Python']
print({1, 2} & {2, 3}) # {2}：交集
print({1, 2} | {2, 3}) # {1, 2, 3}：并集
```

`{}` 是空字典，空集合必须写 `set()`。去重对象必须可哈希；不能直接把列表塞进集合。业务需要稳定顺序时不要依赖 set 的当前打印顺序。

### 5.5、常用容器该选哪个

| 需求 | 推荐 | 原因 / 限制 |
| --- | --- | --- |
| 按位置访问、尾部追加 | `list` | 索引通常 O(1)，尾部追加摊还 O(1) |
| 频繁从队头取元素 | `collections.deque` | 两端操作高效；别反复 `list.pop(0)` 搬移元素 |
| 按 ID 查对象 | `dict` | 平均 O(1) 查找，不是任何情况都 O(1) |
| 判断是否出现过 | `set` | 平均 O(1) 成员判断；列表查找通常 O(n) |
| 词频 / 次数统计 | `collections.Counter` | 少写计数样板 |
| 分组收集 | `collections.defaultdict(list)` | 缺键时生成独立列表 |
| 持续取最小任务 | `heapq` | 堆，不必每次全量排序 |
| 线程间消息传递 | `queue.Queue` | 明确同步机制，不把普通 list 当完整线程协议 |

<!-- demo: run -->
```python
from collections import Counter, defaultdict, deque

print(Counter(["a", "b", "a"]).most_common(1)) # [('a', 2)]
groups = defaultdict(list)
for language, author in [("Swift", "Jobs"), ("Python", "Jobs")]:
    groups[author].append(language)
print(dict(groups))

queue = deque(["A", "B"])
queue.append("C")
print(queue.popleft()) # A
```

**追问：如何创建二维列表？** 用 `[[0] * 3 for _ in range(2)]`；`[[0] * 3] * 2` 重复的是同一个内部列表引用，改一行会影响另一行。

## 六、条件、循环、模式匹配与推导式 <a id="ch06"></a>

### 6.1、条件表达式与普通分支

<!-- demo: run -->
```python
score = 85
if score >= 90:
    level = "优秀"
elif score >= 60:
    level = "通过"
else:
    level = "待加强"

label = "可用" if score >= 60 else "不可用"
print(level, label)
```

简单二选一可以用条件表达式；多分支或带副作用时写普通 `if`，不要嵌套成难读的一行。

### 6.2、`for` 遍历的是元素，不只是索引

<!-- demo: run -->
```python
names = ["Swift", "Python"]
for index, name in enumerate(names, start=1):
    print(index, name)

for name, score in zip(names, [90, 85], strict=True):
    print(name, score)

print(list(range(1, 5))) # [1, 2, 3, 4]
```

`range` 左闭右开，不会事先建立所有整数的列表。`zip` 默认按最短序列结束，要求长度一致时用 `strict=True`，避免悄悄丢数据。

### 6.3、循环的 `else` 为什么有用

<!-- demo: run -->
```python
target = "Rust"
for name in ["Swift", "Python"]:
    if name == target:
        print("找到了")
        break
else:
    print("没有找到")
```

循环的 `else` 表示“正常结束且没有被 `break` 打断”，不是“循环条件为假就永远进入另一条业务分支”。搜索场景可用；团队不熟悉时显式变量也可以，理解成本比省两行更重要。

### 6.4、`match` 不只是另一个 `switch`

Python 3.10+ 支持结构模式匹配，既可判断值，也可拆数据结构。详见 [**模式匹配教程**](https://docs.python.org/3/tutorial/controlflow.html#match-statements)。

<!-- demo: run -->
```python
event = {"type": "download", "bytes": 128}
match event:
    case {"type": "download", "bytes": int(size)} if size >= 0:
        print(f"下载了 {size} 字节")
    case {"type": "cancel"}:
        print("取消")
    case _:
        print("未知事件")
```

**边界：** 裸名字模式通常是在捕获变量，不是与同名常量比较；常量可使用限定名，例如 `State.READY`。匹配数据形状用 `match`，普通范围判断用 `if`。

### 6.5、推导式：把简单转换写清楚

<!-- demo: run -->
```python
values = [1, 2, 3, 4]
squares = [x * x for x in values if x % 2 == 0]
mapping = {x: x * x for x in values}
unique_lengths = {len(x) for x in ["Swift", "Python", "Jobs"]}
print(squares, mapping, unique_lengths)
```

一到两层的简单筛选 / 映射适合推导式；复杂异常处理、状态更新、日志、多层分支用普通循环。不要为了调用副作用写 `[send(x) for x in xs]` 并丢弃返回列表。

## 七、函数、参数、返回值与默认值陷阱 <a id="ch07"></a>

### 7.1、函数是一等对象

**期望回答：** 函数可以赋给变量、当参数、作为返回值。把它理解成 Swift Closure / OC Block 会很顺手，但 Python 中定义普通函数也能直接获得函数对象。

<!-- demo: run -->
```python
def double(value: int) -> int:
    return value * 2


def apply(value: int, operation) -> int:
    return operation(value)


action = double
print(apply(3, action)) # 6
```

没写 `return` 的函数返回 `None`。`return a, b` 返回一个元组，可以在调用方解包。

### 7.2、位置参数、关键字参数与 `*args` / `**kwargs`

<!-- demo: run -->
```python
def request(path: str, /, *, timeout: float = 5.0) -> str:
    return f"{path}, timeout={timeout}"


def describe(*args, **kwargs):
    print(args)   # tuple
    print(kwargs) # dict


print(request("/users", timeout=2.0))
describe(1, 2, name="Jobs")

options = {"timeout": 3.0}
print(request("/users", **options))
```

| 标记 | 作用 | 什么时候推荐 |
| --- | --- | --- |
| `/` 前的参数 | 只能按位置传递 | 库 API 不希望参数名成为调用契约时 |
| `*` 后的参数 | 只能写参数名传递 | 多个 Bool、超时、配置选项，避免实参含义不清 |
| `*args` | 收集多余位置参数 | 转发或真实可变参数，不用来隐藏正常业务签名 |
| `**kwargs` | 收集多余关键字参数 | 装饰器、适配层；普通函数尽量显式声明 |
| 调用处的 `*xs` / `**d` | 解包序列 / 映射 | 已有参数集合时使用，重复键仍会报错 |

### 7.3、默认参数只在定义时求值

**问题：为什么下一次调用还能看到上一次列表里的数据？**

<!-- demo: run -->
```python
def bad_add(item, items=[]):
    items.append(item)
    return items


print(bad_add("A")) # ['A']
print(bad_add("B")) # ['A', 'B']：共享同一个默认列表


def add(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items


print(add("A"), add("B")) # ['A'] ['B']
```

**面试回答：** 默认参数在函数定义执行时创建，不是每次调用都重新创建。可变默认值一般用 `None` 哨兵；dataclass 的可变字段用 `default_factory`。时间、随机值等“每次都应该重新算”的默认值也不要写成定义时调用。

### 7.4、参数传递：修改对象与重新绑定

<!-- demo: run -->
```python
def modify(values):
    values.append(2)
    values = [99]
    return values


original = [1]
result = modify(original)
print(original, result) # [1, 2] [99]
```

函数拿到对象引用的绑定；原地修改能被外部看到，给形参重新赋值不会把调用者的变量改指向。用“对象共享 / 名字绑定”解释比生搬“纯值传递”“纯引用传递”更准确。

### 7.5、同名函数不按参数签名自动重载

**问题：能像 Swift 那样定义几个同名函数，按参数类型自动挑一个吗？**

**期望回答：** 普通 Python `def` 只是把名字绑定到函数，再次定义同名函数会覆盖该绑定。可以使用默认参数、明确的不同函数名，或确实需要时采用分派机制。`typing.overload` 主要给静态检查器描述多种调用签名，不会自动生成运行时重载。

<!-- demo: run -->
```python
def convert(value: int):
    return "整数版本"


def convert(value: str):
    return "后定义的版本"


print(convert(1)) # 后定义的版本；不会自动选择前一个定义
```

按第一个参数类型选择实现，可评估 `functools.singledispatch`；只有一两个清楚的分支时，普通 `if isinstance(...)` 或不同名字通常更容易维护。

## 八、作用域、闭包、`lambda` 与回调 <a id="ch08"></a>

### 8.1、LEGB 是什么

**期望回答：** 普通名字查找可概括为 Local（当前局部）→ Enclosing（外层函数）→ Global（模块）→ Builtins（内置）。给一个名字赋值会影响编译器对其作用域的判断；不能因为下一行才赋值，就假设上一行还会读取同名全局值。

<!-- demo: run -->
```python
def make_counter():
    count = 0

    def increment():
        nonlocal count
        count += 1
        return count

    return increment


counter = make_counter()
print(counter(), counter()) # 1 2
```

`nonlocal` 修改外层函数已有绑定，`global` 修改模块级绑定。二者都不提供并发保护；跨组件共享状态优先显式对象或参数，不到处写全局变量。

### 8.2、循环里创建闭包的晚绑定

<!-- demo: run -->
```python
bad = [lambda: index for index in range(3)]
good = [lambda value=index: value for index in range(3)]
print([fn() for fn in bad])  # [2, 2, 2]
print([fn() for fn in good]) # [0, 1, 2]
```

`bad` 的函数调用时才读取同一个 `index` 绑定。`good` 利用默认参数定义时求值保存当次对象；如果保存的对象自身可变，这仍然不是深复制。

**使用场景：** 为一组按钮绑定不同 ID、创建延迟执行任务时尤其容易踩坑。

### 8.3、`lambda`、普通函数与 `partial` 怎么选

<!-- demo: run -->
```python
from functools import partial

users = [{"name": "B", "age": 20}, {"name": "A", "age": 18}]
print(sorted(users, key=lambda user: user["age"]))


def greet(name, prefix):
    return f"{prefix}，{name}"


say_hello = partial(greet, prefix="你好")
print(say_hello("Jobs"))
```

短小排序键 / 一次表达式用 `lambda`；有多个步骤、异常处理、文档时用 `def`；只想预先绑定一部分参数用 `partial`。回调处传 `handler` 是交出函数，写 `handler()` 是现在就调用它，这与 iOS 事件处理的概念相通。

## 九、类、实例、属性与 dataclass <a id="ch09"></a>

### 9.1、`self`、`__init__` 与实例状态

**问题：Python 的类和 iOS 对象最接近的地方是什么？**

**期望回答：** 类定义对象的状态和行为，实例方法通过 `self` 操作当前对象。`__init__` 负责初始化已经创建的实例；真正的创建步骤由 `__new__` 参与，普通业务通常不需要重写它。

<!-- demo: run -->
```python
class Counter:
    def __init__(self, initial: int = 0):
        self.value = initial

    def increment(self, amount: int = 1) -> int:
        self.value += amount
        return self.value


first = Counter()
second = Counter(10)
print(first.increment(), second.increment()) # 1 11
```

`counter.increment(2)` 会把 `counter` 作为方法的 `self`。`self` 是约定名称，不是一个特殊声明关键字；但不要为了个性换掉它。

### 9.2、类属性与实例属性别混淆

<!-- demo: run -->
```python
class WrongTeam:
    members = []  # 全部实例共享


a = WrongTeam()
b = WrongTeam()
a.members.append("Jobs")
print(b.members)   # ['Jobs']


class Team:
    def __init__(self):
        self.members = []  # 每个实例单独创建
```

**边界：** 类级不可变配置可放类属性；每个实例的列表、字典和状态应在 `__init__` 内创建，或用 dataclass 的 `default_factory`。类属性不会因为名字写在类里就自动变成线程安全单例。

### 9.3、`@property`、`@classmethod`、`@staticmethod`

<!-- demo: run -->
```python
class Temperature:
    def __init__(self, celsius: float):
        self._celsius = celsius

    @property
    def fahrenheit(self) -> float:
        return self._celsius * 1.8 + 32

    @classmethod
    def from_fahrenheit(cls, value: float):
        return cls((value - 32) / 1.8)

    @staticmethod
    def unit_label() -> str:
        return "°C"


t = Temperature.from_fahrenheit(212)
print(round(t.fahrenheit), t.unit_label()) # 212 °C
```

| 方式 | 隐式接收者 | 推荐场景 |
| --- | --- | --- |
| 实例方法 | `self` | 读取 / 修改当前对象 |
| `@property` | `self` | 像字段一样读取的轻量计算或受控属性 |
| `@classmethod` | `cls` | 替代构造入口，需要保留子类类型 |
| `@staticmethod` | 无 | 与类概念紧密相关、却不依赖实例 / 类状态的函数 |
| 模块级函数 | 无 | 普通纯工具函数，不必为归类硬塞进类 |

`_name` 表示内部使用约定，不是访问控制；`__name` 主要触发名字改写以减少继承冲突，也不是安全隔离。属性访问不应偷偷执行昂贵网络操作。

### 9.4、dataclass 能否代替 Swift Struct

<!-- demo: run -->
```python
from dataclasses import dataclass, field, replace


@dataclass(frozen=True)
class User:
    name: str
    tags: tuple[str, ...] = ()


@dataclass
class DownloadBatch:
    paths: list[str] = field(default_factory=list)


user = User("Jobs", ("iOS",))
updated = replace(user, tags=user.tags + ("Python",))
print(user, updated)

a = DownloadBatch()
b = DownloadBatch()
a.paths.append("a.zip")
print(b.paths) # []
```

**期望回答：** dataclass 自动生成初始化、表示、比较等常见方法，适合数据模型；它仍是类。`frozen=True` 阻止通常的字段赋值，但不递归冻结内部对象，更不等于 Swift Struct 的值语义。需要稳定快照时，字段也应优先不可变类型。详见 [**dataclasses**](https://docs.python.org/3/library/dataclasses.html)。

## 十、继承、对象协议与进阶机制 <a id="ch10"></a>

### 10.1、继承与组合怎么选

<!-- demo: run -->
```python
class ConsoleWriter:
    def write(self, text: str) -> None:
        print(text)


class ReportService:
    def __init__(self, writer):
        self.writer = writer

    def report(self, count: int) -> None:
        self.writer.write(f"完成 {count} 项")


ReportService(ConsoleWriter()).report(3)
```

**期望回答：** “它是某种对象”且替换后行为契约成立时考虑继承；只是“它需要某种能力”时优先组合和依赖注入。上例换一个文件 writer 不需要改报告逻辑，也方便测试。

继承语法和 `super()`：

<!-- demo: run -->
```python
class BaseTask:
    def description(self):
        return "任务"


class DownloadTask(BaseTask):
    def description(self):
        return super().description() + "：下载"


print(DownloadTask().description()) # 任务：下载
print([cls.__name__ for cls in DownloadTask.mro()])
```

`super()` 按 MRO（方法解析顺序）协作调用，不是永远直接找“写在旁边的父类”。Python 支持多继承，但复杂菱形继承会增加维护成本；初学业务代码优先简单继承或组合。

### 10.2、双下划线方法：让对象参与语言协议

<!-- demo: run -->
```python
class FileBatch:
    def __init__(self, paths):
        self._paths = tuple(paths)

    def __len__(self):
        return len(self._paths)

    def __iter__(self):
        return iter(self._paths)

    def __repr__(self):
        return f"FileBatch(paths={self._paths!r})"


batch = FileBatch(["a.py", "b.py"])
print(len(batch))  # 2
print(list(batch)) # ['a.py', 'b.py']
print(batch)
```

| 特殊方法 | 语言入口 | 边界 |
| --- | --- | --- |
| `__repr__` / `__str__` | 调试表示 / 面向用户的字符串 | 不泄露密码和 Token |
| `__len__` | `len(obj)` | 返回非负整数 |
| `__iter__` / `__next__` | `for` / `next()` | 定义迭代语义，耗尽抛 `StopIteration` |
| `__getitem__` | `obj[key]` | 可表达索引或键查找 |
| `__call__` | `obj(...)` | 对象真正具有“执行动作”语义时再实现 |
| `__eq__` / `__hash__` | 比较 / 哈希容器 | 相等对象必须有相同哈希；可变键极易出错 |
| `__enter__` / `__exit__` | `with` | 管理资源生命周期 |

平时调用 `len(obj)`，不要到处直接调用 `obj.__len__()`。特殊方法是可定制的协议入口，不是命名装饰。

### 10.3、枚举让状态更明确

<!-- demo: run -->
```python
from enum import Enum


class DownloadState(Enum):
    READY = "ready"
    RUNNING = "running"
    DONE = "done"


state = DownloadState("running")
print(state is DownloadState.RUNNING) # True
print(state.value)                    # running
```

固定状态集合优先枚举，避免拼错字符串悄悄变成新状态。外部值解析失败会抛 `ValueError`，需要明确处理；枚举不自动替你验证状态转换是否合法。

### 10.4、描述符、`__slots__`、元类需要学到多深

描述符是参与属性访问的对象，通过 `__get__`、`__set__` 等方法接管读写；`property` 就属于这类机制。下面用只读描述符感受调用过程：

<!-- demo: run -->
```python
class UpperName:
    def __get__(self, instance, owner):
        if instance is None:
            return self
        return instance.name.upper()


class Profile:
    upper_name = UpperName()

    def __init__(self, name):
        self.name = name


print(Profile("Jobs").upper_name) # JOBS
```

`__slots__` 可以限制实例属性布局，在大量小对象场景减少部分内存开销；不保证继承后的每个实例都没有 `__dict__`，也不是线程安全或不可变声明。

<!-- demo: run -->
```python
class Point:
    __slots__ = ("x", "y")

    def __init__(self, x, y):
        self.x, self.y = x, y


p = Point(1, 2)
print(p.x, hasattr(p, "__dict__")) # 1 False
```

**FAQ：元类是什么，业务中要经常用吗？**

**期望回答：** 类本身也是对象，元类参与创建类，通常的元类是 `type`。业务里先用普通类、装饰器或 `__init_subclass__`；只有设计框架的类创建规则时才考虑自定义元类，不能把复杂度当能力证明。

<!-- demo: run -->
```python
class User:
    pass


print(type(User).__name__)   # type
print(type(User()).__name__) # User
```

## 十一、可迭代对象、迭代器与生成器 <a id="ch11"></a>

### 11.1、`iter`、`next` 与 `yield`

**问题：生成器和列表到底有什么不同？**

**期望回答：** 列表保存结果，生成器按需产生结果并记住执行位置。生成器适合流式处理，通常不能倒退或重新遍历；要多次使用就重新创建生成器，或在可承受内存时转成列表。

<!-- demo: run -->
```python
def chunks(values, size):
    if size <= 0:
        raise ValueError("size 必须大于零")
    for start in range(0, len(values), size):
        yield values[start:start + size]


iterator = chunks([1, 2, 3, 4, 5], 2)
print(next(iterator)) # [1, 2]
print(list(iterator)) # [[3, 4], [5]]
print(list(iterator)) # []：已经耗尽
```

这里输入仍是内存中的列表，生成器只避免一次性创建全部“分块结果”；不能声称用了 `yield` 整个流程就一定恒定内存。

### 11.2、列表推导式与生成器表达式

<!-- demo: run -->
```python
eager = [x * x for x in range(5)]
lazy = (x * x for x in range(5))
print(eager)     # [0, 1, 4, 9, 16]
print(sum(lazy)) # 30
print(sum(lazy)) # 0：耗尽后没有新元素
```

需要索引、排序、重复遍历时用列表；只想单次累计或逐行处理时考虑生成器。`map` / `filter` 在 Python 3 中也按需产生值，别误当已经生成好的列表。

### 11.3、`yield from` 是把迭代转交出去

<!-- demo: run -->
```python
def flatten(groups):
    for group in groups:
        yield from group


print(list(flatten([[1, 2], [3]]))) # [1, 2, 3]
```

**边界：** 这只是展开一层，不是任意递归扁平化。普通生成器和 `async def` 协程不是同一种对象；`yield` 也不意味着开线程。

## 十二、装饰器与上下文管理器 <a id="ch12"></a>

### 12.1、`@decorator` 在做什么

**期望回答：** 装饰器接收函数或类并返回替代对象。`@decorate` 放在函数定义前，可以近似理解成定义后执行 `func = decorate(func)`。它适合统一日志、缓存、鉴权和注册，但不会天然保证异步或并发安全。

<!-- demo: run -->
```python
from functools import wraps
from time import perf_counter


def timed(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            print(f"{func.__name__}: {perf_counter() - start:.6f}s")
    return wrapper


@timed
def total(values):
    return sum(values)


print(total([1, 2, 3])) # 打印耗时，然后打印 6
print(total.__name__)   # total
```

`wraps` 保留被包装函数的重要元信息。此 Demo 只包同步函数；包 `async def` 时需要 `async def wrapper` 并 `await func(...)`，否则测到的可能只是协程对象创建耗时。

### 12.2、缓存装饰器什么时候合适

<!-- demo: run -->
```python
from functools import lru_cache


@lru_cache(maxsize=128)
def normalize(name: str) -> str:
    print("执行转换")
    return name.strip().casefold()


print(normalize(" Jobs "))
print(normalize(" Jobs ")) # 第二次不打印“执行转换”
```

**边界：** 输入要可哈希，结果应适合复用；缓存会持有参数与结果。时间敏感数据需要失效策略，不应直接缓存一次性协程对象。`lru_cache` 内部同步不等于同一个键并发请求只会执行一次底层函数，去重要另行设计。见 [**functools**](https://docs.python.org/3/library/functools.html#functools.lru_cache)。

### 12.3、`with` 与 `contextmanager`

**问题：Python 里怎么实现可靠的成对清理？**

<!-- demo: run -->
```python
from contextlib import contextmanager


@contextmanager
def session(label):
    print(f"打开 {label}")
    try:
        yield {"label": label}
    finally:
        print(f"关闭 {label}")


with session("demo") as value:
    print(value["label"])
# 打开 demo → demo → 关闭 demo
```

**期望回答：** `with` 调用对象的上下文管理协议，适合文件、锁、事务和连接等成对操作。`contextmanager` 允许用一个含单次 `yield` 的函数表达进入与退出。退出会处理异常路径，但不代表自动回滚任意业务操作；具体语义取决于资源实现。

### 12.4、装饰器、继承、普通函数怎么选

| 需求 | 推荐 |
| --- | --- |
| 多个函数需要相同前后逻辑 | 装饰器；保持可理解的签名与异常传播 |
| 要对一个代码块管理资源 | 上下文管理器 |
| 需要明确输入输出的业务转换 | 普通函数 |
| 有生命周期、长期状态和可替换行为 | 类与组合；有真实子类型关系再继承 |

## 十三、异常、日志与失败边界 <a id="ch13"></a>

### 13.1、`try`、`except`、`else`、`finally`

<!-- demo: run -->
```python
def parse_count(text: str) -> int:
    try:
        count = int(text)
    except ValueError as error:
        raise ValueError("数量必须是整数") from error
    else:
        if count < 0:
            raise ValueError("数量不能为负数")
        return count
    finally:
        print("本次解析结束")


print(parse_count("3"))
try:
    parse_count("abc")
except ValueError as error:
    print(error) # 数量必须是整数
```

`except` 处理指定异常，`else` 只在 `try` 没有异常时执行，`finally` 负责退出前清理。不要在 `finally` 中 `return` 覆盖正常结果或吞掉异常。`raise ... from error` 保留因果链，排查比一句“操作失败”更有用。

### 13.2、什么错误应该捕获

**期望回答：** 在能恢复、能重试、能补充上下文或能转成人类提示的边界捕获。函数不知道如何处理时，应让异常继续传播，不用 `except: pass` 把故障抹掉。

| 错误 | 推荐处理 |
| --- | --- |
| 用户输入非法 | 校验并展示可操作提示 |
| 文件不存在 / 无权限 | 区分 `FileNotFoundError`、`PermissionError` 等 |
| 网络暂时失败 | 在幂等与次数限制下考虑重试 |
| 代码逻辑 Bug | 保留堆栈，修复；不伪装成成功 |
| 用户取消、进程退出 | 尊重取消 / 退出，不用裸 `except` 吞掉 |

`Exception` 不包含所有退出类异常。普通业务不应捕获 `BaseException` 来“兜住一切”；任务取消的处理还要遵守异步库约定。

### 13.3、`print` 与 `logging`

<!-- demo: run -->
```python
import logging

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
logger = logging.getLogger(__name__)
logger.info("完成 %d 个文件", 3)
try:
    int("not-a-number")
except ValueError:
    logger.exception("演示：输入解析失败")
```

短 Demo 用 `print`，长期工具用日志级别、模块 logger、异常堆栈和必要的轮转。`logging.basicConfig()` 放应用入口；库内部创建 logger 即可，不抢占宿主日志配置。凭据、完整敏感响应和私人路径应脱敏。

**FAQ：`assert` 可以做用户输入校验吗？**

**期望回答：** 不推荐。`python -O` 可以移除断言，用户输入校验应该显式 `if` 并抛异常。断言适合表达开发期内部不变量或测试预期。

## 十四、类型注解、Protocol 与运行时校验 <a id="ch14"></a>

### 14.1、类型提示不会替你阻止错误输入

<!-- demo: run -->
```python
def echo(value: int) -> int:
    return value


print(echo("文字")) # 运行时仍返回“文字”；静态检查器会指出不匹配


def first(values: list[str]) -> str | None:
    return values[0] if values else None


name = first([])
if name is not None:
    print(name.upper())
```

**期望回答：** 注解用于表达契约并辅助 IDE / 静态检查器，通常不自动执行运行时校验。`str | None` 表示可能无值，但不会生成 Swift Optional 的强制解包规则。外部 JSON、配置和接口输入还需要显式校验或模型库。

### 14.2、常用标注怎么读

| 标注 | 含义 | 注意 |
| --- | --- | --- |
| `list[str]` | 字符串列表 | 不会在每次 append 自动校验 |
| `dict[str, int]` | 字符串键、整数值 | 外部数据仍需验证 |
| `tuple[int, str]` | 固定两个元素 | 与 `tuple[int, ...]` 的任意长度区分 |
| `str \| None` | 字符串或无值 | 等价意图也可写 `Optional[str]` |
| `Callable[[int], str]` | 接收整数返回字符串的函数 | 回调也可以标注 |
| `Any` | 放宽静态检查 | 不要用它消灭所有类型错误 |
| `object` | 任意对象的共同基类 | 操作前通常需要缩小类型范围 |
| `TypedDict` | 字典形状的静态约束 | 运行时仍是普通 dict，不自动校验 |
| `Final` | 不希望重新绑定的静态约定 | 不是强制常量，也不深度冻结对象 |

### 14.3、用 Protocol 表达“有这个能力就行”

<!-- demo: run -->
```python
from typing import Protocol


class Writer(Protocol):
    def write(self, text: str) -> None: ...


class ConsoleWriter:
    def write(self, text: str) -> None:
        print(text)


def send_report(writer: Writer) -> None:
    writer.write("报告已生成")


send_report(ConsoleWriter())
```

`ConsoleWriter` 不必显式继承 `Writer`，只要静态结构满足契约。需要运行时禁止实例化未实现抽象方法的类时，可用 `abc.ABC` / `@abstractmethod`；需要轻量可替换依赖时，Protocol 很适合。见 [**typing.Protocol**](https://docs.python.org/3/library/typing.html#typing.Protocol)。

### 14.4、dataclass 与 Pydantic 怎么选

内部可信数据，dataclass 足够；不可信 JSON / 环境配置需要字段校验时，可考虑 [**Pydantic**](https://docs.pydantic.dev/latest/concepts/models/)。先在虚拟环境执行 `python -m pip install pydantic`，以下按 Pydantic v2 API 编写：

<!-- demo: external -->
```python
from pydantic import BaseModel, ConfigDict, Field, ValidationError


class JobRequest(BaseModel):
    model_config = ConfigDict(strict=True)
    name: str
    retries: int = Field(ge=0, le=5)


print(JobRequest(name="scan", retries=2).model_dump())
try:
    JobRequest(name="scan", retries="2")
except ValidationError:
    print("严格模式不把字符串自动当整数")
```

**FAQ：Pydantic 与静态检查器是否二选一？**

**期望回答：** 不是。静态检查器在开发期发现代码契约问题，Pydantic 在运行时处理外部数据。模型能通过校验也不代表业务授权、权限和状态转换都正确。

### 14.5、泛型：表达输入与输出的类型关系

<!-- demo: run -->
```python
from collections.abc import Sequence
from typing import TypeVar

T = TypeVar("T")


def first_item(values: Sequence[T]) -> T:
    if not values:
        raise ValueError("序列不能为空")
    return values[0]


print(first_item([10, 20]))        # 10；静态结果类型为 int
print(first_item(["Swift", "OC"])) # Swift；静态结果类型为 str
```

**期望回答：** TypeVar 表达“这里的输入元素类型和返回类型是同一个关系”，比把两边都写成 Any 保留更多信息。Sequence 表达只需要序列读取能力，不强迫调用方提供可变 list。Python 3.12+ 还支持新的类型参数语法；本例用兼容 3.11 的形式，类型参数仍不是运行时输入验证。

## 十五、路径、文件、JSON、CSV 与 SQLite <a id="ch15"></a>

### 15.1、路径优先用 `pathlib`

<!-- demo: run -->
```python
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as directory:
    root = Path(directory)
    path = root / "notes.txt"
    path.write_text("Swift\nPython\n", encoding="utf-8")
    print(path.name, path.suffix)
    print(path.read_text(encoding="utf-8").splitlines())
    print([item.name for item in root.glob("*.txt")])
```

不要手拼 `"/"` / `"\\"`，不要假设当前工作目录就是脚本目录。读写文本显式指定编码；小文件可以 `read_text`，大文件逐行读。用户文件默认只读或预览后写入，写入时考虑覆盖、权限、磁盘空间和失败恢复。

### 15.2、`with open` 与逐行读取

<!-- demo: run -->
```python
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as directory:
    path = Path(directory) / "demo.log"
    path.write_text("INFO start\nERROR failed\n", encoding="utf-8")
    with path.open("r", encoding="utf-8") as stream:
        for line in stream:
            if "ERROR" in line:
                print(line.rstrip()) # ERROR failed
```

**期望回答：** `with` 确保异常路径也关闭文件；逐行读取避免把整个文件装进内存。需要二进制时用 `rb` / `wb`，此时处理的是 bytes，不传文本编码。

### 15.3、JSON 与 Python 字面量不是一回事

<!-- demo: run -->
```python
import json

profile = {"name": "Jobs", "enabled": True, "memo": None}
text = json.dumps(profile, ensure_ascii=False)
restored = json.loads(text)
print(text)  # JSON 使用 true / null
print(restored["name"])
```

`dumps` / `loads` 操作字符串，`dump` / `load` 操作文件对象。JSON 键通常是字符串，日期 / Decimal / 自定义类需要显式编码方案。**不要使用 `eval` 解析 JSON，不对不可信内容执行 `pickle.loads`。** 标准边界见 [**json**](https://docs.python.org/3/library/json.html) 与 [**pickle 安全警告**](https://docs.python.org/3/library/pickle.html)。

### 15.4、CSV 是表格文本，不是 Excel 工作簿

<!-- demo: run -->
```python
import csv
import io

buffer = io.StringIO(newline="")
writer = csv.DictWriter(buffer, fieldnames=["name", "score"])
writer.writeheader()
writer.writerow({"name": "Jobs", "score": 90})
buffer.seek(0)
print(list(csv.DictReader(buffer))) # score 读回来是字符串
```

真实文件用 `open(..., newline="", encoding="utf-8")`。CSV 没有字体、Sheet、合并单元格；这些需求用 openpyxl 等。导出不可信文本到表格软件时，还要防止以 `=` 等开头的内容被当公式解释。

### 15.5、SQLite：本地结构化数据

<!-- demo: run -->
```python
import sqlite3

connection = sqlite3.connect(":memory:")
try:
    with connection:
        connection.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
        connection.execute("INSERT INTO users(name) VALUES (?)", ("Jobs",))
    row = connection.execute("SELECT name FROM users WHERE id = ?", (1,)).fetchone()
    print(row[0]) # Jobs
finally:
    connection.close()
```

用参数占位符传数据，不拼 SQL。**`with connection` 管事务，不自动关闭连接**，上例单独关闭。SQLite 适合本地应用与一定规模的数据持久化，多进程高写入压力需要评估锁竞争和数据库选型。见 [**sqlite3**](https://docs.python.org/3/library/sqlite3.html)。

## 十六、模块、包与 `import` <a id="ch16"></a>

### 16.1、模块、导入包、分发包、库分别是什么

**问题：我 `pip install` 成功，为什么 `import` 还找不到？**

**期望回答：** 安装是把分发包及依赖放进某个 Python 环境；导入是当前解释器查找并加载模块。环境可能不一致，安装名与导入名也可能不同。先检查解释器路径、pip 路径与官方导入名，而不是盲目重装。

| 名称 | 可以怎样理解 | 例子 |
| --- | --- | --- |
| 模块 module | 一个可导入的代码单元 | `math`、`json`、自建 `utils.py` |
| 导入包 package | 组织模块的命名空间 | `mypkg.tools`，常规包目录有 `__init__.py` |
| 分发包 distribution | 被包管理器安装的产物 | PyPI 上的 Pillow |
| 库 library | 对一组复用能力的泛称 | 图像库、网络库，未规定一种唯一文件形式 |
| 标准库 | Python 自带的能力集合 | `pathlib`、`json`、`asyncio`，部分组件依赖系统构建 |

### 16.2、几种导入方式

<!-- demo: run -->
```python
import math
from pathlib import Path
import json as json_codec

print(math.sqrt(16))       # 4.0
print(Path("notes.txt").suffix)
print(json_codec.loads('{"ok": true}'))
```

| 写法 | 推荐使用场景 |
| --- | --- |
| `import package` | 保留命名空间，调用来源清楚 |
| `from package import Name` | 常用类 / 函数，避免冗长前缀 |
| `import package as alias` | 社区约定别名或需要消除重名 |
| `from .module import Name` | 包内部相对导入；需要正确包上下文 |
| `from package import *` | 通常避免，容易覆盖名字、降低可查性 |

绝对导入写完整包名，适合跨包边界；相对导入表达同一包内部关系。不要通过随处 `sys.path.append(...)` 掩盖错误的项目结构。

### 16.3、安装名不等于导入名

| 安装命令中的分发名 | 源码导入名 | 用途 |
| --- | --- | --- |
| `Pillow` | `from PIL import Image` | 图像处理 |
| `beautifulsoup4` | `from bs4 import BeautifulSoup` | HTML 解析 |
| `scikit-learn` | `import sklearn` | 机器学习 |
| `PyYAML` | `import yaml` | YAML 解析；不可信数据优先 `safe_load` |
| `PySide6` | `from PySide6 import QtWidgets` | Qt 界面 |

包名的连字符常见于分发名，Python 标识符里则不能直接写连字符。分发包与导入包的区别见 [**Python Packaging：概念解释**](https://packaging.python.org/en/latest/discussions/distribution-package-vs-import-package/)。

### 16.4、导入时会发生什么

首次加载通常会执行模块顶层代码，模块对象放入 `sys.modules`；之后导入通常复用缓存。因此模块顶层不应自动弹窗口、发网络请求、删除文件或启动长期任务。

<!-- demo: run -->
```python
import importlib
import json

again = importlib.import_module("json")
print(again is json) # True：复用模块对象
```

**FAQ：循环导入如何处理？**

**期望回答：** 把共同模型下沉到独立模块，或通过参数 / 接口反转依赖；必要时函数内延迟导入，但不要只用延迟导入掩盖混乱分层。报错里的“partially initialized module”通常提示导入尚未完成。

**FAQ：为什么不能把自己的文件叫 `json.py`、`typing.py`、`requests.py`？**

**期望回答：** 它可能遮蔽同名标准库或第三方模块。查看被导入模块的 `__file__` 可以帮助定位；先改名和修正导入路径，再处理相关缓存，不要删除整个环境来碰运气。

## 十七、像 CocoaPods 一样管理依赖 <a id="ch17"></a>

### 17.1、先把四件事分开

```text
选择 Python 版本 → 为项目隔离环境 → 安装并锁定依赖 → 在源码中 import
```

**问题：Python 中有没有一个完全等同于 Pod 的工具？**

**期望回答：** 没有逐项完全对应的单一工具。PyPI 提供分发，pip 安装包，venv 隔离环境，pyproject 声明项目，uv / Poetry 等可以组织解析、锁定和同步。先理解这些职责，再选一套项目工作流。

| CocoaPods 经验 | Python 常用对应 | 边界 |
| --- | --- | --- |
| Spec 仓库 / 下载源 | PyPI / 私有包索引 | 必须核实包名与来源 |
| `pod install` | `pip install` 或 `uv sync` | 后者更接近从锁文件同步环境的完整工作流 |
| `pod update SomePod` | 有意升级指定依赖并重锁 | 日常同步与升级要区分 |
| Podfile | `pyproject.toml` 的 dependencies 等 | 声明直接依赖，不应只靠当前环境记忆 |
| Podfile.lock | `uv.lock` 等 | 记录解析结果，不等于仅写版本范围 |
| 本地 `:path` Pod | editable install / 本地 path dependency | 发布时不能依赖你本机的绝对路径 |
| CocoaPods 生成集成文件 | 环境中的 `site-packages` / 入口脚本 | 不应手工修改安装后的第三方源码 |

### 17.2、基础路线：`venv + pip`

在新建的练习目录中执行。macOS / Linux：

```shell
python3 -m venv .venv
source .venv/bin/activate
python -m pip install httpx
python -c "import httpx; print(httpx.__version__)"
```

Windows PowerShell：

```powershell
py -3 -m venv .venv
.\.venv\Scripts\python.exe -m pip install httpx
.\.venv\Scripts\python.exe -c "import httpx; print(httpx.__version__)"
```

Windows 示例直接指定环境解释器，不要求调整系统执行策略。也可以按本机策略激活 `.venv\Scripts\Activate.ps1`；激活只改变当前终端使用的命令，不是环境存在的必要条件。详情见 [**venv 官方文档**](https://docs.python.org/3/library/venv.html)。

**边界：** 虚拟环境隔离 Python 包，不是虚拟机，也不是安全沙箱；不会隔离文件权限、外部程序或全部系统动态库。`.venv` 不提交 Git，不复制到另一台机器当安装包。

### 17.3、日常 pip 命令

```shell
python -m pip list
python -m pip show httpx
python -m pip check
python -m pip install -r requirements.txt
python -m pip install -e .
```

前提分别是已存在 `requirements.txt`，或当前目录有可安装项目。`-e .` 表示可编辑安装，适合本地库开发，修改源码通常无需重装；修改依赖或入口配置后仍可能需要重新安装。

如果只需记录一个干净环境的当前包版本，可执行：

```shell
python -m pip freeze > requirements.txt
```

**注意：此重定向会覆盖同名文件。** `freeze` 是当前环境快照，可能包含与你的项目无关的包；它不等于精心维护的直接依赖列表，也不独自保证跨系统重现。不要从污染的全局环境导出后就叫“完整锁文件”。安装基础见 [**PyPA 安装指南**](https://packaging.python.org/en/latest/tutorials/installing-packages/)。

### 17.4、项目路线：`uv + pyproject.toml + uv.lock`

已安装 [**uv**](https://docs.astral.sh/uv/) 后，在练习目录创建一个新项目：

```shell
uv init jobs-python-demo
cd jobs-python-demo
uv add httpx
uv add --dev pytest ruff
uv run python -c "import httpx; print(httpx.__version__)"
uv sync --locked
```

| 文件 / 命令 | 职责 |
| --- | --- |
| `pyproject.toml` | 项目信息、依赖约束、工具配置 |
| `uv.lock` | 解析后的锁定结果；项目通常提交它 |
| `.python-version` | 项目解释器选择提示；不等于已安装该解释器 |
| `uv add` | 添加依赖并更新声明、锁文件与环境 |
| `uv run` | 在项目环境运行，默认会检查并同步相关状态 |
| `uv sync --locked` | 锁文件必须与项目匹配，不自动改锁；不匹配就失败 |
| `uv sync --frozen` | 直接按现有锁文件，不验证它是否与声明一致 |
| `uv lock --upgrade-package httpx` | 有意升级一个包的锁定版本，仍受约束限制 |

**选型建议：** 学概念先亲手跑一次 venv + pip；新建长期工具可选择 uv 完成项目管理。已有团队使用 Poetry / Conda，就遵守现有工作流，不同时让多个工具争管一个环境。

**边界：** uv 默认精确同步可能移除项目环境中未声明的额外包，所以不要手动塞包后又期待它永久留下；升级锁文件后应测试并同步环境。完整语义见 [**uv 项目指南**](https://docs.astral.sh/uv/guides/projects/) 与 [**锁定和同步**](https://docs.astral.sh/uv/concepts/projects/sync/)。

### 17.5、版本范围、extras、开发依赖与平台条件

以下是配置语法示例，不是让你一次装齐全部工具：

```toml
[project]
name = "jobs-demo"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = ["httpx>=0.28,<1"]

[project.optional-dependencies]
gui = ["PySide6"]

[dependency-groups]
dev = ["pytest", "ruff"]
```

库的发布依赖可以声明合理范围；应用交付需要再锁定确切解析结果。`extras` 表达可选功能，开发依赖分组用于测试 / lint，不等于运行时必需依赖。`>=3.11` 只是最低版本声明，不保证所有依赖已经支持每一个更新的 Python 版本。

```shell
python -m pip install ".[gui]"
```

引号防止 Shell 将方括号当通配符。平台限定可以在依赖字符串中写 marker，例如 `colorama; sys_platform == 'win32'`；不要靠导入失败后悄悄忽略必需功能。

### 17.6、pip、uv、pipx、Conda 怎么选

| 工具 | 更适合 | 不要误以为 |
| --- | --- | --- |
| pip + venv | 基础安装、兼容性明确的标准工作流 | pip 自己会帮你隔离所有项目 |
| uv | Python 项目依赖、锁定、运行和工具环境 | 一个跨平台锁文件会让每个依赖都有每个平台的二进制包 |
| pipx / `uv tool` | 安装独立 CLI 工具 | 工具环境中的库就能被你的项目直接 import |
| Conda / Mamba | 需要一起管理 Python 与较多原生依赖的科学环境 | 可以无计划混用 conda 与 pip 并始终保持解析一致 |
| Poetry | 已采用该项目管理工作流的团队 | 需要为了“新”而马上迁走成熟工程 |

**FAQ：装库失败先查什么？**

**期望回答：** 先看完整错误中的第一个原因，再查 Python 版本、目标 CPU、wheel 是否存在、代理 / 证书和权限。没有 wheel 时可能尝试源码构建，需要编译器和系统库；不要把所有失败都归因为 pip 版本，也不要盲目使用 `--break-system-packages`。

## 十八、常用库：按任务选，不按名气堆 <a id="ch18"></a>

### 18.1、先看看标准库能不能解决

| 任务 | 标准库 | 典型边界 |
| --- | --- | --- |
| 路径、文件、复制 | `pathlib`、`shutil` | 大目录避免主线程递归扫描 |
| 命令行参数 | `argparse` | 复杂多级命令可再看 Typer / Click |
| JSON、CSV、TOML 读取 | `json`、`csv`、`tomllib` | `tomllib` 3.11+，不提供写 TOML API |
| 正则 | `re` | 简单查找先用字符串方法，不用正则硬解析嵌套语言 |
| 日期、金额 | `datetime`、`zoneinfo`、`decimal` | 明确时区与舍入 |
| 哈希、随机值 | `hashlib`、`secrets` | 普通哈希不是完整密码存储方案 |
| 本地数据库 | `sqlite3` | 事务、连接归属与并发限制仍需设计 |
| 压缩与归档 | `zipfile`、`tarfile` | 不可信归档要校验目标路径、链接和体积 |
| 调用外部程序 | `subprocess` | 明确参数、超时、输出大小与退出码 |
| 并发 | `threading`、`concurrent.futures`、`asyncio` | 按 I/O / CPU、生态和状态共享选择 |
| 测试与性能 | `unittest`、`timeit`、`cProfile` | 微基准不等于真实业务性能 |
| 简单 GUI | `tkinter` / `ttk` | 标准库接口，但解释器需具备 Tcl/Tk 支持 |

标准库总索引：[**The Python Standard Library**](https://docs.python.org/3/library/index.html)。

### 18.2、第三方库速查

| 需求 | 可优先评估 | 推荐理由 / 不适用情况 |
| --- | --- | --- |
| 同步 HTTP 脚本 | [**Requests**](https://requests.readthedocs.io/en/latest/) | 简洁成熟；不是 asyncio 异步客户端 |
| 同步 / 异步 HTTP | [**HTTPX**](https://www.python-httpx.org/) | 两种客户端模型；异步代码别调用同步请求阻塞循环 |
| 数值数组、矩阵 | [**NumPy**](https://numpy.org/doc/stable/user/quickstart.html) | 向量化；注意 shape、dtype 和复制成本 |
| 表格数据分析 | [**pandas**](https://pandas.pydata.org/docs/getting_started/intro_tutorials/) | 分组、清洗、连接；大数据不一定能整体装内存 |
| 读写 `.xlsx` | [**openpyxl**](https://openpyxl.readthedocs.io/en/stable/tutorial.html) | 单元格、样式、工作表；不是 Excel 公式计算引擎 |
| 图像处理 | [**Pillow**](https://pillow.readthedocs.io/en/stable/handbook/tutorial.html) | 缩放、裁剪、格式转换；不等于桌面 UI 框架 |
| 静态图表 | [**Matplotlib**](https://matplotlib.org/stable/users/explain/quick_start.html) | 生成图表、导出图片；不负责完整业务窗体 |
| 交互图表 | [**Plotly**](https://plotly.com/python/) | 浏览器交互；考虑数据体积与离线资源 |
| HTTP API 服务 | [**FastAPI**](https://fastapi.tiangolo.com/tutorial/) | 类型驱动接口开发；运行服务需要 ASGI 服务器 |
| 完整网站后台 | [**Django**](https://docs.djangoproject.com/en/stable/intro/) | ORM、认证、管理后台等配套；小脚本不必引入 |
| 数据校验 | [**Pydantic**](https://docs.pydantic.dev/latest/) | 外部数据建模；不替代业务权限与静态检查 |
| ORM / 数据库访问 | [**SQLAlchemy**](https://docs.sqlalchemy.org/en/20/tutorial/) | 数据库抽象和映射；仍需理解 SQL、事务与查询成本 |
| 测试 | [**pytest**](https://docs.pytest.org/en/stable/getting-started.html) | fixture、参数化、断言；项目要维护真实测试边界 |
| 格式与 lint | [**Ruff**](https://docs.astral.sh/ruff/) | 格式化与大量静态规则；不是完整类型检查器 |
| 静态类型检查 | [**mypy**](https://mypy.readthedocs.io/en/stable/) / [**Pyright**](https://microsoft.github.io/pyright/) | 开发期检查；不替代运行时输入校验 |
| 桌面应用 | [**PySide6**](https://doc.qt.io/qtforpython-6/) | 丰富控件、模型视图与 Designer；运行体积和部署更复杂 |
| 快速数据网页 | [**Streamlit**](https://docs.streamlit.io/) | 很快把数据变成可操作页面；不是本地原生窗口 |
| 浏览器自动化 | [**Playwright**](https://playwright.dev/python/docs/intro) | 现代浏览器测试；还需要对应浏览器运行文件 |

AI / 机器学习可继续看 [**scikit-learn**](https://scikit-learn.org/stable/getting_started.html) 的经典模型、[**PyTorch**](https://pytorch.org/get-started/locally/) 的张量与深度学习。GPU 版本、驱动和系统架构必须按官方安装矩阵选择；不要把“装了 Python 包”当成“GPU 环境全部就绪”。

### 18.3、三个最小的第三方数据 Demo

先在虚拟环境按需安装，不要求一次装全：

```shell
python -m pip install numpy pandas openpyxl
```

NumPy：对一组数批量运算。

<!-- demo: external -->
```python
import numpy as np

values = np.array([1, 2, 3], dtype=np.int64)
print(values * 10) # [10 20 30]
print(values.mean()) # 2.0
```

pandas：按类别汇总。

<!-- demo: external -->
```python
import pandas as pd

table = pd.DataFrame({"language": ["Swift", "Python", "Python"], "count": [1, 2, 3]})
print(table.groupby("language", sort=True)["count"].sum().to_dict())
# {'Python': 5, 'Swift': 1}
```

openpyxl：创建并读回一个临时 Excel 文件。

<!-- demo: external -->
```python
from pathlib import Path
from tempfile import TemporaryDirectory
from openpyxl import Workbook, load_workbook

with TemporaryDirectory() as directory:
    path = Path(directory) / "report.xlsx"
    book = Workbook()
    book.active.append(["name", "count"])
    book.active.append(["Jobs", 3])
    book.save(path)
    loaded = load_workbook(path, read_only=True)
    try:
        print(loaded.active["A2"].value) # Jobs
    finally:
        loaded.close()
```

**FAQ：怎么判断是否该引入第三方库？**

**期望回答：** 先看标准库能否清楚实现，再评估维护状态、许可证、平台 wheel、依赖体积和团队熟悉度。复杂格式与协议优先成熟库，几行字符串转换不必增加一整套依赖。

## 十九、网络请求、超时与外部程序 <a id="ch19"></a>

### 19.1、HTTP 请求不只是拿到一个字符串

需要虚拟环境安装 `httpx`。下面使用 MockTransport，**不会连接外网**，可以先理解客户端、响应码与 JSON：

<!-- demo: external -->
```python
import httpx


def respond(request: httpx.Request) -> httpx.Response:
    return httpx.Response(200, json={"name": "Jobs", "path": request.url.path})


with httpx.Client(transport=httpx.MockTransport(respond), timeout=5.0) as client:
    response = client.get("https://example.test/users/1")
    response.raise_for_status()
    print(response.json()) # {'name': 'Jobs', 'path': '/users/1'}
```

真实请求时换成正常 `httpx.Client(timeout=...)`，使用经过确认的业务地址。将 URL、参数、认证、响应码和解析错误分开处理。长生命周期客户端能复用连接，别在高频循环里反复创建连接池。见 [**HTTPX QuickStart**](https://www.python-httpx.org/quickstart/)。

### 19.2、超时、重试与幂等

**问题：网络失败就循环重试，行不行？**

**期望回答：** 需要区分连接失败、读超时、限流与业务错误。重试必须有次数、退避和总时间限制；支付、下单等有副作用请求还要幂等键或服务端去重，不能把一次超时当成服务端一定没执行。

HTTP 客户端的连接 / 读取超时不一定是整个业务操作的总截止时间；异步流程可再加总超时边界。不要关闭 TLS 校验解决证书问题，不把 Token 打到日志，也不要无限读取未知体积的响应。

### 19.3、调用 Shell 工具：优先参数数组

<!-- demo: run -->
```python
import subprocess
import sys

result = subprocess.run(
    [sys.executable, "-c", "print('child ready')"],
    check=True,
    capture_output=True,
    text=True,
    timeout=5,
)
print(result.stdout.strip()) # child ready
```

**选型：** 一次性短命令用 `run`；要实时显示日志、发送输入或管理生命周期用 `Popen`。捕获输出会占内存，长期运行工具需流式读取和日志上限。用户输入不要拼进 `shell=True` 字符串；参数数组降低 Shell 注入风险，但仍要验证参数对目标程序的业务含义。

`subprocess` 不是所有移动 / Web 运行环境都可用；冻结应用中的 `sys.executable` 也可能指向你自己的 EXE，不再是一个可以随便 `-m` 执行模块的 Python。见 [**subprocess**](https://docs.python.org/3/library/subprocess.html)。

## 二十、并发、并行、GIL 与 asyncio <a id="ch20"></a>

### 20.1、先判断是等待多，还是计算多

| 工作性质 | 常见选择 | 为什么 / 边界 |
| --- | --- | --- |
| 少量顺序操作 | 同步函数 | 最容易理解与排错，不必强上并发 |
| 阻塞型文件 / 网络 I/O，多项互不依赖 | `ThreadPoolExecutor` | 复用现有同步库；控制线程数与共享状态 |
| 已有异步 HTTP / 数据库生态，大量 I/O | `asyncio` | 用事件循环管理等待；不能混入长时间阻塞调用 |
| 大量纯 Python CPU 计算 | `ProcessPoolExecutor` 等 | 默认有 GIL 的 CPython 可利用多核；有传输和启动成本 |
| NumPy 等原生库计算 | 先用库自己的批量 / 并行能力 | 原生代码可能释放 GIL；避免多层线程池过度抢资源 |
| GUI 内耗时任务 | 工作线程 / 进程，主线程更新 UI | 界面框架的线程规则优先 |

### 20.2、线程池最小 Demo

<!-- demo: run -->
```python
from concurrent.futures import ThreadPoolExecutor
from time import sleep


def fetch_fake(index):
    sleep(0.01) # 模拟阻塞等待，不是真实网络
    return f"item-{index}"


with ThreadPoolExecutor(max_workers=3) as pool:
    results = list(pool.map(fetch_fake, range(5)))
print(results) # item-0 到 item-4，map 按输入顺序返回
```

`as_completed()` 可按完成顺序处理 Future。线程不是免费资源，任务超时或 Future 取消也不意味着已经运行的线程会被强行终止，任务本身需要取消协议。

### 20.3、进程池最小 Demo

保存成 `process_demo.py`，作为文件运行；不要直接拆到交互解释器里测试。

<!-- demo: process -->
```python
from concurrent.futures import ProcessPoolExecutor


def square(value):
    return value * value


def main():
    with ProcessPoolExecutor(max_workers=2) as pool:
        print(list(pool.map(square, [1, 2, 3]))) # [1, 4, 9]


if __name__ == "__main__":
    main()
```

任务函数与输入通常需要可序列化，模块应可被子进程导入，所以优先顶层函数而非 lambda / 局部函数。不要依赖“所有系统默认 fork”；启动方式具有版本与系统差异，尤其要验证 Windows、macOS 和冻结应用。见 [**concurrent.futures**](https://docs.python.org/3/library/concurrent.futures.html)。

### 20.4、`async`、`await` 与 TaskGroup

<!-- demo: run -->
```python
import asyncio


async def fetch_fake(name):
    await asyncio.sleep(0.01)
    return name.upper()


async def main():
    async with asyncio.TaskGroup() as group:
        first = group.create_task(fetch_fake("swift"))
        second = group.create_task(fetch_fake("python"))
    print(first.result(), second.result()) # SWIFT PYTHON


if __name__ == "__main__":
    asyncio.run(main())
```

**期望回答：** 调用 `async def` 通常得到协程对象，不会因此自动执行完函数。`await` 等待异步结果，`create_task` 安排并发运行。Python 3.11+ 的 TaskGroup 管理一组子任务，退出时等待完成；出现普通子任务失败时会取消其它任务并按异常组规则传播。

Jupyter 或已有事件循环的框架里通常使用 `await main()`，不要嵌套 `asyncio.run()`。`await` 是潜在让出点，不意味着每次一定挂起，也不意味着切到后台线程。见 [**asyncio 协程与任务**](https://docs.python.org/3/library/asyncio-task.html)。

### 20.5、超时与取消示例

<!-- demo: run -->
```python
import asyncio


async def main():
    try:
        async with asyncio.timeout(0.01):
            await asyncio.sleep(1)
    except TimeoutError:
        print("超过本次等待时限")


if __name__ == "__main__":
    asyncio.run(main())
```

取消是协作式的，清理放 `finally`；不应随便吞 `asyncio.CancelledError`。同步阻塞函数可考虑 `asyncio.to_thread`，但取消外层等待不等于终止工作线程。大量任务还需 Semaphore 或有界工作队列，不能一次创建几百万个 Task。

### 20.6、GIL 的正确面试回答

**问题：Python 多线程不能并行，这句话对吗？**

**期望回答：** 要限定实现和运行模式。在默认启用 GIL 的 CPython 中，同一解释器里的多个线程通常不能同时执行 Python 字节码，但 I/O 等待及释放 GIL 的原生扩展仍可并发或并行。CPU 密集的纯 Python 工作可以考虑多进程。Python 3.13 引入可选 free-threaded 构建，3.14 将其正式支持，但不是说所有 Python 进程都默认关闭 GIL。

free-threaded 还要检查第三方扩展兼容性，不兼容扩展可能重新启用 GIL。移除 GIL 也不代表业务共享状态自动安全。参见 [**free-threading 官方说明**](https://docs.python.org/3/howto/free-threading-python.html) 与 [**Python 3.14 版本说明**](https://docs.python.org/3/whatsnew/3.14.html#free-threaded-python-is-officially-supported)。

### 20.7、没有 Swift Actor，共享状态怎么办

<!-- demo: run -->
```python
from concurrent.futures import ThreadPoolExecutor
from threading import Lock


class Counter:
    def __init__(self):
        self._value = 0
        self._lock = Lock()

    def increment(self):
        with self._lock:
            self._value += 1

    def snapshot(self):
        with self._lock:
            return self._value


counter = Counter()
with ThreadPoolExecutor(max_workers=4) as pool:
    list(pool.map(lambda _: counter.increment(), range(1000)))
print(counter.snapshot()) # 1000
```

**期望回答：** Python 标准库没有 Swift Actor 的编译器隔离模型。可用锁保护完整的读改写操作，或让一个明确的消费者独占状态，其它任务通过队列发送消息。不能因为有 GIL 就认为 `count += 1`、检查后插入或多字段更新一定具备业务原子性。

`asyncio.Lock` 协调同一事件循环里的协程，不是跨线程锁；也不要在持有 `threading.Lock` 时跨 `await` 等待。单线程事件循环中的状态依然可能在 `await` 前后改变，这与 Actor 可重入需要重新校验状态的思路相通。

## 二十一、测试、调试、性能与安全底线 <a id="ch21"></a>

### 21.1、pytest：测试输入、边界和异常

安装 `pytest` 后，保存成 `test_demo.py`，执行 `python -m pytest -q`：

<!-- demo: pytest -->
```python
import pytest


def parse_retry(text):
    value = int(text)
    if not 0 <= value <= 5:
        raise ValueError("范围应为 0 到 5")
    return value


@pytest.mark.parametrize("text, expected", [("0", 0), ("3", 3), ("5", 5)])
def test_valid(text, expected):
    assert parse_retry(text) == expected


def test_invalid():
    with pytest.raises(ValueError):
        parse_retry("6")
```

预期 4 个测试通过。真实项目还要覆盖空输入、权限、网络失败、取消、重复事件和资源清理，不只测试“调用方法之后得到自己刚写的常量”。[**pytest 入门**](https://docs.pytest.org/en/stable/getting-started.html)。

### 21.2、调试与质量工具

```shell
python -m compileall -q src
python -m pytest -q
ruff check .
ruff format --check .
python -m cProfile -s cumulative app.py
```

这些命令分别要求存在对应源码目录、测试、已安装 Ruff 或 `app.py`。`compileall` 能查语法并生成字节码，不能证明 import 成功、类型正确或业务行为正确。遇到问题先看 traceback 最后异常和相关调用栈；可在本地代码插入 `breakpoint()` 交互调试。

### 21.3、性能优化与安全底线

**FAQ：看到程序慢，先上多线程吗？**

**期望回答：** 先测量，看瓶颈在算法、磁盘、网络、数据库还是 UI 重绘。优先减少重复工作、批量处理、控制数据量，再选并发模型；复杂并发不是优化的第一步。

**FAQ：日常工具最容易忽略哪些安全问题？**

**期望回答：** 不执行不可信代码，不用 eval 解析数据，不反序列化不可信 pickle，不拼接 Shell / SQL，不关闭 TLS 验证。文件写入要限定范围，解压要防路径穿越，敏感信息不要进入日志或包内。虚拟环境和 EXE 打包都不是安全沙箱。

## 二十二、一个可维护的命令行工具怎么组织 <a id="ch22"></a>

### 22.1、目录结构与职责

单文件练习不必立刻搞复杂工程；工具开始拥有测试、依赖与多平台交付时，可采用下面结构。它延续 Jobs 的“外层入口 + 内层 Python 工程”习惯：

```text
JobsReport.py/
├── README.md
├── 【MacOS】📦生成dmg.command
├── 【Windows】📦生成exe.bat
└── JobsReport/
    ├── pyproject.toml
    ├── uv.lock
    ├── src/
    │   └── jobs_report/
    │       ├── __init__.py
    │       ├── core.py
    │       └── cli.py
    ├── tests/
    ├── assets/
    └── scripts/
```

外层打包入口只是未来工程的结构示意，本文没有生成这些脚本。入口只检查环境和触发构建，业务逻辑留在包内；不是把几百行业务 Python 塞进 `.command` / `.bat` 字符串。

### 22.2、一个可直接使用的 argparse Demo

保存成 `report_cli.py`。只统计指定目录的第一层普通非符号链接文件，**不修改文件，也不递归扫描**。

<!-- demo: cli -->
```python
import argparse
import json
from pathlib import Path


def summarize(directory: Path) -> dict[str, int]:
    files = [path for path in directory.iterdir() if not path.is_symlink() and path.is_file()]
    return {"count": len(files), "bytes": sum(path.stat().st_size for path in files)}


def main() -> int:
    parser = argparse.ArgumentParser(description="统计一层目录中的文件数量与大小")
    parser.add_argument("directory", type=Path)
    args = parser.parse_args()
    if not args.directory.is_dir():
        parser.error("请输入存在的目录")
    try:
        result = summarize(args.directory)
    except OSError as error:
        parser.exit(1, f"读取失败：{error}\n")
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

```shell
python report_cli.py --help
python report_cli.py .
```

预期输出类似 `{"count": 3, "bytes": 1024}`，真实结果取决于目录内容。`main()` 编排输入输出，`summarize()` 负责业务，后续 GUI 可复用业务函数。目录扫描过程中内容可能变化，示例在失败时明确报错，并不承诺操作系统级一致快照。

**FAQ：为什么不把所有代码写在模块顶层？**

**期望回答：** 为了控制导入副作用、便于测试和复用业务函数，并让 CLI / GUI 共享同一内核。入口负责参数、日志和退出码，核心函数不应随便退出进程或弹窗。

## 二十三、发布自己的 Python 库：pyproject、wheel 与 sdist <a id="ch23"></a>

### 23.1、先明确“打库”和“打应用”不同

**问题：我想像发布 Pod 一样，把自己的代码给别人使用，应该产出什么？**

**期望回答：** 把代码组织成可安装的 Python 项目，声明元数据、依赖和构建后端，生成 wheel 和源码分发包。别人可以用 pip 安装，再 import 公开模块。wheel 通常不携带 Python 解释器，不是给完全没有 Python 环境的普通用户双击的应用。

| 产物 | 用途 | 是否自带 Python 运行时 |
| --- | --- | --- |
| `.whl`（wheel） | 可直接安装的分发归档，可能包含原生扩展 | 通常不带 |
| `.tar.gz`（sdist） | 源码分发，安装时可能需先构建 wheel | 不带 |
| `.pyz`（zipapp） | 可由兼容 Python 执行的归档应用 | 通常不带 |
| `.exe` / `.app` / Linux 冻结目录 | 给终端用户运行 | 工具通常会收集运行时与依赖 |
| `.msi` / `.dmg` / `.pkg` / `.deb` / `.rpm` | 安装或分发封装 | 取决于内部装的是什么，不由扩展名保证 |

### 23.2、最小可发布项目

这是独立练习项目，不依赖第 22 章文件。创建下面目录：

```text
jobs-text-tools/
├── pyproject.toml
├── README.md
└── src/
    └── jobs_text_tools/
        ├── __init__.py
        ├── cli.py
        └── __main__.py
```

`pyproject.toml`：

<!-- project-file: pyproject.toml -->
```toml
[build-system]
requires = ["hatchling>=1.27"]
build-backend = "hatchling.build"

[project]
name = "jobs-text-tools"
version = "0.1.0"
description = "A small text utility for learning Python packaging"
readme = "README.md"
requires-python = ">=3.11"
dependencies = []

[project.scripts]
jobs-greet = "jobs_text_tools.cli:main"

[tool.hatch.build.targets.wheel]
packages = ["src/jobs_text_tools"]
```

`README.md`：

<!-- project-file: README.md -->
```markdown
# Jobs Text Tools

教学用文本工具库，提供 greet(name) 函数和 jobs-greet 命令。
要求 Python 3.11 及以上，空白名字会被拒绝。
```

`src/jobs_text_tools/__init__.py`：

<!-- project-file: src/jobs_text_tools/__init__.py -->
```python
def greet(name: str) -> str:
    cleaned = name.strip()
    if not cleaned:
        raise ValueError("name 不能为空")
    return f"你好，{cleaned}"
```

`src/jobs_text_tools/cli.py`：

<!-- project-file: src/jobs_text_tools/cli.py -->
```python
import argparse
from . import greet


def main() -> int:
    parser = argparse.ArgumentParser(description="打印问候语")
    parser.add_argument("name")
    args = parser.parse_args()
    try:
        print(greet(args.name))
    except ValueError as error:
        parser.error(str(error))
    return 0
```

`src/jobs_text_tools/__main__.py`：

<!-- project-file: src/jobs_text_tools/__main__.py -->
```python
from .cli import main

if __name__ == "__main__":
    raise SystemExit(main())
```

安装后的三种使用方式：

```shell
python -m pip install -e .
python -c "from jobs_text_tools import greet; print(greet('Jobs'))"
python -m jobs_text_tools Jobs
jobs-greet Jobs
```

后面三条都应输出 `你好，Jobs`。`[project.scripts]` 安装时生成 CLI 入口；它指向一个可调用函数，不是运行你任意指定的 Shell 字符串。

### 23.3、构建、检查与安装产物

在项目目录、已隔离的构建环境中执行：

```shell
python -m pip install build twine
python -m build
python -m twine check dist/*
```

预期生成 `dist/jobs_text_tools-0.1.0-py3-none-any.whl` 与对应的 `.tar.gz`。再在另一个全新虚拟环境安装 wheel，运行 import 和 CLI，确认没有依赖源码目录的偶然存在：

```shell
python -m pip install /实际路径/jobs_text_tools-0.1.0-py3-none-any.whl
jobs-greet Jobs
```

路径是待替换示意。`twine check` 检查分发元数据和描述格式，不是业务测试。`build` 是构建前端，Hatchling 是实际生成产物的构建后端；项目文件与构建流程见 [**PyPA 打包教程**](https://packaging.python.org/en/latest/tutorials/packaging-projects/)。

### 23.4、资源文件与发布边界

纯源码可以 import 成功，不代表图片、模板和配置会自动被打进 wheel。资源需要构建配置收集，运行时优先用 `importlib.resources`，不要依赖当前目录。

以下假设包中已经包含 `templates/help.txt`：

<!-- demo: resource -->
```python
from importlib.resources import files

text = files("jobs_text_tools").joinpath("templates/help.txt").read_text(encoding="utf-8")
print(text)
```

**FAQ：我可以直接上传 PyPI 吗？**

**期望回答：** 先确认包名可用、版本、许可证、公开 API、依赖、资源与敏感信息，再在 TestPyPI / 隔离消费环境验证。上传属于公开发布，不是本地编译的一部分；正式项目应使用受控发布凭据或可信发布机制，不能把 Token 写在代码里。

仅在你主动决定公开上传时使用，例如：

```shell
python -m twine upload --repository testpypi dist/*
```

这会上传产物，**本文交付时未执行任何上传**。练习包名称只是示例，不代表已占用或由你拥有。

## 二十四、桌面应用打包：Windows、macOS、Linux <a id="ch24"></a>

### 24.1、如何选择打包工具

| 工具 | 核心路线 | 推荐场景 / 边界 |
| --- | --- | --- |
| [**PyInstaller**](https://pyinstaller.org/en/stable/) | 分析依赖并冻结运行时、模块、资源 | 已有 Python CLI / GUI 要交给普通用户；不是跨编译器 |
| [**Nuitka**](https://nuitka.net/user-documentation/user-manual.html) | 编译 Python 模块并可生成 standalone / onefile | 愿意管理编译工具链，且有测量依据；不保证任意代码都显著提速 |
| [**Briefcase**](https://briefcase.beeware.org/en/stable/) | 生成各平台应用工程并构建打包 | 接受其应用模板与平台流程，常配合 BeeWare / Toga |
| `zipapp` | 生成 Python 应用归档 `.pyz` | 用户已有兼容 Python、依赖较简单；不是免环境 EXE |

**问题：Mac 上能直接把任意 Python 程序打成 Windows EXE 吗？**

**期望回答：** PyInstaller 的常规流程不支持这样做。Windows 产物在 Windows 构建，macOS 产物在 macOS 构建，Linux 产物在匹配的 Linux 环境构建，再验证 CPU 架构与系统版本。可以用多平台 CI 分别构建，但不是同一个二进制到处运行。依据：[**PyInstaller 平台边界**](https://pyinstaller.org/en/stable/)。

### 24.2、先 `onedir`，再评估 `onefile`

| 模式 | 特征 | 推荐理由 / 代价 |
| --- | --- | --- |
| `--onedir` | 一个目录，含可执行文件和依赖 | 便于检查缺库和资源；分发整个目录 |
| `--onefile` | 主要表现为单个可执行文件 | 便于发送，但启动需解包等操作，故障排查更复杂 |
| `--windowed` | GUI 模式，Windows / macOS 不提供常规控制台 | 出错时不能只依赖 print；先验证控制台版本 |

**FAQ：onefile 是不是把代码变得无法逆向？**

**期望回答：** 不是。冻结和编译都不等于加密保险箱。客户端内不保存必须保密的长期密钥，敏感权限应由服务端控制。

### 24.3、Windows：可执行程序与安装器

先保存第 27 章完整示例为 `tkinter_demo.py`。在 Windows 的构建虚拟环境中执行：

```powershell
python -m pip install pyinstaller
python -m PyInstaller --onedir --name JobsCounter tkinter_demo.py
```

先启动 `dist\JobsCounter\JobsCounter.exe` 检查日志；正常后再构建 GUI 模式：

```powershell
python -m PyInstaller --onedir --windowed --name JobsCounter tkinter_demo.py
```

第二次命令会使用相同构建输出位置，已有输出时注意工具确认提示。分发的是整个 `dist\JobsCounter` 目录，不是只拎出一个 EXE。要单文件可改用 `--onefile` 并重新验证启动、资源和杀毒软件环境。

`.exe` 是可执行文件；`.msi` / MSIX 或安装器 EXE 是安装 / 注册 / 更新封装。需要安装器时，再采用相应 Windows 工具链或 Briefcase 平台流程；不是重命名后缀。商业分发还应完成代码签名与目标机器验证。

### 24.4、macOS：`.app` 与 `.dmg` 是两层

在 macOS 构建环境中：

```shell
python -m pip install pyinstaller
python -m PyInstaller --onedir --windowed --name JobsCounter tkinter_demo.py
```

预期得到 `dist/JobsCounter.app`。`.app` 是应用包目录，`.dmg` 是用于分发的磁盘映像。以下在**新的构建目录、同名目标尚不存在时**演示封装：

```shell
mkdir dmg-root
ditto dist/JobsCounter.app dmg-root/JobsCounter.app
hdiutil create -volname JobsCounter -srcfolder dmg-root -format UDZO dist/JobsCounter.dmg
```

这只是生成一个磁盘映像，不等于完成可信分发。给其它 Mac 用户使用通常还要处理 Developer ID 签名、Hardened Runtime、公证及票据装订等流程；具体按 [**Apple 公证文档**](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) 和选定工具版本执行。不要把关闭 Gatekeeper 当交付步骤。

**架构边界：** arm64 与 x86_64 的 Python、原生扩展和依赖必须匹配；要做 universal2，相关二进制也得支持，不能只加一个参数就创造缺失架构。PyInstaller 的架构与签名说明见 [**Feature notes**](https://pyinstaller.org/en/stable/feature-notes.html)。

### 24.5、Linux：不是所有发行版一个包通吃

```shell
python -m PyInstaller --onedir --name JobsCounter tkinter_demo.py
```

Linux GUI 还依赖目标环境的显示系统与相关系统库；容器里编译成功不等于桌面上能启动。要做 `.deb`、`.rpm`、AppImage 或 Flatpak，需要选对应打包路线并验证运行库兼容性。旧系统的 glibc、不同发行版和 CPU 架构不能靠“Python 跨平台”绕过去。

### 24.6、资源、动态导入、外部程序与故障排查

当项目真的存在 `assets` 目录时，可明确收集：

```shell
python -m PyInstaller --onedir --add-data "assets:assets" app.py
```

当前 PyInstaller 文档采用 `SOURCE:DEST` 形式；旧文章中的平台分隔符写法不应盲目照搬。动态插件可能需要 `--hidden-import` 或 hook；按实际缺失定位，不要把所有已安装包都塞进产物。见 [**PyInstaller 参数**](https://pyinstaller.org/en/stable/usage.html)。

冻结应用读资源通常可基于 `__file__` 定位，路径必须与构建收集位置一致；用户配置和日志应写入用户可写目录，不能写 `.app`、Program Files 或临时解包资源目录。参见 [**冻结后的运行信息**](https://pyinstaller.org/en/stable/runtime-information.html)。

如果工具需要 FFmpeg、Git 或浏览器，这些外部可执行程序不一定因安装了 Python 包就自动包含；要选择明确的内置或外部依赖策略，并核实许可证、架构和查找路径。

### 24.7、交付检查清单

| 检查项 | 应确认的结果 |
| --- | --- |
| 干净机器 | 无开发虚拟环境也能运行，不偷偷依赖你的绝对路径 |
| 系统与 CPU | 每个承诺支持的组合都实际验证 |
| 资源与原生库 | 图片、模板、Qt 插件、扩展模块完整 |
| 文件读写 | 安装目录只读时仍正常；中文和空格路径可用 |
| 失败与日志 | 双击报错有可定位日志，不能只消失不见 |
| UI 与取消 | 长任务不冻结界面，关窗和取消有明确行为 |
| 安全分发 | 按平台签名 / 公证 / 权限流程处理 |
| 更新与版本 | 应用版本、配置兼容和升级路径明确 |

## 二十五、移动端、Web、容器与平台限制 <a id="ch25"></a>

### 25.1、各种包到底给谁用

| 目标 | 常见产物 | 可评估路线 | 构建与使用边界 |
| --- | --- | --- | --- |
| Python 开发者 | wheel / sdist | build + 构建后端 | 用户仍需兼容 Python；原生 wheel 有平台标签 |
| Windows 用户 | EXE 目录 / EXE / 安装器 | PyInstaller、Nuitka、Briefcase 等 | 按 Windows 工具链和架构构建 |
| macOS 用户 | APP、DMG、PKG | PyInstaller / Briefcase + 平台分发工具 | 在 macOS 完成 Apple 工具链与签名流程 |
| Linux 用户 | 可执行目录、DEB / RPM / AppImage 等 | 冻结工具 + 对应包格式工具 | 发行版、glibc、显示系统和架构需验证 |
| Android 用户 | APK / AAB | Briefcase、Kivy、Flet 等 | 需要 Android 构建工具；依赖必须支持移动端 |
| iOS 用户 | Xcode 工程 → 已签名应用 / IPA | Briefcase、Kivy、Flet 等 | 通常需要 macOS + Xcode；不是 PyInstaller 的目标 |
| 浏览器用户 | Web 服务或静态 Web 应用 | Python 后端 / Pyodide / Flet Web 等 | 浏览器沙箱与包兼容性限制不同 |
| 服务端运维 | 源码 / wheel / 容器镜像 | ASGI / WSGI 服务 + 部署工具 | 镜像不是 GUI 安装器；需要配置、监控和安全策略 |

### 25.2、移动端先验证一个最小闭环

**期望回答：** Python 可以参与移动应用，但不是把桌面 Tkinter / PySide 程序换个打包参数就变成 iOS App。先选支持目标平台的 UI / 运行时路线，再确认每个依赖能否构建、权限如何声明、生命周期如何处理。

- [**BeeWare / Briefcase**](https://briefcase.beeware.org/en/stable/reference/platforms/index.html)：生成平台工程，常配合 Toga 的原生控件抽象；有原生扩展的库要核对目标平台 wheel / 支持包。
- [**Kivy**](https://kivy.org/doc/stable/guide/packaging.html)：适合自绘与触摸界面；Android / iOS 各有构建工具链与资源、权限配置。
- [**Flet**](https://flet.dev/docs/publish/)：基于 Flutter 控件体系，支持多种目标；仍遵守官方构建主机矩阵，IPA / macOS 构建不能脱离 Apple 工具链。

Briefcase 的入门流程可以概括为 `new → dev → create → build → run → package`；具体目标与输出格式按平台文档选择。移动端标准库可用范围、C 扩展、JIT、子进程和文件系统都可能受限制。对于你现有的 iOS 产品，优先保留 Swift / OC 主应用，让 Python 服务于工具链或后端。

### 25.3、Web 界面与桌面界面分工不同

| 方式 | Python 跑在哪里 | UI 在哪里 | 边界 |
| --- | --- | --- | --- |
| FastAPI / Django 等后端 | 服务器 | 浏览器前端 | UI 通常由 HTML / CSS / JS 等负责 |
| Streamlit 等数据应用 | 通常是服务器进程 | 浏览器 | 适合内部数据工具，部署后要处理访问控制 |
| Pyodide | 浏览器的 WebAssembly 环境 | 浏览器 | 不是所有 CPython 扩展、系统 API 都能使用 |
| Flet Web | 取决于部署模式 | 浏览器 | 动态 / 静态模式的运行位置和包支持不同 |

没有服务器权限却想把所有桌面 Python 包塞浏览器，通常行不通。WASM、网络权限、文件访问和线程限制要独立验证。

### 25.4、最小 HTTP 服务与容器示例

这是独立目录中的 `app.py`，依赖 `fastapi`、`uvicorn`：

<!-- demo: fastapi -->
```python
from fastapi import FastAPI

app = FastAPI()


@app.get("/health")
def health():
    return {"status": "ok"}
```

本地开发启动：

```shell
python -m pip install fastapi uvicorn
python -m uvicorn app:app --host 127.0.0.1 --port 8000
```

访问 `http://127.0.0.1:8000/health` 应得到状态 JSON。第一个 `app` 是模块名，第二个 `app` 是其中的应用对象；不是重复拼写错误。不要直接把开发服务器暴露到公网当完整生产部署。

如果要容器化，先准备只包含本服务依赖的 `requirements.txt`，生产项目使用经测试的锁定版本。一个基础 `Dockerfile`：

```dockerfile
FROM python:3.14-slim
WORKDIR /app
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt
COPY app.py .
USER 10001
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

```shell
docker build -t jobs-api-demo .
docker run --rm -p 127.0.0.1:8000:8000 jobs-api-demo
```

构建会下载镜像与依赖；运行是长期进程，终端中按 Ctrl+C 停止。容器内绑定所有接口，宿主映射限定本机环回地址。镜像不是虚拟机、不是 Windows EXE，也不自动获得 HTTPS、数据库备份、监控和认证。正式部署应补上基础镜像版本 / digest、依赖锁定、健康检查与外部配置管理。参考 [**Docker Python 指南**](https://docs.docker.com/guides/python/)。

## 二十六、Python GUI 选型与 iOS 界面概念对照 <a id="ch26"></a>

### 26.1、“画界面”通常是创建控件并布局

**问题：Python 有没有类似 UIKit / SwiftUI 的东西？**

**期望回答：** 有多套 GUI 工具，但没有唯一官方统一方案。桌面表单可以使用 Tkinter / Qt Widgets，自定义绘图用 Canvas / 绘图 API，数据图表用 Matplotlib，浏览器里的数据工具可用 Streamlit。先确定界面运行在哪里、需要哪些控件，再选框架。

| 方案 | 更适合 | 不应误判 |
| --- | --- | --- |
| Tkinter / ttk | 小型桌面工具、表单、教学 | 标准库接口不代表任何 Python 构建都有可用 Tk |
| PySide6 / Qt Widgets | 多窗口、菜单、表格树、日志、复杂桌面交互 | 依赖体积和部署成本更高，不是 UIKit 的逐项替身 |
| Qt Quick / QML + Python | 需要更自由的声明式界面与动效 | UI 需要额外学习 QML，不能只会 Python 就省掉布局知识 |
| wxPython | 评估原生风格桌面控件时 | 仍要核对各平台 wheel 与行为差异 |
| Toga / BeeWare | 评估多平台原生控件抽象与平台工程 | 各控件和原生能力的覆盖需要逐项核查 |
| Kivy | 自绘、触摸、多媒体交互 | 不以原生系统控件外观为主要目标 |
| Flet | 用 Python 组织 Flutter 风格控件 | 仍有平台构建链、运行模式和包兼容约束 |
| Streamlit / Gradio | 数据与模型演示、内部 Web 工具 | 在浏览器中使用，不是一个普通原生桌面窗口 |
| Matplotlib / Plotly | 数据可视化 | 图表库不等于完整桌面应用框架 |

**针对你的起点：** 先用 Tkinter 理解事件循环，再用 PySide6 做需要多面板、日志和任务管理的桌面工具；只想给数据处理加页面时，先评估 Streamlit。不是每个项目都要从最重的框架开始。

### 26.2、把 iOS UI 经验迁移过来

| iOS 概念 | Tkinter | PySide6 / Qt |
| --- | --- | --- |
| 应用主循环 | `mainloop()` | `QApplication.exec()` |
| Window / UIView | `Tk`、`Toplevel`、`Frame` | `QMainWindow`、`QWidget` |
| UILabel | `ttk.Label` | `QLabel` |
| UITextField | `ttk.Entry` | `QLineEdit` |
| UIButton / 点击处理 | `ttk.Button(command=handler)` | `QPushButton.clicked.connect(handler)` |
| UIStackView / 布局容器 | `pack` / `grid` | `QVBoxLayout` / `QHBoxLayout` / `QGridLayout` |
| 状态绑定 / 刷新 | `StringVar` 等，或 `configure` | 设置属性、信号槽、模型视图 |
| 自定义绘制 | `Canvas` | `QPainter` 等 |
| Storyboard / 可视化编辑 | 依赖额外工具 | Qt Designer / `.ui` |
| 主线程更新 UI | 创建 Tk 的线程负责控件 | GUI 主线程负责 QWidget |

**边界：** `pack` / `grid`、Qt Layout 与 Auto Layout 不是同一套约束系统；应学习各自的伸缩规则。`sleep()`、长循环和同步网络放点击回调里，同样会卡 UI。

## 二十七、Tkinter：第一个桌面窗口与后台任务 <a id="ch27"></a>

### 27.1、确认 Tk 可用

```shell
python -m tkinter
```

正常时会弹出测试窗口。若缺 `_tkinter`，需要为当前 Python 发行版补相匹配的 Tcl/Tk 支持；不是随便 `pip install tkinter`。参考 [**Tkinter 官方文档**](https://docs.python.org/3/library/tkinter.html)。

### 27.2、完整 Demo：输入框、按钮、标签、布局

保存为 `tkinter_demo.py`，执行 `python tkinter_demo.py`。仅使用标准库接口，不访问网络、不读写用户文件。

<!-- demo: gui-tk -->
```python
import tkinter as tk
from tkinter import ttk


class CounterWindow(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Jobs Python 计数器")
        self.count = 0
        self.name = tk.StringVar(value="Jobs")
        self.status = tk.StringVar(value="点击按钮开始")
        self.columnconfigure(0, weight=1)

        self.panel = ttk.Frame(self, padding=16)
        self.panel.grid(row=0, column=0, sticky="nsew")
        self.panel.columnconfigure(0, weight=1)

        self.entry = ttk.Entry(self.panel, textvariable=self.name)
        self.entry.grid(row=0, column=0, columnspan=2, sticky="ew", pady=6)
        self.label = ttk.Label(self.panel, textvariable=self.status)
        self.label.grid(row=1, column=0, columnspan=2, sticky="w", pady=6)
        self.add_button = ttk.Button(self.panel, text="加一", command=self.increment)
        self.add_button.grid(row=2, column=0, sticky="ew", padx=(0, 8))
        self.reset_button = ttk.Button(self.panel, text="清零", command=self.reset)
        self.reset_button.grid(row=2, column=1, sticky="ew")

    def refresh(self):
        name = self.name.get().strip() or "匿名"
        self.status.set(f"{name}：{self.count}")

    def increment(self):
        self.count += 1
        self.refresh()

    def reset(self):
        self.count = 0
        self.refresh()


if __name__ == "__main__":
    CounterWindow().mainloop()
```

**预期交互：** 输入名字，点“加一”显示 `名字：1`，继续点击累加；点“清零”显示 `名字：0`。代码创建控件、布局和连接回调；真正点击时，事件循环才调用处理函数。

### 27.3、逐行理解最关键的几处

| 代码 | 负责什么 |
| --- | --- |
| `class CounterWindow(tk.Tk)` | 让窗口拥有自己的状态与控件引用 |
| `StringVar` | 保存与 Tk 控件关联的字符串状态 |
| `Frame(..., padding=16)` | 把控件放进带边距的容器 |
| `grid(row=..., column=...)` | 按行列布局，避免写死全部坐标 |
| `sticky="ew"` | 控件沿东西方向拉伸 |
| `columnconfigure(..., weight=1)` | 允许对应列分配剩余宽度 |
| `command=self.increment` | 交出回调，不是立即执行它 |
| `.mainloop()` | 持续处理输入、重绘、计时器等事件 |

**FAQ：`pack`、`grid`、`place` 怎么选？**

**期望回答：** 顺序堆叠用 pack，表单和行列关系用 grid，明确需要坐标布局时才用 place。不要在同一个父容器中混用 pack 与 grid；不同容器可以分别选择。优先布局规则而不是硬编码窗口坐标。

### 27.4、如果真的是“画图形”，用 Canvas

独立保存运行，展示一条进度条与文字：

<!-- demo: gui-canvas -->
```python
import tkinter as tk


def main():
    root = tk.Tk()
    root.title("Canvas 绘图")
    canvas = tk.Canvas(root, width=280, height=100, highlightthickness=0)
    canvas.pack(padx=16, pady=16)
    canvas.create_rectangle(10, 30, 260, 60, outline="#555555")
    canvas.create_rectangle(10, 30, 160, 60, fill="#2878c8", outline="")
    canvas.create_text(135, 80, text="进度 60%")
    root.mainloop()


if __name__ == "__main__":
    main()
```

Canvas 适合示意图、自定义图元和简单可视化；按钮、输入框仍优先真实控件，才能保留键盘操作、焦点与可访问性，不要把全部 UI 都画成不可交互的图片。

### 27.5、后台工作如何安全更新界面

**问题：按钮一点击，为什么窗口拖不动？**

**期望回答：** 点击回调占用了 UI 事件循环，重绘和输入没有机会执行。把阻塞任务交给工作线程，结果放线程安全队列；UI 用 `after()` 定期取结果并修改控件。工作线程不要直接碰 Tk 对象。

下面是独立完整示例 `tk_worker_demo.py`。为了突出线程与关闭流程，任务只模拟短暂等待，不操作真实文件。

<!-- demo: gui-tk-worker -->
```python
import queue
import threading
import tkinter as tk
from tkinter import ttk


def work(events, stop):
    for index in range(20):
        if stop.wait(0.02):
            events.put("已取消")
            return
        events.put(f"进度 {(index + 1) * 5}%")
    events.put("任务完成")


class WorkerWindow(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Tk 后台任务")
        self.events = queue.Queue()
        self.stop = threading.Event()
        self.worker = None
        self.closing = False
        self.status = tk.StringVar(value="等待开始")
        self.label = ttk.Label(self, textvariable=self.status, padding=12)
        self.label.pack()
        self.button = ttk.Button(self, text="开始", command=self.start)
        self.button.pack(padx=12, pady=12)
        self.protocol("WM_DELETE_WINDOW", self.request_close)
        self.after(20, self.poll)

    def start(self):
        if self.worker is not None and self.worker.is_alive():
            return
        self.stop.clear()
        self.button.configure(state="disabled")
        self.worker = threading.Thread(target=work, args=(self.events, self.stop))
        self.worker.start()

    def poll(self):
        while True:
            try:
                self.status.set(self.events.get_nowait())
            except queue.Empty:
                break
        running = self.worker is not None and self.worker.is_alive()
        if self.closing and not running:
            self.destroy()
            return
        if not running and not self.closing:
            self.button.configure(state="normal")
        self.after(20, self.poll)

    def request_close(self):
        self.closing = True
        self.button.configure(state="disabled")
        self.stop.set()


if __name__ == "__main__":
    WorkerWindow().mainloop()
```

**预期：** 点击后进度持续变化，界面仍可响应；关窗先请求停止，轮询发现工作线程结束后销毁窗口，不在主线程里阻塞 `join()`。

**边界：** 本例事件量很小，真实日志需要限量 / 批量刷新，避免一次轮询处理过多消息拖住 UI。真实网络 / 子进程必须设置超时和可取消协议；如果工作线程永远不退出，关闭流程也不会凭空成功。CPU 密集任务应进一步评估进程或原生计算库。

## 二十八、PySide6：Qt 桌面界面、信号槽与工作线程 <a id="ch28"></a>

### 28.1、什么时候从 Tkinter 转到 Qt

**期望回答：** 当工具需要复杂表格树、多窗口、菜单、停靠面板、模型视图或可视化设计器时，Qt 的完整控件体系更适合。代价是更多框架知识、体积和部署工作。PySide6 是 Qt for Python 的绑定，商业分发还要核对所用模块和依赖的当前许可证，不能把 `pip install` 成功当成无限制授权。参见 [**Qt for Python 许可证说明**](https://doc.qt.io/qtforpython-6/licenses.html)。

```shell
python -m pip install PySide6
```

### 28.2、完整 Demo：信号槽与布局

保存为 `pyside_demo.py`，运行 `python pyside_demo.py`：

<!-- demo: gui-qt -->
```python
import sys
from PySide6.QtCore import Slot
from PySide6.QtWidgets import QApplication, QLabel, QLineEdit, QPushButton, QVBoxLayout, QWidget


class GreetingWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Jobs Qt Demo")
        self.name_input = QLineEdit("Jobs")
        self.result_label = QLabel("请输入名字")
        self.button = QPushButton("生成问候")
        self.button.clicked.connect(self.greet)

        self.panel = QVBoxLayout(self)
        self.panel.addWidget(self.name_input)
        self.panel.addWidget(self.result_label)
        self.panel.addWidget(self.button)

    @Slot()
    def greet(self):
        name = self.name_input.text().strip() or "匿名"
        self.result_label.setText(f"你好，{name}")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = GreetingWindow()
    window.show()
    raise SystemExit(app.exec())
```

**预期：** 输入文字后点按钮，标签变成对应问候语；调整窗口宽度时，纵向布局重新分配控件位置。Qt 的 Signal 表示事件发生，Slot 是接收事件的方法，`connect` 建立连接；不是把所有操作立即执行一次。参考 [**Qt Widgets 入门**](https://doc.qt.io/qtforpython-6/tutorials/basictutorial/widgets.html) 与 [**Signals and Slots**](https://doc.qt.io/qtforpython-6/tutorials/basictutorial/signals_and_slots.html)。

### 28.3、后台任务最小完整 Demo

独立保存为 `qt_worker_demo.py`。工作线程只发信号，GUI 方法在主线程更新标签；关闭窗口时先请求中断。

<!-- demo: gui-qt-worker -->
```python
import sys
from PySide6.QtCore import QThread, Signal, Slot
from PySide6.QtWidgets import QApplication, QLabel, QPushButton, QVBoxLayout, QWidget


class Worker(QThread):
    progress = Signal(int)

    def run(self):
        for index in range(20):
            if self.isInterruptionRequested():
                return
            self.msleep(20)
            self.progress.emit((index + 1) * 5)


class TaskWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Qt 后台任务")
        self.worker = None
        self.closing = False
        self.label = QLabel("等待开始")
        self.button = QPushButton("开始")
        self.button.clicked.connect(self.start)
        self.panel = QVBoxLayout(self)
        self.panel.addWidget(self.label)
        self.panel.addWidget(self.button)

    @Slot()
    def start(self):
        if self.worker is not None:
            return
        self.button.setEnabled(False)
        self.worker = Worker(self)
        self.worker.progress.connect(self.update_progress)
        self.worker.finished.connect(self.finished)
        self.worker.finished.connect(self.worker.deleteLater)
        self.worker.start()

    @Slot(int)
    def update_progress(self, value):
        self.label.setText(f"进度 {value}%")

    @Slot()
    def finished(self):
        self.worker = None
        if self.closing:
            self.close()
        else:
            self.button.setEnabled(True)
            self.label.setText("任务完成")

    def closeEvent(self, event):
        if self.worker is not None:
            self.closing = True
            self.button.setEnabled(False)
            self.worker.requestInterruption()
            event.ignore()
        else:
            event.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = TaskWindow()
    window.show()
    raise SystemExit(app.exec())
```

**预期：** 工作时按钮禁用，进度更新，完成后可再次开始；工作中关窗会先请求停止，线程结束后再真正关闭。

**边界：** `requestInterruption()` 只是请求，worker 必须主动检查；真实任务需要捕获异常并发出失败信号。这个 `QThread` 子类适合演示一次性的 `run()` 工作；需要带计时器、Socket、多个槽的长期 worker 时，评估 `QObject + moveToThread()` 模式。不能认为 QThread 对象的任意方法都会自动在工作线程运行，也不要用强制终止线程代替清理。

### 28.4、Qt Designer：可视化画布局

1、启动 PySide6 提供的 Designer，在窗口里拖入 Label、LineEdit、Button 与布局容器。

2、给控件设置稳定的 `objectName`，保存为 `mainwindow.ui`。

3、选择动态加载 `.ui`，或者生成 Python 界面代码。例如：

```shell
pyside6-designer
pyside6-uic mainwindow.ui -o ui_mainwindow.py
```

4、在自己维护的窗口类中使用生成的 UI 并连接信号，**不要把业务逻辑手写进生成文件**，否则再次生成会覆盖。工作方式参考 [**Qt UI 文件教程**](https://doc.qt.io/qtforpython-6/tutorials/basictutorial/uifiles.html)。

**FAQ：Qt Widgets 与 QML 怎么选？**

**期望回答：** 表格、树、菜单和传统桌面工具优先评估 Widgets；更自由的声明式界面、动画和触摸交互可以评估 Qt Quick / QML。两者都需要清楚的业务与展示分层，不能仅凭“声明式”就判断更适合所有应用。

## 二十九、绘图与数据页面：Matplotlib、Streamlit <a id="ch29"></a>

### 29.1、Matplotlib：导出一张图表

安装 `matplotlib` 后，在练习目录运行。会生成 `counts.png`，不要在已有同名重要文件的目录直接执行。

<!-- demo: plot -->
```python
import matplotlib
matplotlib.use("Agg") # 无窗口后端，适合服务器导出图片
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(5, 3), layout="constrained")
ax.bar(["Swift", "OC", "Python"], [3, 2, 4])
ax.set(title="Demo counts", ylabel="Count")
fig.savefig("counts.png", dpi=150)
plt.close(fig)
print("已生成 counts.png")
```

`Figure` 是整张画布，`Axes` 是图表区域，`ax.bar` 才是在其中画柱形图。想在桌面交互显示时使用可用的 GUI 后端并调用 `plt.show()`；想嵌进 Qt / Tk 窗口，需要对应的 Matplotlib Canvas 适配组件。中文字体要确认已安装，不能假定每台机器都具备相同字体。参考 [**Matplotlib Quick start**](https://matplotlib.org/stable/users/explain/quick_start.html)。

**FAQ：为什么 matplotlib 会画图，仍然要 PySide6？**

**期望回答：** Matplotlib 负责图表，PySide6 负责完整桌面应用的窗口、按钮、菜单和布局；需要交互数据工具时可以组合。只导出报告图片则不必引入完整 GUI。

### 29.2、Streamlit：很快做一个数据网页

安装 `streamlit` 后，保存为 `dashboard.py`：

<!-- demo: streamlit -->
```python
import streamlit as st

st.title("Jobs 数据小工具")
name = st.text_input("名字", value="Jobs")
if "clicks" not in st.session_state:
    st.session_state.clicks = 0
if st.button("加一"):
    st.session_state.clicks += 1
st.write(f"{name}，你点击了 {st.session_state.clicks} 次")
st.bar_chart({"count": [1, 3, 2, 4]})
```

```shell
python -m streamlit run dashboard.py --server.address 127.0.0.1
```

**预期：** 在浏览器打开终端提示的本机地址，输入名字、点击按钮，计数与图表可见；终端里的服务需要持续运行，按 Ctrl+C 停止。

### 29.3、Streamlit 的执行模型与普通窗口不同

**问题：为什么按钮点击后，顶层变量好像重新初始化了？**

**期望回答：** Streamlit 的一般交互会触发脚本重新执行。跨重跑保留当前会话状态使用 `st.session_state`，但它不是长期数据库。昂贵计算可以评估缓存 API，私有用户数据要谨慎处理缓存共享范围。见 [**Streamlit 基础概念**](https://docs.streamlit.io/get-started/fundamentals/main-concepts)。

**选型：** 数据筛选、报表、原型很合适；复杂多窗口桌面交互用 Qt，完整网站产品则可能需要更明确的前后端架构。不要以为一个网页能打开，就已经完成认证、部署、多人隔离和持久化。

## 三十、面试 FAQ：问题与期望回答 <a id="ch30"></a>

本章的回答可以先直接说出口，再用对应章节的 Demo 展开；不用背实现细枝末节冒充跨版本保证。

### 30.1、对象与容器

**1、问题：Python 的变量和赋值应该怎样理解？**

**期望回答：** 变量名是对象的绑定，赋值通常不复制对象。两个名字绑定同一个可变对象时，原地修改会相互可见；给其中一个名字重新赋值，不会自动改变另一个名字的绑定。讨论参数传递时，我也用这套模型区分“修改对象”和“重新绑定形参”。

**2、问题：`is` 和 `==` 有什么区别？**

**期望回答：** `is` 判断是否是同一个对象，`==` 判断值相等，后者可以由类型定义。判断 `None` 用 `is None`，比较数值或文本用 `==`。不能因为某次小整数缓存或字符串驻留恰好返回同一对象，就把它当通用规则。

**3、问题：list、tuple、set、dict 怎么选？**

**期望回答：** 按位置排列且要修改，用 list；固定组合可用 tuple；去重和成员判断用 set；按键找值用 dict。dict 保持插入顺序，set 不承诺迭代顺序。tuple 的外层不能换元素，但内部引用的对象可能可变，所以不能简单说“元组里的所有内容都不可变”。

**4、问题：浅复制与深复制有什么区别？**

**期望回答：** 浅复制新建外层对象，嵌套成员通常仍共享；深复制尝试递归复制对象图。是否深复制取决于业务语义，文件、锁、连接等资源不能机械复制。对于跨层数据，我更倾向明确的数据快照，而不是一律 deepcopy。

**5、问题：Python 如何管理内存，会不会泄漏？**

**期望回答：** 常见 CPython 以引用计数配合循环垃圾回收管理对象，但不能把具体析构时机当成所有实现的语言保证。对象被全局缓存、回调或容器持续持有，就可能长期占用内存。外部资源及时释放靠 with / finally，而不是等待垃圾回收。

### 30.2、函数、闭包与装饰器

**6、问题：为什么不推荐可变默认参数？**

**期望回答：** 默认参数在函数定义执行时求值，默认列表会被多次调用共享。通常改用 None，在函数体内按需创建；dataclass 字段使用 default_factory。关键不是“列表不能作为参数”，而是不应意外共享默认对象。

**7、问题：`*args` 和 `**kwargs` 分别是什么？**

**期望回答：** 定义处分别收集额外的位置参数和关键字参数，得到 tuple 和 dict；调用处的星号则用于解包已有数据。它们适合通用转发和装饰器，但普通业务函数应尽量保持显式参数，不能靠 kwargs 隐藏接口契约。

**8、问题：闭包里循环变量为什么都变成最后一个值？**

**期望回答：** 闭包通常在调用时读取外层绑定，循环创建的多个函数可能共享同一个变量。可以通过默认参数、工厂函数或 partial 固定当次输入。默认参数保存的是当次对象引用，如果对象可变，仍需要判断是否要复制。

**9、问题：装饰器是什么，`wraps` 为什么有用？**

**期望回答：** 装饰器接收函数或类并返回替代对象，常用于在原行为前后加统一逻辑。wraps 保留名称、文档和被包装对象引用等元信息，方便调试与工具识别。同步装饰器不能不加区分地套在 async 函数上，否则执行和计时语义可能错误。

**10、问题：生成器为什么省内存？**

**期望回答：** 它按需产生结果，不需要事先保存全部输出，适合单次流式处理。但输入本来就是一个大列表，或者下游立刻 list(generator)，内存仍可能很大。生成器通常会耗尽，需要重跑时应重新创建。

### 30.3、面向对象与类型

**11、问题：dataclass 是否等价于 Swift Struct？**

**期望回答：** 不等价。dataclass 自动生成常见模型方法，但仍是 Python 类，赋值仍可以共享实例。frozen 限制通常的字段赋值，不会深度冻结字段里的列表，也不会自动获得 Swift 的值语义。

**12、问题：实例方法、类方法、静态方法怎么区分？**

**期望回答：** 实例方法接收 self，用当前实例状态；classmethod 接收 cls，适合替代构造等需要保留实际类类型的逻辑；staticmethod 没有隐式接收者。如果只是无状态工具函数，模块级函数往往更直接。

**13、问题：Python 的 `super()` 是直接调用父类吗？**

**期望回答：** 它按 MRO 继续查找，尤其多继承时不能简单等同于固定父类。协作式多继承需要参与者遵守一致的调用约定。一般业务里，如果只是复用某种能力，我优先组合，避免不必要的继承复杂度。

**14、问题：类型注解是否会在运行时拒绝错误类型？**

**期望回答：** 通常不会。注解表达契约，交给 IDE、mypy 或 Pyright 做静态检查。外部 JSON 或配置需要运行时验证，可用显式校验或 Pydantic；这与静态类型检查互补。

**15、问题：鸭子类型、Protocol 和 ABC 有什么区别？**

**期望回答：** 鸭子类型强调对象能完成所需操作，不必来自特定继承树；typing.Protocol 把这种结构契约表达给静态检查器；ABC 则能在运行时阻止未实现抽象方法的类实例化。按静态契约、运行时约束与团队可读性选择，不能只因名字像 Swift Protocol 就当完全相同。

### 30.4、导入与依赖

**16、问题：pip install 与 import 是一个过程吗？**

**期望回答：** 不是。pip 安装分发包到某个环境，import 由当前解释器按模块查找规则加载代码。两者可能使用不同环境，而且 Pillow 对应 PIL 这类安装名与导入名差异很常见。先核对环境和官方导入名，再排查包本身。

**17、问题：为什么每个项目都建议有虚拟环境？**

**期望回答：** 为了隔离依赖，避免不同项目对库版本的要求互相影响。虚拟环境不是安全沙箱，也不会包含所有系统库。它属于可重建的本地环境，应该提交依赖声明与锁文件，而不是提交整个 .venv。

**18、问题：pyproject.toml、requirements.txt、uv.lock 有什么区别？**

**期望回答：** pyproject 描述项目、依赖约束、构建与工具配置；requirements 是 pip 接收的一组安装要求；uv.lock 保存 uv 解析出的锁定结果。pip freeze 可以生成当前环境版本快照，但不等于维护好的直接依赖设计或跨平台完整锁定。

**19、问题：导入模块为什么会执行代码？**

**期望回答：** 模块初始化需要执行其顶层定义和语句，初始化后的模块通常缓存到 sys.modules。为了避免导入时就启动任务或弹窗，业务入口放 main 并用入口保护。模块顶层适合定义与轻量初始化，不适合隐藏副作用。

**20、问题：循环导入和模块重名怎么排查？**

**期望回答：** 循环导入先看是否两个模块互相依赖未完成的定义，再把共同模型下沉或反转依赖。模块重名看实际导入模块的 __file__，检查项目里有没有 json.py、typing.py 等遮蔽标准库的名字。不要第一步就删环境重装。

### 30.5、并发与异步

**21、问题：GIL 是什么，有 GIL 就线程安全吗？**

**期望回答：** GIL 是 CPython 某些运行模式下对解释器执行的锁，不是业务锁。即使存在 GIL，多步检查和更新、外部资源访问仍可能发生逻辑竞争。Python 还有可选 free-threaded 构建，所以并发设计应靠明确同步协议，不依赖偶然的字节码行为。

**22、问题：多线程、多进程、asyncio 怎么选？**

**期望回答：** 先看工作性质。现有阻塞 I/O 可用线程池，大量异步 I/O 用 asyncio，默认有 GIL 的纯 Python CPU 工作可评估多进程。还要算任务粒度、序列化、进程启动、内存和库自身并行的成本。

**23、问题：`async def` 是否自动并行或离开主线程？**

**期望回答：** 不会。调用通常产生协程对象，需要 await 或调度成 Task；同一事件循环中的协程通常在一个线程中协作执行。同步网络、sleep 或长循环塞进去照样堵住事件循环，必须选择真正异步 API 或外部执行资源。

**24、问题：取消任务会立刻停止线程、网络和数据库操作吗？**

**期望回答：** 不保证。取消常是协作式信号，运行中的线程不会因为 Future.cancel 就被安全杀死；已发给远端的操作也可能已经执行。代码要定义超时、检查取消、清理资源和幂等策略。

**25、问题：Python 能像 Actor 一样保护共享状态吗？**

**期望回答：** 可以用锁、队列或单一消费者设计出类似的所有权边界，但标准语言不提供 Swift Actor 那套静态隔离检查。关键是把完整的业务决策放在同一同步范围内。即使只有一个事件循环线程，await 期间也可能有其它任务改变状态。

### 30.6、GUI

**26、问题：Tkinter 和 PySide6 如何选择？**

**期望回答：** 小型表单与工具可以先用 Tkinter，复杂表格、多面板、菜单与可视化设计通常更适合 Qt。选择还要考虑团队知识、依赖体积、目标系统和许可证。不是 Tkinter 永远简单，也不是 Qt 一定适合所有小脚本。

**27、问题：为什么 GUI 点击按钮后会卡死？**

**期望回答：** 回调长时间占用了 UI 线程，事件循环无法重绘或处理输入。把耗时 I/O 放工作线程、重计算按需要放进程或原生库，再将结果交回 UI。只是在回调里写 async 或开一个计时器，不会自动修复阻塞。

**28、问题：工作线程为什么不能直接改界面？**

**期望回答：** GUI 对象通常有线程归属，直接跨线程访问会破坏框架约定。Tk 可以用队列加 after 在 UI 线程取结果，Qt 可以把 worker 信号连接到 UI 对象的槽。要同时处理窗口关闭、旧任务回调和对象生命周期。

**29、问题：QThread 子类的所有方法都在子线程运行吗？**

**期望回答：** 不是。QThread 对象本身有自己的线程归属，普通方法调用不会因类型叫 QThread 就自动切线程。run 中的工作与对象上其它方法的执行位置要分别判断；复杂长期 worker 可以使用 QObject 加 moveToThread，并明确连接方式。

**30、问题：Streamlit 与普通桌面 GUI 的关键区别？**

**期望回答：** Streamlit 在浏览器中提供数据页面，常见交互会重跑脚本；需要用会话状态或缓存管理跨次执行的数据。桌面 GUI 通常围绕长期存在的控件树与事件回调运行。两者的部署、状态、权限和用户隔离都不同。

### 30.7、构建与分发

**31、问题：wheel 和 EXE 有什么区别？**

**期望回答：** wheel 是给 Python 环境安装的分发包，通常不带解释器；EXE 是平台可执行文件，冻结工具可以连同运行时与依赖一起收集。库交付给开发者，应用交付给终端用户，先明确对象再选产物。

**32、问题：为什么有的 wheel 可以跨平台，有的不行？**

**期望回答：** 纯 Python wheel 常见 py3-none-any 标签；包含原生扩展时，需要匹配 Python 实现 / 版本、ABI、系统与 CPU。跨平台源码不等于跨平台二进制。没有匹配 wheel 时，安装可能回退到源码构建，而这又需要目标工具链。

**33、问题：Mac 上用 PyInstaller 能直接得到 Windows EXE 吗？**

**期望回答：** 常规流程不能。PyInstaller 不是跨编译器，应在对应目标系统构建并验证。可以用 Windows / macOS / Linux 的 CI 任务分别产出，但要维护各自依赖、资源和签名流程。

**34、问题：`.app`、`.dmg`、签名与公证是什么关系？**

**期望回答：** app 是应用包，dmg 是分发磁盘映像；签名标识与保护产物完整性，公证属于 Apple 分发信任流程。生成 dmg 不会自动完成签名、公证，也不能通过改后缀把源码变成应用。具体步骤要按产物和官方流程完成。

**35、问题：为什么源码能运行，打包后却打不开？**

**期望回答：** 常见是动态导入、资源、原生库或插件没收集，或者代码依赖当前目录和开发机环境。先用 onedir 和控制台版本定位，再检查日志、资源路径、架构及签名，最后到没有开发环境的目标机器验证。

### 30.8、工程质量

**36、问题：为什么用 with，不依赖垃圾回收关文件？**

**期望回答：** 外部资源释放需要确定的作用域语义，内存回收时机不能替代它。with 让成功和异常路径都调用退出协议；数据库连接的事务上下文与关闭动作还要看具体 API，不能一概而论。

**37、问题：异常应该在哪里捕获？**

**期望回答：** 在有能力恢复、重试、补充上下文或转成人类提示的层捕获。底层不知道如何处理时继续传播；入口统一记录与退出。不能 except: pass，也不要捕获失败后继续打印“全部成功”。

**38、问题：怎么测试文件、网络和 GUI 相关逻辑？**

**期望回答：** 先把业务核心与 I/O、界面分离。文件用临时目录，网络用可控的假客户端或传输层，业务函数测输入、异常和边界；再做少量真实集成与 UI 冒烟验证。不要在单元测试里依赖公共网络稳定性。

**39、问题：为什么不把全部 Python 代码压成一行？**

**期望回答：** 可读性和可定位错误比省行数更重要。简单映射与筛选可以用推导式，复杂控制流、资源管理和副作用用普通函数与循环。代码需要被后来的自己和同事理解，而不是只证明语法可以这么写。

**40、问题：怎样设计一个既能 CLI 又能 GUI 的工具？**

**期望回答：** 把业务核心写成明确输入输出的函数或服务，CLI 管参数与退出码，GUI 管控件与线程切换。两者复用核心，不让核心到处 print、弹窗或退出进程。依赖声明、日志、测试和打包配置与源码一起维护。

## 三十一、日常报错与选型速查 <a id="ch31"></a>

### 31.1、看到异常，先查这一项

| 现象 | 优先检查 | 不推荐的第一反应 |
| --- | --- | --- |
| `ModuleNotFoundError` | 当前解释器、安装环境、导入名、项目结构 | 全局重装全部库 |
| `ImportError` / partially initialized module | 循环导入、重名、库 API 版本 | 到处加 sys.path |
| `TypeError` | 实参与签名、None、类型混用、绑定方法 | 删除所有注解 |
| `AttributeError: NoneType...` | 上一步是否返回 None，是否误用原地修改方法返回值 | 只在崩溃处套 try/except |
| `KeyError` / `IndexError` | 数据契约、缺键、越界 | 无条件给默认值掩盖数据损坏 |
| `UnboundLocalError` | 当前函数赋值导致名字被判为局部 | 全部改成 global |
| `UnicodeDecodeError` | 文件真实编码和二进制 / 文本边界 | 永久 `errors='ignore'` 丢数据 |
| `externally-managed-environment` | 是否在系统托管环境，是否应使用 venv | 直接破坏系统包管理边界 |
| `No matching distribution found` | 包名、Python 版本、平台 wheel、索引 | 认为一定是网络问题 |
| `DLL load failed` / 无法加载 `.so` | 架构、动态库、ABI、系统依赖 | 只检查 Python import 拼写 |
| `coroutine was never awaited` | 是否忘了 await / 调度 | 给所有函数都写 async |
| `asyncio.run() cannot be called...` | 外部是否已有事件循环 | 再创建一层循环 |
| Qt / Tk 无显示、插件错误 | GUI 环境、插件收集、运行位置 | 当作业务函数错误 |
| 打包后闪退 | 先开控制台、看日志、核对资源与架构 | 把整个虚拟环境复制过去 |

### 31.2、常用表达速查

| 想做什么 | Python 写法 / 选择 |
| --- | --- |
| 判空值 | `value is None` |
| 判断容器非空 | `if values:`；先确认空容器与 None 是否要区分 |
| 安全取得可选字典字段 | `mapping.get("key", default)` |
| 带索引遍历 | `enumerate(values)` |
| 成对遍历且长度必须一致 | `zip(a, b, strict=True)` |
| 排序得到新列表 | `sorted(values, key=...)` |
| 保序去重可哈希值 | `list(dict.fromkeys(values))` |
| 拼路径 | `Path(root) / "file.txt"` |
| 拼字符串序列 | `separator.join(parts)` |
| 限定关键字参数 | `def run(*, timeout=5): ...` |
| 可靠释放资源 | `with ...:` / `try/finally` |
| 异步等待 | `await asyncio.sleep(...)`，不要 `time.sleep` 堵循环 |
| 当前 Python 的包管理器 | `python -m pip ...` |
| 查看真实解释器 | `python -c "import sys; print(sys.executable)"` |

### 31.3、常见名词白话表

| 词 | 白话解释 |
| --- | --- |
| Interpreter | 真正读取并执行 Python 程序的运行环境 |
| Module | 一块可导入的代码 |
| Package | 组织模块的命名空间；另注意分发包含义 |
| Dependency | 当前项目需要别人提供的能力 |
| Virtual environment | 项目自己的一套 Python 包安装位置 |
| Wheel | 安装 Python 包用的归档格式 |
| ABI | 编译后部件之间的二进制调用约定 |
| Binding | 既可能指名字绑定对象，也可能指 Python 调用 C++ 库的桥接层 |
| Iterator | 记住遍历进度、每次交出下一个元素的对象 |
| Coroutine | 可以挂起和恢复的异步操作对象 |
| Event loop | 持续处理事件和调度可继续任务的循环 |
| GIL | CPython 特定运行模式中的全局解释器锁 |
| Freeze | 把程序运行需要的部分收集成可分发应用 |
| SDK / Toolchain | 目标平台的开发接口、编译和打包工具集合 |

## 三十二、学习路线、练习答案与验证记录 <a id="ch32"></a>

### 32.1、按能力推进，不用先背完整语言手册

| 阶段 | 阅读与动手 | 达标标志 |
| --- | --- | --- |
| 先会运行 | 第 2、16、17 章；创建 venv，确认解释器，安装一个库 | 能解释安装环境与 import 的关系 |
| 会读语法 | 第 3—8 章；亲手改容器、函数和闭包 Demo | 能预测输出，解释副作用发生在哪个对象上 |
| 会组织逻辑 | 第 9—15 章；模型、异常、资源、文件 | 能把输入、业务、输出分开 |
| 会做工具 | 第 19—22 章；统计目录、模拟网络、加测试 | 失败有提示，任务范围与退出码明确 |
| 会画界面 | 第 26—29 章；先计数器，再后台任务 | 界面响应、线程归属与关窗流程清楚 |
| 会交付 | 第 23—25 章；先构建并安装 wheel，再打本机应用 | 能解释源码、库包、运行时、安装器分别在哪 |
| 会面试 | 第 30 章；每题口述并举一个 Demo | 回答包含条件、理由与不能保证的边界 |

### 32.2、练习一：保序去重，不修改输入

**问题：** 输入语言名字列表，保留第一次出现的顺序，并返回新列表。

**期望思路：** 对可哈希字符串，可以利用 dict 的插入顺序；不要原地删除正在遍历的列表元素。

<!-- demo: run -->
```python
def unique_names(names):
    return list(dict.fromkeys(names))


source = ["Swift", "Python", "Swift"]
assert unique_names(source) == ["Swift", "Python"]
assert source == ["Swift", "Python", "Swift"]
```

### 32.3、练习二：为什么这个模型的数据会串

**问题：** 多个实例共享类级 `items = []` 会串数据，如何修正？

**期望思路：** 每个实例独立创建容器，或使用 dataclass 的工厂。

<!-- demo: run -->
```python
from dataclasses import dataclass, field


@dataclass
class Batch:
    items: list[str] = field(default_factory=list)


a, b = Batch(), Batch()
a.items.append("file-a")
assert b.items == []
```

### 32.4、练习三：并发执行，但限制同时工作的数量

**问题：** 模拟 10 个异步 I/O 工作，最多同时运行 3 个，如何写？

<!-- demo: run -->
```python
import asyncio


async def main():
    semaphore = asyncio.Semaphore(3)

    async def work(index):
        async with semaphore:
            await asyncio.sleep(0.01)
            return index * 2

    results = await asyncio.gather(*(work(i) for i in range(10)))
    assert results == [i * 2 for i in range(10)]


if __name__ == "__main__":
    asyncio.run(main())
```

**期望回答：** Semaphore 限制进入工作区的协程数量；gather 这里返回的结果按输入顺序。示例只有 10 项，若任务数量极大，仍需有界生产 / 消费队列，不能只限执行数量却无限创建等待 Task。

### 32.5、练习四：设计一个“Python 版 iOS 工具箱”

**问题：** 目录统计工具需要 CLI、GUI 和未来打包，怎样分层？

**期望回答：** 路径扫描与统计属于 core，argparse 属于 CLI，窗口与线程切换属于 GUI。两种入口调用同一个 core；文件系统通过临时目录验证，GUI 验证事件与关闭，最终在目标平台打包。扫描、日志与界面更新都要有规模边界，不能为了方便把所有逻辑放进按钮回调。

### 32.6、官方资料与原文入口

本文是原创讲解与教学 Demo，不是对官方手册的逐段翻译。稳定语言语义与工具当前行为分别以相应官方资料为准。

- 语言学习：[**Python Tutorial**](https://docs.python.org/3/tutorial/)、[**数据模型**](https://docs.python.org/3/reference/datamodel.html)、[**标准库**](https://docs.python.org/3/library/)。
- 工程与依赖：[**PyPA Packaging Guide**](https://packaging.python.org/)、[**venv**](https://docs.python.org/3/library/venv.html)、[**uv**](https://docs.astral.sh/uv/)。
- 并发：[**asyncio**](https://docs.python.org/3/library/asyncio.html)、[**concurrent.futures**](https://docs.python.org/3/library/concurrent.futures.html)、[**free-threading**](https://docs.python.org/3/howto/free-threading-python.html)。
- 界面：[**Tkinter**](https://docs.python.org/3/library/tkinter.html)、[**Qt for Python**](https://doc.qt.io/qtforpython-6/)、[**Streamlit**](https://docs.streamlit.io/)、[**Matplotlib**](https://matplotlib.org/stable/)。
- 分发：[**PyInstaller**](https://pyinstaller.org/en/stable/)、[**Nuitka**](https://nuitka.net/)、[**Briefcase**](https://briefcase.beeware.org/)、[**Flet 发布指南**](https://flet.dev/docs/publish/)。

### 32.7、验证范围

本次验证日期为 **2026-08-30**。验证时直接提取本文代码块，避免另写一套“看起来相同”的 Demo 掩盖文档错误。

| 验证项 | 本次结果 |
| --- | --- |
| 语法与文档结构 | 83 个 Python 代码块通过 Python 3.11 语法规则解析；TOML 配置可解析，章节编号、代码围栏和表格结构已检查 |
| 基础与并发 Demo | 64 个标准库 / 多进程示例在 CPython 3.14.7 运行通过，文件操作使用临时目录 |
| 第三方库 | Pydantic、NumPy、pandas、openpyxl、HTTPX 示例在隔离的 Python 3.12.13 验证环境运行通过；HTTP 使用模拟传输，没有请求真实业务接口 |
| 测试与入口 | pytest 示例 4 个测试通过；目录统计 CLI 检查正常结果和无效目录；FastAPI 健康检查接口通过测试客户端验证 |
| 桌面 GUI | 本机 Tk 9.0、Qt 6.11.1 下，5 个 GUI 示例完成窗口 / 控件、按钮、绘图、任务完成、取消或关闭等适用流程的基本检查；Qt 使用离屏渲染 |
| 图表与数据页面 | Matplotlib 成功生成 PNG 并检查图像；Streamlit 通过 AppTest 检查输入、重复点击、重新执行和会话状态 |
| 库包构建与消费 | 示例项目生成 wheel 与 sdist，均通过 `twine check`；wheel 在另一套干净的 Python 3.14.7 环境安装，import、`python -m` 与命令行入口均通过 |
| 条件资源示例 | 为 `importlib.resources` 示例提供独立临时包和 `templates/help.txt` 后读取成功；不意味着第 23.2 节未添加模板的初始项目已经含有该资源 |
| 外部链接 | 76 个不同外链均成功取得页面或资源；封面服务不接受 HEAD，改用 GET 检查通过 |

**这些结果不能推导出：** 所有 Python 版本都已运行验证，所有第三方库版本都兼容，或者一个系统上的 GUI 检查能代替其它系统验收。83 个代码块中含多文件项目的组成部分和需要依赖 / 测试数据的片段，并非 83 个都适合直接粘贴到同一个文件。

**本次没有执行：** Windows / Linux / iOS / Android 应用构建，EXE / APP / DMG / 安装器 / Docker 镜像构建，平台签名、公证、商店提交和 PyPI 上传。相关章节提供工具用法与选型边界，正式交付仍需在目标平台完成构建及消费验证。

本次只交付这份 Markdown；验证依赖与示例产物放在临时目录和隔离环境，没有修改全局 Python 包或现有 Swift / OC 文档。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
