---
title: "Git 仓库治理与高级工具"
date: 2026-08-04T15:56:10+08:00
draft: false
weight: 760
summary: "## 🔥 前言 > 高级 Git 的价值不在于命令更冷门，而在于能缩小历史、工作区、性能和安全问题的搜索空间。本文覆盖 revision 选择、worktree、stash、rerere、bisect、Hook、签名、稀疏仓库、LFS、离线备份与维护边界。 ## 一、Revision 选择与历史查询 🔼 🔽 ### 1.1、常用选择器 | 语法 | 含义 |"
bookCollapseSection: false
---


![Jobs出品，必属精品](https://picsum.photos/1500/400)


---

## 🔥 <font id=前言>前言</font>

> 高级 Git 的价值不在于命令更冷门，而在于能缩小历史、工作区、性能和安全问题的搜索空间。本文覆盖 revision 选择、worktree、stash、rerere、bisect、Hook、签名、稀疏仓库、LFS、离线备份与维护边界。

## 一、Revision 选择与历史查询 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1.1、常用选择器

| 语法 | 含义 |
| --- | --- |
| `<rev>^` / `<rev>^1` | 第一个父提交。 |
| `<rev>^2` | merge commit 的第二个父提交。 |
| `<rev>~3` | 连续沿第一父提交回退三次。 |
| `A..B` | B 可达但 A 不可达的提交集合。 |
| `A...B` | 对 `git log` 等 revision set，表示两边可达集合的对称差。 |
| `:<path>` / `HEAD:<path>` | 索引或指定 tree 中的路径内容。 |

`git diff A...B` 是容易混淆的特例：它通常比较 `merge-base(A,B)` 与 B，不等同于把 revision set 的对称差逐个做 diff。

先可视化再执行批量历史操作：

```shell
git log --oneline --graph --decorate --all
git log --left-right --cherry-pick A...B
git merge-base A B
git rev-list --count A..B
```

### 1.2、按路径、内容和函数定位

```shell
git log --follow -- <path>
git log --all --full-history -- <path>
git log -S'<exact-string>' -- <path>
git log -G'<regex>' -- <path>
git log -L <start>,<end>:<path>
git blame -w -C -C -- <path>
```

- `-S` 查找某字符串出现次数发生变化的提交；`-G` 查找 patch 文本匹配正则的提交。
- `--follow` 只适用于单一路径的启发式重命名跟踪，不是完整文件身份数据库。
- Blame 显示最后修改某行的提交，不等于证明需求来源、原创作者或责任归属；结合提交、评审和 Issue 判断。

## 二、`worktree`：一个仓库同时检出多个分支

```shell
git worktree list --porcelain
git worktree add --branch hotfix ../project-hotfix origin/main
git worktree lock --reason 'removable drive' ../project-hotfix
git worktree unlock ../project-hotfix
git worktree remove ../project-hotfix
git worktree prune --dry-run --verbose
```

- 多个 worktree 共享对象库和部分引用，但各自有工作区、索引与 `HEAD`。
- 同一普通分支默认不能同时检出到两个 worktree，避免两个工作区竞争移动同一分支。
- 手动删除目录后用 `prune --dry-run` 先预览过期元数据；不要直接批量删 `.git/worktrees`。
- 修复 `.git` 元数据前查看 `git rev-parse --git-common-dir`，避免只修当前 worktree 却损坏共享状态。

## 三、`stash` 与临时上下文

```shell
git stash push --include-untracked --message 'context before hotfix'
git stash list --date=local
git stash show --patch stash@{0}
git stash apply stash@{0}
git stash branch recover/context stash@{0}
```

- 默认 stash 不包含 untracked 和 ignored 文件；`--include-untracked` 包含前者，`--all` 还会包含 ignored，范围更大。
- `apply` 成功后保留 stash；`pop` 会尝试应用并删除，冲突时要核对 stash 是否仍存在。
- stash 是本地对象与引用，不会随普通 Push 自动备份到远端。
- 长期或重要工作不应只靠 stash 保存；创建分支和 WIP commit 更可追溯。

## 四、复用冲突解决：`rerere`

```shell
git config rerere.enabled true
git rerere status
git rerere diff
```

`rerere` 记录冲突形状和已采用的解决方案，后续遇到相同冲突时可复用。自动复用后仍要审查结果和测试；“文本冲突相同”不能证明业务语义仍相同。

共享工作流启用前要明确：是否允许自动暂存、缓存保留多久、怎样清理错误解法，以及 CI 是否会验证复用结果。

## 五、二分定位回归：`bisect`

手动二分：

```shell
git bisect start
git bisect bad
git bisect good <known-good-commit>
```

每轮测试后执行 `git bisect good`、`git bisect bad`，无法判断时用 `git bisect skip`。结束必须：

```shell
git bisect reset
```

自动测试：

```shell
git bisect run ./reproduce-regression.sh
```

- 测试脚本退出 `0` 表示 good，`1` 到 `127`（除 `125`）表示 bad，`125` 表示无法测试当前提交。
- 构建不确定、依赖外部波动或测试有随机性时，bisect 结论也不可靠。
- 问题由两个独立提交组合触发时，单一“首次坏提交”模型可能不足。

## 六、Hook 与自动化边界

常见本地 Hook：`pre-commit`、`commit-msg`、`pre-push`；常见服务端 Hook：`pre-receive`、`update`、`post-receive`。

```shell
git config --show-origin --get core.hooksPath
git rev-parse --git-path hooks
```

- `.git/hooks` 默认不被 Git 提交。团队共享 Hook 应把脚本放在 tracked 目录，再由明确的安装入口或 `core.hooksPath` 接入。
- 客户端 Hook 能改善反馈速度，但用户可绕过或根本未安装；强制质量和权限规则必须在 CI、保护分支或服务器端再次验证。
- `--no-verify` 只能跳过命令支持跳过的客户端 Hook，不能绕过服务器 Hook、Ruleset 或分支保护。
- Hook 会执行本机代码。克隆不受信任仓库后，不应盲目运行仓库提供的安装脚本或把其 Hook 接入全局配置。

## 七、Commit 与 Tag 签名

签名证明“某个受信任密钥签了这个对象”，不自动证明代码正确、账号没有失陷或作者经过人工审核。

SSH 签名示例：

```shell
git config gpg.format ssh
git config user.signingkey ~/.ssh/id_ed25519.pub
git config commit.gpgsign true
git commit -S
git log --show-signature -1
```

本地验证 SSH 签名还需要配置 `gpg.ssh.allowedSignersFile`，把可信身份与公钥建立明确映射。GitHub 的 `Verified` 状态还取决于账号登记、邮箱和平台验证规则；本地成功与平台显示是两层判断。

签名 annotated tag：

```shell
git tag --sign v1.0.0 --message 'Release v1.0.0'
git tag --verify v1.0.0
```

## 八、大仓库与按需检出

### 8.1、Shallow clone

```shell
git clone --depth 1 --single-branch <url>
git fetch --deepen 100
git fetch --unshallow
```

浅克隆缺少部分祖先历史，会影响 merge-base、blame、bisect、版本计算和某些推送。CI 能否使用取决于任务是否需要完整历史。

### 8.2、Partial clone

```shell
git clone --filter=blob:none <url>
```

Partial clone 保留提交和 tree，但按需获取缺失 blob；需要服务器支持。它不是离线完整备份，后续访问旧文件内容可能再次联网。

### 8.3、Sparse checkout

```shell
git clone --sparse <url>
git sparse-checkout set src docs
git sparse-checkout list
git sparse-checkout disable
```

Sparse checkout 只控制工作区展开范围，不自动减少所有对象下载；可与 partial clone 组合。脚本不能把未展开路径误判为仓库丢文件。

### 8.4、Git LFS

```shell
git lfs install --local
git lfs track '*.psd'
git add .gitattributes
git add <large-files>
```

LFS 在 Git 中提交 pointer，对象内容存入独立 LFS 服务。迁移已有大文件历史不能只补一条 `.gitattributes`；需要评估配额、历史重写、fork、Release、CI 拉取与备份策略。没有安装 LFS 的客户端会看到 pointer 或在 checkout 时失败。

## 九、备份、迁移与可移植产物

### 9.1、Bundle

```shell
git bundle create repository.bundle --all
git bundle verify repository.bundle
git bundle list-heads repository.bundle
git clone repository.bundle restored-repository
```

Bundle 保存选定 refs 可达的 Git 对象，不包含未提交工作区、ignored 文件、LFS 服务对象、子模块仓库内容、托管平台 Issue、PR、Actions Secret 或 Release 资产。

### 9.2、Archive

```shell
git archive --format=tar.gz --output=source.tar.gz HEAD
```

Archive 是某个 tree 的文件快照，不含 Git 历史；子模块 gitlink 不会自动展开为子模块文件。

### 9.3、Mirror 迁移

```shell
git clone --mirror <source-url> repository.git
git -C repository.git remote set-url --push origin <target-url>
git -C repository.git show-ref
```

`git push --mirror` 会让目标引用集合匹配镜像，并可能删除目标独有 refs。执行前必须审计源与目标、保护规则、默认分支、LFS、CI、Release 和协作者；不能把它当普通 Push 示例直接运行。

## 十、对象完整性与维护

```shell
git count-objects --verbose
git fsck --full
git maintenance run
git gc
```

- `git fsck` 检查对象连通性和有效性；dangling 不等于损坏，也不等于都应删除。
- `git gc`、`git maintenance` 会打包对象、更新 commit-graph 等辅助结构，并按配置处理不可达对象；不要在恢复误删内容前主动加速清理。
- `git prune` 是底层删除工具，不是日常“修复仓库”命令。
- 维护失败先查磁盘、权限、并发锁、文件系统和 Git 版本；不要直接删除 pack、index、commit-graph 或 refs 文件。

仓库损坏时优先顺序：

1. 停止写入，保存错误和文件系统现场。
2. 复制或快照仓库，再运行 `git fsck --full`。
3. 与可信远端或其它克隆对比缺失对象。
4. 能重新克隆时保留原仓作为证据，不直接覆盖唯一副本。
5. 工作区未提交内容和 Git 对象库分开备份。

## 十一、凭据与历史泄漏治理

- Token、密码、Cookie、私钥和云凭据一旦进入提交或截图，先撤销并轮换；不能等历史清理完成后再处理有效凭据。
- 删除当前文件、补 `.gitignore` 或覆盖截图只影响新提交，不会自动清除旧提交、fork、缓存、Release 和构建产物。
- 历史改写工具会改变提交 ID，需要协调保护分支、开放 PR、标签、部署、镜像和所有克隆；改写后还要阻止旧提交重新推回。
- Secret scanning 能帮助发现已知格式，不代表“未告警就是安全”；高熵随机值、私有格式和图片中的凭据仍需人工与图像审计。
- 远端 URL、进程参数、CI 日志和诊断 Trace 都可能泄漏认证信息；分享前脱敏。

## 十二、官方资料

- [**gitrevisions**](https://git-scm.com/docs/gitrevisions)
- [**git-log**](https://git-scm.com/docs/git-log)
- [**git-worktree**](https://git-scm.com/docs/git-worktree)
- [**git-stash**](https://git-scm.com/docs/git-stash)
- [**git-rerere**](https://git-scm.com/docs/git-rerere)
- [**git-bisect**](https://git-scm.com/docs/git-bisect)
- [**githooks**](https://git-scm.com/docs/githooks)
- [**Git 对象签名**](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- [**partial clone**](https://git-scm.com/docs/partial-clone)
- [**sparse checkout**](https://git-scm.com/docs/git-sparse-checkout)
- [**Git LFS**](https://git-lfs.com/)
- [**git-bundle**](https://git-scm.com/docs/git-bundle)
- [**git-archive**](https://git-scm.com/docs/git-archive)
- [**git-maintenance**](https://git-scm.com/docs/git-maintenance)
- [**git-fsck**](https://git-scm.com/docs/git-fsck)

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
