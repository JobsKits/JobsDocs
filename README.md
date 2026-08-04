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

- `./blog/install.command` 不是远端发布脚本。它负责同步 JobsDocs 文档、启动 Hugo 本地服务并打开 `http://localhost:1313/`，用于发布前预览。
- 正式站点由 [**Cloudflare Pages**](https://pages.cloudflare.com/) 托管，项目名为 `jobsdocs`，线上地址为 `https://jobsdocs.ccwu.cc/`。
- 站点原有 Cloudflare Pages Git 集成已经能够随 `main` 推送自动构建；新增的 `./.github/workflows/deploy-blog.yml` 用于把发布入口收口到 GitHub Actions，并补充手动发布能力。

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

- 自动发布：提交代码并推送到远端 `main` 分支，`Deploy Blog` 工作流会同步文档、构建 Hugo 站点并部署到 Cloudflare Pages。

  ```shell
  git push origin main
  ```

- 手动发布：打开 GitHub 仓库的 `Actions` → `Deploy Blog` → `Run workflow`，确认选择 `main` 后运行。
- 发布流程：

  ```mermaid
  flowchart LR
      A["推送 main 或手动运行"] --> B["同步 JobsDocs 文档"]
      B --> C["Hugo 构建 blog/public"]
      C --> D["Wrangler 上传"]
      D --> E["Cloudflare Pages 正式站点"]
  ```

### 2.4、首次启用 GitHub Actions 发布

1. 在 Cloudflare 创建 API Token，权限选择 `Account` → `Cloudflare Pages` → `Edit`，资源范围只授权站点所在账户。
2. 在 GitHub 仓库打开 `Settings` → `Secrets and variables` → `Actions`，新增两个 Repository secrets：

   | Secret 名称             | 内容                     |
   | ----------------------- | ------------------------ |
   | `CLOUDFLARE_ACCOUNT_ID` | Cloudflare 账户 ID       |
   | `CLOUDFLARE_API_TOKEN`  | 上一步创建的 API Token   |

3. Cloudflare Pages 原有 Git 集成如果仍开启自动生产部署，需要先在 `jobsdocs` 项目中关闭生产分支的自动部署，避免一次 `git push` 同时触发 Cloudflare 内建部署和 GitHub Actions 部署。
4. 推送一次 `main`，或手动运行 `Deploy Blog`，确认 `Build Hugo site` 与 `Deploy to Cloudflare Pages` 均成功。
5. 打开 `https://jobsdocs.ccwu.cc/jobs-git-version.js`，确认其中的短提交号与本次发布提交一致。

> 未配置上述两个 Secrets 时，工作流可以被触发，但 Cloudflare 部署步骤会因缺少凭据而失败。

## 三、维护规则 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 新增文档优先写清楚问题背景、适用版本、操作步骤和验证方式。
- 第三方原文资料尽量保留原貌；Jobs 自己的补充说明单独成段，避免混淆来源。
- 命令、路径、文件名使用反引号；第三方工具第一次出现时优先补官方链接。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
