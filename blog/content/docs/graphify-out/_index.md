---
title: "graphify-out"
date: 2026-08-04T15:56:10+08:00
draft: false
weight: 810
summary: "Corpus Check - 27 files · ~185,019 words - Verdict: corpus is large enough that graph structure adds value. ## Summary - 433 nodes · 473 edges · 35 communities (31 shown, 4 thin om"
bookCollapseSection: false
---


## Corpus Check
- 27 files · ~185,019 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 433 nodes · 473 edges · 35 communities (31 shown, 4 thin omitted)
- Extraction: 78% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 101 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_历史改写与恢复|历史改写与恢复]]
- [[_COMMUNITY_远端同步与文件状态|远端同步与文件状态]]
- [[_COMMUNITY_Git 知识与 Actions 模型|Git 知识与 Actions 模型]]
- [[_COMMUNITY_SSH 身份与提交安全|SSH 身份与提交安全]]
- [[_COMMUNITY_JobsBlock 子模块截图|JobsBlock 子模块截图]]
- [[_COMMUNITY_Git 对象与状态模型|Git 对象与状态模型]]
- [[_COMMUNITY_SSH 密钥生命周期|SSH 密钥生命周期]]
- [[_COMMUNITY_GUI 仓库操作|GUI 仓库操作]]
- [[_COMMUNITY_Git 元数据结构|Git 元数据结构]]
- [[_COMMUNITY_Mermaid Actions 自动化|Mermaid Actions 自动化]]
- [[_COMMUNITY_子模块生命周期与修复|子模块生命周期与修复]]
- [[_COMMUNITY_已脱敏 Classic Token|已脱敏 Classic Token]]
- [[_COMMUNITY_SSH 公钥格式|SSH 公钥格式]]
- [[_COMMUNITY_Classic PAT 权限|Classic PAT 权限]]
- [[_COMMUNITY_Actions 手动运行|Actions 手动运行]]
- [[_COMMUNITY_iOS 协议类图样例|iOS 协议类图样例]]
- [[_COMMUNITY_SSH 主机信任校验|SSH 主机信任校验]]
- [[_COMMUNITY_Actions Secrets 设置|Actions Secrets 设置]]
- [[_COMMUNITY_恢复提交拓扑|恢复提交拓扑]]
- [[_COMMUNITY_添加远端对话框|添加远端对话框]]
- [[_COMMUNITY_远端仓库设置|远端仓库设置]]
- [[_COMMUNITY_子模块目录结构|子模块目录结构]]
- [[_COMMUNITY_Workflow YAML 编辑|Workflow YAML 编辑]]
- [[_COMMUNITY_示例 SSH 公钥表单|示例 SSH 公钥表单]]
- [[_COMMUNITY_已脱敏 Actions Secret|已脱敏 Actions Secret]]
- [[_COMMUNITY_分支提交拓扑|分支提交拓扑]]
- [[_COMMUNITY_Git 配置层级|Git 配置层级]]
- [[_COMMUNITY_Fork PR 权限边界|Fork PR 权限边界]]
- [[_COMMUNITY_子模块版本故障|子模块版本故障]]
- [[_COMMUNITY_凭据泄漏治理|凭据泄漏治理]]
- [[_COMMUNITY_macOS SSH Agent|macOS SSH Agent]]
- [[_COMMUNITY_无共同历史合并|无共同历史合并]]
- [[_COMMUNITY_跨仓库写入凭据|跨仓库写入凭据]]
- [[_COMMUNITY_Git 仓库初始化|Git 仓库初始化]]
- [[_COMMUNITY_HTTPS 凭据诊断|HTTPS 凭据诊断]]

## God Nodes (most connected - your core abstractions)
1. `Git 知识地图` - 12 edges
2. `GitHub 个人访问令牌（classic）` - 12 edges
3. `Git 桌面客户端仓库操作工具栏` - 11 edges
4. `Actions secrets and variables settings page` - 10 edges
5. `已选中的 JobsBlock 子目录` - 10 edges
6. `已登记的 SSH 认证密钥` - 9 edges
7. `Commit Object` - 8 edges
8. `New personal access token (classic) page` - 8 edges
9. `Accepted SSH public key format prefixes` - 8 edges
10. `Git 索引` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Git 知识地图` --references--> `Git Remote Management`  [EXTRACTED]
  Git的使用.md/README.md → Git的使用.md/Git的一些使用说明.md/Git的一些使用说明.md
- `Git 六层状态模型` --semantically_similar_to--> `Git 对象模型`  [INFERRED] [semantically similar]
  Git的使用.md/Git故障诊断与恢复.md/Git故障诊断与恢复.md → Git的使用.md/Git核心原理与日常工作流.md/Git核心原理与日常工作流.md
- `Git Cherry-pick` --conceptually_related_to--> `Commit Object`  [EXTRACTED]
  Git的使用.md/Git的一些使用说明.md/Git的一些使用说明.md → Git的使用.md/Git核心原理与日常工作流.md/Git核心原理与日常工作流.md
- `Submodule Detached HEAD` --semantically_similar_to--> `Detached HEAD`  [INFERRED] [semantically similar]
  Git的使用.md/Git子模块使用.md/Git子模块使用.md → Git的使用.md/Git核心原理与日常工作流.md/Git核心原理与日常工作流.md
- `Git SSH Transport Diagnosis` --conceptually_related_to--> `SSH Authentication to GitHub`  [INFERRED]
  Git的使用.md/Git故障诊断与恢复.md/Git故障诊断与恢复.md → Git的使用.md/通过SSH连接到GitHub/通过SSH连接到GitHub.md

## Hyperedges (group relationships)
- **Git 工作区、索引、对象库与引用状态流** — git_working_tree, git_index, git_object_database, git_ref, git_head [EXTRACTED 1.00]
- **Jobs SourceTree Commit 与 Fetch 修复体系** — sourcetree_sh, jobs_commit_repair_action, jobs_fetch_repair_action, git_submodule_preflight, git_ref_df_conflict, git_ref_conflict_backup [EXTRACTED 1.00]
- **Mermaid Actions 验证与发布流水线** — mermaid_workflow_yaml, actions_verify_job, actions_publish_job, mermaid_cli_11_16, generated_diagram_png, actions_no_change_guard [EXTRACTED 1.00]

## Communities (35 total, 4 thin omitted)

### Community 0 - "历史改写与恢复"
Cohesion: 0.08
Nodes (26): Pre-rewrite Backup Branch, Git Branch, Dangling Git Object, Detached HEAD, Fast-forward Integration, Force-with-lease, git fsck, Git Garbage Collection (+18 more)

### Community 1 - "远端同步与文件状态"
Cohesion: 0.08
Nodes (25): 跨平台大小写与 Unicode 文件名, Git Clone, 可审查提交设计, 可复核 Git 日常流程, Git Fetch, Git Fetch Failure Diagnosis, Git 文件生命周期, core.excludesFile (+17 more)

### Community 2 - "Git 知识与 Actions 模型"
Cohesion: 0.09
Nodes (23): act Local GitHub Actions Emulator, GitHub Actions Supply Chain Security, Atlassian Sourcetree Support, Git 文档维护与可信度规则, Git Blame Semantics, Git Cherry-pick, Commit、Fetch、Pull、Push 故障分流, Git 知识地图 (+15 more)

### Community 3 - "SSH 身份与提交安全"
Cohesion: 0.09
Nodes (23): Git Author Identity, Git Commit Failure Diagnosis, Commit Identity 与 SSH Identity 分离, Git Commit Signing, Git Hook, Git Hook Governance, Git index.lock, Git SSH Object Signing (+15 more)

### Community 4 - "JobsBlock 子模块截图"
Cohesion: 0.12
Nodes (21): 按不定参数与确定参数组织 Block API, JobsBlock 作为 CocoaPods 库进行定义与发布, 名称被截断的 CocoaPods 发布 Shell 脚本, 文件管理器三列目录层级视图, 确定参数的Block 目录, JobsOCKit 的 .gitmodules 文件, 已选中的 JobsBlock 子目录, JobsBlock 内部的 .git 目录 (+13 more)

### Community 5 - "Git 对象与状态模型"
Cohesion: 0.14
Nodes (19): Annotated Tag Object, Git Archive, Git Bisect, Blob Object, Git Bundle, Commit Object, Git 冲突索引阶段, Git 索引 (+11 more)

### Community 6 - "SSH 密钥生命周期"
Cohesion: 0.15
Nodes (18): Authentication Keys 认证密钥列表, Common SSH problems 故障排查入口, Delete 删除 SSH 密钥操作, Generating SSH keys 指南入口, 使用 SSH 密钥认证 GitHub 连接, GitHub 账户 SSH keys 管理页面, SSH 密钥添加日期元数据, 密钥使用状态：Never used (+10 more)

### Community 7 - "GUI 仓库操作"
Cohesion: 0.15
Nodes (18): 分支操作, 分支创建与历史整合, 提交操作, 抓取操作, Git 桌面客户端仓库操作工具栏, 记录本地仓库变更, 合并操作, 拉取操作 (+10 more)

### Community 8 - "Git 元数据结构"
Cohesion: 0.12
Nodes (18): .git/COMMIT_EDITMSG 文件, 提交消息编辑缓冲内容, 当前检出分支或提交的 HEAD 引用, 用占位文件保留空目录的惯例, .git/FETCH_HEAD 文件, 最近抓取的远端引用元数据, 文件管理器列视图, 已选中的 .git/config 文件 (+10 more)

### Community 9 - "Mermaid Actions 自动化"
Cohesion: 0.15
Nodes (17): actions/checkout@v7, GitHub Actions Concurrency, No-change Commit Guard, Publish Mermaid Diagrams Job, Pull Request main Trigger, Push main Trigger, actions/setup-node@v7, Verify Mermaid Rendering Job (+9 more)

### Community 10 - "子模块生命周期与修复"
Cohesion: 0.15
Nodes (17): Gitlink 160000, Git Submodule, git submodule add, Git Submodule Commit 预检, git submodule sync, .gitmodules, Jobs SourceTree Commit 修复动作, SourceTree.sh (+9 more)

### Community 11 - "已脱敏 Classic Token"
Cohesion: 0.13
Nodes (17): 使用个人访问令牌进行 API over Basic Authentication, Delete 删除令牌操作, 脱敏示例名称：Example Token, Fine-grained tokens（Beta）入口, Generate new token 操作, 个人访问令牌可替代 Git over HTTPS 密码, 通过个人访问令牌访问 GitHub API, GitHub Personal access tokens (classic) 管理页面 (+9 more)

### Community 12 - "SSH 公钥格式"
Cohesion: 0.14
Nodes (16): Accepted SSH public key format prefixes, Add SSH Key button, Authentication Key type selected, ecdsa-sha2-nistp256 key format, ecdsa-sha2-nistp384 key format, ecdsa-sha2-nistp521 key format, GitHub Add new SSH Key page, GitHub SSH authentication (+8 more)

### Community 13 - "Classic PAT 权限"
Cohesion: 0.14
Nodes (16): Classic personal access token can authenticate to the API over Basic Authentication, Classic personal access token can replace a password for Git over HTTPS, GitHub strongly recommends setting a token expiration date for security, Fine-grained personal access tokens shown as Beta alternative, GitHub personal access tokens settings, New personal access token (classic) page, Token expiration is set to No expiration, public_repo scope for public repository access (+8 more)

### Community 14 - "Actions 手动运行"
Cohesion: 0.16
Nodes (14): 推送者 295060456, Commit 4340134, Filter workflow runs 运行筛选框, generate_diagrams.yml 工作流定义文件, Generate Mermaid Diagrams 工作流, GitHub Actions 工作流运行页面, 工作流运行状态：In progress, main 分支 (+6 more)

### Community 15 - "iOS 协议类图样例"
Cohesion: 0.14
Nodes (14): AppToolsProtocol, BaseButtonProtocol, BaseCellProtocol, BaseProtocol, BaseViewControllerProtocol, BaseViewProtocol, UICollectionViewCellProtocol, UITableViewCellProtocol (+6 more)

### Community 16 - "SSH 主机信任校验"
Cohesion: 0.17
Nodes (13): ED25519 host key fingerprint displayed (value withheld), First SSH connection reports that host authenticity is not yet established, Independent host fingerprint verification before acceptance, Remote host ED25519 key permanently added to known hosts, GitHub states that SSH authentication does not provide shell access, Second SSH authentication test succeeds without another host-trust prompt, SSH -T authentication test command against a Git hosting endpoint, SSH trust-on-first-use workflow (+5 more)

### Community 17 - "Actions Secrets 设置"
Cohesion: 0.17
Nodes (13): Repository collaborators can use secrets and variables for Actions, Actions secrets and variables settings page, Environment secrets section reports no secrets, Secrets and variables are not passed to workflows triggered by pull requests from forks, GitHub repository Settings for 295060456/JobsOCBaseConfigDemo, Manage environment secrets button, New repository secret button, Repository secret added notification (+5 more)

### Community 18 - "恢复提交拓扑"
Cohesion: 0.21
Nodes (13): 当前选中的提交 2282b85（On main: 111）, 提交 71d1a69（index on main: 845ac79 no message）, 提交 845ac79（no message）, 提交 b499a6f（Recovered from tree）, 提交 b605d74（index on main: 845ac79 no message）, 提交 bf963c8（On main: 222）, 通过恢复引用保全并检查找回的 Git 历史, On main 与 index on main 形成的恢复提交对 (+5 more)

### Community 19 - "添加远端对话框"
Cohesion: 0.20
Nodes (12): Add remote repository configuration dialog, Cancel button enabled, Confirm button disabled, Extended integration enables deeper hosting-provider workflows such as Bitbucket, Hosting Root URL field empty, Hosting Type dropdown set to Unknown, Hosting Username field empty, Optional extended hosting integration section (+4 more)

### Community 20 - "远端仓库设置"
Cohesion: 0.20
Nodes (11): Add remote repository button highlighted, Confirm remote repository settings button, Edit configuration file button, Edit remote repository button disabled, GitHub SSH remote path for 295060456/JobsGenesis.git, Git remote named origin, Remote Repositories tab selected, Remote repository paths table with Name and Path columns (+3 more)

### Community 21 - "子模块目录结构"
Cohesion: 0.22
Nodes (10): assets directory, .git metadata directory, Git submodule configuration, .gitmodules file selected, JobsBlock directory, LICENSE file, Possible JobsBlock submodule working tree, README.md file (+2 more)

### Community 22 - "Workflow YAML 编辑"
Cohesion: 0.25
Nodes (9): 编辑器后退与前进导航控件, generate_diagrams.yml YAML 配置文件, 已打开的 generate_diagrams.yml 文件标签, Generate Mermaid Diagrams 可读名称, 第 1 行 YAML 映射：name: Generate Mermaid Diagrams, 编辑器面包屑状态：No Selection, 源代码编辑器界面, 为自动化工作流配置显示名称 (+1 more)

### Community 23 - "示例 SSH 公钥表单"
Cohesion: 0.29
Nodes (8): Add SSH key button, Authentication Key type selected, Documentation replaces actual public key material with an explicit example placeholder, SSH key Title field set to Example Mac, Key field contains an EXAMPLE PUBLIC KEY placeholder, Registering a public key for GitHub account SSH authentication, GitHub Add new SSH Key page, Descriptive SSH key title identifies the client device or purpose

### Community 24 - "已脱敏 Actions Secret"
Cohesion: 0.32
Nodes (8): Required secret Name field set to ACTIONS_PAT, Secrets and variables > Actions navigation selected, Add secret button, Credential disclosure prevention through screenshot redaction, GitHub repository Settings page, Actions secrets / New secret form, Possible GitHub personal access token stored as an Actions secret, Required Secret field value is visibly redacted

### Community 25 - "分支提交拓扑"
Cohesion: 0.29
Nodes (8): 彩色分支与提交拓扑图, 底部部分可见的提交 69fe614（no message）, 提交 7d2c34c（no message）, 提交 d6a0600（描述：11）, Git 图形化提交历史界面, 本地分支 main, 远端默认分支引用 origin/HEAD, 远端跟踪分支 origin/main

### Community 26 - "Git 配置层级"
Cohesion: 0.33
Nodes (6): Git Command-line Configuration, Git Configuration Scope, Git Global Configuration, Git Local Configuration, Git System Configuration, Git Worktree Configuration

### Community 27 - "Fork PR 权限边界"
Cohesion: 0.50
Nodes (4): Fork Pull Request Secret Boundary, GitHub Actions Least Privilege, GITHUB_TOKEN, pull_request_target Security Risk

### Community 28 - "子模块版本故障"
Cohesion: 0.50
Nodes (4): git submodule update, Submodule not our ref Failure, Submodule Pinned Revision, Recursive Submodule Clone

### Community 29 - "凭据泄漏治理"
Cohesion: 0.67
Nodes (3): Git Secret Leak Governance, Secret Revocation and Rotation, Secret Scanning

### Community 30 - "macOS SSH Agent"
Cohesion: 0.67
Nodes (3): Sourcetree Git and SSH Client Selection, ssh-agent, macOS Keychain SSH Integration

## Ambiguous Edges - Review These
- `Repository secrets section reports no secrets` → `Repository secret added notification`  [AMBIGUOUS]
  Git的使用.md/Github.workflow.md/assets/image-20240704142744377.png · relation: conceptually_related_to

## Knowledge Gaps
- **183 isolated node(s):** `GitHub Docs`, `Atlassian Sourcetree Support`, `Git 故障止损流程`, `Git 文档维护与可信度规则`, `Git Repository Initialization` (+178 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Repository secrets section reports no secrets` and `Repository secret added notification`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **Why does `Git 知识地图` connect `Git 知识与 Actions 模型` to `远端同步与文件状态`, `SSH 身份与提交安全`, `Git 对象与状态模型`, `Mermaid Actions 自动化`, `子模块生命周期与修复`?**
  _High betweenness centrality (0.089) - this node is a cross-community bridge._
- **Why does `Git 对象模型` connect `Git 对象与状态模型` to `Git 知识与 Actions 模型`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Why does `Mermaid Class Diagram Input Sample` connect `Mermaid Actions 自动化` to `Git 知识与 Actions 模型`, `iOS 协议类图样例`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `GitHub 个人访问令牌（classic）` (e.g. with `Fine-grained tokens（Beta）入口` and `Generate new token 操作`) actually correct?**
  _`GitHub 个人访问令牌（classic）` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `GitHub Docs`, `Atlassian Sourcetree Support`, `Git 故障止损流程` to the rest of the system?**
  _183 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `历史改写与恢复` be split into smaller, more focused modules?**
  _Cohesion score 0.08307692307692308 - nodes in this community are weakly interconnected._
