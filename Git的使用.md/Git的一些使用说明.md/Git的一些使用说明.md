# `Git` 的一些使用说明

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

> 面向已经会使用 `add`、`commit`、`fetch`、`pull` 和 `push` 的开发者，集中说明远端、配置、rebase、cherry-pick、历史改写、stash 恢复和无共同历史合并。临时故障先看 [Git 故障诊断与恢复手册](../Git故障诊断与恢复.md/Git故障诊断与恢复.md)。

## 一、高频观察命令 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1.1、仓库、分支与状态

```shell
git rev-parse --show-toplevel
git status --short --branch
git branch --verbose --verbose
git log --oneline --graph --decorate --all -30
git worktree list
```

### 1.2、远端

```shell
git remote
git remote -v
git remote get-url --all origin
git remote show origin
git remote show -n origin
git config --get-all remote.origin.url
git config --get-all remote.origin.fetch
```

- `git remote show origin` 会联系远端并展示跟踪关系、HEAD 分支和 stale 引用；`-n` 不查询远端，只使用本地缓存。
- 一个远端可以配置多个 Fetch URL 或 Push URL，排错时用 `--all` / `--get-all`，不要只看第一条。

修改远端：

```shell
git remote add origin <url>
git remote set-url origin <new-url>
git remote set-url --add --push origin <push-url>
git remote rename origin upstream
git remote remove origin
```

### 1.3、子模块远端

查看全部已初始化子模块，包括嵌套子模块：

```shell
git submodule foreach --recursive 'printf "[%s]\n" "$name"; git remote -v; printf "\n"'
```

查看指定子模块：

```shell
git -C <submodule-path> remote -v
```

## 二、配置文件与优先级

### 2.1、配置层级

Git 配置不是只有 `.git/config`：

| 层级 | 常用命令 | 典型位置 | 优先级 |
| --- | --- | --- | --- |
| 系统 | `git config --system` | Git 安装或系统配置目录 | 低 |
| 用户 | `git config --global` | `~/.gitconfig` 或 XDG 配置 | 中 |
| 仓库 | `git config --local` | 当前仓库的 Git config | 高 |
| worktree | `git config --worktree` | 启用扩展后的 worktree 配置 | 更具体 |
| 命令行 | `git -c key=value ...` | 仅本次进程 | 最高 |

查值时同时看来源：

```shell
git config --list --show-origin --show-scope
git config --show-origin --get-all pull.rebase
```

### 2.2、仓库配置示例

```ini
[core]
  repositoryformatversion = 0
  filemode = true
  bare = false
  logallrefupdates = true
  ignorecase = true
  precomposeunicode = true
[remote "origin"]
  url = git@github.com:OWNER/REPOSITORY.git
  fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
  remote = origin
  merge = refs/heads/main
[pull]
  rebase = false
```

- `core.repositoryformatversion`：仓库格式版本。不要手工改成未知值。
- `core.filemode`：是否把可执行位变化视为内容变化；它不表示 Git 跟踪全部 Unix 权限。
- `core.bare`：`true` 表示裸仓库，没有普通工作区，常用于服务器端仓库。
- `core.logallrefupdates`：控制分支等引用是否记录 reflog。
- `core.ignoreCase`：Git 在大小写不敏感文件系统上的兼容提示。Git 会在 init/clone 时探测；手工改错可能造成异常行为。
- `core.precomposeUnicode`：macOS Git 对文件名 Unicode 分解/合成的兼容设置，用于跨 macOS、Linux 和 Windows 协作。
- `remote.<name>.url`：远端地址。
- `remote.<name>.fetch`：refspec；示例把全部远端分支映射到 `refs/remotes/origin/*`，前导 `+`允许对应远端跟踪引用接受非快进更新。
- `branch.<name>.remote` 与 `branch.<name>.merge`：共同定义当前分支的 upstream。
- `pull.rebase`：控制 Pull 的整合方式；也可以在单次命令中用 `--rebase`、`--no-rebase` 或 `--ff-only` 覆盖。

## 三、`rebase`

### 3.1、模型

Rebase 选出当前分支相对上游独有的提交，把分支临时移到新基点，再按顺序重放这些提交。它重写提交对象，因此提交 ID 会变化。

```text
A---B---C---D  main
     \
      E---F---G  feature

git switch feature
git rebase main

A---B---C---D  main
             \
              E'---F'---G'  feature
```

### 3.2、价值与代价

- 价值：让主题分支基于新上游继续开发、整理本地提交、减少不必要的 merge commit。
- 代价：提交 ID 改变；已发布分支需要非快进推送；协作者若仍基于旧提交继续工作，会产生重复提交或覆盖风险。
- Rebase 不是“不可逆”。操作进行中可用 `git rebase --abort`；完成后旧分支尖端通常仍能从分支 reflog 找到。但 reflog 有保留期限，对象也可能被垃圾回收，因此不能把恢复能力理解为永久备份。

### 3.3、常用命令

```shell
git switch feature
git rebase main
git rebase --continue
git rebase --skip
git rebase --abort
git rebase --show-current-patch
```

交互式整理当前分支最近 5 个提交：

```shell
git rebase -i HEAD~5
```

完成后查找原分支尖端：

```shell
git reflog show feature --date=iso
```

### 3.4、发布后的安全推送

```shell
git fetch origin
expected_remote_commit="$(git rev-parse refs/remotes/origin/feature)"
git push --force-with-lease=feature:"$expected_remote_commit" origin HEAD:feature
```

裸 `--force` 可能覆盖不在本地历史中的远端新提交。`--force-with-lease` 也不是团队沟通的替代品；共享主分支仍应遵守保护规则。

## 四、`cherry-pick`

### 4.1、语义

`git cherry-pick` 把已有提交引入的变化应用到当前分支，通常为每个被选提交创建一个新的提交。新提交内容可能相同，但父提交、提交者时间和提交 ID 通常不同。

```shell
git switch <target-branch>
git cherry-pick <commit>
```

适合：

- 把修复回移到维护分支。
- 只引入主题分支的一部分提交。
- 在不合并整条分支的前提下复用独立改动。

不适合：

- 需要保留完整分支关系时。
- 同一批提交会长期在多个分支反复双向挑选时；这会增加重复变更与冲突识别难度。

### 4.2、冲突与中止

```shell
git status
git add <resolved-paths>
git cherry-pick --continue
git cherry-pick --skip
git cherry-pick --abort
git cherry-pick --quit
```

- `--abort` 返回本次序列开始前的状态。
- `--quit` 只清除 sequencer 状态，不保证把工作区恢复到开始前。

### 4.3、多个提交与范围

```shell
git cherry-pick <commit-1> <commit-2>
git cherry-pick A..B
git cherry-pick A^..B
```

- `A..B` 表示从 B 可达但从 A 不可达的提交，通常不包含 A。
- 在线性历史中需要同时包含 A 到 B，常用 `A^..B`。
- 范围会触发一次 revision walk；复杂分叉先用 `git log --oneline A..B` 核对实际集合和顺序。
- 跨公开维护分支回移修复时可考虑 `-x`，在提交信息中记录来源提交。

## 五、让主分支指向另一个历史位置

![主分支历史示意](./assets/preview.webp)

### 5.1、先明确三种不同目标

| 目标 | 是否改写历史 | 推荐方式 |
| --- | --- | --- |
| 从旧提交继续新开发，但保留现有 `main` | 否 | 从目标提交创建新分支。 |
| 更换托管平台默认分支 | 不一定 | 推送新分支，在平台设置中切换默认分支。 |
| 让远端 `main` 回退到旧提交 | 是 | 团队确认后重置本地分支，再用带预期值的 lease 推送。 |

### 5.2、安全保留旧历史

```shell
git switch --create new-main <target-commit>
git push --set-upstream origin new-main
```

然后在 GitHub / GitLab 的仓库设置中把 `new-main` 设为默认分支。确认分支保护、CI、部署、Pull Request 基线和协作者都已迁移后，再决定是否删除旧分支。很多托管平台不允许直接删除默认或受保护分支。

### 5.3、确需改写 `main`

```shell
git fetch origin
expected_remote_commit="$(git rev-parse refs/remotes/origin/main)"
git branch backup/main-before-rewrite "$expected_remote_commit"
git switch main
git reset --hard <target-commit>
git push --force-with-lease=main:"$expected_remote_commit" origin main:main
```

- `reset --hard` 会覆盖工作区和索引；执行前确认没有需要保留的本地修改。
- 本地备份分支只存在本机；重要时同步推送到受控的远端备份分支。
- 改写主分支会影响所有协作者、开放 Pull Request、发布与部署，不是个人仓库外的常规操作。

## 六、误删 `stash` 的恢复

### 6.1、先纠正两个误区

- Push 到远端不会直接清理本地 dangling 对象。删除时机由本地引用、reflog 过期、自动维护、`git gc` / `git prune` 和相关配置决定。
- `git fsck` 找到的每个 dangling commit 不一定都是 stash。不能把全部候选自动合并进当前分支。

### 6.2、恢复顺序

先查 reflog：

```shell
git reflog show --all --date=iso
git log -g --all --oneline --decorate
```

如果 stash 引用与 reflog 已不存在，再找悬空对象：

```shell
git fsck --full --no-reflogs --unreachable
```

逐个检查候选：

```shell
git show --stat <candidate-commit>
git show --no-patch --pretty=raw <candidate-commit>
git diff <candidate-commit>^1 <candidate-commit>
```

确认是目标 stash 后，先恢复 stash 引用：

```shell
git stash store -m 'recovered stash' <candidate-commit>
git stash list
git stash show --stat stash@{0}
```

或者先创建保护分支，只读检查其文件树：

```shell
git branch recover/stash-candidate <candidate-commit>
```

### 6.3、恢复边界

- stash 可能由多个父提交分别保存工作区、索引和可选的未跟踪内容；只比较一个父提交可能看不全。
- `git fsck --lost-found` 可以把 dangling 对象写到 `.git/lost-found`，但不会替你识别哪个对象最正确。
- 对象已经被垃圾回收且不存在于远端、备份、文件系统快照或其它克隆时，Git 无法恢复。

## 七、合并无共同历史的仓库

`fatal: refusing to merge unrelated histories` 表示两个提交图没有共同祖先。文件内容相同不代表提交历史相关。

### 7.1、先确认是不是配错远端

```shell
git remote -v
git fetch <remote>
git log --oneline --graph --decorate --all -30
git merge-base HEAD <remote>/<branch> || true
```

如果本应是同一项目却没有共同祖先，优先核对：

- 是否连接了错误仓库。
- 是否有人重新初始化 `.git` 后强推。
- 是否下载源码压缩包后重新 `git init`。
- 是否把两个独立项目误放到同一远端。

### 7.2、确认要合并两个独立历史

```shell
git fetch <remote>
git merge <remote>/<branch> --allow-unrelated-histories
```

如有冲突：

```shell
git status
git add <resolved-paths>
git commit
```

- `--allow-unrelated-histories` 只允许 Git 进入合并，不会自动判断哪边内容正确。
- 不需要先全局设置 `pull.rebase`。把 Fetch 与 Merge 拆开，意图更清楚，也避免意外影响以后所有 Pull。
- 两个项目只是暂时需要互相引用时，submodule、subtree、包管理或保持独立仓库可能比永久合并历史更合适。

## 八、官方资料

- [**Git 配置**](https://git-scm.com/docs/git-config)
- [**Git Rebase**](https://git-scm.com/docs/git-rebase)
- [**Git Cherry-pick**](https://git-scm.com/docs/git-cherry-pick)
- [**Git Push**](https://git-scm.com/docs/git-push)
- [**Git Reflog**](https://git-scm.com/docs/git-reflog)
- [**Git Fsck**](https://git-scm.com/docs/git-fsck)

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
