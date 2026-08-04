---
title: "Git 故障诊断与恢复手册"
date: 2026-08-04T15:56:10+08:00
draft: false
weight: 630
summary: "## 🔥 前言 > 这是一份“先恢复开发节奏，再追根因”的故障手册。目标不是背诵清理命令，而是先判断失败发生在工作区、索引、本地对象库、引用、远端传输还是托管平台，然后只修改真正阻塞的那一层。 ## 一、六层状态模型 🔼 🔽 | 层 | 典型对象 | 常用观察命令 | 常见故障 | | --- | --- | --- | --- | | 工作区 | 当前文件"
bookCollapseSection: false
---


![Jobs出品，必属精品](https://picsum.photos/1500/400)


---

## 🔥 <font id=前言>前言</font>

> 这是一份“先恢复开发节奏，再追根因”的故障手册。目标不是背诵清理命令，而是先判断失败发生在工作区、索引、本地对象库、引用、远端传输还是托管平台，然后只修改真正阻塞的那一层。

## 一、六层状态模型 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 层 | 典型对象 | 常用观察命令 | 常见故障 |
| --- | --- | --- | --- |
| 工作区 | 当前文件内容 | `git status`、`git diff` | 冲突、权限、文件与目录互换、未跟踪文件遮挡。 |
| 索引 | 下一次提交的快照 | `git diff --cached`、`git ls-files -s` | 暂存遗漏、锁、gitlink 与 `.gitmodules` 不一致。 |
| 本地对象库 | commit、tree、blob、tag | `git cat-file`、`git fsck` | 对象损坏、悬空对象、磁盘或文件系统异常。 |
| 本地引用 | `HEAD`、分支、标签、reflog | `git show-ref`、`git reflog` | 引用锁、分支指向错误、reflog 过期。 |
| 远端跟踪引用 | `refs/remotes/<远端>/...` | `git for-each-ref`、`git remote show` | stale ref、D/F 冲突、大小写碰撞。 |
| 远端服务 | GitHub、GitLab、自建服务 | `git ls-remote`、平台审计日志 | 认证、权限、保护分支、仓库不存在、服务故障。 |

## 二、通用止损清单

### 2.1、先保存现场

```shell
snapshot_dir="$(mktemp -d "${TMPDIR:-/tmp}/git-diagnosis.XXXXXX")"
git status --short --branch
git diff > "$snapshot_dir/git-working-tree.patch"
git diff --cached > "$snapshot_dir/git-index.patch"
git ls-files --others --exclude-standard > "$snapshot_dir/untracked-files.txt"
git reflog -30 --date=iso
git remote -v
git submodule status --recursive
```

- Patch 只保存文本差异，不包含未跟踪文件、空目录、文件权限之外的元数据或子模块内部未提交内容；重要未跟踪文件要另行复制。
- 仓库正在 rebase、merge、cherry-pick 或 revert 时，先用 `git status` 识别进行中的操作，不要混用另一套 `--continue` / `--abort`。
- 不知道能否恢复时，不执行 `git gc --prune=now`、`git prune`、`reset --hard`、`clean -fdx` 或删除整个 `.git`。

### 2.2、确认真实仓库与 Git 目录

```shell
git rev-parse --show-toplevel
git rev-parse --git-dir
git rev-parse --git-common-dir
git worktree list --porcelain
```

- 普通仓库的 Git 目录通常是根目录下的 `.git`。
- 子模块和 linked worktree 的 `.git` 可能是指向真实 gitdir 的文本文件；不能据此认定仓库损坏。
- 多 worktree 共用对象与部分引用。手动改 `.git` 元数据前必须看 `--git-common-dir`，否则可能改错位置。

## 三、无法 `Commit`

### 3.1、先区分“无法暂存”与“无法创建提交”

```shell
git status --short --branch
git diff
git diff --cached
git add --dry-run -A -- .
```

- `git add` 把工作区内容写入索引；`git commit` 读取索引并创建提交。
- Sourcetree 的 Commit 界面会同时编排暂存、移除和提交，因此界面上的 Commit 失败可能实际是某条 `git add` 或 `git rm` 失败。
- `git add -A -- .` 会在当前路径范围内统一记录新增、修改和删除；`--` 结束选项解析，避免以 `-` 开头的路径被当作参数。

### 3.2、错误分流

| 报错或现象 | 根因方向 | 先做什么 |
| --- | --- | --- |
| `nothing to commit` | 索引没有相对 `HEAD` 的变化 | 看 `git diff --cached`；需要提交的内容先暂存。 |
| `unmerged files` | merge/rebase/cherry-pick 冲突未解决 | `git status`，解决每个冲突后 `git add`，再执行对应 `--continue`。 |
| `Author identity unknown` | `user.name` / `user.email` 缺失 | 先查配置来源，再按仓库或全局设置。 |
| `index.lock: File exists` | 另一个 Git 进程仍在运行，或进程异常退出留下旧锁 | 先确认进程；只在没有 Git 进程时移走旧锁。 |
| Hook 返回非零 | `pre-commit`、`commit-msg` 等校验失败 | 直接运行 Hook 或查看输出；`--no-verify` 只用于定位，不是长期修复。 |
| GPG / SSH signing failed | 签名程序、密钥、agent 或 pinentry 异常 | 查 `commit.gpgsign`、`gpg.format` 与 signing key。 |
| `.gitmodules` / gitlink 报错 | 子模块配置、路径与索引模式 `160000` 不一致 | 进入 3.5 子模块预检。 |
| `not removing ... recursively without -r` | GUI 对文件/目录互换或目录删除做了分步 `git rm` | 用完整索引刷新替代逐路径操作，并先核对范围。 |
| `No space left on device` / 只读错误 | 磁盘、配额、挂载或权限问题 | 先处理系统资源，不要反复重建索引。 |

### 3.3、身份、Hook 与签名

```shell
git config --show-origin --get-regexp '^user\.(name|email)$'
git config --show-origin --get commit.gpgsign
git config --show-origin --get gpg.format
git config --show-origin --get user.signingkey
git config --show-origin --get core.hooksPath
find "$(git rev-parse --git-path hooks)" -maxdepth 1 -type f -perm -u+x -print
```

`core.hooksPath` 没有输出时，Hook 默认在 `git rev-parse --git-path hooks` 指向的目录；如果它有输出，应检查配置指向的目录，而不是继续假设使用默认 `.git/hooks`。

- 仅当前仓库设置身份：

  ```shell
  git config user.name 'Your Name'
  git config user.email 'you@example.com'
  ```

- `git commit --no-verify` 会跳过 `pre-commit` 和 `commit-msg` 等 Hook，可能绕过团队质量门禁；只能在确认规则允许且已理解后果时使用。
- `git commit --no-gpg-sign` 可用来判断是否由签名链路造成，但不应在强制签名的仓库中当成最终方案。

### 3.4、锁文件

```shell
ps aux | grep '[g]it'
find "$(git rev-parse --git-dir)" -maxdepth 2 -name '*.lock' -print
```

处理原则：

1. 先退出正在操作同一仓库的 Git 客户端、编辑器任务和 Sourcetree 动作。
2. 确认没有 Git 进程仍使用该仓库。
3. 把明确的旧锁移动到备份位置，而不是直接批量删除。
4. 重新运行最小只读命令，例如 `git status`，确认仓库恢复。

### 3.5、子模块与 Jobs Commit 修复脚本

父仓索引用模式 `160000` 记录子模块提交，也称 gitlink；父仓不会直接提交子模块工作区里的文件修改。

```shell
git ls-files -s | awk '$1 == 160000 { print $2, $4 }'
git submodule status --recursive
git config --file .gitmodules --get-regexp '^submodule\..*\.(path|url)$'
```

[**Jobs SourceTree Commit 修复动作**](https://github.com/JobsKits/SourceTree.sh/tree/main/%E3%80%90MacOS%40SourceTree%E3%80%91%F0%9F%93%A5%E4%BF%AE%E5%A4%8DGit%E6%97%A0%E6%B3%95Commit.command) 当前实现的核心流程是：

1. 有 `.gitmodules` 变更时先执行 `git add -A -- .gitmodules`，满足删除或迁移 gitlink 前的配置一致性要求。
2. 从索引读取全部 `160000` gitlink，检查缺失、空目录、路径迁移和 `.git/core.worktree` 错位。
3. 缺失工作树按 `.gitmodules` 尝试 `git submodule update --init --recursive`。
4. 如果父仓锁定提交已经无法从新克隆子模块取到，但脚本得到一个有效且 clean 的当前 `HEAD`，会保留这个工作树；后续全量暂存可能让父仓 gitlink 改指该 `HEAD`，必须人工判断这个依赖升级是否正确。
5. 同一 `.gitmodules` section 改路径时，会在旧路径不存在、URL 与 gitdir remote 能相互验证等条件下同步 `.gitmodules`、`core.worktree` 与新旧 gitlink；条件不足时停止。
6. 已登记到 `.gitmodules` 的同源副本如果借用了旧路径 gitdir，会尝试复制独立 gitdir；当前 Sourcetree 书签自身借错 gitdir 时，也可能把它转换为独立 Git 工作树。
7. 子模块内部有真实修改时保留原样并报告；父仓提交仍只记录 gitlink 指向，不会包含子模块未提交文件。
8. 预检通过后执行 `git add -A -- .`，用一次完整索引刷新替代 Sourcetree 对单个路径的分步 `add` / `rm`。
9. 脚本不会执行 `commit`、`push`、`reset`、`clean`，不使用 `git add -f`，但会修改索引、Git 元数据，并可能访问子模块远端；执行后必须检查暂存区。

### 3.6、运行 Commit 修复动作

在 Sourcetree 中选中目标仓库，运行自定义动作 `📥修复Git无法Commit`。动作接收 `$REPO` 后直接执行；结束后回到“文件状态”刷新，并逐项核对：

```shell
git status --short --branch
git diff --cached -- .gitmodules
git diff --cached --submodule
git ls-files -s | awk '$1 == 160000 { print $2, $4 }'
```

终端独立运行时，不要把 `~` 放进单引号；使用明确安装根目录：

```shell
source_tree_actions_root='/path/to/SourceTree.command'
"${source_tree_actions_root}/【MacOS@SourceTree】📥修复Git无法Commit.command/【MacOS@SourceTree】📥修复Git无法Commit.command" \
  '/path/to/repository'
```

日志写到系统临时目录，文件名为 `【MacOS@SourceTree】📥修复Git无法Commit.log`。日志可能包含本机路径、远端和子模块状态，分享前脱敏。

## 四、无法 `Fetch`

### 4.1、Fetch 到底会改什么

`git fetch` 下载远端对象，并按 refspec 更新本地引用；常见映射是：

```ini
[remote "origin"]
  fetch = +refs/heads/*:refs/remotes/origin/*
```

因此，即使工作区完全没改，Fetch 仍会写入 `FETCH_HEAD`、远端跟踪引用、reflog、对象与维护数据。Fetch 不会自动把远端提交合并进当前本地分支；那是 Pull 或后续 merge/rebase 的职责。

### 4.2、先做最小诊断

```shell
git remote -v
git remote get-url --all origin
git ls-remote --heads origin
git fetch --prune origin
git for-each-ref --format='%(refname) %(objectname)' refs/remotes/origin/
```

| 报错 | 方向 | 检查 |
| --- | --- | --- |
| `Could not resolve host` | DNS 或网络 | 域名解析、网络、代理。 |
| `Connection timed out` / refused | 网络、端口、防火墙、服务不可用 | HTTPS/SSH 端口和远端状态。 |
| `Permission denied (publickey)` | SSH key、agent、Host 配置或账号权限 | `ssh -vT git@github.com`，不要先重建所有密钥。 |
| HTTP `401` / `403` | Token、SSO、权限或组织策略 | 凭据来源、Token 权限、有效期和 SSO 授权。 |
| `repository not found` | URL 错误、仓库被移动/删除，或无权访问私有仓库 | `git remote get-url` 与平台页面。 |
| `cannot lock ref` + `.lock` | 并发进程或旧锁 | 先确认 Git/Sourcetree 进程。 |
| `refs/remotes/...` + `Not a directory` | 远端跟踪引用 D/F 冲突 | 进入 4.3。 |
| `exists; cannot create` | 分支前缀互换或大小写路径碰撞 | 对比远端真实分支与本地 refs。 |
| `bad object` / `missing blob` | 对象库或引用损坏 | 备份后执行 `git fsck --full`，必要时重新克隆对比。 |
| `No space left on device` | 磁盘空间或配额 | 先释放空间并检查文件系统。 |

### 4.3、远端引用的文件/目录冲突

Git 引用名映射为层级路径。远端从 `release` 迁移到 `release/v2` 时，本地旧的 `refs/remotes/origin/release` 可能是文件，而新分支需要它成为目录；反向迁移也会产生目录挡住文件的问题。macOS 默认大小写不敏感文件系统还可能把远端的 `SaaS` 与 `saas/...` 映射到同一路径。

安全顺序：

1. 先正常 `git fetch --prune`，只在命中特定引用路径冲突时进入修复。
2. 用 `git ls-remote --heads <远端>` 读取远端真实分支，不能只相信本地缓存。
3. 只提取错误明确点名的目标分支，不扫描并删除整个远端引用空间。
4. 先执行 `git remote prune <远端>` 清理远端已删除的跟踪引用。
5. 如果 loose ref 或 reflog 仍造成文件/目录阻塞，把精确路径移动到备份区。
6. 再次 Fetch，并以退出码和目标引用是否生成作为成功条件。

[**Jobs SourceTree Fetch 修复动作**](https://github.com/JobsKits/SourceTree.sh/tree/main/%E3%80%90MacOS%40SourceTree%E3%80%91%F0%9F%93%A5%E4%BF%AE%E5%A4%8DGit%E6%97%A0%E6%B3%95Fetch.command) 已按上述边界实现，备份写入当前仓库 Git 元数据下的：

```text
.git/jobs-ref-conflict-backups/YYYYMMDD-HHMMSS-PID/
├── refs/remotes/...
└── logs/refs/remotes/...
```

脚本不执行 Pull、merge、rebase、commit、push、reset 或 checkout；它只更新 Fetch 本来就会更新的远端跟踪状态，并移动本次明确阻塞的 loose ref/reflog。网络、DNS、代理、认证、权限、真实并发锁和磁盘故障不属于该脚本的修复范围。

### 4.4、为什么不直接删除整个 `refs/remotes/origin`

- 远端跟踪引用本身可重新 Fetch，但 reflog 可能承载本地排错证据。
- 多 worktree、packed refs、特殊 refspec 和多个远端可能让“看似只是缓存”的目录承担更多状态。
- 大小写碰撞时，被阻塞的路径可能仍对应远端有效分支；全部删除会扩大影响范围。
- 精确备份后重试既保留证据，也能验证真正阻塞点。

### 4.5、运行 Fetch 修复动作

在 Sourcetree 中选中目标仓库，运行自定义动作 `📥修复Git无法Fetch`。默认远端为 `origin`；只有普通 Fetch 已失败且错误命中远端跟踪引用路径冲突时，脚本才进入备份修复。

终端运行：

```shell
source_tree_actions_root='/path/to/SourceTree.command'
"${source_tree_actions_root}/【MacOS@SourceTree】📥修复Git无法Fetch.command/【MacOS@SourceTree】📥修复Git无法Fetch.command" \
  '/path/to/repository'
```

指定其它远端：

```shell
source_tree_actions_root='/path/to/SourceTree.command'
"${source_tree_actions_root}/【MacOS@SourceTree】📥修复Git无法Fetch.command/【MacOS@SourceTree】📥修复Git无法Fetch.command" \
  '/path/to/repository' \
  'upstream'
```

执行后核对：

```shell
git for-each-ref --format='%(refname) %(objectname)' refs/remotes/
git remote show <remote>
git status --short --branch
```

Fetch 动作的日志文件为 `【MacOS@SourceTree】📥修复Git无法Fetch.log`；它会记录两次 Fetch 输出、远端选择、备份路径和最终退出结果。备份属于 Git 元数据排错证据，不应在未确认恢复完成前删除。

## 五、无法 `Pull`

Pull 通常等价于 Fetch 后执行 merge 或 rebase；先把两阶段拆开：

```shell
git fetch --prune origin
git status --short --branch
git log --oneline --graph --decorate --all -30
```

| 现象 | 处理 |
| --- | --- |
| `Need to specify how to reconcile divergent branches` | 本次明确使用 `--rebase`、`--no-rebase` 或 `--ff-only`；不要不理解就全局写死。 |
| `refusing to merge unrelated histories` | 两端没有共同祖先；确认确实要合并两个独立项目后，显式使用 `--allow-unrelated-histories`。 |
| 工作区改动会被覆盖 | 先提交、暂存到 stash，或取消本次整合；不要直接硬重置。 |
| merge/rebase 冲突 | 逐文件解决，确认索引后执行对应 `--continue`；需要放弃时用对应 `--abort`。 |

## 六、无法 `Push`

### 6.1、常见分流

| 报错 | 根因 | 处理 |
| --- | --- | --- |
| `non-fast-forward` | 远端分支含本地未整合的提交，或本地改写了历史 | 先 Fetch 并检查分叉；整合或在明确需要时使用安全强推。 |
| `protected branch hook declined` | 保护分支或服务端 Hook 拒绝 | 走 Pull Request、审批或满足平台规则。 |
| `permission denied` / 403 | 当前凭据无写权限 | 检查账号、远端 URL、Token/SSH 权限和组织策略。 |
| `pre-receive hook declined` | 服务端校验失败 | 阅读远端输出；本地 `--no-verify` 无法跳过服务端 Hook。 |

### 6.2、安全强推

裸 `--force` 会关闭非快进保护，可能覆盖他人提交。优先记录你确认过的远端提交，并把它作为 lease：

```shell
git fetch origin
expected_remote_commit="$(git rev-parse refs/remotes/origin/main)"
git push --force-with-lease=main:"$expected_remote_commit" origin HEAD:main
```

- 如果远端已经不是 `expected_remote_commit`，推送会失败，提醒你重新检查别人的新提交。
- Sourcetree 或后台任务自动 Fetch 可能更新远端跟踪引用；显式写预期提交比无参数 `--force-with-lease` 更清楚。
- 保护分支、服务端 Hook 和权限策略仍可以拒绝强推；客户端参数不能越过服务器规则。

## 七、认证、代理与传输排错

### 7.1、SSH

```shell
ssh -T git@github.com
ssh -vT git@github.com
git config --show-origin --get core.sshCommand
```

- `-vT` 会输出密钥选择、Host 匹配和握手过程；日志可能包含用户名、路径、主机和网络信息，分享前脱敏。
- 多账号应使用 `~/.ssh/config` 的 Host 别名分别绑定 `IdentityFile`，再让不同仓库使用不同别名 URL。
- Host Key 指纹变化不能直接忽略；先从托管平台官方页面核对指纹，排除中间人攻击或域名指向错误。

### 7.2、HTTPS、代理与凭据

```shell
git config --show-origin --get-regexp '^(http\.|https\.|credential\.|remote\.)'
git config --global --get http.proxy
git config --global --get https.proxy
```

- 不把 `http.sslVerify=false` 当通用修复；这会失去 TLS 证书校验。
- 不把 Token 写入远端 URL、脚本、README 或 shell 历史。
- 组织可能要求 SSO、细粒度 Token、审批或限定有效期；“Token 没过期”不等于“对目标仓库有权限”。

## 八、对象、提交与 `stash` 恢复

### 8.1、恢复顺序

1. 先查仍有语义名称的 reflog。

   ```shell
   git reflog show --all --date=iso
   git log -g --all --oneline --decorate
   ```

2. 对删除的 stash 单独查 stash reflog；如果 ref/reflog 已被删除，再查悬空对象。

   ```shell
   git fsck --full --no-reflogs --unreachable
   ```

3. 用 `git show --stat <对象>`、`git show <对象>` 和父提交结构确认候选，不要把所有 dangling commit 自动合并到当前分支。
4. 先创建保护分支或新 stash，再恢复到工作区。

   ```shell
   git branch recover/candidate <commit>
   git stash store -m 'recovered stash' <stash-commit>
   ```

### 8.2、边界

- Push 到远端不会直接清理本地 dangling 对象。对象何时被删除取决于本地引用、reflog 过期、`git gc` / `git maintenance` / `git prune` 和相关配置。
- `git fsck --lost-found` 会把 dangling commit 和其它对象写入 `.git/lost-found`，但它不会判断哪个对象是用户要找的 stash。
- stash 通常不是单一普通提交，可能包含工作区、索引以及可选未跟踪内容的多父提交结构；恢复前要检查。
- 对象一旦已经被垃圾回收且没有远端、备份、文件系统快照或其它克隆副本，就不能靠 Git 命令凭空恢复。

## 九、诊断日志

```shell
GIT_TRACE=1 git fetch origin
GIT_TRACE_PACKET=1 GIT_TRACE=1 git fetch origin
GIT_CURL_VERBOSE=1 git fetch origin
```

- Trace 会增加大量内部信息。日志可能包含仓库地址、代理、用户名、路径和协议元数据；分享前必须脱敏。
- 只在复现最小问题时开启，完成后不要长期写进全局环境变量。
- Trace 不是修复动作；先保留原始错误，再用它缩小失败阶段。

## 十、官方资料

- [**git-add**](https://git-scm.com/docs/git-add)：索引与 `-A` 语义。
- [**git-fetch**](https://git-scm.com/docs/git-fetch)：远端跟踪引用、refspec 与 pruning。
- [**git-submodule**](https://git-scm.com/docs/git-submodule)：子模块初始化、更新、同步和路径。
- [**git-reflog**](https://git-scm.com/docs/git-reflog)：本地引用历史与过期。
- [**git-fsck**](https://git-scm.com/docs/git-fsck)：对象连通性、dangling 与 lost-found。
- [**git-push**](https://git-scm.com/docs/git-push)：快进规则与 `--force-with-lease`。
- [**GitHub SSH 文档**](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)：密钥、agent 与连接测试。
- [**Atlassian Sourcetree 自定义动作**](https://support.atlassian.com/sourcetree/kb/using-git-in-custom-actions/)：自定义动作入口与执行方式。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
