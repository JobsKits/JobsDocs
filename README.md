# `JobsDocs`

<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

[toc]

---

## 🔥 <font id=前言>前言</font>

这里用于长期收集、整理和沉淀 Jobs 日常技术文档。文档优先服务复用：能快速定位主题、能直接复制命令、能看清风险边界。

## 一、目录定位 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `iOS相关的文档和资料.md`：iOS、[**Xcode**](https://developer.apple.com/xcode)、构建问题和工程化资料。
- [`Git的使用.md`](./Git的使用.md/README.md)：Git 日常与进阶、子模块、GitHub SSH、GitHub Actions，以及无法 Commit / Fetch / Pull / Push 的故障诊断与恢复。
- `blog`：博客源码、文档同步脚本、本地预览入口和 [**Hugo**](https://gohugo.io) 配置。
- `.github/workflows/deploy-blog.yml`：[**GitHub Actions**](https://docs.github.com/actions) 博客发布工作流。
- 其它专题目录：按主题继续沉淀，不混放临时文件。

## 二、Blog 预览与发布 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 2.1、先记结论

- `./blog/install.command` 是博客文件的统一生成入口：默认双击时同步文档并启动本地预览；传入 `--ci` 时无交互完成一次正式构建后退出。
- 正式站点由 [**Cloudflare Pages**](https://pages.cloudflare.com/) 托管，项目名为 `jobsdocs`，线上地址为 `https://jobsdocs.ccwu.cc/`。
- `./.github/workflows/deploy-blog.yml` 会在 `main` 收到推送后运行 `./blog/install.command --ci`，再把生成的 `./blog` 文件提交回 `main`；Cloudflare Pages Git 集成负责发布这个生成提交。

### 2.2、本地同步与预览

- 可以双击 `./blog/install.command`，也可以在终端执行：

  ```shell
  cd blog
  ./install.command
  ```

- 脚本运行后会先展示说明并等待回车；随后执行 `./blog/sync_docs.sh`，再运行 `hugo server -D --disableFastRender`。
- 执行前需要确保本机已经安装 Hugo；可以通过 `hugo version` 检查。
- 本地预览流程会重新生成 `./blog/content/docs`、`./blog/public`及部分站点运行文件。预览结束后先检查 `git status`，确认生成差异符合预期再提交。
- 停止本地预览：回到运行脚本的终端，按 `Control + C`。
- 本地预览日志位于系统临时目录中的 `install.log`。

### 2.3、自动发布与手动发布

- 自动发布：提交源码并推送到远端 `main` 分支，`Deploy Blog` 工作流会同步文档、生成 Hugo 站点，并由 `github-actions[bot]` 把变化提交回 `main`。

  ```shell
  git push origin main
  ```

- 手动发布：打开 GitHub 仓库的 `Actions` → `Deploy Blog` → `Run workflow`，确认选择 `main` 后运行。
- 发布流程：

  ```mermaid
  flowchart LR
      A["推送 main 或手动运行"] --> B["install.command --ci"]
      B --> C["生成 blog/content 与 blog/public"]
      C --> D["机器人提交生成文件到 main"]
      D --> E["Cloudflare Pages Git 集成发布"]
  ```

### 2.4、GitHub Actions 运行边界

- 工作流使用 GitHub 自动提供的 `GITHUB_TOKEN` 写回本仓库，不需要 Cloudflare API Token、账户 ID 或其它 Repository secrets。
- 机器人提交使用仓库自身的 `GITHUB_TOKEN` 推送，不会再次触发同一个 GitHub Actions 工作流，因此不会递归提交。
- Cloudflare Pages 继续保持 Git 自动生产部署；机器人生成提交进入 `main` 后，由 Cloudflare 完成正式发布。
- 如果 `Commit generated files` 报 `403` 或分支保护错误，需要检查仓库 `Settings` → `Actions` → `General` 中的 Workflow permissions，以及 `main` 的分支规则是否允许 GitHub Actions 写入。
- 打开 `https://jobsdocs.ccwu.cc/jobs-git-version.js`，可以核对线上短提交号是否已更新。

## 三、维护规则 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 新增文档优先写清楚问题背景、适用版本、操作步骤和验证方式。
- 第三方原文资料尽量保留原貌；Jobs 自己的补充说明单独成段，避免混淆来源。
- 命令、路径、文件名使用反引号；第三方工具第一次出现时优先补官方链接。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
