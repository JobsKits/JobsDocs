---
title: "Windows 脚本代码片段"
date: 2026-11-15T12:49:45+08:00
draft: false
weight: 110
summary: "📚 目录（点击展开 / 收起） - 🔥 前言 - 一、从哪些成熟脚本提炼 - 1.1、来源与固定职责 - 1.2、观察结果不能机械提升为标准 - 二、PowerShell 入口基座 - 2.1、同名包装与三层说明 - 2.2、可复制的只读起步骨架 - 2.3、版本与文件编码必须显式 - 三、Batch 只作薄入口 - 3.1、参数、路径和退出码 - 3.2、"
bookCollapseSection: false
---


![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、从哪些成熟脚本提炼](#windows-source-map)
  - [1.1、来源与固定职责](#source-functions)
  - [1.2、观察结果不能机械提升为标准](#read-pattern-boundaries)
- [二、PowerShell 入口基座](#powershell-foundation)
  - [2.1、同名包装与三层说明](#script-package)
  - [2.2、可复制的只读起步骨架](#safe-entry-example)
  - [2.3、版本与文件编码必须显式](#version-and-encoding)
- [三、Batch 只作薄入口](#batch-launcher)
  - [3.1、参数、路径和退出码](#batch-template)
  - [3.2、包名可变时按唯一标记寻址](#marked-package)
- [四、路径、遍历和文本修改](#paths-and-text)
  - [4.1、路径作为数据处理](#literal-paths)
  - [4.2、跳过依赖目录与链接](#tree-traversal)
  - [4.3、严格 UTF-8 与 BOM 保留](#strict-utf8)
- [五、外部命令与结果通道](#native-commands)
  - [5.1、不要只依赖 try / catch 判断失败](#native-exit)
  - [5.2、发现、验证、修复、再验证](#command-health)
- [六、交互、日志和来源显示](#prompts-and-logging)
  - [6.1、普通写操作默认取消](#keyboard-confirm)
  - [6.2、显示真实来源，日志保持纯文本](#source-display)
  - [6.3、会话配色采用完整保护，不能简化恢复](#terminal-style)
- [七、下载、依赖和缓存](#downloads-and-sdk)
  - [7.1、先下载临时文件，再验证并发布](#download-template)
  - [7.2、必需 SDK 的持续获取是专门流程](#sdk-retry)
  - [7.3、Release 分页与断点按真实对象验证](#release-object-identity)
- [八、环境作用域与进程归属](#process-and-environment)
  - [8.1、新版宿主将环境直接交给子进程](#child-process-environment)
  - [8.2、PATH、代理和永久配置各有边界](#environment-scope)
  - [8.3、进程收据至少核对 PID、启动时间和路径](#process-receipt)
- [九、幂等、并发检查与恢复](#backup-and-rollback)
  - [9.1、先预览，确认后复检，再备份写入](#backup-edit-template)
  - [9.2、部署与反部署共用一份归属协议](#deployment-contract)
  - [9.3、大文件用流式分卷、候选校验和无覆盖发布](#file-volumes)
- [十、Windows 平台动作单独归纳](#windows-specific)
  - [10.1、注册表、任务、服务与快捷方式](#platform-boundaries)
  - [10.2、常见迁移误区](#windows-not-shell-translation)
- [十一、如何验证这些范本](#validation)
  - [11.1、先做 AST 解析，再做隔离行为检查](#ast-validation)
  - [11.2、本文的核对范围](#validation-status)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

这份文档归纳 Jobs 本机已有 Windows 脚本中的固定写法，与 [**MacOS**](https://www.apple.com/macos/) 的 [Shell 范本](./Shell脚本代码片段.md)配套。以 `JobsGenesis` 为主要来源，也纳入散落在业务仓库中的原生部署入口；不是把 [**zsh**](https://www.zsh.org/) 命令逐行翻译成 Windows 命令。

优先使用系统自带的 [**Windows PowerShell 5.1**](https://learn.microsoft.com/powershell/scripting/windows-powershell/overview)完成业务，用 `.cmd` / `.bat` 提供双击入口。确实使用 [**PowerShell 7**](https://learn.microsoft.com/powershell/scripting/overview)或新版运行库特性的脚本，单独声明最低版本，不能伪装成 5.1 兼容。这里的基线是既有桌面脚本的实现口径，不代表操作系统仍受厂商支持，也不代表所有 Windows 版本已经实测。

正文将**已有做法**与**归纳模板**分开：前者有本地来源和函数名；后者在这些做法上补齐当前约束、明确输入输出和失败语义，不能反推每个原脚本已具备模板的全部能力。本轮只整理文档，不执行原脚本的安装、部署、删除、注册表写入和任务注册。

## 一、<span id="windows-source-map">从哪些成熟脚本提炼</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1.1、<span id="source-functions">来源与固定职责</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 以下相对路径从本文目录出发；同名副本作为覆盖对象，不作为独立成熟方案重复统计。来源核对日期：2026-11-15。

| 标记 | 真实来源 | 可复用的职责 |
| --- | --- | --- |
| W01 | [Others 公共工具](../../JobsGenesis/JobsCommand@Others/WindowsOS/Common/JobsTools.ps1) | `Read-JobsText`、`Invoke-JobsNative`、`Assert-JobsPathAncestors`、`Get-JobsFiles`、`Read-JobsUtf8`、`Invoke-JobsReplace`：EOF、退出码、路径边界、跳过目录、保 BOM、并发检查。 |
| W02 | [Git 工具模块](../../JobsGenesis/JobsCommand@Gits/WindowsOS/GitTools.psm1) | [**Git**](https://git-scm.com/) 的 `Invoke-JobsNative` 返回 `Code / Lines / Text`；`Invoke-JobsGit` 用参数数组和进程级 `-c`，不改全局配置。 |
| W03 | [Flutter 工具模块](../../JobsGenesis/JobsCommand@Flutter/WindowsOS/Scripts/FlutterTools.psm1) | [**Flutter**](https://flutter.dev/) / [**FVM**](https://fvm.app/) 的 `Resolve-JobsProject`、`Get-JobsFlutter`、`Invoke-JobsFlutter`：工程身份、项目 FVM 优先、工作目录恢复。 |
| W04 | [SDK 获取与选路](../../JobsGenesis/JobsCommand@Flutter/WindowsOS/Scripts/SdkDownloadRoute.ps1/SdkDownloadRoute.ps1) | `Receive-JobsSdkRoutedFile`：来源和路线、续传元数据、ETag、长度和已知摘要核验。 |
| W05 | [搜索替换入口](../../JobsGenesis/JobsCommand@Others/WindowsOS/【WindowsOS】全文件搜索文字替换/【WindowsOS】全文件搜索文字替换.ps1)、[双击包装](../../JobsGenesis/JobsCommand@Others/WindowsOS/【WindowsOS】全文件搜索文字替换/【WindowsOS】全文件搜索文字替换.cmd) | `-Check`、模块定位、异常转退出码、`DisableDelayedExpansion`、参数透传。 |
| W06 | [独立右键功能管理](../../JobsGenesis/OS@Extension/WindowsOS@Extension/JobsCommandShortcutCreator/Scripts/Manage.ps1) | `New-JobsTerminalStyleState`、`Start-JobsTerminalStyle`、`Stop-JobsTerminalStyle`：会话临时配色、能力检测与恢复；`Main` 保持独立功能管理边界。 |
| W07 | [JobsSh 工具基座](../../JobsGenesis/JobsSh.sh/WindowsOS/JobsTools.ps1) | 同平台批量工具的自述、交互、日志和终端保护；不可因为叫公共模块就把它误当独立运行入口。 |
| W08 | [学术服务部署](../../学术服务平台/部署/Windows/【Windows】部署.ps1/【Windows】部署.ps1) | `Enter-OriginLock`、`Get-ArtifactInventory`、`Save-Origin`、`Stop-OriginProcesses`、`Restore-OriginFile`：互斥、原点收据、进程身份、可续恢复。 |
| W09 | [学术服务反部署](../../学术服务平台/部署/Windows/【Windows】反部署.ps1/【Windows】反部署.ps1) | `Invoke-OriginUndo`、`Assert-UndoSnapshot`：数据策略、快照复检、按阶段恢复与中断后续行。 |
| W10 | [学术服务双击入口](../../学术服务平台/部署/Windows/【Windows】双击部署（快捷入口）.cmd) | ASCII 包装按 `deployment.entry` 标记只接受唯一包，不猜中文目录名，不忽略最终退出码。 |
| W11 | [JobsIM 部署](../../JobsIM/部署/WindowsOS/部署运行.ps1/部署运行.ps1) | 明确 `#requires -Version 7.4`；`Invoke-Tool` 使用 `ArgumentList` 和子进程环境；`Assert-Owner` 绑定项目与用户 SID；备份与恢复私钥分目录树。 |
| W12 | [WindowsOS 文件分卷内核](../../WindowsOS/WindowsOS_10/WindowsOS/Common/FileVolumes.ps1) | `Get-JobsVolumeGroup`、`Invoke-JobsFileMerge / Split`：卷组身份、固定内存流式读写、SHA-256、候选发布与流释放。 |
| W13 | [WindowsOS Release 获取](../../WindowsOS/WindowsOS_10/WindowsOS/【WindowsOS】⏬下载当前仓库Release.cmd/【WindowsOS】⏬下载当前仓库Release.ps1) | `Get-ReleaseApiItems`、`Get-ReleaseIdentity`、`Receive-ReleaseAttempt / Asset`：分页、附件身份、Range 核对与安全续传。 |

### 1.2、<span id="read-pattern-boundaries">观察结果不能机械提升为标准</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- W01 / W03 等来源仍可见输入编号、输入任意字符或精确 `YES` 的不同菜单；新范本的普通写操作采用键盘菜单并默认取消。来源只证明相关方法存在，不证明所有旧交互符合当前习惯。
- 精确大写 `YES` 仅保留给已经明确采用该门禁的独立危险操作；不要把输入任意字符当作危险授权。
- W01 / W03 使用共享模块，适合说明职责；部署／反部署入口的生命周期核心要内嵌自包含，不因此重新抽出随身必需的状态库。
- W11 的 `ArgumentList`、`$IsWindows` 等写法属于声明了新版宿主的脚本；5.1 模板使用兼容实现。不能把语法能解析与运行库成员存在混为一谈。
- 上游第三方、供应商、生成包装器及作者归属不明确的脚本，仅列为排除范围，不蒸馏成 Jobs 自有标准；本次不修改这些来源文件。

## 二、<span id="powershell-foundation">PowerShell 入口基座</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 2.1、<span id="script-package">同名包装与三层说明</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```text
【WindowsOS】示例工具.ps1/
├── 【WindowsOS】示例工具.ps1
├── 【WindowsOS】示例工具.cmd
└── README.md
```

- `.ps1` 负责参数、内置自述、确认、检查和业务；`.cmd` 负责选择解释器和转交，业务只执行一次。
- `README.md` 写完整能力、模式、参数、默认值、依赖、输入输出、日志、副作用和失败处理；源码头注释方便维护；运行时自述是写在源码中的固定文本，不能运行时读取 README 拼起来。
- 内部模块和测试按职责管理；不得因为被调用就自行豁免用户现行包装规则。`OS@Extension` 的明确目录例外按原工程保留，不借文档整理搬动源脚本。

### 2.2、<span id="safe-entry-example">可复制的只读起步骨架</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

归纳自 W01 / W03 / W05。下面是完整可运行的**目录检查器**，默认 `Check`，只统计目录的直接子项；没有安装、下载和写配置。`Run` 仅用于演示自述确认后的日志初始化，业务仍只读。新业务替换 `Invoke-Business` 时，同时改自述、计划和确认，不能保留“只读”字样掩盖写操作。

```powershell
#requires -Version 5.1
<#
【WindowsOS】示例工具.ps1 | Jobs Windows 目录检查器
Created by Jobs on 2026年11月15日，星期日.
用途：检查目标目录并统计直接子项；不递归、不安装、不改配置。
影响：Check / Plan 不落盘；Run 确认后仅在临时目录创建本次日志。
运行：同级 .cmd 或 powershell.exe -NoProfile -File 本文件 -Mode Check。
#>
[CmdletBinding()]
param(
    [ValidateSet('Check', 'Plan', 'Run')][string]$Mode = 'Check',
    [string]$Target = ''
)
$script:TargetRoot = $null
$script:LogFile = $null
$script:Cancelled = $false
# 输出固定自述；只有 Run 模式要求可交互输入并等待确认。
function Show-ScriptIntro {
    Write-Host 'Jobs Windows 目录检查器'
    Write-Host '用途：统计目标目录直接子项；不安装、不修改目标文件。'
    Write-Host 'Check / Plan 不落盘；Run 仅创建系统临时目录中的独立日志。'
    Write-Host 'Run 需回车继续；输入其它内容取消；Ctrl+C 停止。'
    if ($Mode -ne 'Run') { return }
    if ([Console]::IsInputRedirected -or $Host.Name -ne 'ConsoleHost') {
        throw 'Run 需要交互终端；当前环境只能使用 Check / Plan。'
    }
    $answer = Read-Host '已了解用途与影响，按回车继续；输入其它内容取消'
    if ($null -eq $answer -or $answer -ne '') { $script:Cancelled = $true }
}
# 在自述之后设置本脚本的错误策略并解析实际路径，不依赖启动目录。
function Initialize-Context {
    if ($script:Cancelled) { return }
    Set-StrictMode -Version 2.0
    $script:ErrorActionPreference = 'Stop'
    $candidate = $Target
    if ([string]::IsNullOrWhiteSpace($candidate)) { $candidate = $PSScriptRoot }
    $item = Get-Item -LiteralPath $candidate -Force -ErrorAction Stop
    if (-not $item.PSIsContainer) { throw '目标必须是目录。' }
    $script:TargetRoot = $item.FullName
    if ($Mode -eq 'Run') {
        $name = 'Jobs-Directory-' + [Guid]::NewGuid().ToString('N') + '.log'
        $script:LogFile = Join-Path ([IO.Path]::GetTempPath()) $name
        [IO.File]::WriteAllText($script:LogFile, '', (New-Object Text.UTF8Encoding($false)))
    }
}
# 同步显示结果和写入本次日志，数据输出不混入成功输出流。
function Write-RunMessage {
    param([string]$Message)
    Write-Host $Message
    if ($script:LogFile) {
        [IO.File]::AppendAllText($script:LogFile, $Message + [Environment]::NewLine,
            (New-Object Text.UTF8Encoding($false)))
    }
}
# 执行当前模式的真实只读行为，取消时立即返回。
function Invoke-Business {
    if ($script:Cancelled) { Write-Host '已取消。'; return }
    if ($Mode -eq 'Plan') {
        Write-RunMessage ('计划：读取目录直接子项；目标：' + $script:TargetRoot)
        return
    }
    $items = @(Get-ChildItem -LiteralPath $script:TargetRoot -Force -ErrorAction Stop)
    Write-RunMessage ('目标：' + $script:TargetRoot)
    Write-RunMessage ('直接子项：' + $items.Count)
    if ($script:LogFile) { Write-RunMessage ('日志：' + $script:LogFile) }
}
# 只编排高层步骤；真实工作与状态处理留在对应方法。
function Main {
    Show-ScriptIntro # 展示内置自述并按当前模式处理确认。
    . Initialize-Context # 在入口当前作用域准备错误策略、目标和日志。
    Invoke-Business # 执行当前模式的目录检查。
}
try {
    Main
    exit 0
} catch {
    [Console]::Error.WriteLine('失败：' + $_.Exception.Message)
    exit 1
}
```

- `Check` / `Plan` 的承诺要落实到调用链：不创建缓存、日志或锁，不执行首次运行会下载组件的命令，不修改环境或索引；“调用了帮助命令”不自动等于无副作用。
- 本文骨架使用纯文本，方便重定向和检查。生产交互入口如启用黑底白字及彩色强调，按[终端保护](#terminal-style)嵌入完整成熟实现；不把三行改色命令伪装成可精确恢复的保护。
- `Main` 直接调用高层方法，每行带职责注释；异常处理集中在最终调用边界。库函数返回结果或抛错，避免深层 `exit` 使调用者无法清理。
- `#requires` 会先于脚本主体检查最低版本；这是解释器门槛。确认前只能做必要的展示准备，真实初始化继续放在确认之后。

### 2.3、<span id="version-and-encoding">版本与文件编码必须显式</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 同一份中文源码在两代宿主中读取一致，比“终端看起来没乱码”更重要。

| 对象 | 5.1 / 7 共用口径 | 不应混淆的事情 |
| --- | --- | --- |
| 中文 `.ps1` / `.psm1` | 保存为 UTF-8 **带 BOM** | `chcp 65001` 不会给源码补 BOM。 |
| `.cmd` / `.bat` | 优先 ASCII 内容；有中文时对目标宿主实测编码与代码页 | 代码页影响当前控制台，不能当成文件编码修复。 |
| JSON / 配置 / 日志 | 使用明确的 [**.NET**](https://dotnet.microsoft.com/) `UTF8Encoding`；已有文件保留 BOM 和换行策略 | 不用 `>` / `Out-File` 的宿主默认编码覆盖未知文件。 |
| 5.1 兼容代码 | 避免 `??`、三元表达式、`ForEach-Object -Parallel`、`$IsWindows` | 7 的解析器通过不证明 5.1 能执行。 |
| 原生输出 | 依据工具真实输出约定解码 | 不把所有工具输出强行解释为 UTF-8。 |

5.1 与 7 的默认编码和 `utf8` 参数含义有差异；中文脚本面向 5.1 时使用带 BOM 的 UTF-8，数据文件按消费端约定处理。具体差异见 [Microsoft 编码说明](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)及[脚本文件编码说明](https://learn.microsoft.com/powershell/scripting/dev-cross-plat/vscode/understanding-file-encoding)。

## 三、<span id="batch-launcher">Batch 只作薄入口</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 3.1、<span id="batch-template">参数、路径和退出码</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

归纳自 W05 / W10。下面的 ASCII 包装适用于“同目录仅有一个 `.ps1` 实施文件”的明确交付结构；数量不是一个就失败，不按排序选第一个。已有中文同名启动器也可直接用带引号的固定相对路径。

```bat
@echo off
rem ASCII source; one implementation script in this package.
setlocal DisableDelayedExpansion
set "jobs_script="
set "jobs_count=0"
for %%F in ("%~dp0*.ps1") do (
    if exist "%%~fF" if not exist "%%~fF\" (
        set /a jobs_count+=1 >nul
        set "jobs_script=%%~fF"
    )
)
if not "%jobs_count%"=="1" goto missing_script
set "jobs_engine=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%jobs_engine%" goto missing_engine
"%jobs_engine%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%jobs_script%" %*
set "jobs_result=%errorlevel%"
endlocal & exit /b %jobs_result%
:missing_script
>&2 echo Expected exactly one PowerShell implementation in this package.
endlocal & exit /b 1
:missing_engine
>&2 echo Windows PowerShell was not found at the system location.
endlocal & exit /b 1
```

- `%~dp0` 指向包装器自身目录；`DisableDelayedExpansion` 避免路径中的 `!` 在包装层再次展开；不要用 `call` 或二次拼接重新解释 `%*`。
- 参数由调用者按当前 Shell 的规则引用。薄包装不能承诺任意未转义的 `& | > < ^ % !` 文本都能安全透传；复杂数据用 JSON 文件／标准输入等已定义协议交给 `.ps1`，不当作可执行命令文本拼接。
- `-NoProfile` 避免用户配置影响自动化；`-ExecutionPolicy Bypass` 只用于这次新进程，不改永久策略，不能覆盖组策略。企业策略拒绝时明确报告，不自动提权或修改机器策略。[执行策略官方说明](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies)
- `pause` 只适合明确的双击交互入口，必须在调用前识别的交互模式下执行并保留已捕获退出码；任务计划、CI、[**Sourcetree**](https://www.sourcetreeapp.com/) 动作入口不要无条件暂停。上例不自动猜测“双击”。
- 如果实施脚本声明 7.4，包装器就查找和验证 `pwsh.exe` 的版本，失败时说明需求；不要自动回退到 5.1，也不要为运行入口擅自全局安装新版宿主。
- `System32` 是系统约定位置；脚本自带资源仍从自身目录解析。32 位父进程的文件系统重定向、进程位数和注册表视图需要在对应宿主单独验证。

### 3.2、<span id="marked-package">包名可变时按唯一标记寻址</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W10 的固定写法是：扫描同级 `*.ps1` 目录，同时检查 `deployment.entry` 与目录内同名实施文件，仅允许唯一命中。这个模式用于“快捷入口在包外、包名包含中文且可能变化”的场景；标记名必须对应真实动作，部署与反部署分别登记，不能找到任意标记就执行。

包外快捷入口只转交当前平台唯一实施脚本；不要复制部署流程、自述和确认，不依赖当前工作目录，也不回退到开发机旧源码位置。

## 四、<span id="paths-and-text">路径、遍历和文本修改</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 4.1、<span id="literal-paths">路径作为数据处理</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

已有做法：W01 的 `Get-JobsPath / Assert-JobsPathAncestors`、W03 的 `Resolve-JobsDirectory`。归纳规则是先校验用户显式路径，再发现工程根；一切文件名用 `-LiteralPath`，避免 `[]` 被当成通配符。`GetFullPath` 只是规范化，不证明存在、归属或没有联接。

```powershell
# 验证文件系统目录，并拒绝目标及已有祖先中的联接和符号链接。
function Resolve-JobsPlainDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { throw '目录不能为空。' }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if (-not $item.PSIsContainer -or $item.PSProvider.Name -ne 'FileSystem') {
        throw '需要文件系统目录。'
    }
    $cursor = $item
    while ($null -ne $cursor) {
        if (($cursor.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw ('拒绝处理联接或符号链接：' + $cursor.FullName)
        }
        $cursor = $cursor.Parent
    }
    return $item.FullName
}
# 在明确目录中运行逻辑，失败也恢复调用方工作目录。
function Invoke-JobsInDirectory {
    param([string]$Directory, [scriptblock]$Action)
    $root = Resolve-JobsPlainDirectory $Directory
    Push-Location -LiteralPath $root
    try { & $Action } finally { Pop-Location }
}
```

- 不全局删除路径中的引号；参数传入的字符串已经是路径数据。只有专门接收“拖入路径文本”的入口，才剥离匹配的一对外层引号与末尾换行，不破坏合法文件名。
- 用户相对路径明确约定按哪个目录解析。工程内配套路径固定由 `$PSScriptRoot` / 项目根推导；新建文件要校验已有祖先，不能只检查尚不存在的叶子。
- 本文的联接拒绝策略适用于批量修改等需要清楚边界的工具；确需允许链接的业务应验证真实目标和授权范围，不静默放开全目录。
- 路径确认和写入间仍可能发生竞争；哈希复检、互斥锁和受控目录共同降低风险，不能声称几次 `Test-Path` 已消除全部竞争条件。

### 4.2、<span id="tree-traversal">跳过依赖目录与链接</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W01 `Get-JobsFiles` 与 W03 `Get-JobsSourceFiles` 都采用受控递归；归纳模板增加常见供应商目录，并保留返回 `FileInfo` 对象，方便调用方继续按扩展名筛选。

```powershell
# 只产出授权目录下的普通文件，不跟随链接、不进入依赖和生成目录。
function Get-JobsManagedFiles {
    param([Parameter(Mandatory = $true)][string]$Root)
    $directory = Resolve-JobsPlainDirectory $Root
    $skip = @('.git', 'node_modules', 'Pods', 'PodsManual', '.dart_tool',
        'build', 'DerivedData', 'vendor', '.venv', '.gradle', '.fvm')
    foreach ($item in Get-ChildItem -LiteralPath $directory -Force -ErrorAction Stop) {
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
        if ($item.PSIsContainer) {
            if ($item.Name -in $skip -or $item.Name -like 'ManualBy*Pods@Pods') { continue }
            Get-JobsManagedFiles -Root $item.FullName
        } else {
            $item
        }
    }
}
```

排除目录不等于完成所有权检查；写入计划还要排除文件头、版权或路径显示属于第三方的源码，以及生成文件。无权限的目录明确报错，不把漏扫后的数量显示成完整结果。

### 4.3、<span id="strict-utf8">严格 UTF-8 与 BOM 保留</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

归纳自 W01 `Read-JobsUtf8 / Write-JobsUtf8`。此模板明确只处理严格 UTF-8；拒绝二进制或 UTF-16，不“猜编码后覆盖”。处理大文件时另做大小限制或流式实现，不一次读入任意体积文件。

```powershell
# 返回文本及原 BOM 状态，无法严格解码时保留原件并报错。
function Read-JobsUtf8Document {
    param([string]$Path)
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes -contains 0) { throw '文件含 NUL，不按 UTF-8 文本修改。' }
    $offset = 0
    $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 239 -and
        $bytes[1] -eq 187 -and $bytes[2] -eq 191
    if ($bom) { $offset = 3 }
    $encoding = New-Object Text.UTF8Encoding($false, $true)
    return [pscustomobject]@{
        Text = $encoding.GetString($bytes, $offset, $bytes.Length - $offset)
        Bom = $bom
    }
}
# 依照原文档 BOM 状态写入，不额外添加换行。
function Write-JobsUtf8Document {
    param([string]$Path, [AllowEmptyString()][string]$Text, [bool]$Bom)
    [IO.File]::WriteAllText($Path, $Text, (New-Object Text.UTF8Encoding($Bom)))
}
```

字面替换用 `$doc.Text.Replace($Find, $Replacement)`，不把用户文本直接塞给正则 `-replace`。空查找串必须拒绝；没有差异就不写入、不制造备份。原换行由整个字符串保留，只有新增行才按文件既有策略选择换行。

## 五、<span id="native-commands">外部命令与结果通道</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 5.1、<span id="native-exit">不要只依赖 try / catch 判断失败</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W02 的固定做法是参数数组、捕获原生退出码并返回结构化结果。`$ErrorActionPreference = 'Stop'` 不能跨宿主统一代替原生程序的失败码判断；7 的原生命令错误偏好也需要明确。参考 [LASTEXITCODE 官方定义](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables#lastexitcode)及[原生命令错误偏好](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables#psnativecommanduseerroractionpreference)。

```powershell
# 运行有限输出的 .exe；日志走 Host，返回对象才进入成功输出流。
function Invoke-JobsExecutable {
    param(
        [Parameter(Mandatory = $true)][string]$Program,
        [string[]]$Arguments = @(),
        [int[]]$SuccessCodes = @(0),
        [switch]$Quiet
    )
    $command = Get-Command $Program -CommandType Application -ErrorAction Stop |
        Select-Object -First 1
    if ([IO.Path]::GetExtension($command.Source) -ine '.exe') {
        throw '此模板只处理 .exe；批处理文件需要单独验证 cmd 参数规则。'
    }
    $oldPreference = $ErrorActionPreference
    $hasNativePreference = $null -ne (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue)
    $oldNativePreference = $null
    try {
        $ErrorActionPreference = 'Continue'
        if ($hasNativePreference) {
            $oldNativePreference = $PSNativeCommandUseErrorActionPreference
            $PSNativeCommandUseErrorActionPreference = $false
        }
        $global:LASTEXITCODE = -1
        $lines = @(& $command.Source @Arguments 2>&1 | ForEach-Object { [string]$_ })
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
        if ($hasNativePreference) { $PSNativeCommandUseErrorActionPreference = $oldNativePreference }
    }
    if (-not $Quiet) { foreach ($line in $lines) { Write-Host $line } }
    if ($code -notin $SuccessCodes) {
        throw ('工具失败：' + [IO.Path]::GetFileName($command.Source) + '，退出码 ' + $code)
    }
    return [pscustomobject]@{ Code = $code; Lines = $lines; Text = ($lines -join "`n") }
}
```

- 返回结构与日志分离：函数里的裸字符串、`Write-Output`、未抑制的 `Add()` 返回值都可能混进调用结果；只作展示用 `Write-Host`，不需要的返回值用 `[void]` 或 `$null =`。
- 原生命令 stderr 不必然表示失败；成功码由工具协议决定。例如 [**Robocopy**](https://learn.microsoft.com/windows-server/administration/windows-commands/robocopy) 的 `0..7` 没有复制失败，`>=8` 表示出现失败；额外文件／不匹配仍要按业务要求报告，不能一律标成零差异。
- 不记录可能包含密码的完整参数、连接串或全部原始输出。敏感工具使用 `-Quiet` 并只展示必要的脱敏摘要；URL 脱敏不等于通用日志脱敏。
- 大量输出、进度、超时、后台运行用专门进程管理，不用这个缓冲全部输出的短命令模板。不要把数据函数整体放入显示／着色管道而改变输入与状态。

### 5.2、<span id="command-health">发现、验证、修复、再验证</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W01 `Require-JobsCommand` 负责发现，W08 `Test-BootstrapGo / Ensure-Go` 再验证实际版本。写新工具时先确认完整依赖链，复用健康上游，只修复缺失或损坏的一层。

```powershell
# 发现真实应用路径；是否健康由对应工具的最小只读探针判断。
function Find-JobsApplication {
    param([string]$Name)
    $found = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -eq $found) { throw ('缺少命令：' + $Name + '；请准备后重新检查。') }
    return $found.Source
}
# 验证 Git 可执行，不因路径存在就报告环境就绪。
function Test-JobsGitHealth {
    $exe = Find-JobsApplication 'git.exe'
    $result = Invoke-JobsExecutable -Program $exe -Arguments @('--version') -Quiet
    if ($result.Text -notmatch '^git version ') { throw 'Git 版本输出无法确认。' }
    return $exe
}
```

普通安装／修复先展示对象、来源和范围并确认，每层最多一次后复检；已获授权的必需 SDK 网络获取采用[持续重试边界](#sdk-retry)。安装后刷新当前进程的命令发现与 PATH，不能仅提示“重启电脑”就宣称本轮已就绪；不为一个工具强制安装未用到的包管理器。

## 六、<span id="prompts-and-logging">交互、日志和来源显示</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 6.1、<span id="keyboard-confirm">普通写操作默认取消</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

以下为面向 `ConsoleHost` 的两项原生键盘菜单，适合确认一个已经完整展示的普通操作计划；默认选中取消，方向键／Tab 切换，回车确认，Esc 取消。多层列表优先复用项目已验证的 [**fzf**](https://github.com/junegunn/fzf) 选择器，子层明确支持左键返回，不能用重跑全部业务实现返回。

```powershell
# 显式键盘确认一个普通写操作；非交互环境、EOF 和取消均不执行。
function Confirm-JobsKeyboardAction {
    param([Parameter(Mandatory = $true)][string]$Message)
    if ($Host.Name -ne 'ConsoleHost' -or [Console]::IsInputRedirected -or [Console]::IsOutputRedirected) {
        throw '当前宿主不支持此交互确认，请在真正终端运行。'
    }
    Write-Host $Message
    Write-Host '↑/↓、←/→ 或 Tab 切换；回车确认；Esc 取消。默认取消。'
    $execute = $false
    while ($true) {
        if ($execute) { Write-Host '[ ] 取消    [x] 执行' }
        else { Write-Host '[x] 取消    [ ] 执行' }
        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            'Tab' { $execute = -not $execute }
            'UpArrow' { $execute = -not $execute }
            'DownArrow' { $execute = -not $execute }
            'LeftArrow' { $execute = -not $execute }
            'RightArrow' { $execute = -not $execute }
            'Escape' { return $false }
            'Enter' { return $execute }
        }
    }
}
# 只用于已明确要求保留精确 YES 的独立危险门禁。
function Confirm-JobsExactYes {
    param([string]$Message)
    if ($Host.Name -ne 'ConsoleHost' -or [Console]::IsInputRedirected) {
        throw '危险确认需要真实交互终端。'
    }
    Write-Host ('危险范围：' + $Message)
    $answer = Read-Host '必须精确输入大写 YES；直接回车或其它输入取消'
    return ($null -ne $answer -and $answer -ceq 'YES')
}
```

- 首屏“已了解用途”的回车确认与“执行写操作”的确认是两个职责，不用首屏回车默认触发未展示的安装／升级。
- 无文字输入的危险入口要用明确危险选项，再按空格复核；空选、取消、输入结束或选择器失败均不执行。上面的普通菜单不能直接替代危险门禁。
- 已发现唯一目标可以自动复用，多个目标显示来源与范围供选择；自动识别不替代写操作授权。
- 提示中“仅回车”的整段选项使用绿色粗体，“输入任意字符后回车”的整段选项使用红色粗体；固定词 `YES` 不能误标成仅回车执行。纯文本能力下降时保留清晰文案，不能伪称粗体已生效。
- Sourcetree 动作进程不等待输入；需要选择和危险确认时转交独立交互终端。不能仅凭重定向或 `TERM=dumb` 判断它来自 Sourcetree，也不能因此跳过确认。

### 6.2、<span id="source-display">显示真实来源，日志保持纯文本</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W01 `Show-JobsSource` 会剥离 URL 的认证信息、查询与片段。归纳模板只负责地址展示副本，绝不把脱敏地址回写到业务请求。签名位于路径等非常规位置时还需按来源协议额外脱敏。

```powershell
# 为日志生成地址副本；不能作为下载地址返回给业务使用。
function Get-JobsSourceDisplay {
    param([string]$Source)
    $uri = $null
    if ([Uri]::TryCreate($Source, [UriKind]::Absolute, [ref]$uri) -and $uri.Host) {
        $builder = New-Object UriBuilder($uri)
        $builder.UserName = ''
        $builder.Password = ''
        $builder.Query = ''
        $builder.Fragment = ''
        return $builder.Uri.AbsoluteUri
    }
    return $Source
}
# 在传输之前显示对象、可核对来源与目标，不夹带控制码和认证参数。
function Show-JobsTransferSource {
    param([string]$Object, [string]$Source, [string]$Destination, [string]$Version = '')
    Write-Host ('来源｜' + $Object)
    Write-Host ('来源地址：' + (Get-JobsSourceDisplay $Source))
    Write-Host ('目标位置：' + $Destination)
    if ($Version) { Write-Host ('版本：' + $Version) }
}
```

- 先显示来源再开始传输；镜像、分支、版本或路线改变时更新来源。包管理器尚未解析最终 URL，就显示已知软件源与包 ID，并明确“最终下载地址待解析”。
- 只有本地规则展开时说“配置地址／展开结果”，不能称为已验证的 HTTP 重定向终点或真实代理出口。
- 日志按运行编号分开或追加，保留对象、来源、目标、失败码和恢复结果；不清空仍用于恢复的旧记录。落盘使用纯文本，终端控制序列不混入日志。
- 不直接记录输入正文、密码、Token、私钥、Cookie、整个环境或连接串。对敏感工具不回显未经筛选的异常正文；可检索审计与秘密恢复材料分开保存。

### 6.3、<span id="terminal-style">会话配色采用完整保护，不能简化恢复</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

已有完整实现见 W06 / W07 的 `New-JobsTerminalStyleState`、`Start-JobsTerminalStyle`、`Stop-JobsTerminalStyle`。它包含 Win32 控制台模式、颜色快照、嵌套归属、输入事件保留与恢复判断，不能缩成改 `RawUI.BackgroundColor` 后再 `Clear-Host`。

维护时读取当前 `jobs-macos-shell` 中的《临时终端配色范本》，并与 [W06 生产实现](../../JobsGenesis/OS@Extension/WindowsOS@Extension/JobsCommandShortcutCreator/Scripts/Manage.ps1)核对，再把完整代码内嵌到可独立分发的入口；最终运行不能依赖用户机器上的 Skill 文件。

- 只修改本次连接的控制台会话，不改默认 Profile、注册表主题、字体、透明度或其它窗口。
- 保存本次实际改动的前景、背景、必要色表和模式；结束时按进入前快照精确恢复，不能拿 `SGR 0` 或默认黑白代替原状态。
- `NO_COLOR`（含空值）、重定向、非 ConsoleHost、未知能力或无法可靠读取恢复时，原地纯文本降级。
- 同控制台嵌套入口复用有效归属，不能内层提前恢复；用户运行中修改的状态保留并报告冲突。
- 正常退出、错误、可捕获中断均核对恢复；进程被强杀或控制台崩溃不能承诺自动恢复。提供精确的手动恢复入口，语法检查不能替代真实终端测试。

## 七、<span id="downloads-and-sdk">下载、依赖和缓存</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 7.1、<span id="download-template">先下载临时文件，再验证并发布</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W04 有完整选路与续传，W08 `Receive-Dependency` 有有界请求和持续退避。以下是**单次获取且要求可信 SHA-256 的小文件模板**，不是完整 SDK 下载器；来源与目标已经由调用方确认，目标存在时拒绝覆盖。官方摘要必须从可追溯渠道取得，不以同一未知镜像随包提供的摘要独立证明可信。

```powershell
# 单次获取 HTTPS 文件；校验通过才以新文件发布，不覆盖既有目标。
function Receive-JobsVerifiedFile {
    param(
        [Parameter(Mandatory = $true)][uri]$Uri,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][string]$Sha256
    )
    if ($Uri.Scheme -cne 'https' -or $Uri.UserInfo) { throw '只接受无内嵌凭据的 HTTPS 地址。' }
    if ($Sha256 -notmatch '^[0-9a-fA-F]{64}$') { throw '需要已确认的 SHA-256。' }
    $parent = Resolve-JobsPlainDirectory ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($Destination)))
    $final = Join-Path $parent ([IO.Path]::GetFileName($Destination))
    if (Test-Path -LiteralPath $final) { throw '目标已存在，不隐式覆盖。' }
    Show-JobsTransferSource -Object ([IO.Path]::GetFileName($final)) -Source $Uri.AbsoluteUri -Destination $final
    $part = Join-Path $parent ('.jobs-download-' + [Guid]::NewGuid().ToString('N') + '.part')
    $published = $false
    try {
        Invoke-WebRequest -Uri $Uri -UseBasicParsing -OutFile $part -TimeoutSec 120 -ErrorAction Stop
        $actual = (Get-FileHash -LiteralPath $part -Algorithm SHA256 -ErrorAction Stop).Hash
        if ($actual -ine $Sha256) { throw '下载摘要不符，未发布目标。' }
        if (Test-Path -LiteralPath $final) { throw '下载期间目标已被创建，保留现状。' }
        [IO.File]::Move($part, $final)
        $published = $true
        Write-Host ('校验通过：' + $final)
    } finally {
        if (-not $published -and [IO.File]::Exists($part)) {
            [IO.File]::Delete($part)
        }
    }
}
```

- 上例只删除本次 UUID 临时文件，不清空共享缓存；它不支持续传和持久失败证据。需要这些能力时复用 W04 的完整实现，不把这个简版挂到大 SDK 获取入口。
- 下载成功要验证内容，不能只看 `Test-Path` 或 HTTP 成功。归档另查预期文件、大小、摘要／签名及解压后的布局，防止错误页和不完整 SDK 进入后续流程。
- `Invoke-WebRequest` 的 HTTPS 起点不自动证明最终重定向路线符合策略；严格限 HTTPS 重定向、来源白名单或实际路线要求时，使用项目已验证的获取器并核对每次跳转，不能沿用上例声称已验证全部路线。
- TLS／证书失败明确报错；不加入忽略证书或关闭校验的通用回退。压缩包解压到独立暂存目录，验证条目不会越出目标树后再发布，拒绝覆盖不明旧目录。

### 7.2、<span id="sdk-retry">必需 SDK 的持续获取是专门流程</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 流程已声明并获准的必需 SDK，网络失败、断流和单次超时后持续自动重试；有上限退避，不设默认总次数或总时长上限，用户可随时 Ctrl+C。重试只包住可重入的获取步骤，不重跑整个安装／构建／启动业务。
- 参数错误、版本不存在、磁盘不足、权限、认证和许可证问题明确停止或等待处理，不伪装成网络重试。取消异常和取消退出码原样上抛，不能被 `catch { continue }` 吞掉。
- 缓存身份包含来源对象、版本、架构和可信验证信息；续传必须匹配 ETag／验证器及长度，不把两个来源的字节直接拼接。损坏缓存保留可核对副本，不整片删共享缓存。
- 下载前按目标工程、FVM 声明、宿主架构、engine／提交确认对象；有 `.fvmrc` 而本地 SDK 缺失时，不能悄悄切到全局 SDK。W03 `Get-JobsFlutter` 正是这条边界。
- 已声明自动选路的 Flutter 获取在下载前检测可用路线，保留显式源／代理及其空值；临时注入只作用本任务及子进程，失败后重新检测。路线探测不是授权修改系统代理。
- 同一个 SDK 缓存只允许一个有效写者；等待锁可取消，不能为抢锁杀另一个任务。持续显示真实进度、当前来源、重试次数和下次间隔，元数据输出与进度分通道。
- SDK 目录存在不代表就绪；组件、版本和最小健康探针全部通过后才进入业务。首次运行隐式补齐的组件也属于获取链，不能绕开上述边界。

### 7.3、<span id="release-object-identity">Release 分页与断点按真实对象验证</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W13 是 `JobsGenesis` 之外的成熟来源。固定模式是先取齐分页，再展示完整附件列表；断点不是“同名文件存在就接着写”，而是核对附件 ID、名称、URL、大小、更新时间与可得摘要。

- `206` 响应核对 `Content-Range` 起点和总长度；服务器忽略 Range 返回 `200`、或范围无效时，保留旧候选并重新获取，不能把整包追加进断点文件。
- 完整文件验证声明大小；上游确实提供 SHA-256 时再验摘要，未提供就明确“仅完成大小等现有证据检查”，不能报告全量摘要通过。
- `Retry-After` 与速率限制进入退避策略，取消仍能退出。W13 自身存在对部分认证／不存在响应持续退避的业务选择；这不作为通用下载标准，确定的认证、许可或版本错误仍按当前入口明确阻断。
- 一个镜像仓库的目录名包含 XP／2003／7，不意味着这些新脚本可在对应旧系统执行；最低宿主与镜像文件所属系统分开说明。

## 八、<span id="process-and-environment">环境作用域与进程归属</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 8.1、<span id="child-process-environment">新版宿主将环境直接交给子进程</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

已有做法见 W11 `Invoke-Tool`。下面明确要求 **PowerShell 7.4+**，只处理短时 `.exe`；`ArgumentList` 负责参数序列，不手拼一个 `Arguments` 字符串。它不是可直接粘贴进 5.1 的公共方法。[ArgumentList 官方说明](https://learn.microsoft.com/dotnet/api/system.diagnostics.processstartinfo.argumentlist)

```powershell
#requires -Version 7.4
# 为短时工具设置独立环境，父进程环境保持原值。
function Invoke-JobsIsolatedTool {
    param(
        [string]$Exe, [string[]]$Arguments = @(),
        [string]$WorkingDirectory, [hashtable]$Environment = @{}
    )
    if ([IO.Path]::GetExtension($Exe) -ine '.exe') { throw '需要 .exe；不隐式交给 cmd.exe。' }
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Exe
    $start.WorkingDirectory = $WorkingDirectory
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($argument in $Arguments) { $start.ArgumentList.Add($argument) }
    foreach ($key in $Environment.Keys) {
        if ($null -eq $Environment[$key]) { [void]$start.Environment.Remove($key) }
        else { $start.Environment[$key] = [string]$Environment[$key] }
    }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $start
    try {
        if (-not $process.Start()) { throw '子进程未启动。' }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $out = $stdout.GetAwaiter().GetResult()
        $err = $stderr.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) {
            throw ('子进程失败，退出码 ' + $process.ExitCode + '；原始输出可能含敏感数据，不自动回显。')
        }
        return [pscustomobject]@{ Code = $process.ExitCode; Stdout = $out; Stderr = $err }
    } finally { $process.Dispose() }
}
```

- 该片段没有超时／进程树清理，适用边界只到可信短时工具。长下载、前台服务和后台作业采用完整生命周期实现，取消时核对本轮整个子树；`Dispose()` 只释放句柄，不代表已经结束进程。
- 5.1 如需 `ProcessStartInfo.Arguments`，复用 W04 的 `ConvertTo-JobsSdkRouteArgument` 和已有测试，先确认目标程序的解析规则。不能用 `($Arguments -join ' ')` 代替引用，也不能把一套 C 运行库规则当成所有解释器的通用规则。
- 顺序读取 stdout 再 stderr 会在输出量大时互相堵塞；W11 同时启动两路异步读取。不要为了显示实时进度再改回顺序同步读取。

### 8.2、<span id="environment-scope">PATH、代理和永久配置各有边界</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 临时 PATH／代理优先用子进程环境；不要把 `.zprofile` 的思路照搬成 `setx`。`setx` 写的是后续进程的持久环境，不能修复当前进程，也不适合盲目重写整段 PATH。
- 原地修改前逐键保留“未设置／空值／非空值”和本次写入值，退出时只恢复本次改过且仍等于本次值的项；并发修改保留并报告，不能清空所有代理代替恢复。
- 代理自述说明目的、影响进程、风险、撤回方式；只对子进程注入时无需转储父进程全部秘密。后台应用继续运行仍持有旧环境，关闭终端不等于应用已恢复。
- 需要持久写用户或机器环境时先展示真实作用域与原值类别，防重复，写后读回；保密快照与脱敏日志分离。没有对应授权就不升级到机器级、系统代理或全局 Git 配置。
- `$HOME`、`$PID`、`$Host`、`$Error` 等是自动变量或系统变量，不拿来存业务状态。使用 `JobsTargetRoot`、`JobsProcessId` 等职责名称，特别注意 PowerShell 变量名不区分大小写。

### 8.3、<span id="process-receipt">进程收据至少核对 PID、启动时间和路径</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W08 `Add-OriginProcess / Stop-OriginProcesses`、W11 `Server-IsRunning` 都不只信 PID。以下归纳方法只**验证**一个已有收据，不终止进程；调用者仍要先验证收据文件的归属和不可被未授权修改的存储边界。

```powershell
# 根据已验证的项目收据查找本实例，不按名称或端口接管陌生进程。
function Get-JobsOwnedProcess {
    param([Parameter(Mandatory = $true)]$Receipt)
    $item = Get-Process -Id ([int]$Receipt.pid) -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    try {
        $started = $item.StartTime.ToUniversalTime().Ticks.ToString()
        if ($started -cne [string]$Receipt.started -or $item.Path -cne [string]$Receipt.path) {
            throw 'PID 已复用或路径不匹配，拒绝控制该进程。'
        }
        return $item
    } catch {
        $item.Dispose()
        throw
    }
}
```

不能读取身份就保留并停止该动作；不要 `taskkill /IM` 扫同名程序，也不要按端口杀服务。部署前记录项目、用户／SID、实例和平台归属；服务管理器托管的服务按原管理器停止，不能混用“前台终端退出即回收”的策略。

## 九、<span id="backup-and-rollback">幂等、并发检查与恢复</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 9.1、<span id="backup-edit-template">先预览，确认后复检，再备份写入</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W01 `Invoke-JobsReplace` 的成熟顺序是：扫描计划、保存原文／BOM／哈希、显示命中、确认、检查是否被并发修改、备份、替换。下面归纳为**单个已有 UTF-8 文件**的提交方法；参数中的哈希与新文本由先前只读计划产生，调用者先完成普通确认或危险门禁。

```powershell
# 提交一个已确认计划：拒绝并发变更，保留原件备份，不承诺多文件事务。
function Set-JobsPlannedText {
    param(
        [string]$Path, [string]$ExpectedSha256,
        [AllowEmptyString()][string]$NewText, [bool]$Bom
    )
    $parent = Resolve-JobsPlainDirectory ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($Path)))
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw '需要不带链接的普通文件。'
    }
    if ((Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash -ine $ExpectedSha256) {
        throw '文件已并发修改，保留现状。'
    }
    $doc = Read-JobsUtf8Document $item.FullName
    if ($doc.Text -ceq $NewText -and $doc.Bom -eq $Bom) { return $null }
    $suffix = [DateTime]::Now.ToString('yyyyMMdd-HHmmss-fff') + '-' + [Guid]::NewGuid().ToString('N')
    $backup = $item.FullName + '.jobs-backup-' + $suffix
    Copy-Item -LiteralPath $item.FullName -Destination $backup -ErrorAction Stop
    if ((Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash -ine $ExpectedSha256) {
        throw '备份与计划快照不符，停止写入。'
    }
    if ((Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash -ine $ExpectedSha256) {
        throw '备份期间原件发生变化，保留原件与备份。'
    }
    Write-JobsUtf8Document -Path $item.FullName -Text $NewText -Bom $Bom
    $writtenHash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
    return [pscustomobject]@{
        Path = $item.FullName; Backup = $backup
        Before = $ExpectedSha256; After = $writtenHash
    }
}
```

- 这是普通文件操作的基础模板，写入本身不是原子事务；崩溃／磁盘故障仍可能留下部分内容，但备份可用于核对。要求更高时采用同卷暂存替换、ACL／元数据保存、事务收据和独占锁，并针对文件系统实测。
- 恢复时先检查当前文件哈希仍等于收据 `After`，备份等于 `Before`；不满足就保留并报告。不能拿旧备份盲盖用户后来编辑的文件。
- 追加内容用完整行或受控标记块判断是否已存在，重复执行无差异不写；不得因为找到一段相似子串就判断整块已完整安装。
- 多文件任务逐项记录完成／失败，任一失败最终返回非零并保留已完成清单；不能因最后一项成功就覆盖前面失败，也不能把单文件备份误称为整批自动回滚。

### 9.2、<span id="deployment-contract">部署与反部署共用一份归属协议</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> W08 / W09 是需要整体复用行为的成熟来源；不能从中只摘 `Remove-Item -Recurse`，丢掉原点、锁和恢复证据。

| 阶段 | 必须保留的证据 | 失败／取消边界 |
| --- | --- | --- |
| 部署前 | 项目、平台、实例归属；已有配置与依赖清单；原始哈希和必要 ACL | 非空无主目录、另一平台持有、未知锁均保留并停止。 |
| 取得互斥 | `FileShare.None` 等原生排他机制；锁拥有者身份 | 不能仅靠“锁目录存在／PID 不在”推断锁可回收。 |
| 部署后 | 实际创建／替换清单、版本、备份、进程身份 | 已有与新建、共享与专用分别登记。 |
| 停止实例 | PID、启动时间、程序路径及项目收据 | 身份未知、权限不足、PID 复用时不强杀。 |
| 数据选择 | 默认备份／明确清零；附件、密钥与配置配套范围 | 选择与危险授权分别处理；取消、空选不清理。 |
| 校验备份 | 清理树外备份、可恢复材料及完整性验证 | 备份失败或源已变化时保留源和旧备份，不继续清零。 |
| 恢复原点 | 对照旧／新哈希，分阶段记录已恢复项 | 并发修改不覆盖；中断后允许按收据核对续行。 |
| 完成验收 | 配置、服务、SDK／缓存及数据去向逐项对账 | 有未完成项就明确报告，不能笼统称“已回到原点”。 |

- 原生部署／反部署脚本内嵌核心生命周期；允许必要冗余，不要求目标机器先跑开发期生成器或额外准备无关解释器。修复要查齐授权范围中的同源副本并做行为等价验证。
- `Remove-Item -Recurse -Force` 只能作为已确认清单内对象的最终动作，不能替代项目归属判定。原有／共享 SDK、用户 PATH、外部数据库和其它项目实例全部保留。
- W11 将实例、加密备份和恢复私钥放在源码外，并要求备份与私钥不在同一目录树；“已生成备份文件”“已实际解密检查”“已完成恢复演练”分别记录，不能互相冒充。
- 互斥与状态回执是协议，不能只为省代码换成另一种格式；升级读取旧状态时显式兼容或阻断，不把未知格式当作全新部署。

### 9.3、<span id="file-volumes">大文件用流式分卷、候选校验和无覆盖发布</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

W12 的固定写法适合归纳为文件处理协议；不把 `ReadAllBytes` 文本模板拿来处理任意体积镜像。

- 卷名带明确的序号／总数；先验证同目录、同原文件名、编号连续且无重复、总长度不溢出。Windows 保留设备名、尾点／空格和非法字符在命名阶段拒绝。
- 所有输入先按 Windows 的 `FileShare.Read` 规则打开以阻止其它写入和删除，校验元数据快照，再创建 `CreateNew` 候选；所有流和哈希对象在 `finally` 中释放。真实共享语义须在 Windows 验证。
- 固定大小缓冲区复制并累计哈希；输出刷新后重新读取，核对长度和 SHA-256，再复查输入未变。分卷完成还按顺序重组摘要与源摘要比较，防止只验每卷却漏掉顺序错误。
- 归纳后的发布候选应放在**最终目标所在文件系统**，目标已存在拒绝覆盖；跨卷另行复制和复验，不承诺 `File.Move` 自动完成跨卷原子发布。W12 默认同源目录候选、可选异盘输出这一组合需要单独处理。
- 未发布候选保留为 `.partial` 并说明位置，源文件与完整分卷保留；重复运行先发现已存在结果，不自动清空旧数据。

## 十、<span id="windows-specific">Windows 平台动作单独归纳</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 10.1、<span id="platform-boundaries">注册表、任务、服务与快捷方式</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 这些动作不能靠把 MacOS 命令名替换掉完成；复用时先确认作用域、身份、反向操作和最低系统能力。

| 场景 | 当前可参考的本地实现 | 固定写法／检查点 |
| --- | --- | --- |
| 计划任务 | W01 `Invoke-JobsScheduler` | 用明确的 `JobsScheduler-` 名称和当前用户归属，确认后增删启停；命令路径与参数分开，不把用户输入当可执行代码。 |
| 快捷方式 | [快捷方式功能](../../JobsGenesis/OS@Extension/WindowsOS@Extension/JobsCommandShortcutCreator/Scripts/CommandShortcut.ps1) | 区分目标文件、参数、工作目录和图标；依赖不存在就报告，不能把开发路径写进分发产物。 |
| 右键菜单 | W06 独立功能包 | 用户级与机器级登记分开；安装／卸载只管理本包键值，保留同名冲突和用户修改证据。 |
| 文件扩展名显示 | [JobsSh 显示设置](../../JobsGenesis/JobsSh.sh/WindowsOS/【WindowsOS】文件扩展名显示.ps1) | 作用于当前用户的具体配置项；写前快照、写后读取，区分配置已写与 Explorer 已刷新。 |
| 容器 | W01 `Get-JobsContainer / Require-JobsDocker` | 检查真实引擎和运行模式；同名容器必须有本工具 owner 标签，卷数据不能随容器顺手删除。 |
| Windows 服务 | [JobsSh 服务工具](../../JobsGenesis/JobsSh.sh/WindowsOS/JobsTools.ps1) | 仅操作当前入口负责的服务；启动／停止／卸载分开，管理员权限不足明确失败，不静默提权。 |

注册表值除数据外还要保存是否存在与 `RegistryValueKind`，区分 32／64 位视图；恢复只针对本次改动且当前值仍匹配的项。任务计划需要保留触发器、账户、权限和动作；服务需要保留启动类型、二进制路径和归属。通用“导出整个注册表／删整棵服务目录”不属于最小恢复方案。

### 10.2、<span id="windows-not-shell-translation">常见迁移误区</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 调外部工具用 `curl.exe`、`where.exe` 等明确名称并 `Get-Command -CommandType Application`；不要把 5.1 的同名别名当成真实可执行文件。
- PowerShell `-eq / -contains` 默认通常不区分大小写；要求精确大写门禁用 `-ceq`，路径比较按 Windows 文件系统与实际对象规则处理，不能拿它简化所有字符串协议。
- `$?` 与 `$LASTEXITCODE` 是不同结果；`Write-Host` 之后再查看 `$?` 不再证明前一条业务命令成功。
- `Start-Process -ArgumentList` 不等于 `.NET ProcessStartInfo.ArgumentList`；不要因为同名就认为它自动保留任意参数数组边界。
- `.cmd` / `.bat` 内括号块的 `%var%` 会提前展开，`!var!` 又与延迟展开、路径感叹号冲突；复杂业务下沉 `.ps1`，不为省一层文件堆叠转义。
- GUI 管理面板不能替代日志与失败码；静默启动只意味着隐藏窗口，不能说明业务成功。面板线程不执行长任务，后台结果要回传到所属面板，不截取其它窗口进度。
- 5.1 / 7、控制台／GUI、32／64 位、Windows 本机／[**WSL**](https://learn.microsoft.com/windows/wsl/) 是不同组合；通过其中一种不代表全部支持。真实支持矩阵写到对应入口 README，不照搬当前最新版号码作保证。

## 十一、<span id="validation">如何验证这些范本</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 11.1、<span id="ast-validation">先做 AST 解析，再做隔离行为检查</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

下面只解析指定脚本，不执行主体、安装和模块加载。兼容 5.1 的脚本还要在 5.1 本机解析并验证运行库；新版宿主解析通过只能证明当前解析器接受语法。

```powershell
# 使用实际待检查的脚本路径替换参数值；Parser 不执行脚本主体。
param([Parameter(Mandatory = $true)][string]$ScriptPath)
$tokens = $null
$parseErrors = $null
$null = [Management.Automation.Language.Parser]::ParseFile(
    $ScriptPath, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count -gt 0) {
    $parseErrors | ForEach-Object {
        [Console]::Error.WriteLine(('{0}:{1} {2}' -f $ScriptPath,
            $_.Extent.StartLineNumber, $_.Message))
    }
    exit 1
}
Write-Host 'AST 语法解析通过；尚未执行业务。'
```

- 用临时目录验证中文、空格、`[]`、括号、不同工作目录、整包复制与改名；新建和覆盖分别测试，不在真实用户目录试删。
- 用假命令／隔离 PATH 测全链健康、末端缺失、上游缺失、安装失败、安装后复检失败。不能为验证控制流运行真实安装器。
- 文本覆盖零差异、BOM／换行保留、非法 UTF-8、二进制、链接祖先、并发改动、备份失败、重复执行和恢复冲突。
- 网络覆盖错误页、摘要不符、404、超时、超过旧次数后恢复、等待中取消、缓存身份不符；拦截新增探测入口，避免旧 mock 漏网触发真实下载。
- 真实 TTY 覆盖默认取消、每种键位、EOF、子层返回、重新进入、终端配色和恢复；静态出现按键名不代表交互已通过。
- 部署用隔离资源验证原有／新建／共享对象、锁竞争、PID 复用、备份与清零、失败续行和重复反部署；不卸载用户真实环境。

### 11.2、<span id="validation-status">本文的核对范围</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

本文来源通过本机只读核对；13 个 PowerShell 代码块已在当前 MacOS 的 PowerShell 7.7.0 中通过 AST 解析，20 项隔离检查覆盖 BOM／换行保留、无差异写入、并发拒绝、非法 UTF-8、二进制拒绝、目录排除、链接拒绝、工作目录恢复、来源脱敏、原生命令失败码和 Check／Plan 不落盘。组合片段时必须保留各节声明的依赖方法和最低版本，不能把每段当成可单独分发的完整程序。

Windows PowerShell 5.1 本机执行、Windows 真实键盘与控制台恢复、Batch 参数解析、注册表／任务／服务操作和真实部署／反部署不在本轮实测范围。MacOS 上的 `pwsh` 不代替这些验收；检查状态应随后续真实修改同步更新。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
