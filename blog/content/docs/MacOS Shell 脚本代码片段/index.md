---
title: "MacOS Shell 脚本代码片段"
date: 2026-11-15T12:49:45+08:00
draft: false
weight: 100
summary: "📚 目录（点击展开 / 收起） - 🔥 前言 - 一、从成熟脚本提取的固定写法 - 1.1、先自述，再初始化，最后编排业务 - 1.2、自身路径、参数数组与拖入路径 - 1.3、纯文本日志与管道真实退出码 - 1.4、确认、选择与返回是不同状态 - 1.5、自检：发现、运行验证、定点修复、复检 - 1.6、来源先显示，下载完成后再发布 - 1.7、批量先成功"
bookCollapseSection: false
---


![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、从成熟脚本提取的固定写法](#distilled-patterns)
  - [1.1、先自述，再初始化，最后编排业务](#runtime-skeleton)
  - [1.2、自身路径、参数数组与拖入路径](#paths-and-arguments)
  - [1.3、纯文本日志与管道真实退出码](#logging-and-exit)
  - [1.4、确认、选择与返回是不同状态](#confirmation-and-selection)
  - [1.5、自检：发现、运行验证、定点修复、复检](#dependency-health)
  - [1.6、来源先显示，下载完成后再发布](#source-and-download)
  - [1.7、批量先成功枚举，再逐项处理](#nul-batch)
  - [1.8、备份、候选、并发核对和恢复](#transactional-write)
  - [1.9、锁、进程身份与退出清理](#locks-processes-cleanup)
  - [1.10、部署与反部署成对，恢复只处理本次归属](#deployment-state)
  - [1.11、终端展示、来源日志与应用动作](#terminal-style)
  - [1.12、验证小片段，避免用真实业务验证框架](#verification-boundary)
- [二、来源范围与持续维护](#sources-and-maintenance)
  - [2.1、扫描范围与证据强度](#survey-scope)
  - [2.2、JobsGenesis 之外的固定写法](#outside-genesis)
  - [2.3、片段如何成为后续脚本的参考](#maintenance-contract)
- [三、专项代码片段](#specialized-snippets)
  - [3.1、🎯 Debug](#jobs-toc-heading-20)
  - [3.2、🎯 Logo](#jobs-toc-heading-21)
  - [🎯 打开系统设置](#jobs-toc-heading-22)
  - [🎯 等待用户输入后执行](#jobs-toc-heading-23)
  - [🎯 判断是否当前IP在🇨🇳中国（大陆地区）](#jobs-toc-heading-24)
  - [🎯 git](#jobs-toc-heading-25)
    - [1、目录判定](#jobs-toc-heading-26)
    - [2、检测远程仓库](#jobs-toc-heading-27)
  - [🎯 获取系统变量](#jobs-toc-heading-28)
    - [1、路径](#jobs-toc-heading-29)
      - [1.1、获取：脚本所在目录的绝对路径](#jobs-toc-heading-30)
      - [1.2、获取：当前脚本文件名](#jobs-toc-heading-31)
      - [1.3、获取：脚本路径](#jobs-toc-heading-32)
      - [1.4、\*获取：桌面路径 \*](#jobs-toc-heading-33)
      - [1.5、循环问正确（判断依据解耦自定义拓展）的路径，直到正确为止](#jobs-toc-heading-34)
    - [2、获取：当前用户名](#jobs-toc-heading-35)
    - [3、\*获取：🍏 Xcode 信息 \*](#jobs-toc-heading-36)
    - [4、\*获取：☕ Java 信息 \*](#jobs-toc-heading-37)
    - [5、获取：🤖  Android SDK 信息](#jobs-toc-heading-38)
  - [🎯 生成桌面快捷方式](#jobs-toc-heading-39)
  - [🎯 转换路径为绝对路径](#jobs-toc-heading-40)
  - [🎯 识别.xcodeproj](#jobs-toc-heading-41)
  - [🎯 Android 模拟器🤖](#jobs-toc-heading-42)
    - [2、📱关闭 iOS 模拟器](#jobs-toc-heading-43)
    - [3、📱打开 iOS 模拟器](#jobs-toc-heading-44)
  - [3.4、🎯 执行耗时](#jobs-toc-heading-45)
  - [3.5、🎯 写文件](#jobs-toc-heading-46)
    - [🎯 1、单行写文件（避免重复写入）](#jobs-toc-heading-47)
    - [🎯 2、多行写文件（避免重复写入）](#jobs-toc-heading-48)
    - [🎯 3、函数将内容插入到指定的文件顶部](#jobs-toc-heading-49)
  - [3.6、🎯 环境变量](#jobs-toc-heading-50)
    - [🎯 1、写单行的环境变量](#jobs-toc-heading-51)
    - [🎯 2、写多行的环境变量](#jobs-toc-heading-52)
    - [🎯 3、🌐 环境变量格式化](#jobs-toc-heading-53)
  - [3.7、🎯 判断芯片架构（ARM64 / x86\_64）](#jobs-toc-heading-54)
  - [3.8、🎯 SDKMAN](#jobs-toc-heading-55)
  - [3.9、🎯 💎Rubygems 自检安装](#jobs-toc-heading-56)
    - [🎯1、自检安装 💎Gem.CocoaPods](#jobs-toc-heading-57)
    - [🎯2、自检安装 💎Gem.bundler](#jobs-toc-heading-58)
  - [3.10、🎯 🍺Homebrew 自检安装](#jobs-toc-heading-59)
    - [🎯 1、自检安装 🍺Homebrew （自动架构判断，包含环境注入）](#jobs-toc-heading-60)
    - [🎯 2、自检安装 🍺Homebrew.fzf](#jobs-toc-heading-61)
    - [🎯 3、自检安装 🍺Homebrew.jq](#jobs-toc-heading-62)
    - [🎯 4、自检安装 🍺Homebrew.dart](#jobs-toc-heading-63)
    - [🎯 5、自检安装 🍺Homebrew.coreutils（提供 realpath）](#jobs-toc-heading-64)
    - [🎯 6、自检安装 🍺Homebrew.bc](#jobs-toc-heading-65)
    - [🎯 7、自检安装 🍺Homebrew.Gradle](#jobs-toc-heading-66)
    - [🎯 8、自检安装 🍺Homebrew.jenv](#jobs-toc-heading-67)
    - [🎯 9、自检安装 🍺Homebrew.cocoapods](#jobs-toc-heading-68)
    - [🎯 10、自检安装 🍺Homebrew.Perl](#jobs-toc-heading-69)
    - [🎯 11、自检安装 Rbenv](#jobs-toc-heading-70)
    - [🎯 12、官方安装 Ruby](#jobs-toc-heading-71)
  - [3.11、🎯 删除🍺Homebrew](#jobs-toc-heading-72)
  - [3.12、🎯自检安装 fvm（Dart官方推荐）](#jobs-toc-heading-73)
  - [3.13、🎯 设置Ruby镜像源（根据 IP 自动判断）](#jobs-toc-heading-74)
  - [3.14、🎯 镜像切换](#jobs-toc-heading-75)
    - [1、CocoaPods 镜像切换](#jobs-toc-heading-76)
    - [2、Ruby  镜像切换](#jobs-toc-heading-77)
  - [3.15、🎯 检测本地Java环境是否已经安装](#jobs-toc-heading-78)
  - [3.16、🎯 Flutter](#jobs-toc-heading-79)
    - [🎯 1、判断当前目录是否为Flutter项目根目录](#jobs-toc-heading-80)
    - [🎯 2、获取 Flutter项目名称](#jobs-toc-heading-81)
    - [🎯 3、判断Flutter文件是否是入口🚪](#jobs-toc-heading-82)
    - [🎯 4、统一获取Flutter项目路径和Dart入口文件路径](#jobs-toc-heading-83)
    - [🎯 5、FVM 检测](#jobs-toc-heading-84)
  - [3.17、🎯 全更新](#jobs-toc-heading-85)
  - [3.18、🎯 Git](#jobs-toc-heading-86)
    - [🎯 1、删除本地Git缓存目录](#jobs-toc-heading-87)
    - [🎯 2、删除CDN源trunk](#jobs-toc-heading-88)
    - [🎯 3、添加Git源](#jobs-toc-heading-89)
  - [3.19、🎯判断两个文件内容是否一致](#jobs-toc-heading-90)
  - [3.20、🎯重启](#jobs-toc-heading-91)
  - [3.21、🎯 Shell](#jobs-toc-heading-92)
    - [🎯 1、切换Shell](#jobs-toc-heading-93)
    - [🎯 2、显示当前Shell](#jobs-toc-heading-94)
    - [🎯 3、打开新的终端窗口并切换到脚本所在的目录](#jobs-toc-heading-95)
    - [🎯 4、关闭终端窗口](#jobs-toc-heading-96)
    - [🎯 5、打开新的终端窗口](#jobs-toc-heading-97)
    - [🎯 6、仅对当前Shell有效的临时环境](#jobs-toc-heading-98)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

本文从本机自维护脚本中提取经常复用的结构、交互和恢复机制，面向新脚本编写及已有脚本维护。[**WindowsOS**](https://www.microsoft.com/windows) 的原生实现单独放在[Windows 脚本代码片段](./Windows脚本代码片段.md)，不把 MacOS 命令逐字替换成另一端命令。

- **先读公约和脚本 Skill，再读对应平台的本文片段，最后对照当前来源脚本。** 片段解释可复用的思路及边界，不能代替项目真实参数、权限、业务确认与平台验证。
- 本文使用 [**zsh**](https://zsh.sourceforge.io/)；独立入口使用 `#!/bin/zsh`，`# shell: zsh` 仅是编辑器提示。原生 Shell 可以减少额外解释器依赖，但性能与兼容性仍取决于调用的工具和实现。
- [固定写法](#distilled-patterns)优先用于新代码。[专项片段](#specialized-snippets)保留原资料；其中历史独立示例可能依赖上下文，不能把旧安装菜单、未定义变量、直接覆盖和全局修改当作现行生产基座。
- 文中标为“归纳模板”的代码经过必要简化，不声称与来源逐字相同；真实来源、适用范围和验证边界见[来源与维护](#sources-and-maintenance)。文档里的相对来源链接要求本机兄弟仓保持现有相对布局；单独克隆 JobsDocs 时不一定存在。

## 一、<span id="distilled-patterns">从成熟脚本提取的固定写法</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1.1、<span id="runtime-skeleton">先自述，再初始化，最后编排业务</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

自述前只计算展示需要的值；日志创建、目录写入、环境修复和业务都放在确认之后。`main()` 只写高层函数调用和同行职责注释。独立终端、应用动作、自动化入口各自声明身份，非 TTY 不代表已授权无人值守运行。

以下是**归纳的最小流程模板**：业务仅打印当前脚本路径，确认后只创建一个私有日志。它演示路径、确认、日志、退出码与清理的组合；正式可交互入口还应复用[终端展示保护](#terminal-style)中的完整现行实现。模板刻意使用纯文本，不自行改变终端颜色。

```shell
#!/bin/zsh
# 用途：展示自述后输出自身位置；确认前不写文件。
# 影响：确认后仅在系统临时目录建立私有日志；Ctrl+C 取消。
# shell: zsh

ENTRY_PATH="${0:A}"
SCRIPT_DIR=""
SCRIPT_PATH=""
LOG_FILE=""
# 展示用途和影响，输入结束不能视作确认。
show_script_intro_and_wait() {
  printf '%s\n' '脚本自述：展示自身位置并建立本次日志。'
  printf '脚本：%s\n' "$ENTRY_PATH"
  printf '%s\n' '影响：只写系统临时目录；按回车继续，Ctrl+C 取消。'
  if [[ ! -t 0 || ! -t 1 ]]; then
    printf '%s\n' '需要可交互终端；当前入口未声明自动化模式。' >&2
    exit 2
  fi
  local answer=""
  IFS= read -r 'answer?➤ ' || exit 130
  [[ -z "$answer" ]] || exit 0
}
# 确认后初始化运行环境，不依赖启动工作目录。
initialize_runtime() {
  setopt NO_NOMATCH PIPE_FAIL
  SCRIPT_PATH="$ENTRY_PATH"
  SCRIPT_DIR="${SCRIPT_PATH:h}"
  LOG_FILE="$(umask 077; mktemp "${TMPDIR:-/tmp}/jobs-script.XXXXXXXX")" || exit 1
  trap 'exit 130' INT
  trap 'exit 143' TERM
}
# 展示内容与日志内容分离；该模板使用纯文本。
log_message() {
  local level="$1" text="$2"
  printf '[%s] %s\n' "$level" "$text" >&2
  printf '[%s] %s\n' "$level" "$text" >> "$LOG_FILE" || return 1
}
# 汇总退出结果，日志供后续排查。
finish_runtime() {
  local result_code="$1"
  printf '退出码：%s；日志：%s\n' "$result_code" "$LOG_FILE" >&2
}
# 在脚本定义区声明退出函数，避免函数局部 EXIT trap 提前触发。
TRAPEXIT() {
  local result_code=$?
  (( ZSH_SUBSHELL == 0 )) || return "$result_code"
  if [[ -n "$LOG_FILE" ]]; then
    finish_runtime "$result_code"
  fi
  return "$result_code"
}
# 编排本例业务，并显式处理失败。
run_business() {
  log_message INFO "脚本目录：$SCRIPT_DIR" || exit 1
  log_message SUCCESS '只读示例完成。' || exit 1
}
# 收口高层流程，真实业务分支留在各职责函数内。
main() {
  show_script_intro_and_wait # 首先展示用途并取得本次运行确认。
  initialize_runtime # 确认后才创建日志并注册退出处理。
  run_business "$@" # 执行已声明的业务并传递原参数。
}

main "$@"
```

来源：[CodeGraph 安装器](<../../JobsGenesis/JobsCommand@iOS/配置相关/【MacOS】⚙️安装代码地图CodeGraph.command/【MacOS】⚙️安装代码地图CodeGraph.command>) 的 `show_script_intro_and_wait`、`initialize_runtime`、`main`；[CodeSnippets 安装器](<../../JobsGenesis/JobsCommand@iOS/配置相关/【MacOS】⚙️双击安装JobsCodeSnippets.command/【MacOS】⚙️双击安装JobsCodeSnippets.command>) 的 `configure_runtime`、`run_business`。原有终端监督保护需要与既有 trap 合并，不能把这里的 EXIT trap 覆盖到成熟入口上。

### 1.2、<span id="paths-and-arguments">自身路径、参数数组与拖入路径</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 脚本资源从脚本自身位置或明确项目标记解析；用户目录从运行环境取得。`pwd` 是调用者的位置，不自动代表工程根；同名包装后必须重新核对层级。App 包外资源还须考虑系统隔离运行路径，不能仅靠 `../Scripts` 推定。
- 首选原始参数 `"$@"`，每个参数是一个路径。不要 `eval` 拖入文本，不全局删除引号，不把空格拆成多个文件。以下模板接收**已经存在的单个真实路径**；交互拖入后带有 Shell 转义的字符串，需要来源脚本的词法解析步骤，不能直接当成原始参数。

```shell
# 接收原始路径参数，保留路径内部的空格和引号。
resolve_existing_path() {
  local candidate="$1"
  [[ -n "$candidate" && -e "$candidate" ]] || return 1
  print -r -- "${candidate:A}"
}
# 用参数数组调用程序，避免把数据重新解释成命令。
inspect_selected_paths() {
  local selected_path=""
  for selected_path in "$@"; do
    [[ -e "$selected_path" ]] || return 1
    /usr/bin/stat -f '%N | %z bytes' "$selected_path" || return 1
  done
}
```

来源：[Release 附件替换](<../../JobsGenesis/JobsCommand@Gits/MacOS/【MacOS】🔄替换GitHub Release附件.command/【MacOS】🔄替换GitHub Release附件.command>) 的 `normalize_directory`。它先接受真实路径，必要时才用 zsh 分词及解引号，并拒绝多个词和控制字符；这种策略与只去掉一层首尾引号的简单输入不是同一能力。

### 1.3、<span id="logging-and-exit">纯文本日志与管道真实退出码</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 每次运行建立唯一、私有的日志；固定 `脚本名.log` 可用于明确的单实例入口，但不能让并发任务互相清空。终端负责颜色，日志只存可搜索文本；自述标题、普通说明和操作选项的样式使用现行展示函数。
- `command | tee` 不能只看 `$?`。以下归纳片段一次保存整个 `pipestatus`，先传递业务失败，再报告日志写入失败。它用于**不包含秘密且自身输出为纯文本的命令**；外部彩色输出应在 tee 前增加过滤段，并同步检查每个过滤段状态。

```shell
# 同时展示和记录纯文本命令输出，不让 tee 掩盖业务失败。
run_logged() {
  local -a command_args=("$@")
  local -a stage_codes=()
  "${command_args[@]}" 2>&1 | tee -a "$LOG_FILE"
  stage_codes=("${pipestatus[@]}")
  if (( stage_codes[1] != 0 )); then
    printf '命令失败，退出码：%s\n' "${stage_codes[1]}" >&2
    return "${stage_codes[1]}"
  fi
  if (( stage_codes[2] != 0 )); then
    printf '日志写入失败：%s\n' "$LOG_FILE" >&2
    return "${stage_codes[2]}"
  fi
  return 0
}
```

来源：CodeGraph 安装器的 `log_message`、`run_logged`。来源的业务码捕获经过这里的归纳增强，不能反过来声称来源已经检查所有管道阶段。`pipestatus` 属于 zsh；不能直接贴进 bash。[zsh 官方参数说明](https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Set-By-The-Shell)解释其含义。

### 1.4、<span id="confirmation-and-selection">确认、选择与返回是不同状态</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 首屏自述的回车只表示“了解用途”。普通安装、更新与修复使用键盘菜单，默认跳过；选择目标只形成计划，最终确认后才执行。
- 危险动作默认取消；已有精确 `YES` 门禁保留。明确要求免文字输入的入口按命名危险选项及空格复核处理，不能用普通回车默认执行。
- [**fzf**](https://formulae.brew.sh/formula/fzf) 子层提供 `←` 返回真正上一层；取消、返回、空选、执行失败和成功分别传递。切换上层目标后清除依赖它的下层结果。`FZF_DEFAULT_OPTS` 不能改变必需方向键。

下面只示范**普通执行确认**，不用于下载附件多选或危险动作。依赖必须在已授权的依赖准备阶段就绪；缺失时停止，不悄悄改成数字输入。

```shell
# 默认跳过；只接受明确选中的执行项。
confirm_regular_action() {
  [[ -t 0 && -t 1 ]] || return 2
  command -v fzf >/dev/null 2>&1 || return 2
  fzf --version >/dev/null 2>&1 || return 2
  local picked="" picker_code=0
  picked="$(printf '%s\n' '跳过 / 取消' '执行本次操作' |
    FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE='' fzf --no-multi \
      --bind='up:up,down:down,tab:down,shift-tab:up,esc:abort' \
      --header='↑/↓ 或 Tab 选择；回车确认；默认跳过' \
      --prompt='执行确认 > ')" || picker_code=$?
  (( picker_code == 0 )) || return "$picker_code"
  [[ "$picked" == '执行本次操作' ]]
}
# 精确 YES 仅适用于保留这种约定的独立危险操作。
confirm_dangerous_yes() {
  [[ -t 0 && -t 1 ]] || return 2
  local answer=""
  printf '风险：%s\n' "$1" >&2
  printf '%s\n' '必须输入 YES；直接回车、其它输入和 EOF 均取消。' >&2
  IFS= read -r 'answer?➤ ' || return 1
  [[ "$answer" == YES ]]
}
```

完整层级状态参考 Release 附件替换的 `choose_with_fzf`、`collect_plan`，不是整份照抄：该来源仍含旧的多选按键，下载附件面板须使用当前“完整取数 → 零项提示／一项真实数据／多项首行全选 → 最终确认”约定。纯空白执行等下载专项规则不推广给普通安装菜单。

### 1.5、<span id="dependency-health">自检：发现、运行验证、定点修复、复检</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

`command -v` 只说明候选存在。需要验证 `--version`、运行时最小能力及实际执行通道；升级走哪个包管理器，就检查那条依赖链。已有健康环境直接复用，不为了形式完整重新安装。

```shell
# 发现一个真实可用的 brew，不在 brew 缺失时调用 brew --prefix。
resolve_healthy_brew() {
  local candidate="" discovered=""
  discovered="$(command -v brew 2>/dev/null)"
  for candidate in "$discovered" /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -n "$candidate" && -x "$candidate" ]] || continue
    "$candidate" --version >/dev/null 2>&1 || continue
    "$candidate" --prefix >/dev/null 2>&1 || continue
    print -r -- "$candidate"
    return 0
  done
  return 1
}
# 显示候选与健康结果；缺失时交回已授权的安装流程。
check_brew_health() {
  local brew_bin=""
  brew_bin="$(resolve_healthy_brew)" || return 1
  printf '可用 Homebrew：%s\n' "$brew_bin"
}
```

来源：CodeGraph 安装器的 `jobs_brew_candidate_ok`、`jobs_brew_find`、`check_node_npm_health`、`find_healthy_node_npm`。上例覆盖系统常规前缀，显式自定义路径应先校验再复用。它不安装、不改启动文件、不批量升级软件。[**Homebrew**](https://brew.sh/) 的环境刷新只在确认的候选可用后执行。

- 普通本地修复按层执行一次并立即复检，失败即停止下游，避免无限递归。
- 已声明并获准的必需 SDK 获取是持续重试的专项例外：只包围可重入的获取步骤；退避等待可取消，保留可靠缓存，取消码不重试。磁盘、权限、认证、许可和版本不存在等确定错误另行处理。
- 业务命令不能因网络重试重复构建、重启、上传或修改远端。来源：[SDK 获取重试](<../../Flutter/tool/setup/Scripts/【MacOS】SDK获取重试.zsh/【MacOS】SDK获取重试.zsh>) 的 `jobs_sdk_retry`；其 `LOCAL_OPTIONS`、`LOCAL_TRAPS` 和原输入流传递也应保留。

### 1.6、<span id="source-and-download">来源先显示，下载完成后再发布</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 在传输前显示对象、实际来源、目标和已知版本；切换来源时更新显示。配置 URL、Git 本地规则展开的 URL 与经过网络验证的终点分开描述。
- 展示 URL 去掉凭据、查询与片段；展示副本不能回写业务地址。不要原样打印带认证参数的命令、HTTP Header 或环境。私有日志也不能保存秘密。
- 以下归纳模板用于**一次普通 HTTPS 制品获取**，要求调用方已经展示来源、取得授权，并传入来自独立可信渠道的 SHA256。目标文件已存在时拒绝覆盖；中断可能留下同目录临时文件，由入口登记后清理。不提供断点续传和 SDK 无限重试。

```shell
# 下载到同目录临时文件，验证后发布；目标父目录由调用方准备。
download_verified_once() {
  local asset_url="$1" target_file="$2" expected_sha256="$3"
  local temp_file="" actual_sha256="" transfer_code=0
  [[ "$asset_url" == https://* ]] || return 2
  [[ "$expected_sha256" =~ '^[[:xdigit:]]{64}$' ]] || return 2
  [[ -d "${target_file:h}" && ! -e "$target_file" && ! -L "$target_file" ]] || return 2
  temp_file="$(umask 077; mktemp "${target_file}.part.XXXXXXXX")" || return 1
  curl --fail --location --proto '=https' --proto-redir '=https' \
    --connect-timeout 10 --speed-limit 1 --speed-time 30 \
    --output "$temp_file" -- "$asset_url" || transfer_code=$?
  if (( transfer_code != 0 )); then
    rm -f -- "$temp_file"
    return "$transfer_code"
  fi
  actual_sha256="$(shasum -a 256 "$temp_file")" || {
    rm -f -- "$temp_file"
    return 1
  }
  actual_sha256="${actual_sha256%% *}"
  if [[ "${actual_sha256:l}" != "${expected_sha256:l}" ]]; then
    rm -f -- "$temp_file"
    return 1
  fi
  # 使用 link 的精确双路径语义，目标已存在（含目录）时失败。
  if ! /bin/link "$temp_file" "$target_file"; then
    rm -f -- "$temp_file"
    return 1
  fi
  rm -f -- "$temp_file"
}
```

来源：Release 附件替换的 `stage_plan`、`download_asset`、`verify_download`、`backup_assets`、`check_concurrent_changes`。上例的本地发布是归纳改进，使用 MacOS 原生 `/bin/link` 的精确目标语义，受目标文件系统 hard link 能力限制；不支持时应明确失败，不能偷偷降级成覆盖。生产入口把临时文件纳入自身清理登记；不可信可写共享目录还需更严格的目录与文件身份控制。参数语义见 [curl 官方手册](https://curl.se/docs/manpage.html)。

持续下载和分卷不能仅凭“文件存在”成功：核对资产 ID、版本、长度和可信摘要；续传必须确认远端标识仍相同。API 数据先取齐分页再展示，限流等待、传输重试、本地错误各自分支处理。

### 1.7、<span id="nul-batch">批量先成功枚举，再逐项处理</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

路径清单使用 NUL 分隔，兼容空格、中文、引号和换行。先把 `find` 结果写入私有清单并确认成功，再遍历，避免进程替换隐藏扫描失败。目录跳过只是第一层过滤，不能代替文件所有权检查。

```shell
# 只读统计授权根内的文件；生产写操作还需逐项所有权白名单。
inspect_file_tree() {
  local scan_root="$1" manifest_file="" current_file="" file_count=0
  [[ -d "$scan_root" && ! -L "$scan_root" ]] || return 2
  scan_root="${scan_root:A}"
  manifest_file="$(umask 077; mktemp "${TMPDIR:-/tmp}/jobs-files.XXXXXXXX")" || return 1
  if ! find "$scan_root" \
    -type d \( -name .git -o -name node_modules -o -name Pods \
      -o -name PodsManual -o -name 'ManualBy*Pods@Pods' -o -name .dart_tool \
      -o -name build -o -name DerivedData -o -name Vendor -o -name vendor \) -prune \
    -o -type f -print0 > "$manifest_file"; then
    rm -f -- "$manifest_file"
    return 1
  fi
  while IFS= read -r -d '' current_file; do
    (( file_count += 1 ))
  done < "$manifest_file"
  rm -f -- "$manifest_file" || return 1
  printf '只读枚举文件数：%s\n' "$file_count"
}
```

来源：[全文搜索替换](<../../JobsGenesis/JobsCommand@Others/MacOS/【MacOS】全文件搜索文字替换.command/【MacOS】全文件搜索文字替换.command>) 的 `replace_in_target`。第三方、生成源码和归属不明文件排除；只维护 Jobs 自有或明确接管的内容。

### 1.8、<span id="transactional-write">备份、候选、并发核对和恢复</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

成熟写入不是“先备份，然后无条件覆盖”。应保存原始快照与身份，在候选副本中生成并验证完整内容；发布前确认原对象未变，完成后核对结果。恢复也只撤回本次拥有且未被后续修改的资源。

下面的归纳模板仅处理**普通单文件、同目录候选、协作锁保护且目录可信**的场景。调用前应已取得同一写入协议的锁、完成危险确认及元数据保存。它检测常见并发变化，但比较到替换之间仍有竞争窗口；不是任意进程下的文件系统 CAS，也不用于有额外 ACL／扩展属性恢复要求的配置。

```shell
# 核对原件仍等于快照后替换，保留备份供上层恢复。
publish_checked_candidate() {
  local target_file="$1" original_copy="$2" candidate_file="$3"
  [[ -f "$target_file" && ! -L "$target_file" ]] || return 2
  [[ -f "$original_copy" && ! -L "$original_copy" ]] || return 2
  [[ -f "$candidate_file" && ! -L "$candidate_file" ]] || return 2
  [[ "${target_file:A:h}" == "${candidate_file:A:h}" ]] || return 2
  cmp -s "$target_file" "$original_copy" || return 3
  # 调用方先验证候选语法、权限和必要元数据，再进入本步骤。
  mv -f -- "$candidate_file" "$target_file" || return 1
  return 0
}
```

- 文件级参考全文搜索替换的 `replace_in_file`：不跟随符号链接、区分未匹配与读取失败、同目录临时文件、不覆盖旧备份。
- 目录事务参考 CodeSnippets 安装器的 `prepare_transaction`、`record_metadata`、`compare_original_files`、`publish_candidate`、`handle_interrupt`：备份内容与元数据，发布前再次核对；不能把它简化为 `cp` 加 `rm -rf`。
- 托管配置块使用唯一开始／结束标记。零组可新增，一组可更新，多组、缺边界、嵌套异常应停止；保留块外文本。仅用 `grep` 搜到一行不是完整幂等更新协议。

### 1.9、<span id="locks-processes-cleanup">锁、进程身份与退出清理</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 锁使用实际平台提供的互斥机制；记录本轮 owner、对象范围、创建信息。未知锁、活动锁不强删；只因时间较旧不能判死。锁类型不同，释放方式也不同，不能把持久文件锁路径当空目录删掉。
- `kill -0 PID` 只做存活检查。停止前同时核对 PID、启动时间、可执行路径／命令以及所属项目收据；身份改变则保留并报告。停止自己创建的子进程时登记整个任务树，不能用宽泛 `pkill -f`。
- zsh 的函数 `EXIT` trap 与脚本退出存在作用域差异；避免在锁获取函数里注册一个会随函数返回提前释放的 EXIT。命令替换子 Shell 也不能释放主进程的锁。参考 [zsh 官方 trap 说明](https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html)。
- 清理注册本轮临时文件、私有目录、子进程和锁；按反向依赖顺序清理，保留业务退出码。清理前重新校验路径、非链接、设备／inode 或 owner；不能只检查一个字符串以临时目录开头。
- `SIGKILL`、断电与终端崩溃不能承诺由 trap 恢复；持久恢复材料必须可供下次启动核验。

来源：[子模块下载](<../../JobsGenesis/JobsCommand@Gits/MacOS/【MacOS】⏬下载配置当前Git子模块（可向下同步递归）.command/【MacOS】⏬下载配置当前Git子模块（可向下同步递归）.command>) 的 `acquire_download_lock`、`TRAPEXIT`、`release_download_runtime`；[Finder 部署事务](<../../JobsGenesis/OS@Extension/MacOS@Extension/JobsFileHasher/Scripts/【MacOS】AppDeployment.zsh/【MacOS】AppDeployment.zsh>) 的 `jobs_deployment_validate_transaction`、`jobs_deployment_release_transaction`；[学术平台部署](<../../学术服务平台/部署/MacOS/【MacOS】部署.command/【MacOS】部署.command>) 的 `lc_release_lock`、`lc_stop_recorded`；[JobsIM 部署](<../../JobsIM/部署/MacOS/部署运行.command/部署运行.command>) 的 `assert_owner`、`process_matches`。

### 1.10、<span id="deployment-state">部署与反部署成对，恢复只处理本次归属</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

从散落业务仓提取的部署机制不能被通用安装器替代，推荐保留以下完整协议：

- 用项目真实位置、用户和对象身份形成独立状态区；没有收据的非空目录不自动接管。
- 记录部署前资源快照、原始备份及部署后摘要，配置、数据、工具和缓存分开归属；恢复时仅处理仍等于本次 after 状态的资源。
- 部署 checkpoint 与恢复进度落盘，失败后下次可识别未完成阶段；完成反部署后逐项核对 before 状态。用户后来新建、修改或共享的对象保留并报告。
- 数据备份与数据恢复分开确认；加密备份可通过解密并读取归档结构验证，但这仍不等于数据库恢复演练。
- 核心生命周期直接内嵌到各平台入口；可以有必要冗余，不能要求用户运行开发期生成器或另装无关解释器才能部署。快捷入口可转交本平台唯一实施入口。

来源：[学术平台部署](<../../学术服务平台/部署/MacOS/【MacOS】部署.command/【MacOS】部署.command>) 的 `lc_manifest`、`lc_begin`、`lc_checkpoint`、`lc_restore_resources`；[JobsIM 部署](<../../JobsIM/部署/MacOS/部署运行.command/部署运行.command>) 的 `initialize`、`assert_owner`、`backup_instance`。这些来源的业务成熟度与入口格式分开判断，不把它们现存的每个顶层执行语句认定为新规范。

### 1.11、<span id="terminal-style">终端展示、来源日志与应用动作</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

终端默认颜色是会话共享状态。生产入口复制现行脚本 Skill 中的**完整临时终端配色范本**，并参考 CodeGraph 安装器的 `jobs_terminal_style_run`／`jobs_terminal_style_bootstrap`；不把数百行状态保护删成 `37;40m` 和 `reset`。范本属于开发时参考，交付脚本内嵌实现，不在运行时读取本机 Skill 路径。

- 只修改实际连接的会话，先读回再修改，退出精确恢复本次改动；不能修改最前窗口、默认 Profile、启动配置或系统主题。用户运行中更改了原项时保留新值并报告冲突。
- 非 TTY、`TERM` 空／`dumb`、`NO_COLOR`（含空值）及应用纯文本输出降级；能力不明或读写恢复无法可靠验证时保持原状态。控制序列只发终端，不写日志。
- 自述标题和正文、仅回车与任意字符选项按真实交互突出；固定词 `YES` 不属于“仅回车”。颜色不改变输入含义与默认值。
- [**Sourcetree**](https://www.sourcetreeapp.com/) 动作必须明确识别来源，第一屏即纯文本；需交互的业务转交独立终端，参数安全引用并保留最终退出码。非 TTY 本身不是应用身份。
- [Git 动态代理](<../../JobsGenesis/JobsCommand@Gits/MacOS/【MacOS】🌐双击配置Git动态代理.command/【MacOS】🌐双击配置Git动态代理.command>) 的 `execute_selected_command`、`execute_network_policy` 展示另一项边界：代理限定本任务／子进程，尊重显式设置，不写全局配置，真实业务最多执行一次。网络探测失败不能盲目重放远端写操作。

### 1.12、<span id="verification-boundary">验证小片段，避免用真实业务验证框架</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 静态：对本文新归纳 zsh 片段执行 `zsh -n`；检查代码块闭合、文内锚点及相对来源。
- 隔离：在中文、空格、引号路径和无关工作目录验证自身寻址；用假命令验证业务失败与日志失败；在临时目录验证批量扫描和候选发布，不触碰真实部署目录。
- 交互：fzf 的方向键、默认取消、EOF、子层返回和重新进入需要真实 TTY 行为验证。语法检查不能代替按键验收；模板未验部分如实注明。
- 平台：MacOS 测试不能证明 Windows 原生行为，通用 PowerShell AST 解析不能证明注册表、终端或服务行为。无需为文档验证安装软件、清理环境、修改仓库索引、部署或反部署业务。

当前核对：8 个新归纳代码块通过 `zsh -n`，10 项隔离夹具覆盖退出码、日志失败、特殊路径、NUL 枚举、候选并发检查与假下载校验；独立复核补测子 Shell 归属、非 TTY 门禁和目标目录竞争。最小流程模板已在真实 TTY、中文空格路径及无关工作目录完成确认后执行。两份文档的目录转换、锚点与 HTML 预览已核对；封面外链未请求。本文新确认菜单的完整按键路径、生产终端配色和真实部署未执行，不从片段检查推定这些行为已经通过。

## 二、<span id="sources-and-maintenance">来源范围与持续维护</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 2.1、<span id="survey-scope">扫描范围与证据强度</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

扫描基准为 2026-11-15，本机 GitHub 根内按 `.command`、`.sh`、`.zsh`、`.bash`、`.ps1`、`.psm1`、`.psd1`、`.bat`、`.cmd` 发现候选，另检索局部 `AGENTS.md`。重点覆盖 JobsGenesis 的 Git 工具、环境配置、iOS 工具、系统扩展及双端脚本，也审阅其它仓库的独特机制。

| 层次 | 结果与含义 |
| --- | --- |
| 常规发现 | 2,271 条候选路径，包含 10 份规则文件与 91 条显式第三方目录路径；不是自维护脚本数量。 |
| 第一层排除后 | 2,170 条脚本候选，JobsGenesis 1,632 条、其余仓库 538 条；按字节摘要有 1,236 组，反映副本重复，不代表语义去重。 |
| 补充忽略文件发现 | 跳过 Skills、第三方及常见构建依赖目录后另得 2,601 条候选，与常规范围不同、不可直接相减；发现的生成报告、SDK缓存、供应商源码继续排除。 |
| 正文证据 | 按用途读取代表函数并给出实际来源；不是逐份完整审计全部脚本，也不是所有来源脚本已经通过现行格式或实机验收。 |
| 不自动推广 | 第三方、生成、所有权不明、旧副本；仅文件名相似、路径存在或过去测试通过，都不能作为本轮成熟度证明。 |

### 2.2、<span id="outside-genesis">JobsGenesis 之外的固定写法</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 主仓外按不同业务抽样核实，避免只从一套公共函数重复计数。

| 来源 | 值得复用的部分 | 边界 |
| --- | --- | --- |
| [学术平台部署入口](<../../学术服务平台/部署/MacOS/【MacOS】部署.command/【MacOS】部署.command>) | 资源快照、摘要、owner锁、checkpoint、恢复进度；仅撤回归属资源 | 不执行真实安装或清理验证；业务版本与目标系统分别核验 |
| [JobsIM 部署入口](<../../JobsIM/部署/MacOS/部署运行.command/部署运行.command>) | 每项目独立状态、PID身份、备份加密后解密读回 | 归档可读不等于数据库恢复演练 |
| [Flutter SDK 重试](<../../Flutter/tool/setup/Scripts/【MacOS】SDK获取重试.zsh/【MacOS】SDK获取重试.zsh>) | 局部选项与trap、获取阶段重试、取消码、不重复业务 | 不把 SDK 专项无限重试推广给普通安装或远端写入 |
| [Pod Install 离线保护](<../../JobsOCBaseConfigDemo@ByPods/ScriptsByPods/Cocoapods相关脚本/【MacOS】📦Pod Install离线保护.command/【MacOS】📦Pod Install离线保护.command>) | `offline`、`check-only`、`skip` 三种语义分离；辅助失败不覆盖主任务结果 | 仅自维护 hook 辅助入口，不修改 Pods 内第三方；不能借文档验收运行 pod install |
| [WindowsOS 下载器](<../../WindowsOS/WindowsOS_10/WindowsOS/【WindowsOS】⏬下载当前仓库Release.cmd/【WindowsOS】⏬下载当前仓库Release.ps1>) | 原生获取、附件身份、断点与取消 | Windows 对应实现与详细来源在独立文档核对；不从 Shell 推定原生支持 |

### 2.3、<span id="maintenance-contract">片段如何成为后续脚本的参考</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 写／改脚本前，先加载公约与对应语言／平台 Skill，再阅读这里命中的片段和真实来源函数；跨平台任务同时读取两份文档。
- 当前确认的规则优先于旧示例；发现不一致时调整归纳模板，标清来源仅证明哪一项机制，不整份继承旧写法。
- 新的长期固定写法优先更新已有对应章节，写清用途、参数、依赖、返回值、取消／失败、清理与验证。普通事实不重复入库，不把项目专用常量变成全局默认值。
- 新模板只替换项目值，保留已确认的工程判断；对关键控制实现做必要隔离验证。正式脚本自包含，开发机文档和 Skill 路径不成为分发产物依赖。

## 三、<span id="specialized-snippets">专项代码片段</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 以下保留既有专题资料。示例中的 `SYSTEM_BIN_DIR`、`SYSTEM_CONFIG_DIR` 等变量须由所属项目定义；环境安装、强制停止、删除、覆盖、镜像与默认 Shell 修改须另行确认。新入口以[固定写法](#distilled-patterns)为基座，旧的“任意字符执行”、彩色日志直接落盘、直接下载执行和未校验进程身份等写法不作为现行标准。

### <span id="jobs-toc-heading-20" data-jobs-toc="v2">3.1、🎯 **Debug** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
echo "📄 SCRIPT_PATH = $SCRIPT_PATH"
read "?👉 按下回车开始执行，或 Ctrl+C 取消..."
```

### <span id="jobs-toc-heading-21" data-jobs-toc="v2">3.2、🎯 **Logo** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* ```shell
  print_logo() {
    info "======================="
    info "     Jobs Installer    "
    info "======================="
  }
  ```

* ```shell
  print_description() {
    echo ""
    color_echo "||=================================================||"
    color_echo "||  JJJJJJJJ     oooooo    bb          SSSSSSSSSS  ||"
    color_echo "||        JJ    oo    oo   bb          SS      SS  ||"
    color_echo "||        JJ    oo    oo   bb          SS          ||"
    color_echo "||        JJ    oo    oo   bbbbbbbbb   SSSSSSSSSS  ||"
    color_echo "||  J     JJ    oo    oo   bb      bb          SS  ||"
    color_echo "||  JJ    JJ    oo    oo   bb      bb  SS      SS  ||"
    color_echo "||   JJJJJJ      oooooo     bbbbbbbb   SSSSSSSSSS  ||"
    color_echo "||=================================================||"
    echo ""
  }
  ```
  
* ```shell
  # ✅ 自述信息
  show_banner() {
    clear
    highlight_echo '                                                                                       '
    highlight_echo '88888888888 88         88        88 888888888888 888888888888 88888888888 88888888ba   '
    highlight_echo '88          88         88        88      88           88      88          88      "8b  '
    highlight_echo '88          88         88        88      88           88      88          88      ,8P  '
    highlight_echo '88aaaaa     88         88        88      88           88      88aaaaa     88aaaaaa8P''  '
    highlight_echo '88""""""     88         88        88      88           88      88""""""     88""""""88''  '
    highlight_echo '88          88         88        88      88           88      88          88     `8b   '
    highlight_echo '88          88         Y8a.    .a8P      88           88      88          88      8b   '
    highlight_echo '88          88888888888 `"Y8888Y"`       88           88      88888888888 88      `8b  '
    warn_echo    "                        🛠️ FLUTTER iOS 模拟器 启动脚本"
    echo ""
    success_echo "🛠️ 本脚本用于将 Dart 或 Flutter 项目运行到 iOS 模拟器"
    success_echo "===================================================================="
    success_echo "👉 支持："
    success_echo "   1. 拖入 Flutter 项目根目录（含 pubspec.yaml 和 lib/main.dart）或 Dart 单文件（含 void main）"
    success_echo "   2. 自动识别 FVM、构建模式、flavor 参数"
    success_echo "   3. 自动启动 iOS 模拟器，处理假后台问题"
    success_echo "   4. 支持 fzf 模拟器选择与创建（设备 + 系统组合）"
    success_echo "   5. flutter run 日志异常时自动修复 CocoaPods"
    success_echo "   6. 自动创建桌面 .command 快捷方式"
    success_echo "===================================================================="
    error_echo   "📌 如需运行断点调试，请使用 VSCode / Android Studio / Xcode 等 IDE。终端运行不支持断点。"
    echo ""
  }
  ```

### 🎯 🖨️打印输出彩色函数 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

* ```shell
  SCRIPT_BASENAME=$(basename "$0" | sed 's/\.[^.]*$//')   # 当前脚本名（去掉扩展名）
  LOG_FILE="$TMPDIR/${SCRIPT_BASENAME}.log"                  # 设置对应的日志文件路径
  
  log()            { echo -e "$1" | tee -a "$LOG_FILE"; }
  color_echo()     { log "\033[1;32m$1\033[0m"; }         # ✅ 正常绿色输出
  info_echo()      { log "\033[1;34mℹ $1\033[0m"; }       # ℹ 信息
  success_echo()   { log "\033[1;32m✔ $1\033[0m"; }       # ✔ 成功
  warn_echo()      { log "\033[1;33m⚠ $1\033[0m"; }       # ⚠ 警告
  warm_echo()      { log "\033[1;33m$1\033[0m"; }         # 🟡 温馨提示（无图标）
  note_echo()      { log "\033[1;35m➤ $1\033[0m"; }       # ➤ 说明
  error_echo()     { log "\033[1;31m✖ $1\033[0m"; }       # ✖ 错误
  err_echo()       { log "\033[1;31m$1\033[0m"; }         # 🔴 错误纯文本
  debug_echo()     { log "\033[1;35m🐞 $1\033[0m"; }      # 🐞 调试
  highlight_echo() { log "\033[1;36m🔹 $1\033[0m"; }      # 🔹 高亮
  gray_echo()      { log "\033[0;90m$1\033[0m"; }         # ⚫ 次要信息
  bold_echo()      { log "\033[1m$1\033[0m"; }            # 📝 加粗
  underline_echo() { log "\033[4m$1\033[0m"; }            # 🔗 下划线
  ```

  > ```
  > # ✅ 示例用法
  > # success_echo "安装成功"
  > # error_echo "安装失败"
  > # info_echo "开始执行脚本..."
  > # warn_echo "检测到风险配置"
  > # note_echo "请注意版本兼容性"
  > # debug_echo "当前变量值：\$VAR=xxx"
  > # highlight_echo "推荐使用该功能"
  > # bold_echo "这是加粗文本"
  > # underline_echo "点击链接查看详情"
  > # gray_echo "跳过无关文件"
  > ```

* ```shell
  # ============================= 日志输出函数 =============================
  # 默认日志文件路径（可被外部覆盖）
  LOG_FILE="${LOG_FILE:-$TMPDIR/script_log.txt}"
  # 通用日志输出（含日志落盘）
  log() {
    local msg="$1"
    echo -e "$msg" | tee -a "$LOG_FILE"
  }
  
  # --------------------------- 各类语义输出 ---------------------------
  info()        { log "\033[1;34mℹ $1\033[0m"; }     # ℹ 信息（蓝）
  success()     { log "\033[1;32m✔ $1\033[0m"; }     # ✔ 成功（绿）
  warn()        { log "\033[1;33m⚠ $1\033[0m"; }     # ⚠ 警告（黄）
  error()       { log "\033[1;31m✖ $1\033[0m"; }     # ✖ 错误（红）
  debug()       { log "\033[1;35m🐞 $1\033[0m"; }     # 🐞 调试（紫）
  note()        { log "\033[1;36m➤ $1\033[0m"; }     # ➤ 提示（青）
  highlight()   { log "\033[1;36m🔹 $1\033[0m"; }     # 🔹 高亮（青）
  bold()        { log "\033[1m$1\033[0m"; }          # 📝 加粗
  gray()        { log "\033[0;90m$1\033[0m"; }       # ⚫ 灰色（弱提示）
  underline()   { log "\033[4m$1\033[0m"; }          # 🔗 下划线
  ```
  
  > ```shell
  > # ✅ 示例用法
  > # success "安装成功"
  > # warn "即将覆盖文件"
  > # error "安装失败"
  > # debug "路径为 $HOME/bin"
  > # note "下一步执行 flutter build"
  > # bold "重要步骤"
  > ```
  
* ```shell
  _color_echo() {
    local color="$1"; shift
    local text="$*"
  
    case "$color" in
      red)        printf "\033[31m%s\033[0m\n" "$text" ;;  # 错误 ❌
      green)      printf "\033[32m%s\033[0m\n" "$text" ;;  # 成功 ✅
      yellow)     printf "\033[33m%s\033[0m\n" "$text" ;;  # 警告 ⚠️
      blue)       printf "\033[34m%s\033[0m\n" "$text" ;;  # 信息 📘
      purple)     printf "\033[35m%s\033[0m\n" "$text" ;;  # 调试 🟣
      cyan)       printf "\033[36m%s\033[0m\n" "$text" ;;  # 辅助 💠
      white)      printf "\033[37m%s\033[0m\n" "$text" ;;  # 普通 ⚪
      gray)       printf "\033[90m%s\033[0m\n" "$text" ;;  # 次要信息 ⚫
  
      bold)       printf "\033[1m%s\033[0m\n" "$text" ;;   # 粗体
      underline)  printf "\033[4m%s\033[0m\n" "$text" ;;   # 下划线
  
      success)    printf "\033[1;32m✔ %s\033[0m\n" "$text" ;;
      error)      printf "\033[1;31m✖ %s\033[0m\n" "$text" ;;
      info)       printf "\033[1;34mℹ %s\033[0m\n" "$text" ;;
      warning)    printf "\033[1;33m⚠ %s\033[0m\n" "$text" ;;
      note)       printf "\033[1;35m➤ %s\033[0m\n" "$text" ;;
  
      *)          printf "%s\n" "$text" ;;  # 默认普通输出
    esac
  }
  ```
  
  > ```shell
  > # ✅ 示例用法
  > # _color_echo red "❌ 出错了"
  > # _color_echo green "✅ 成功完成任务"
  > # _color_echo yellow "⚠️ 警告信息"
  > # _color_echo blue "📘 蓝色提示"
  > # _color_echo purple "🟣 紫色调试"
  > # _color_echo cyan "💠 青色辅助"
  > # _color_echo white "⚪ 普通白色输出"
  > # _color_echo gray "⚫ 灰色信息"
  > 
  > # _color_echo bold "📝 加粗文字"
  > # _color_echo underline "🔗 下划线文字"
  > 
  > # _color_echo success "✔ 操作成功（绿色 + 图标）"
  > # _color_echo error "✖ 操作失败（红色 + 图标）"
  > # _color_echo info "ℹ 信息提示（蓝色 + 图标）"
  > # _color_echo warning "⚠ 注意风险（黄色 + 图标）"
  > # _color_echo note "➤ 额外提示（紫色 + 图标）"
  > ```
  
* ```shell
  _JobsPrint() {
    local COLOR="$1"
    local TEXT="$2"
    local RESET="\033[0m"
    echo "${COLOR}${TEXT}${RESET}"
  }
  
  _JobsPrint_Red()        { _JobsPrint "\033[1;31m" "$1"; }   # 🔴 红色（错误）
  _JobsPrint_Green()      { _JobsPrint "\033[1;32m" "$1"; }   # 🟢 绿色（成功）
  _JobsPrint_Yellow()     { _JobsPrint "\033[1;33m" "$1"; }   # 🟡 黄色（警告）
  _JobsPrint_Blue()       { _JobsPrint "\033[1;34m" "$1"; }   # 🔵 蓝色（信息）
  _JobsPrint_Purple()     { _JobsPrint "\033[1;35m" "$1"; }   # 🟣 紫色（调试）
  _JobsPrint_Cyan()       { _JobsPrint "\033[1;36m" "$1"; }   # 🔵 青色（辅助）
  _JobsPrint_White()      { _JobsPrint "\033[1;37m" "$1"; }   # ⚪ 白色（普通输出）
  _JobsPrint_Gray()       { _JobsPrint "\033[0;90m" "$1"; }   # ⚫ 灰色（次要信息）
  _JobsPrint_Bold()       { _JobsPrint "\033[1m"     "$1"; }   # 📝 粗体
  _JobsPrint_Underline()  { _JobsPrint "\033[4m"     "$1"; }   # 🔗 下划线
  ```
  
  > ```shell
  > # ✅ 示例用法
  > # _JobsPrint_Red "❌ 安装失败"
  > # _JobsPrint_Green "✅ 安装成功"
  > # _JobsPrint_Yellow "⚠️ 请注意：配置存在风险"
  > # _JobsPrint_Blue "📘 正在拉取远程资源..."
  > # _JobsPrint_Purple "🟣 进入调试模式"
  > # _JobsPrint_Cyan "🔵 正在初始化辅助模块..."
  > # _JobsPrint_White "⚪ 普通提示：操作完成"
  > # _JobsPrint_Gray "⚫ 跳过无关文件"
  > # _JobsPrint_Bold "📝 加粗强调：重要内容"
  > # _JobsPrint_Underline "🔗 文档地址：https://example.com"
  > ```

### 🎯 📔日志输出 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```shell
# ✅ 日志输出（日志文件名 == 脚本文件名）
init_logging() {
  local custom_log_name="$1"

  # 获取脚本路径（兼容 Finder 双击和终端执行）
  local resolved_path="${(%):-%x}"
  script_path="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

  local default_log_name="$(basename "$resolved_path" | sed 's/\.[^.]*$//').log"
  local log_file_name="${custom_log_name:-$default_log_name}"

  LOG_FILE="${script_path}/${log_file_name}"

  # 清空旧日志
  : > "$LOG_FILE"

  # 打印路径（彩色输出后才重定向）
  info_echo "日志记录启用：$LOG_FILE"

  # 重定向所有输出到终端 + 日志
  exec 1> >(tee -a "$LOG_FILE") 2>&1
}
```

### <span id="jobs-toc-heading-22" data-jobs-toc="v2">🎯 打开系统设置 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
open "x-apple.systempreferences:com.apple.preference.security?Privacy"
```

### <span id="jobs-toc-heading-23" data-jobs-toc="v2">🎯 等待用户输入后执行 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* ```
  # ✅ 通用：回车跳过，任意字符执行
  ask_run() {
    echo ""
    note_echo "👉 $1"
    gray_echo "【回车=跳过，任意字符=执行】"
    local input
    read "input?➤ "
    [[ -n "$input" ]]
  }
  ```

  > ```shell
  > ask_run "安装/更新 Homebrew？" && install_homebrew
  > ```

* ```shell
  wait_for_user_to_start() {
    echo ""
    note_echo "👉 ${1:-是否执行该步骤？}"
    gray_echo "【回车=跳过，任意字符=执行】"
    local sim_input
    IFS= read -r "sim_input?➤ "
    [[ -n "$sim_input" ]]
  }
  ```
  
  > ```shell
  > echo "准备执行 flutter clean..."
  > if wait_for_user_to_start "执行 flutter clean？"; then
  >   flutter clean
  > else
  >   echo "跳过 flutter clean"
  > fi
  > ```
  
* ```shell
  wait_for_user_to_start() {
    echo ""
    read "?👉 按下回车开始执行，或 Ctrl+C 取消..."
    echo ""
  }
  ```
  
  > ```shell
  > echo "即将执行 flutter build..."
  > wait_for_user_to_start
  > flutter build apk --release
  > ```
  
* ```shell
  wait_for_user_to_start() {
    read -p "⚠️ 确定要卸载 XXX？请输入 yes 开始执行：" confirm
  
    if [[ "$confirm" != "yes" ]]; then
      echo "❎ 已取消卸载操作"
      exit 0
    fi
  
    echo "🧨 正在卸载 XXX..."
  }
  ```
  
  > ```shell
  > echo "准备执行危险操作：卸载 XXX"
  > wait_for_user_to_start
  > # 真正的卸载命令放这里
  > rm -rf $(brew --prefix)/XXX
  > echo "✅ 卸载完成"
  > ```

### <span id="jobs-toc-heading-24" data-jobs-toc="v2">🎯 判断是否当前IP在🇨🇳中国（大陆地区）<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
is_in_china() {
  local country
  country=$(curl -s --max-time 3 https://ipinfo.io | jq -r '.country' 2>/dev/null)

  if [[ "$country" == "CN" ]]; then
    return 0  # 是中国，true
  else
    return 1  # 不是中国，false
  fi
}
```

### <span id="jobs-toc-heading-25" data-jobs-toc="v2">🎯 [**git**](https://git-scm.com/) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-26" data-jobs-toc="v2">1、目录判定 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
is_git_repo() {
  local dir="$1"
  # 工作副本：.git 目录或 .git 文件（worktree 等）
  [[ -d "$dir/.git" || -f "$dir/.git" ]] && return 0
  # 裸仓库（可选）
  [[ -f "$dir/HEAD" && -d "$dir/objects" && -d "$dir/refs" ]] && return 0
  return 1
}
```

#### <span id="jobs-toc-heading-27" data-jobs-toc="v2">2、检测远程仓库 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
ensure_git_remote() {
  local remote_name="${1:-origin}"
  local remote_url

  # 如果已经存在远程仓库，直接提示并返回
  if git remote get-url "$remote_name" >/dev/null 2>&1; then
    info_echo "已存在 git remote [$remote_name] -> $(git remote get-url "$remote_name")"
    return 0
  fi

  # 循环直到用户输入有效的远程地址
  while true; do
    read -rp "请输入远程仓库地址 (例如 https://github.com/user/repo.git): " remote_url
    if [[ -z "$remote_url" ]]; then
      warn_echo "输入为空，请重新输入"
      continue
    fi

    # 验证远程是否可访问
    if git ls-remote "$remote_url" >/dev/null 2>&1; then
      git remote add "$remote_name" "$remote_url"
      success_echo "已成功配置 git remote [$remote_name] -> $remote_url"
      break
    else
      error_echo "无法访问 $remote_url，请检查地址是否正确"
    fi
  done
}
```

### <span id="jobs-toc-heading-28" data-jobs-toc="v2">🎯 获取系统变量 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-29" data-jobs-toc="v2">1、路径 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

##### <span id="jobs-toc-heading-30" data-jobs-toc="v2">1.1、<font color=red>**获取：脚本所在目录的绝对路径**</font> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

  >- **${BASH_SOURCE[0]:-${(%):-%x}}**：获取当前脚本路径，兼容 **bash** 和 **zsh**。🔔 `:-` 是默认值语法（如果前者不存在就用后者）
  >  * **bash** 用 `BASH_SOURCE[0]`
  >   * **zsh**用 `${(%):-%x}`
  >
  > - **dirname**：提取文件路径中的目录部分，例如：/a/b/c.sh → /a/b
  > 
  > - **cd "$(dirname ...)"**：切换到脚本所在的目录，准备获取绝对路径
  >
  >- **pwd**：获取当前目录的**绝对路径**，即脚本所在目录的绝对路径
  >
  > - **整体结构 $(...)**：使用命令替换，将整个执行结果赋值给变量
  >
  >- **最终变量 `SCRIPT_DIR`=...**：：将脚本自身所在目录的**绝对路径**保存到 `SCRIPT_DIR` 中，适用于引用、路径拼接等
  >

  ```shell
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
  ```

```shell
cd "$SCRIPT_DIR" || {
      echo "❌ 无法进入脚本目录：$SCRIPT_DIR"
      exit 1
}
```

##### <span id="jobs-toc-heading-31" data-jobs-toc="v2">1.2、**获取：当前脚本文件名** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

  > `basename "$0"`：提取脚本文件的**文件名**部分（去除路径）

  ```shell
  script_file="$(basename "$0")"
  ```

##### <span id="jobs-toc-heading-32" data-jobs-toc="v2">1.3、**获取：脚本路径** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/$(basename -- "$0")"
```

##### <span id="jobs-toc-heading-33" data-jobs-toc="v2">1.4、**获取：桌面路径 **<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

  ```shell
  DESKTOP_PATH=~/Desktop
  ```

##### <span id="jobs-toc-heading-34" data-jobs-toc="v2">1.5、循环问正确（判断依据解耦自定义拓展）的路径，直到正确为止 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
# shell: zsh

# ✅ 彩色输出函数
SCRIPT_BASENAME=$(basename "$0" | sed 's/\.[^.]*$//')   # 当前脚本名（去掉扩展名）
LOG_FILE="$TMPDIR/${SCRIPT_BASENAME}.log"                  # 设置对应的日志文件路径

log()            { echo -e "$1" | tee -a "$LOG_FILE"; }
color_echo()     { log "\033[1;32m$1\033[0m"; }        # ✅ 正常绿色输出
info_echo()      { log "\033[1;34mℹ $1\033[0m"; }      # ℹ 信息
success_echo()   { log "\033[1;32m✔ $1\033[0m"; }      # ✔ 成功
warn_echo()      { log "\033[1;33m⚠ $1\033[0m"; }      # ⚠ 警告
warm_echo()      { log "\033[1;33m$1\033[0m"; }        # 🟡 温馨提示（无图标）
note_echo()      { log "\033[1;35m➤ $1\033[0m"; }      # ➤ 说明
error_echo()     { log "\033[1;31m✖ $1\033[0m"; }      # ✖ 错误
err_echo()       { log "\033[1;31m$1\033[0m"; }        # 🔴 错误纯文本
debug_echo()     { log "\033[1;35m🐞 $1\033[0m"; }     # 🐞 调试
highlight_echo() { log "\033[1;36m🔹 $1\033[0m"; }     # 🔹 高亮
gray_echo()      { log "\033[0;90m$1\033[0m"; }        # ⚫ 次要信息
bold_echo()      { log "\033[1m$1\033[0m"; }           # 📝 加粗
underline_echo() { log "\033[4m$1\033[0m"; }           # 🔗 下划线

# ✅ 路径工具函数
abs_path() {
  local p="$1"
  [[ -z "$p" ]] && return 1
  p="${p//\"/}"
  [[ "$p" != "/" ]] && p="${p%/}"
  if [[ -d "$p" ]]; then
    (cd "$p" 2>/dev/null && pwd -P)
  elif [[ -f "$p" ]]; then
    (cd "${p:h}" 2>/dev/null && printf "%s/%s\n" "$(pwd -P)" "${p:t}")
  else
    return 1
  fi
}

is_ok_root() {
  local p="$1" # SCRIPT_DIR
  # 校验逻辑
#  return 1 # 不正确的路径
  return 0 # 正确的路径
}

# ✅ 项目入口识别
detect_entry() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

  while true; do
    warn_echo "📂 请拖入正确的目录路径："
    read -r user_input
    user_input="${user_input//\"/}"
    user_input="${user_input%/}"

    if [[ -z "$user_input" ]]; then
      if is_ok_root "$SCRIPT_DIR"; then
        ok_root=$(abs_path "$SCRIPT_DIR")
        highlight_echo "🎯 检测到脚本所在目录:$SCRIPT_DIR 即正确的路径，自动使用。"
        break
      else
        error_echo "❌ 当前目录:$SCRIPT_DIR 不是正确的路径，请重新拖入。"
        continue
      fi
    fi

    error_echo "❌ 无效路径:$SCRIPT_DIR，请重新拖入正确的路径："
  done

  cd "$ok_root" || { error_echo "无法进入项目目录：$ok_root"; exit 1; }
  success_echo "✅ 项目路径：$ok_root"
}

# ✅  主流程函数
main() {
  clear
  show_banner                   # 自述信息
  detect_entry                  # 项目入口识别
}

# ✅ 脚本执行入口
main "$@"
```

#### <span id="jobs-toc-heading-35" data-jobs-toc="v2">2、**获取：当前用户名** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

  > 用双引号 `"` 包裹起来，可以防止用户名中出现空格、特殊字符时发生错误

  ```shell
  user="$USER" # 最强兼容性（大部分 shell 都默认支持）
  user="${USER:-$(whoami)}" # 最强健壮性：防止极端场景 $USER 为空
  ```

  ```shell
  user="$(whoami)"
  ```

  ```shell
  user="$(id -un)" 
  ```

  ```shell
  user="$(logname)" 
  ```

| 表达式    | 类型     | 含义说明                                                 |
| --------- | -------- | -------------------------------------------------------- |
| `"$USER"` | 环境变量 | 当前 **shell** 会话中的用户名变量（快捷方式）            |
| `whoami`  | 命令     | 实际正在运行当前 **shell** 进程的用户名                  |
| `id -un`  | 命令     | 当前有效用户的用户名（与 `whoami` 通常一样，但更底层）   |
| `logname` | 命令     | 最初登录系统的用户（在 `sudo` 场景下可能与当前用户不同） |

#### <span id="jobs-toc-heading-36" data-jobs-toc="v2">3、**获取：🍏 Xcode 信息 **<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
print_xcode_info() {
  highlight_echo "🍏 Xcode 信息"
  if command -v xcodebuild >/dev/null 2>&1; then
    info_echo "Xcode 版本：$(xcodebuild -version | head -n 1)"
    info_echo "Xcode 路径：$(xcode-select -p)"
  else
    error_echo "未检测到 xcodebuild"
  fi
}
```

#### <span id="jobs-toc-heading-37" data-jobs-toc="v2">4、**获取：☕ Java 信息 ** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```
print_java_info() {
  highlight_echo "☕ Java 环境"
  if command -v java >/dev/null 2>&1; then
    java -version 2>&1 | head -n 1
    info_echo "JAVA_HOME：${JAVA_HOME:-[未设置]}"
  else
    error_echo "未安装 Java"
  fi
}
```

#### <span id="jobs-toc-heading-38" data-jobs-toc="v2">5、**获取：🤖  [Android](https://www.android.com/) SDK 信息** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
print_android_sdk_info() {
  highlight_echo "🤖 Android SDK"
  if [[ -n "$ANDROID_SDK_ROOT" ]]; then
    info_echo "ANDROID_SDK_ROOT：$ANDROID_SDK_ROOT"
    if [[ -d "$ANDROID_SDK_ROOT" ]]; then
      success_echo "SDK 目录存在"
      if [[ -f "$ANDROID_SDK_ROOT/tools/bin/sdkmanager" ]]; then
        "$ANDROID_SDK_ROOT/tools/bin/sdkmanager" --version
      elif [[ -f "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]]; then
        "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --version
      else
        warn_echo "未找到 sdkmanager"
      fi
    else
      error_echo "ANDROID_SDK_ROOT 路径不存在"
    fi
  else
    warn_echo "未设置 ANDROID_SDK_ROOT 环境变量"
  fi
}
```

### <span id="jobs-toc-heading-39" data-jobs-toc="v2">🎯 生成桌面快捷方式 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
shortcut_name="${flutter_project_name}.command"
shortcut_path="$HOME/Desktop/$shortcut_name"
if [[ ! -f "$shortcut_path" ]]; then
  ln -s "$script_path/$script_file" "$shortcut_path"
  chmod +x "$shortcut_path"
  echo "📎 已在桌面创建快捷方式：$shortcut_name"
fi
```

### <span id="jobs-toc-heading-40" data-jobs-toc="v2">🎯 转换路径为<font color=red>**绝对路径**</font> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> **将用户输入的路径（文件或文件夹）转换为“绝对路径（不含软链接）”**，并去掉多余的双引号或末尾斜杠，增强兼容性。

```shell
abs_path() {
  local p="$1"
  [[ -z "$p" ]] && return 1
  p="${p//\"/}"                                                         # ✅ 移除双引号，防止参数传递误差
  [[ "$p" != "/" ]] && p="${p%/}"     												          # ✅ 去除末尾斜杠，标准化路径形式

  if [[ -d "$p" ]]; then
    (cd "$p" 2>/dev/null && pwd -P)                                     # ✅ 子 shell，避免污染当前目录
  elif [[ -f "$p" ]]; then
    (cd "${p:h}" 2>/dev/null && printf "%s/%s\n" "$(pwd -P)" "${p:t}")  # ✅ 精准拼接
  else
    return 1
  fi
}
```

### <span id="jobs-toc-heading-41" data-jobs-toc="v2">🎯 识别**`.xcodeproj`**  <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
find_or_prompt_xcodeproj() {
  XCODEPROJ=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.xcodeproj" | head -n 1)

  if [[ -z "$XCODEPROJ" ]]; then
    error_echo "❌ 未找到 .xcodeproj 文件，请手动拖入"
    read "?🔍 拖入 .xcodeproj 文件后回车：" XCODEPROJ
    XCODEPROJ=${XCODEPROJ%\"}
    XCODEPROJ=${XCODEPROJ#\"}
  fi

  PBXPROJ_PATH="$XCODEPROJ/project.pbxproj"
  if [[ ! -f "$PBXPROJ_PATH" ]]; then
    error_echo "❌ project.pbxproj 文件无效，脚本终止"
    exit 1
  fi
  info_echo "📂 当前工程：$XCODEPROJ"
}
```

### <span id="jobs-toc-heading-42" data-jobs-toc="v2">🎯 [**Android**](https://www.android.com/) 模拟器🤖<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* 检查模拟器是否存在；启动一个可用的；设置并返回 `$device_id`

  ```shell
  get_or_start_android_emulator() {
    # ✅ 全局声明变量 device_id
    typeset -g device_id
  
    device_id=$(eval "${flutter_cmd[@]}" devices | grep -iE 'emulator|android' | awk -F '•' '{print $2}' | head -n1 | xargs)
  
    if [[ -n "$device_id" ]]; then
      success_echo "📱 已找到 Android 模拟器设备：$device_id"
      return 0
    fi
  
    warn_echo "⚠️ 未找到 Android 模拟器，尝试自动启动..."
  
    if ! command -v emulator &>/dev/null; then
      error_echo "❌ 未找到 emulator 命令，请检查 ANDROID_HOME 设置"
      return 1
    fi
  
    local avd_name
    avd_name=$(avdmanager list avd | grep "Name:" | head -n1 | awk -F': ' '{print $2}' | xargs)
  
    if [[ -z "$avd_name" ]]; then
      error_echo "❌ 没有可用的 AVD，请先创建模拟器"
      echo "你可以运行：avdmanager create avd -n your_avd_name -k \"system-images;android-30;google_apis;x86_64\""
      return 1
    fi
  
    note_echo "🚀 启动模拟器：$avd_name"
    nohup emulator -avd "$avd_name" >/dev/null 2>&1 &
  
    local timeout=60
    while [[ $timeout -gt 0 ]]; do
      device_id=$(eval "${flutter_cmd[@]}" devices | grep -iE 'emulator|android' | awk -F '•' '{print $2}' | head -n1 | xargs)
      if [[ -n "$device_id" ]]; then
        success_echo "✅ 模拟器启动成功：$device_id"
        return 0
      fi
      sleep 2
      ((timeout-=2))
    done
  
    error_echo "❌ 模拟器启动超时（60秒）"
    return 1
  }
  ```

* ```shell
  start_android_emulator() {
    if adb devices | grep -q "device$"; then
      success_echo "✅ 已检测到设备或模拟器"
      return
    fi
    warm_echo "🖥️ 当前无模拟器运行，准备启动 AVD..."
    if ! command -v fzf &>/dev/null; then
      error_echo "❌ 未安装 fzf，请先安装：brew install fzf"
      exit 1
    fi
    avds=($("$ANDROID_HOME/emulator/emulator" -list-avds))
    if [[ ${#avds[@]} -eq 0 ]]; then
      error_echo "❌ 未找到任何 AVD，请先使用 avdmanager 创建模拟器"
      exit 1
    fi
    selected_avd=$(printf "%s\n" "${avds[@]}" | fzf --prompt="📱 选择要启动的模拟器：")
    if [[ -z "$selected_avd" ]]; then
      error_echo "❌ 未选择 AVD，已取消"
      exit 1
    fi
    highlight_echo "🚀 启动模拟器：$selected_avd ..."
    nohup "$ANDROID_HOME/emulator/emulator" -avd "$selected_avd" >/dev/null 2>&1 &
    info_echo "⏳ 等待模拟器启动中，请稍候..."
    for i in {1..30}; do
      if adb devices | grep -q "device$"; then
        success_echo "✅ 模拟器已就绪"
        return
      fi
      sleep 2
    done
    error_echo "❌ 模拟器启动失败，请手动检查 AVD 是否可用"
    exit 1
  }
  ```

### 3.3、🎯 **iOS** 模拟器📱<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 1、（检测）防止假后台  <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 如果是假后台：`xcrun simctl list devices | grep -E "Booted"` 控制台什么也不输出
> 如果真后台：`xcrun simctl list devices | grep -E "Booted"` 控制台会有输出

```shell
fix_fake_simulator() {
  warn_echo "🕵️ 检测模拟器是否处于假后台..."
  booted_check=$(xcrun simctl list devices | grep "(Booted)") # ✅ 使用 simctl 检查当前是否有已启动（Booted）状态的模拟器设备
  simulator_running=$(pgrep -f Simulator)                     # ✅ 检查是否存在 Simulator 应用的后台进程（即进程存在但可能界面未显示）
  
  # 🧠 如果没有任何 Booted 状态的设备，但检测到 Simulator 进程，说明是“假后台”
  if [[ -z "$booted_check" && -n "$simulator_running" ]]; then
    error_echo "❗️ 模拟器处于假后台状态，正在强制关闭..."
    xcrun simctl shutdown all >/dev/null 2>&1                 # 🧹 使用 simctl 关闭所有模拟器实例（防止残留）
    osascript -e 'quit app "Simulator"' >/dev/null 2>&1       # 🧼 使用 AppleScript 关闭 Simulator 应用（用于 GUI 层面的强制退出）
    pkill -f Simulator >/dev/null 2>&1                        # 🧯 最后保险措施：通过进程名强制终止 Simulator 进程
    success_echo "✅ 已强制关闭假后台模拟器。"
  else
    success_echo "✅ 模拟器状态正常，无需关闭。"
  fi
}
```

#### <span id="jobs-toc-heading-43" data-jobs-toc="v2">2、📱关闭 **iOS** 模拟器 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
xcrun simctl shutdown all
# 检查是否有iOS模拟器进程存在(存在即杀进程)
if pgrep -f 'Simulator' >/dev/null; then
    # 如果有，则会杀死所有包含"Simulator"字符串的进程
    pkill -f 'Simulator'
    echo "iOS模拟器进程已终止"
else
    echo "没有找到iOS模拟器进程"
fi
```

#### <span id="jobs-toc-heading-44" data-jobs-toc="v2">3、📱打开 **iOS** 模拟器 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
open -a Simulator
```

### <span id="jobs-toc-heading-45" data-jobs-toc="v2">3.4、🎯 执行耗时 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
START_TIME=$(date +%s) # 放在最前面
# 耗时操作...

print_duration() {
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  info "⚙️ 脚本总耗时：${DURATION}s"
}

print_duration
```

### <span id="jobs-toc-heading-46" data-jobs-toc="v2">3.5、🎯 写文件 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

>* **追加写入**
>
>   * 单行文件
>
>     ```shell
>     echo 'export PATH="$HOME/.pub-cache/bin:$PATH"' >> ~/.zshrc
>     ```
>
>   * 多行文件
>
>     ```shell
>     cat <<EOF >> ~/.zshrc
>                                          
>     # >>> Flutter 环境变量 >>>
>     export PATH="\$HOME/.pub-cache/bin:\$PATH"
>                                          
>     EOF
>     ```
>
>* **覆盖写入**
>
>   * 单行文件
>
>     ```shell
>     echo 'export PATH="$HOME/.pub-cache/bin:$PATH"' > ~/.zshrc
>     ```
>
>   * 多行文件
>
>     ```shell
>      cat <<EOF > ~/.zshrc
>                                                                           
>      # >>> Flutter 环境变量 >>>
>      export PATH="\$HOME/.pub-cache/bin:\$PATH"
>                                                                           
>      EOF
>     ```
>  

#### <span id="jobs-toc-heading-47" data-jobs-toc="v2">🎯 1、单行写文件（避免重复写入）<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
inject_shellenv_block() {
  local profile_file="$1"   # 参数1：要写入的配置文件，例如 "$HOME/.zprofile"
  local id="$2"             # 参数2：环境变量块 ID，例如 "homebrew_env"
  local shellenv="$3"       # 参数3：实际写入内容，例如 'eval "$($(brew --prefix)/bin/brew shellenv)"'
  local header="# >>> ${id} 环境变量 >>>"
  local footer="# <<< ${id} 环境变量 <<<"

  if [[ -z "$profile_file" || -z "$id" || -z "$shellenv" ]]; then
    error_echo "❌ 缺少参数：inject_shellenv_block <profile_file> <id> <shellenv>"
    return 1
  fi

  [[ -f "$profile_file" ]] || touch "$profile_file"

  if grep -Fq "$header" "$profile_file" || grep -Fq "$shellenv" "$profile_file"; then
    info_echo "📌 已存在环境变量：$id"
  else
    {
      echo ""
      echo "$header"
      echo "$shellenv"
      echo "$footer"
    } >> "$profile_file"
    success_echo "✅ 已写入：$profile_file -> $id"
  fi

  eval "$shellenv"
  success_echo "🟢 shellenv 已在当前终端生效：$id"
}
```

#### <span id="jobs-toc-heading-48" data-jobs-toc="v2">🎯 2、多行写文件（避免重复写入）<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
append_env_block() {
  local file="$1"           # 参数1：要写入的文件路径，例如 ~/.zshrc
  shift                     # 去掉第一个参数
  local block=("$@")        # 参数2+：多行内容数组

  # 提取 block 中第一行作为 header（用作唯一标识）
  local header="${block[0]}"
  if [[ -z "$header" ]]; then
    error_echo "❌ 环境变量块不能为空"
    return 1
  fi

  # 如果文件中已包含该 header，跳过写入
  if grep -Fq "$header" "$file" 2>/dev/null; then
    info_echo "📌 已存在：$header"
  else
    echo "" >> "$file"
    for line in "${block[@]}"; do
      echo "$line" >> "$file"
    done
    success_echo "✅ 已写入到 $file：$header"
  fi
}
```

#### <span id="jobs-toc-heading-49" data-jobs-toc="v2">🎯 3、函数将内容插入到指定的文件顶部 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
insert_block_to_profile_top() {
  local marker="$1"
  shift
  local block=("${@}")

  for line in "${block[@]}"; do
    if grep -Fq "$line" "$PROFILE_FILE"; then
      info_echo "已存在配置：$line"
      return
    fi
  done

  local original_content="$(< "$PROFILE_FILE")"
  local block_text="${(j:\n:)block}"
  echo -e "${block_text}\n\n${original_content}" > "$PROFILE_FILE"
  success_echo "✅ 写入成功：$marker"
}
```

> ```shell
> marker="# 🧪配置 KK"
> block=(
>   "$marker"
>   'export KK=1234'
> )
> insert_block_to_profile_top "$marker" "${block[@]}"
> ```

### <span id="jobs-toc-heading-50" data-jobs-toc="v2">3.6、🎯 环境变量 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| shell 类型 | 默认配置文件      | macOS 默认用哪个❓                                            |
| ---------- | ----------------- | ------------------------------------------------------------ |
| `bash`     | `~/.bash_profile` | **macOS Catalina（10.15）** 以前                             |
| `zsh`      | `~/.zprofile`     | ✅ **macOS Catalina（10.15）** 以后<font color=red>默认</font> |

```shell
# 写 Homebrew 的环境变量（区分架构）
arch=$(get_cpu_arch)

if [[ "$arch" == "arm64" ]]; then
  inject_shellenv_block "$HOME/.zprofile" "homebrew_env" 'eval "$($(brew --prefix)/bin/brew shellenv)"'
else
  inject_shellenv_block "$HOME/.bash_profile" "homebrew_env" 'eval "$($(brew --prefix)/bin/brew shellenv)"'
fi
```

#### <span id="jobs-toc-heading-51" data-jobs-toc="v2">🎯 1、写单行的环境变量 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
inject_shellenv_block "$HOME/.zprofile" "homebrew_env" 'eval "$($(brew --prefix)/bin/brew shellenv)"'
```

#### <span id="jobs-toc-heading-52" data-jobs-toc="v2">🎯 2、写多行的环境变量 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
append_env_block "$HOME/.zshrc" \
  'export PATH="$HOME/fvm/default/bin:$PATH"' \
  'export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn'
```

#### <span id="jobs-toc-heading-53" data-jobs-toc="v2">🎯 3、🌐 环境变量格式化 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

<font color=red>把环境变量 `$PATH` 中的路径项按冒号（`:`）拆分，并逐行打印每一项路径</font>

> `IFS=':'`：设置字段分隔符（Internal Field Separator）为 `:`；
>
> `read -ra PATH_PARTS`：
>
> - `-r`：表示不让反斜杠转义；
> - `-a PATH_PARTS`：把读取的结果保存到数组 `PATH_PARTS` 中；
>
> `<<< "$PATH"`：将 `$PATH` 的内容作为输入传给 `read`；

```shell
IFS=':' read -ra PATH_PARTS <<< "$PATH" # 等价于把 $PATH 按 : 拆成数组。
for p in "${PATH_PARTS[@]}"; do # 遍历数组 PATH_PARTS 中的每一项；
    echo "  $p" # 并在每一项前加两个空格打印出来。
done
```

```shell
$(brew --prefix)/bin:$(brew --prefix)/bin:$SYSTEM_USR_DIR/bin:$SYSTEM_BIN_DIR 

=>

$(brew --prefix)/bin
$(brew --prefix)/bin
$SYSTEM_USR_DIR/bin
$SYSTEM_BIN_DIR
```

### <span id="jobs-toc-heading-54" data-jobs-toc="v2">3.7、🎯 判断芯片架构（`ARM64` / `x86_64`）<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
get_cpu_arch() {
  [[ $(uname -m) == "arm64" ]] && echo "arm64" || echo "x86_64"
}
```

### <span id="jobs-toc-heading-55" data-jobs-toc="v2">3.8、🎯 [**SDKMAN**](https://sdkman.io/) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> 暂不把 **SDKMAN** 写进通用脚本基座。它更偏交互式 Java 生态管理，和 `Homebrew + jenv` 的职责有重叠。需要独立封装时，再按“安装、环境注入、版本切换、卸载回滚”四段式补充。

### <span id="jobs-toc-heading-56" data-jobs-toc="v2">3.9、🎯 💎[**Rubygems**](https://rubygems.org/) 自检安装 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-57" data-jobs-toc="v2">🎯1、自检安装 💎**`Gem.CocoaPods`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_cocoaPods() {
  if ! command -v gem &>/dev/null; then
    error_echo "❌ 未检测到 Ruby gem，请先安装 Ruby 或使用 Homebrew 安装方式"
    return 1
  fi

  if ! command -v pod &>/dev/null; then
    info_echo "📦 未检测到 CocoaPods，正在通过 gem 安装..."
    sudo gem install cocoapods || { error_echo "❌ CocoaPods 安装失败（gem）"; exit 1; }
    success_echo "✅ CocoaPods 安装成功（gem）"
  else
    info_echo "🔄 CocoaPods 已安装。是否通过 gem 升级？"
    if ask_run "执行 sudo gem update cocoapods？"; then
      sudo gem update cocoapods || { error_echo "❌ CocoaPods 升级失败（gem）"; exit 1; }
      success_echo "✅ CocoaPods 升级完成（gem）"
    else
      note_echo "⏭️ 已选择跳过 CocoaPods gem 升级"
    fi
  fi

  info_echo "🔧 初始化 CocoaPods 仓库（pod setup）..."
  pod setup || warn_echo "⚠️ pod setup 执行失败，可能已初始化"

  pod --version | tee -a "$LOG_FILE"
}
```

#### <span id="jobs-toc-heading-58" data-jobs-toc="v2">🎯2、自检安装 💎**`Gem.bundler`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_bundler() {
  if ! command -v gem &>/dev/null; then
    error_echo "❌ 未检测到 Ruby gem，请先安装 Ruby 或使用 rbenv / Homebrew 安装方式"
    return 1
  fi

  if ! gem list -i bundler &>/dev/null; then
    info_echo "📦 未检测到 Bundler，正在通过 gem 安装..."
    sudo gem install bundler || { error_echo "❌ Bundler 安装失败（gem）"; exit 1; }
    success_echo "✅ Bundler 安装成功（gem）"
  else
    info_echo "🔄 Bundler 已安装。是否通过 gem 升级？"
    if ask_run "执行 sudo gem update bundler？"; then
      sudo gem update bundler || { error_echo "❌ Bundler 升级失败（gem）"; exit 1; }
      success_echo "✅ Bundler 升级完成（gem）"
    else
      note_echo "⏭️ 已选择跳过 Bundler gem 升级"
    fi
  fi

  info_echo "📦 当前 Bundler 版本："
  bundler -v | tee -a "$LOG_FILE"
}
```

### <span id="jobs-toc-heading-59" data-jobs-toc="v2">3.10、🎯 🍺**`Homebrew`** 自检安装 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-60" data-jobs-toc="v2">🎯 1、自检安装 🍺**`Homebrew`** （自动架构判断，包含环境注入）<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_homebrew() {
  local arch="$(get_cpu_arch)"                   # 获取当前架构（arm64 或 x86_64）
  local shell_path="${SHELL##*/}"                # 获取当前 shell 名称（如 zsh、bash）
  local profile_file=""
  local brew_bin=""
  local shellenv_cmd=""

  if ! command -v brew &>/dev/null; then
    warn_echo "🧩 未检测到 Homebrew，正在安装中...（架构：$arch）"

    if [[ "$arch" == "arm64" ]]; then
      # Apple Silicon 原生 Homebrew（$(brew --prefix)）
      $SYSTEM_BIN_DIR/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        error_echo "❌ Homebrew 安装失败（arm64）"
        exit 1
      }
      brew_bin="$(brew --prefix)/bin/brew"
    else
      # Intel 或在 Apple Silicon 下装一份 Intel 版 Homebrew（需要 Rosetta）
      arch -x86_64 $SYSTEM_BIN_DIR/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        error_echo "❌ Homebrew 安装失败（x86_64）"
        exit 1
      }
      brew_bin="$(brew --prefix)/bin/brew"
    fi

    success_echo "✅ Homebrew 安装成功"

    # ==== 注入 shellenv 到对应配置文件（自动生效） ====
    shellenv_cmd="eval \"\$(${brew_bin} shellenv)\""
    case "$shell_path" in
      zsh)   profile_file="$HOME/.zprofile" ;;
      bash)  profile_file="$HOME/.bash_profile" ;;
      *)     profile_file="$HOME/.profile" ;;
    esac
    inject_shellenv_block "$profile_file" "homebrew_env" "$shellenv_cmd"

    # 立刻对当前会话生效（不等重开终端）
    eval "$(${brew_bin} shellenv)"

  else
    info_echo "🔄 Homebrew 已安装。是否执行更新？"
    echo "👉 直接按 [Enter]：跳过更新"
    echo "👉 输入任意字符后回车：执行 brew update && brew upgrade && brew cleanup && brew doctor && brew -v"
    # 仅当“输入任意字符”时执行；直接回车跳过
    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在更新 Homebrew..."
      # 分步执行，任一步失败立即报错退出，方便定位
      brew update       || { error_echo "❌ brew update 失败"; return 1; }
      brew upgrade      || { error_echo "❌ brew upgrade 失败"; return 1; }
      brew cleanup      || { error_echo "❌ brew cleanup 失败"; return 1; }
      brew doctor       || { warn_echo  "⚠️  brew doctor 有警告/错误，请按提示处理"; }
      brew -v           || { warn_echo  "⚠️  打印 brew 版本失败（可忽略）"; }
      success_echo "✅ Homebrew 已更新"
    else
      note_echo "⏭️ 已选择跳过 Homebrew 更新"
    fi
  fi
}
```

```shell
# 写 Homebrew 的环境变量（区分架构）
arch=$(get_cpu_arch)

if [[ "$arch" == "arm64" ]]; then
  inject_shellenv_block "$HOME/.zprofile" "homebrew_env" 'eval "$($(brew --prefix)/bin/brew shellenv)"'
else
  inject_shellenv_block "$HOME/.bash_profile" "homebrew_env" 'eval "$($(brew --prefix)/bin/brew shellenv)"'
fi
```

#### <span id="jobs-toc-heading-61" data-jobs-toc="v2">🎯 2、自检安装 🍺**`Homebrew.fzf`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_fzf() {
  if ! command -v fzf &>/dev/null; then
    note_echo "📦 未检测到 fzf，正在通过 Homebrew 安装..."
    brew install fzf || { error_echo "❌ fzf 安装失败"; exit 1; }
    success_echo "✅ fzf 安装成功"
  else
    info_echo "🔄 fzf 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade fzf && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 fzf..."
      brew upgrade fzf       || { error_echo "❌ fzf 升级失败"; return 1; }
      brew cleanup           || { warn_echo  "⚠️  brew cleanup 执行时有警告"; }
      success_echo "✅ fzf 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 fzf 升级"
    fi
  fi
}
```

* 使用**`fzf`** 

  ```shell
  fzf_select() {
    echo -e "$@" | tr ' ' '\n' | fzf --prompt="请选择安装方式：" --height=10 --border
  }
  ```

  > 基本用法👇
  >
  > ```shell
  > result=$(fzf_select "通过 Homebrew 安装" "通过 Git 安装" "取消")
  > ```

#### <span id="jobs-toc-heading-62" data-jobs-toc="v2">🎯 3、自检安装 🍺**`Homebrew.jq`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_jq() {
  if ! command -v jq &>/dev/null; then
    note_echo "📦 未检测到 jq，正在通过 Homebrew 安装..."
    brew install jq || { error_echo "❌ jq 安装失败"; exit 1; }
    success_echo "✅ jq 安装成功"
  else
    info_echo "🔄 jq 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade jq && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 jq..."
      brew upgrade jq         || { error_echo "❌ jq 升级失败"; return 1; }
      brew cleanup            || { warn_echo "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ jq 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 jq 升级"
    fi
  fi
}
```

#### <span id="jobs-toc-heading-63" data-jobs-toc="v2">🎯 4、自检安装 🍺**`Homebrew.dart`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_dart() {
  if ! command -v dart &>/dev/null; then
    note_echo "📦 未检测到 dart，正在通过 Homebrew 安装..."
    brew tap dart-lang/dart
    brew install dart || { error_echo "❌ dart 安装失败"; exit 1; }
    success_echo "✅ dart 安装成功"
  else
    info_echo "🔄 dart 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade dart && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 dart..."
      brew upgrade dart       || { error_echo "❌ dart 升级失败"; return 1; }
      brew cleanup            || { warn_echo "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ dart 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 dart 升级"
    fi
  fi
}
```

#### <span id="jobs-toc-heading-64" data-jobs-toc="v2">🎯 5、自检安装 🍺**`Homebrew.coreutils`**（提供 `realpath`）<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_coreutils() {
  if ! command -v realpath >/dev/null; then
    note_echo "📦 未检测到 coreutils（提供 realpath），正在通过 Homebrew 安装..."
    brew install coreutils || { error_echo "❌ coreutils 安装失败"; exit 1; }
    success_echo "✅ coreutils 安装成功"
  else
    info_echo "🔄 coreutils 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade coreutils"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 coreutils..."
      brew upgrade coreutils || { error_echo "❌ coreutils 升级失败"; return 1; }
      brew cleanup           || { warn_echo "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ coreutils 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 coreutils 升级"
    fi
  fi

  # 确保 coreutils 提供的命令优先级最高
  export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
}
```

#### <span id="jobs-toc-heading-65" data-jobs-toc="v2">🎯 6、自检安装 🍺**`Homebrew.bc`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_bc() {
  if ! command -v bc &>/dev/null; then
    info_echo "📦 未检测到 bc，正在通过 Homebrew 安装..."
    brew install bc || { error_echo "❌ bc 安装失败"; exit 1; }
    success_echo "✅ bc 安装成功"
  else
    info_echo "🔄 bc 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade bc && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 bc..."
      brew upgrade bc        || { error_echo "❌ bc 升级失败"; return 1; }
      brew cleanup           || { warn_echo "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ bc 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 bc 升级"
    fi
  fi
}
```

#### <span id="jobs-toc-heading-66" data-jobs-toc="v2">🎯 7、自检安装 🍺**`Homebrew.Gradle`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_gradle() {
  if ! command -v gradle &>/dev/null; then
    note_echo "📦 未检测到 Gradle，正在通过 Homebrew 安装..."
    brew install gradle || { error_echo "❌ Gradle 安装失败"; exit 1; }
    success_echo "✅ Gradle 安装成功"
  else
    info_echo "🔄 Gradle 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade gradle && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 Gradle..."
      brew upgrade gradle    || { error_echo "❌ Gradle 升级失败"; return 1; }
      brew cleanup           || { warn_echo "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ Gradle 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 Gradle 升级"
    fi
  fi

  # 🔍 输出当前版本（带版本号高亮）
  gradle_ver=$(gradle --version 2>/dev/null | grep Gradle | awk '{print $2}')
  highlight_echo "📌 当前 Gradle 版本：$gradle_ver"
}
```

#### <span id="jobs-toc-heading-67" data-jobs-toc="v2">🎯 8、自检安装 🍺**`Homebrew.jenv`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> [**Flutter**](https://flutter.dev/).[**Android**](https://www.android.com/)的运行和打包需要一个[**Java**](https://www.java.com/zh-CN/)环境（有必要和系统[**Java**](https://www.java.com/zh-CN/)环境进行区分开）
>
> [**jenv**](https://github.com/jenv/jenv) **不会自己安装 Java**，你需要手动或用[**Homebrew**](https://brew.sh/)安装好 **JDK**，然后让 [**jenv**](https://github.com/jenv/jenv) **识别**它。
>
> [**Java**](https://www.java.com/zh-CN/)来源：官方Java、[**OpenJDK**](https://openjdk.org/)、[**temurin**](https://adoptium.net/zh-CN/temurin/releases)

```shell
install_rbenv() {
  if ! command -v rbenv &>/dev/null; then
    info_echo "📦 未检测到 rbenv，正在通过 Homebrew 安装..."
    brew install rbenv ruby-build || { error_echo "❌ rbenv 安装失败"; exit 1; }
    success_echo "✅ rbenv 安装成功"

    # ✅ 仅在首次安装后，写入 rbenv 环境变量到对应 shell 配置文件
    local shellrc
    if [[ -n "$ZSH_VERSION" || "${SHELL##*/}" == "zsh" ]]; then
      shellrc="$HOME/.zshrc"
    else
      shellrc="$HOME/.bash_profile"
    fi

    # 确保文件存在，避免 grep 报错
    [[ -f "$shellrc" ]] || touch "$shellrc"

    if ! grep -qF '# >>> rbenv 初始化 >>>' "$shellrc"; then
      info_echo "📎 正在写入 rbenv 初始化配置到：$shellrc"
      {
        echo ''
        echo '# >>> rbenv 初始化 >>>'
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"'
        echo 'eval "$(rbenv init -)"'
        echo '# <<< rbenv 初始化 <<<'
      } >> "$shellrc"
      success_echo "✅ rbenv 初始化配置已写入 $shellrc"
    else
      info_echo "📌 rbenv 初始化配置已存在于 $shellrc"
    fi

  else
    info_echo "🔄 rbenv 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade rbenv ruby-build && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 rbenv..."
      brew upgrade rbenv ruby-build || { error_echo "❌ rbenv 升级失败"; return 1; }
      brew cleanup                  || { warn_echo  "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ rbenv 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 rbenv 升级"
    fi
  fi

  # ✅ 当前会话立即生效
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  success_echo "🟢 rbenv 初始化完成并在当前终端生效"
}
```

> * 查 `.jenv/versions` 的链接来源
>
>   ```shell
>   jenv versions --bare --verbose
>   ```
>
>   ```shell
>   ls -l ~/.jenv/versions/
>   ```
>
>   ```shell
>   list_jenv_java_paths() {
>     echo "📦 当前 jenv 添加的 JDK 路径映射："
>     for v in ~/.jenv/versions/*; do
>       name=$(basename "$v")
>       target=$(readlink "$v")
>       echo "  $name  ->  $target"
>     done
>   }
>   ```
>
> * 添加所有 brew 安装的 Java 到 jenv管理
>
>   ```shell
>   add_all_brew_java_to_jenv() {
>     echo "🧭 正在检测架构并添加 brew 安装的 Java 版本到 jenv..."
>   
>     if [[ "$(uname -m)" == "arm64" ]]; then
>       base_path="$(brew --prefix)/opt"
>       echo "🐹 当前为 Apple Silicon (ARM64)"
>     else
>       base_path="$(brew --prefix)/opt"
>       echo "🧠 当前为 Intel x86_64 架构"
>     fi
>   
>     found=false
>   
>     for path in "$base_path"/openjdk*/libexec/openjdk.jdk/Contents/Home; do
>       if [[ -d "$path" ]]; then
>         echo "➕ 添加到 jenv: $path"
>         jenv add "$path"
>         found=true
>       fi
>     done
>   
>     if [[ "$found" == false ]]; then
>       echo "⚠️ 未找到任何 openjdk 安装路径，请先通过 brew 安装 openjdk"
>     else
>       jenv rehash
>       echo "✅ 已添加并刷新 jenv"
>     fi
>   }
>   ```
>
>   ```shell
>   jenv_add() {
>   	for v in 8 11 17 21; do
>       path="$(brew --prefix)/opt/openjdk@${v}/libexec/openjdk.jdk/Contents/Home"
>       [[ -x "$path/bin/java" ]] && jenv add "$path"
>     done
>   
>     jenv rehash # 重新生成 shims，使得你添加或切换的 Java 版本能被系统识别并生效。
>   }
>   ```
>
>   ```shell
>   jenv versions --bare --verbose # 用这里的结果
>   
>   jenv global openjdk64-24.0.2   # 全局（所有项目默认）
>   jenv local openjdk64-21.0.8    # 当前目录（项目级）
>   java --version                 # 验证
>   ```
>
> * 批量移除 jenv管理的 所有 Java 版本
>
>   ```shell
>   jenv_remove_all_java() {
>     echo "🧹 开始移除所有通过 Homebrew 安装并注册到 jenv 的 Java 版本..."
>                               
>     if [[ "$(uname -m)" == "arm64" ]]; then
>       base_path="$(brew --prefix)/opt"
>     else
>       base_path="$(brew --prefix)/opt"
>     fi
>                               
>     found=false
>                               
>     for path in "$base_path"/openjdk*/libexec/openjdk.jdk/Contents/Home; do
>       if [[ -d "$path" ]]; then
>         echo "❌ 正在移除：$path"
>         jenv remove "$path"
>         found=true
>       fi
>     done
>                               
>     if [[ "$found" == false ]]; then
>       echo "⚠️ 未检测到任何已注册 Java 安装路径"
>     else
>       jenv rehash
>       echo "✅ 已完成全部移除"
>     fi
>   }
>   ```

#### <span id="jobs-toc-heading-68" data-jobs-toc="v2">🎯 9、自检安装 🍺**`Homebrew.cocoapods`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
install_cocoapods() {
  if ! command -v pod &>/dev/null; then
    info_echo "📦 未检测到 CocoaPods，正在通过 Homebrew 安装..."
    brew install cocoapods || { error_echo "❌ CocoaPods 安装失败"; exit 1; }
    success_echo "✅ CocoaPods 安装成功"
  else
    info_echo "🔄 CocoaPods 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade cocoapods && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 CocoaPods..."
      brew upgrade cocoapods || { error_echo "❌ CocoaPods 升级失败"; return 1; }
      brew cleanup           || { warn_echo "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ CocoaPods 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 CocoaPods 升级"
    fi
  fi

  # ✅ 打印版本并写入日志
  pod --version | tee -a "${LOG_FILE:-$TMPDIR/install.log}"
}
```

#### <span id="jobs-toc-heading-69" data-jobs-toc="v2">🎯 10、自检安装 🍺**`Homebrew.Perl`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
ensure_perl_installed() {
  if ! brew list perl &>/dev/null; then
    warn_echo "📦 未检测到 Homebrew 安装的 Perl，正在安装..."
    brew install perl || {
      error_echo "❌ Perl 安装失败，请检查网络或更换镜像"
      exit 1
    }
    success_echo "✅ Perl 安装成功"
  else
    info_echo "🔄 检测到 Perl。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade perl && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 Perl..."
      brew upgrade perl      || { error_echo "❌ Perl 升级失败"; return 1; }
      brew cleanup           || { warn_echo "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ Perl 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 Perl 升级"
    fi
  fi

  # 🔍 打印版本并写入日志
  perl -v | head -n 2 | tee -a "${LOG_FILE:-$TMPDIR/install.log}"
}
```

#### <span id="jobs-toc-heading-70" data-jobs-toc="v2">🎯 11、自检安装 **`Rbenv`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> `rbenv` 是一个 **Ruby 版本管理工具**

```shell
install_rbenv() {
  if ! command -v rbenv &>/dev/null; then
    info_echo "📦 未检测到 rbenv，正在通过 Homebrew 安装..."
    brew install rbenv ruby-build || { error_echo "❌ rbenv 安装失败"; exit 1; }
    success_echo "✅ rbenv 安装成功"

    # ✅ 首次安装：写入环境变量到 shell 配置文件
    local shellrc
    if [[ -n "$ZSH_VERSION" || "${SHELL##*/}" == "zsh" ]]; then
      shellrc="$HOME/.zshrc"
    else
      shellrc="$HOME/.bash_profile"
    fi
    [[ -f "$shellrc" ]] || touch "$shellrc"

    if ! grep -qF '# >>> rbenv 初始化 >>>' "$shellrc"; then
      info_echo "📎 正在写入 rbenv 初始化配置到：$shellrc"
      {
        echo ''
        echo '# >>> rbenv 初始化 >>>'
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"'
        echo 'eval "$(rbenv init -)"'
        echo '# <<< rbenv 初始化 <<<'
      } >> "$shellrc"
      success_echo "✅ rbenv 初始化配置已写入 $shellrc"
    else
      info_echo "📌 rbenv 初始化配置已存在于 $shellrc"
    fi
  else
    info_echo "🔄 rbenv 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 brew upgrade rbenv ruby-build && brew cleanup"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 rbenv..."
      brew upgrade rbenv ruby-build || { error_echo "❌ rbenv 升级失败"; return 1; }
      brew cleanup                  || { warn_echo "⚠️ brew cleanup 执行时有警告"; }
      success_echo "✅ rbenv 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 rbenv 升级"
    fi
  fi

  # ✅ 当前会话立即生效
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  success_echo "🟢 rbenv 环境已初始化并在当前终端生效"
}

```

#### <span id="jobs-toc-heading-71" data-jobs-toc="v2">🎯 12、官方安装 **`Ruby`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
# 1. 克隆 rbenv 到本地
git clone https://github.com/rbenv/rbenv.git ~/.rbenv

# 2. 初始化 PATH 和 shell hook
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc

# 3. 加载到当前 shell 会话
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(~/.rbenv/bin/rbenv init -)"

# 4. 安装 ruby-build 插件（用来安装 Ruby）
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# 显示可安装的版本
rbenv install -l | grep -v - | tail -n 20

# 安装最新版（举例）
rbenv install 3.3.0

# 设置为全局默认
rbenv global 3.3.0

# 验证安装
ruby -v
```

### <span id="jobs-toc-heading-72" data-jobs-toc="v2">3.11、🎯 删除🍺[**Homebrew**](https://brew.sh/) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
# 1. 尝试 untap & 清理
brew untap homebrew/core || true
brew cleanup || true

# 2. 官方卸载脚本（HEAD 版）
$SYSTEM_BIN_DIR/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# 3. 手动删除常见路径（Intel 和 M 系）
sudo rm -rf $(brew --prefix)/Caskroom/
sudo rm -rf $(brew --prefix)/Frameworks/
sudo rm -rf $(brew --prefix)/Homebrew/
sudo rm -rf $(brew --prefix)/bin/
sudo rm -rf $(brew --prefix)/etc/
sudo rm -rf $(brew --prefix)/include/
sudo rm -rf $(brew --prefix)/lib/
sudo rm -rf $(brew --prefix)/opt/
sudo rm -rf $(brew --prefix)/sbin/
sudo rm -rf $(brew --prefix)/share/
sudo rm -rf $(brew --prefix)/var/
sudo rm -rf $(brew --prefix)/

# 4. 修复 fatal: Could not resolve HEAD 错误
brew_repo=$(brew --repo homebrew/core 2>/dev/null)
if [[ -n "$brew_repo" ]]; then
  sudo rm -rf "$brew_repo"
fi
```

### <span id="jobs-toc-heading-73" data-jobs-toc="v2">3.12、🎯自检安装 **`fvm`**（[**Dart**](https://dart.dev/)官方推荐） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> <font color=red>**安装`fvm`的大前提是预先安装`dart`环境 **</font>
>
> <font color=red>🍺[**Homebrew**](https://brew.sh/) 核心源中目前**没有**收录 [**Dart**](https://dart.dev/) 的 `fvm` 工具</font>

```shell
install_fvm() {
  if ! command -v fvm &>/dev/null; then
    note_echo "📦 未检测到 fvm，正在通过 dart pub global 安装..."
    dart pub global activate fvm || { error_echo "❌ fvm 安装失败"; exit 1; }
    success_echo "✅ fvm 安装成功"

    # ✅ 首次安装：写入并让当前会话立刻可用
    inject_shellenv_block "$HOME/.zshrc" "fvm_env" 'export PATH="$HOME/.pub-cache/bin:$PATH"'
  else
    info_echo "🔄 fvm 已安装。是否执行升级？"
    echo "👉 直接按 [Enter]：跳过升级"
    echo "👉 输入任意字符后回车：执行 dart pub global activate fvm（幂等升级）"

    local confirm
    IFS= read -r confirm
    if [[ -n "$confirm" ]]; then
      info_echo "⏳ 正在升级 fvm..."
      dart pub global activate fvm || { error_echo "❌ fvm 升级失败"; return 1; }
      success_echo "✅ fvm 已升级到最新版本"
    else
      note_echo "⏭️ 已选择跳过 fvm 升级"
    fi

    # 确保 PATH 中包含 pub-cache（若先前未写入过）
    export PATH="$HOME/.pub-cache/bin:$PATH"
  fi

  # 🔍 输出当前版本并写入日志
  fvm --version | tee -a "${LOG_FILE:-$TMPDIR/install.log}"
}

```

### <span id="jobs-toc-heading-74" data-jobs-toc="v2">3.13、🎯 设置**`Ruby`**镜像源（根据 IP 自动判断）<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
set_gem_source() {
  COUNTRY=$(curl -s https://ipinfo.io | jq -r '.country')
  if [[ "$COUNTRY" == "CN" ]]; then
    gem sources --remove https://rubygems.org/ 2>/dev/null
    gem sources --add https://gems.ruby-china.com/
    info "🇨🇳 使用 Ruby 中国镜像"
  else
    gem sources --remove https://gems.ruby-china.com/ 2>/dev/null
    gem sources --add https://rubygems.org/
    info "🌐 使用默认 Ruby 镜像"
  fi
  gem sources -l | tee -a "$LOG_FILE"
}
```

### <span id="jobs-toc-heading-75" data-jobs-toc="v2">3.14、🎯 镜像切换 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-76" data-jobs-toc="v2">1、[**CocoaPods**](https://cocoapods.org/) 镜像切换 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
switch_cocoapods_source() {
  local sources=(
    "清华源|https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git"
    "华为源|https://repo.huaweicloud.com/repository/CocoaPods/"
  )
  local selected_source url

  selected_source=$(printf "%s\n" "${sources[@]}" | fzf --prompt="🎯 选择 CocoaPods 镜像源：") || return 1
  url="${${selected_source}#*|}"

  info_echo "🧩 正在切换镜像源为: $url"
  pod repo remove trunk >/dev/null 2>&1 || true
  pod repo add trunk "$url"
  echo "$url" > "$CONFIG_FILE"
  success_echo "📦 已记住镜像源: $url"
}
```

#### <span id="jobs-toc-heading-77" data-jobs-toc="v2">2、[**Ruby**](https://www.ruby-lang.org/en/)  镜像切换 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
set_gem_source() {
  if is_in_china; then
    gem sources --remove https://rubygems.org/ 2>/dev/null
    gem sources --add https://gems.ruby-china.com/ 2>/dev/null
    note_echo "🇨🇳 当前在中国，已切换为 Ruby 中国镜像源"
  else
    gem sources --remove https://gems.ruby-china.com/ 2>/dev/null
    gem sources --add https://rubygems.org/ 2>/dev/null
    note_echo "🌐 当前不在中国，已切换为官方 Ruby 镜像源"
  fi

  info_echo "📦 当前 RubyGem 源列表："
  gem sources -l | tee -a "$LOG_FILE"
}
```

### <span id="jobs-toc-heading-78" data-jobs-toc="v2">3.15、🎯 检测本地[**Java**](https://www.java.com/zh-CN/)环境是否已经安装 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> **`command -v java`**：检查 `java` 命令是否存在于 `PATH` 中；
>
> **`>/dev/null 2>&1`**：忽略输出（标准输出和错误输出）；
>
> 如果存在，则执行 `then` 块，否则执行 `else`。
>
> **`java -version 2>&1 | head -n 1`**：获取 `java -version` 输出（通常是多行），`head -n 1`：只取第一行显示版本号。
>
> **`echo "JAVA_HOME" "${JAVA_HOME:-[未设置]}"`**：`${JAVA_HOME:-[未设置]}`：如果 `JAVA_HOME` 没有设置，就显示 `[未设置]`；

```shell
if command -v java >/dev/null 2>&1; then
    java -version 2>&1 | head -n 1
    echo "JAVA_HOME" "${JAVA_HOME:-[未设置]}"
else
    echo "未安装 Java"
fi 
```

### <span id="jobs-toc-heading-79" data-jobs-toc="v2">3.16、🎯 [**Flutter**](https://flutter.dev/) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-80" data-jobs-toc="v2">🎯 1、判断当前目录是否为[**Flutter**](https://flutter.dev/)项目根目录 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
is_flutter_project_root() {
  [[ -f "$1/pubspec.yaml" && -d "$1/lib" ]]
}
```

#### <span id="jobs-toc-heading-81" data-jobs-toc="v2">🎯 2、获取 [**Flutter**](https://flutter.dev/)项目名称  <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
_get_flutter_project_name() {
  local root="$1"
  if is_flutter_project_root "$root"; then
    flutter_project_name=$(grep -m1 '^name:' "$root/pubspec.yaml" | awk '{print $2}')
    [[ -z "$flutter_project_name" ]] && flutter_project_name="Flutter项目"
  else
    flutter_project_name="Flutter项目"
  fi
}
```

#### <span id="jobs-toc-heading-82" data-jobs-toc="v2">🎯 3、判断[**Flutter**](https://flutter.dev/)文件是否是入口🚪<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> <font color=red>**支持的**`main`**函数写法**</font>
> `void main() {}`// 标准同步入口
> `void main() => runApp();`// 箭头函数写法
> `Future<void> main() async {}`// 异步入口函数
> `Future<void> main() => runApp(); `// 异步箭头写法
> `main() {}`// 无返回值声明的入口
> `main() async {}`// 无返回值 + 异步入口

```shell
_is_dart_entry_file() {
  local f="$1"
  local abs=$(abs_path "$f") || return 1
  [[ $abs == *.dart ]] || return 1

  # ✅ 支持 main() {...} 和 main() => ... 写法
  if grep -Ev '^\s*//' "$abs" | grep -Eq '\b(Future\s*<\s*void\s*>|void)?\s*main\s*\(\s*\)\s*(async\s*)?(\{|=>)' ; then
    return 0
  fi
  return 1
}
```

```shell
detect_entry() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
  SCRIPT_PATH="${SCRIPT_DIR}/$(basename -- "$0")"

  while true; do
    warn_echo "📂 请拖入 Flutter 项目根目录或 Dart 单文件路径："
    read -r user_input
    user_input="${user_input//\"/}"
    user_input="${user_input%/}"

    if [[ -z "$user_input" ]]; then
      if is_flutter_project_root "$SCRIPT_DIR"; then
        flutter_root=$(abs_path "$SCRIPT_DIR")
        entry_file="$flutter_root/lib/main.dart"
        highlight_echo "🎯 检测到脚本所在目录即 Flutter 根目录，自动使用。"
        break
      else
        error_echo "❌ 当前目录不是 Flutter 项目根目录，请重新拖入。"
        continue
      fi
    fi

    if [[ -d "$user_input" ]]; then
      if is_flutter_project_root "$user_input"; then
        flutter_root=$(abs_path "$user_input")
        entry_file="$flutter_root/lib/main.dart"
        break
      fi
    elif [[ -f "$user_input" ]]; then
      if is_dart_entry_file "$user_input"; then
        entry_file=$(abs_path "$user_input")
        flutter_root="${entry_file:h}"
        break
      fi
    fi

    error_echo "❌ 无效路径，请重新拖入 Flutter 根目录或 Dart 单文件。"
  done

  cd "$flutter_root" || { error_echo "无法进入项目目录：$flutter_root"; exit 1; }
  success_echo "✅ 项目路径：$flutter_root"
  success_echo "🎯 入口文件：$entry_file"
}
```

#### <span id="jobs-toc-heading-83" data-jobs-toc="v2">🎯 4、统一获取[**Flutter**](https://flutter.dev/)项目路径和[**Dart**](https://dart.dev/)入口文件路径 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> 兼容用户拖入目录、拖入[**Dart**](https://dart.dev/)文件、或直接回车（默认为当前目录为[**Flutter**](https://flutter.dev/)项目根目录）三种用法

```shell
resolve_flutter_root() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
  SCRIPT_PATH="${SCRIPT_DIR}/$(basename -- "$0")"

  debug_echo "🐞 SCRIPT_DIR: $SCRIPT_DIR"
  debug_echo "🐞 SCRIPT_PATH: $SCRIPT_PATH"
  debug_echo "🐞 当前工作目录：$(pwd -P)"

  flutter_root=""
  entry_file=""

  while true; do
    warn_echo "📂 请拖入 Flutter 项目根目录或 Dart 单文件路径："
    read -r user_input
    user_input="${user_input//\"/}"
    user_input=$(echo "$user_input" | xargs)
    debug_echo "🐞 用户输入路径：$user_input"

    # ✅ 用户直接回车：尝试脚本目录是否为 Flutter 项目
    if [[ -z "$user_input" ]]; then
      debug_echo "🐞 用户未输入路径，尝试使用 SCRIPT_DIR 检测"
      if is_flutter_project_root "$SCRIPT_DIR"; then
        flutter_root="$SCRIPT_DIR"
        entry_file="$flutter_root/lib/main.dart"
        highlight_echo "🎯 检测到脚本所在目录是 Flutter 根目录，自动使用"
        break
      else
        error_echo "❌ SCRIPT_DIR ($SCRIPT_DIR) 不是有效 Flutter 项目"
        continue
      fi
    fi

    # ✅ 用户拖入路径
    if [[ -d "$user_input" ]]; then
      debug_echo "🐞 检测到输入是目录"
      if is_flutter_project_root "$user_input"; then
        flutter_root="$user_input"
        entry_file="$flutter_root/lib/main.dart"
        highlight_echo "🎯 成功识别 Flutter 根目录：$flutter_root"
        break
      else
        error_echo "❌ 目录中未找到 pubspec.yaml 或 lib/：$user_input"
      fi
    elif [[ -f "$user_input" ]]; then
      debug_echo "🐞 检测到输入是文件"
      if grep -q 'main()' "$user_input"; then
        entry_file="$user_input"
        flutter_root="$(dirname "$user_input")"
        highlight_echo "🎯 成功识别 Dart 单文件：$entry_file"
        break
      else
        error_echo "❌ 文件不是 Dart 主程序：$user_input"
      fi
    else
      error_echo "❌ 输入路径无效：$user_input"
    fi
  done

  cd "$flutter_root" || {
    error_echo "❌ 无法进入项目目录：$flutter_root"
    exit 1
  }

  success_echo "✅ 项目路径：$flutter_root"
  success_echo "🎯 入口文件：$entry_file"
}
```

#### <span id="jobs-toc-heading-84" data-jobs-toc="v2">🎯 5、[**FVM**](https://fvm.app/) 检测 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
detect_flutter_cmd() {
  script_path="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
  local fvm_config_path="$script_path/.fvm/fvm_config.json"
  if command -v fvm >/dev/null 2>&1 && [[ -f "$fvm_config_path" ]]; then
    flutter_cmd=("fvm" "flutter")
    info_echo "🧩 检测到 FVM 项目，使用命令：fvm flutter"
  else
    flutter_cmd=("flutter")
    info_echo "📦 使用系统 Flutter 命令：flutter"
  fi
}
```

```shell
read '?📦 执行 flutter pub get？(回车=跳过 / 任意字符=执行) ' run_get
if [[ -n "$run_get" ]]; then
  "${flutter_cmd[@]}" pub get
else
  _color_echo yellow "⏭️ 跳过 pub get。"
fi
```

> 如果安装了[**FVM**](https://fvm.app/) ，则 `fvm flutter pub get`
>
> 如果没有安装[**FVM**](https://fvm.app/) ，则 `flutter pub get`

### <span id="jobs-toc-heading-85" data-jobs-toc="v2">3.17、🎯 全更新 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

**`.zshrc`**

 ```shell
 update() {
     brew update && brew upgrade && brew cleanup && brew doctor && brew -v # Homebrew
     dart pub global activate fvm                                          # fvm
     gem update && gem clean
     pod repo update --verbose
 }
 ```

### <span id="jobs-toc-heading-86" data-jobs-toc="v2">3.18、🎯 **`Git`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-87" data-jobs-toc="v2">🎯 1、删除本地**`Git`**缓存目录 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
REPO_PATH="$HOME/.cocoapods/repos/cocoapods"
if [ -d "$REPO_PATH" ]; then
  print_green "🗑️ 删除本地 git 源缓存目录: $REPO_PATH"
  rm -rf "$REPO_PATH"
else
  print_green "✅ 本地 git 缓存目录不存在，无需删除"
fi
```

#### <span id="jobs-toc-heading-88" data-jobs-toc="v2">🎯 2、删除**`CDN`**源**`trunk`** <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
if pod repo list | grep -q "^trunk"; then
  print_green "🔍 检测到 trunk（CDN 源），正在删除..."
  pod repo remove trunk
else
  print_green "✅ 未检测到 trunk（CDN 源），无需删除"
fi
```

#### <span id="jobs-toc-heading-89" data-jobs-toc="v2">🎯 3、添加**`Git`**源<a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
print_green "🔗 正在添加 Git 源 https://github.com/CocoaPods/Specs.git ..."
pod repo add cocoapods https://github.com/CocoaPods/Specs.git
```

### <span id="jobs-toc-heading-90" data-jobs-toc="v2">3.19、🎯判断两个文件内容是否一致 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
# 判断源文件和目标文件内容是否完全一致
is_actions_plist_same() {
    if [[ ! -f "${CURRENT_ACTIONS_PLIST}" || ! -f "${TARGET_ACTIONS_PLIST}" ]]; then
        return 1
    fi

    cmp -s "${CURRENT_ACTIONS_PLIST}" "${TARGET_ACTIONS_PLIST}"
}
```

### <span id="jobs-toc-heading-91" data-jobs-toc="v2">3.20、🎯重启 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* App 名、进程名、`open -a` 用的名字，不一定是同一个东西

  * **Finder**
    * App 名：`Finder`
    * 进程名：`Finder`
  * [**SourceTree**](https://www.sourcetreeapp.com/)
    * App 名：`Sourcetree`
    * 进程名：`Sourcetree`
  * [**Google Chrome**](https://www.google.com/chrome/)
    * App 名：`Google Chrome`
    * 进程名：`Google Chrome`
  * [**Visual Studio Code**](https://code.visualstudio.com/)
    * App 名：`Visual Studio Code`
    * 进程名：`Code`

* **任意 macOS App 通用重启函数**

  ```shell
  # 判断指定进程是否在运行
  is_app_running() {
      local process_name="$1"
      pgrep -x "${process_name}" >/dev/null 2>&1
  }
  
  # 优雅退出指定 App
  quit_app_gracefully() {
      local app_name="$1"
      osascript -e "tell application \"${app_name}\" to quit" >/dev/null 2>&1 || true
  }
  
  # 强制结束指定进程
  force_kill_app() {
      local process_name="$1"
      pkill -x "${process_name}" >/dev/null 2>&1 || true
  }
  
  # 等待指定进程退出
  wait_for_app_exit() {
      local process_name="$1"
      local timeout_seconds="${2:-15}"
      local elapsed=0
  
      while is_app_running "${process_name}"; do
          ((elapsed++))
          gray_echo "等待 ${process_name} 完全退出 ... ${elapsed}s/${timeout_seconds}s"
          sleep 1
  
          if [[ ${elapsed} -ge ${timeout_seconds} ]]; then
              return 1
          fi
      done
  
      return 0
  }
  
  # 启动指定 App
  launch_app() {
      local app_name="$1"
      local app_path="$2"
  
      info_echo "正在启动 ${app_name} ..."
      sleep 1
  
      if [[ -n "${app_path}" && -d "${app_path}" ]]; then
          open -a "${app_path}" || exit_with_error "启动 ${app_name} 失败，请手动打开"
      else
          open -a "${app_name}" || exit_with_error "启动 ${app_name} 失败，请手动打开"
      fi
  
      success_echo "${app_name} 已重新启动"
  }
  
  # 通用：安全重启任意 macOS App
  restart_app() {
      local app_name="$1"
      local process_name="$2"
      local app_path="$3"
      local timeout_seconds="${4:-15}"
  
      if [[ -z "${app_name}" ]]; then
          exit_with_error "restart_app 缺少参数：app_name"
      fi
  
      if [[ -z "${process_name}" ]]; then
          process_name="${app_name}"
      fi
  
      info_echo "准备重启 ${app_name} ..."
  
      if is_app_running "${process_name}"; then
          note_echo "检测到 ${app_name} 正在运行，准备优雅退出 ..."
          quit_app_gracefully "${app_name}"
  
          if wait_for_app_exit "${process_name}" "${timeout_seconds}"; then
              success_echo "${app_name} 已正常退出"
          else
              warn_echo "${app_name} 长时间未退出，尝试强制结束进程 ..."
              force_kill_app "${process_name}"
              sleep 2
  
              if is_app_running "${process_name}"; then
                  exit_with_error "${app_name} 强制退出失败，请手动关闭后再试"
              fi
  
              success_echo "${app_name} 已被强制结束"
          fi
      else
          warn_echo "当前未检测到 ${app_name} 运行中，将直接启动"
      fi
  
      launch_app "${app_name}" "${app_path}"
  }
  ```

### <span id="jobs-toc-heading-92" data-jobs-toc="v2">3.21、🎯 `Shell` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-93" data-jobs-toc="v2">🎯 1、切换`Shell` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
# ========== 获取所有可用 shell ==========
available_shells=($(cat $SYSTEM_CONFIG_DIR/shells | grep -E "^/"))

if [[ ${#available_shells[@]} -eq 0 ]]; then
    echo "❌ 无法读取可用 shell"
    exit 1
fi

# ========== fzf 选择 ==========
echo "🎯 请选择你要切换的默认 shell："
selected_shell=$(printf "%s\n" "${available_shells[@]}" | fzf --prompt="Shell ➜ ")

if [[ -z "$selected_shell" ]]; then
    echo "❌ 未选择 shell，操作取消"
    exit 1
fi

# ========== 执行切换 ==========
echo "🔧 正在切换默认 shell 为：$selected_shell"
chsh -s "$selected_shell"
```

#### <span id="jobs-toc-heading-94" data-jobs-toc="v2">🎯 2、显示当前`Shell` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
echo "✅ 当前默认 shell 已更新为："
dscl . -read ~/ UserShell
```

#### <span id="jobs-toc-heading-95" data-jobs-toc="v2">🎯 3、打开新的终端窗口并切换到脚本所在的目录 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
open_terminal_and_cd() {
    local dir="$1"
    osascript <<EOF
tell application "Terminal"
    do script "cd $dir"
    activate
end tell
EOF
}
```

#### <span id="jobs-toc-heading-96" data-jobs-toc="v2">🎯 4、关闭终端窗口 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
close_terminal_window() {
    # 获取所有终端窗口的索引
    WINDOW_IDS=$(osascript -e 'tell application "Terminal" to get id of every window')
    # 将索引分行并输出
    echo "当前终端ID为："
    echo "$WINDOW_IDS" | tr ',' '\n'
    # 假设要关闭第一个窗口（索引从1开始）
    WINDOW_TO_CLOSE=$(echo "$WINDOW_IDS" | tr ',' '\n' | head -n 1)
    # 关闭指定窗口
    osascript -e "tell application \"Terminal\" to close (every window whose id is $WINDOW_TO_CLOSE) without saving"
}
```

#### <span id="jobs-toc-heading-97" data-jobs-toc="v2">🎯 5、打开新的终端窗口 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
open_terminal_and_cd() {
    local dir="$1"
    osascript <<EOF
tell application "Terminal"
    do script "cd $dir"
    activate
end tell
EOF
}
```

> ```shell
> current_directory=$(dirname "$(readlink -f "$0")") # 获取当前脚本文件的目录 
> open_terminal_and_cd "$current_directory" # 打开新的终端窗口并切换到脚本所在的目录
> ```

#### <span id="jobs-toc-heading-98" data-jobs-toc="v2">🎯 6、仅对当前`Shell`有效的临时环境 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
# ================================== 通用开发环境变量配置 ==================================

# ✅ Android SDK 根目录（默认路径，若 ANDROID_HOME 未设置则自动补上）
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"

# ✅ Android 工具路径（无论系统是否配置，当前 shell 会话内始终有效）
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# ✅ Android cmdline tools Homebrew 安装路径（可选备用）
export PATH="$(brew --prefix)/share/android-commandlinetools/cmdline-tools/latest/bin:$PATH"

# ✅ Dart pub 全局工具路径（如 fvm）
export PATH="$HOME/.pub-cache/bin:$PATH"

# ✅ Flutter FVM 默认路径（用于未配置 FVM 的情况）
export PATH="$HOME/fvm/default/bin:$PATH"

# ✅ Homebrew.coreutils
export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"

# ✅ 检测本地项目内 FVM，并加入本地 flutter 路径（自动支持 .fvm 项目）
if [[ -d ".fvm/flutter_sdk" ]]; then
  export PATH="$(pwd)/.fvm/flutter_sdk/bin:$PATH"
fi

# ✅ CocoaPods Git 源修复依赖（部分网络下需设置语言）
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ✅ jenv 初始化（确保脚本中可以用 jenv 控制 Java）
if [[ -d "$HOME/.jenv" ]]; then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi

# ✅ Homebrew 安装路径加入 PATH（根据芯片架构区分，确保 brew 可用）
if [[ "$(uname -m)" == "arm64" ]]; then
  export PATH="$(brew --prefix)/bin:$PATH"
else
  export PATH="$(brew --prefix)/bin:$PATH"
fi

# ✅ Flutter 镜像源（可选：解决国内访问慢的问题）
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

# ✅ Xcode 工具路径（必要时强制指定 Xcode 命令路径）
# export DEVELOPER_DIR="$APPLICATIONS_DIR/Xcode.app/Contents/Developer"

# ✅ 手动注入某些环境变量块（如 fvm）
# inject_shellenv_block "$HOME/.zshrc" "fvm_env" 'export PATH="$HOME/.pub-cache/bin:$PATH"'
```

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
