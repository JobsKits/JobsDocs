---
title: "利用Cloudflare进行科学上网（免费）"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 40
summary: "一、🔥 前言 ### 1、📖 参考资料 👉2026 最强 Cloudflare 免费节点！永久可用+免费域名｜10分钟搭建｜解锁 ChatGPT / Gemini ！ ### 2、🔨 所需工具 需要的相关账户 Google账户 Github账户 注册域名（永久免费） dnshe digitalplat 云服务器提供商（不推荐国内大厂：阿里云/腾讯云） 推荐 "
bookCollapseSection: false
---


<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>


## 一、🔥 <font id=前言>前言</font>

### 1、📖 参考资料

* 👉[**2026 最强 Cloudflare 免费节点！永久可用+免费域名｜10分钟搭建｜解锁 ChatGPT / Gemini ！**](https://www.freedidi.com/23618.html)

### 2、🔨 所需工具

* 需要的相关账户
  * [**Google**](https://www.google.com)账户
  * [**Github**](https://github.com/)账户
  
* 注册域名（永久免费）
  
  * [**dnshe**](https://www.dnshe.com/)
  * [**digitalplat**](https://digitalplat.org/)
  
* 云服务器提供商（不推荐国内大厂：阿里云/腾讯云）
  
  * **推荐**
    * 🌟 [**Goodkvm**](https://www.goodkvm.com/)
    * 🌟 [**Cloudflare**](https://www.cloudflare.com/)
  * 其他（不推荐）
    * [**GoDaddy**](https://www.gpdaddy.com/)
    * [**DigitalOcean**](https://www.digitalocean.com/)
  
* ⏬代码管理工具
  
  * [**Sourcetree**](https://www.sourcetreeapp.com/)
  
* ⏬网络代理工具
  
  * [**v2rayn**](https://github.com/2dust/v2rayn/releases)
  
    ```shell
    # 因为MacOS的安全策略所限制，成功安装完成v2rayn以后，需要执行如下命令
    xattr -cr $APPLICATIONS_DIR/v2rayN.app 
    ```
  
    * **Apple** 芯片 ➤ **v2rayN-macos-arm64.dmg**
    * **Intel**芯片➤ **v2rayN-macos-64.dmg**
  
* 查询当前IP
  
  * [**ip.cn**](https://ip.cn/ )
  * [**ip38**](https://www.ip38.com/)
  * [**ipaddress.my**](https://ipaddress.my/)
  
* 测速工具

  * **ping**
  * [**speedtest**](https://www.speedtest.net/zh-Hans)

## 二、⚙️ 实操

* 利用[**dnshe**](https://www.dnshe.com/)，<font id=域名注册>**注册一个永久免费的域名**</font>

  > 用[**Github**](https://github.com/)进行授权登录，则不需要填入邀请码
  
  ![image-20260429102356582](./assets/image-20260429102356582.png)

* 创建KV的命名空间（取名为**JobsGo**）
  
  ```shell
  # 需要运行命令行，来创建KV的命名空间（取名为JobsGo）
  # 命令执行过程中，会跳到浏览器授权账户
  npx wrangler kv namespace create JobsGo
  ```
  
  ```shell
  # 如果执行过程中，npm 缓存权限/损坏，则需要执行以下命令执行修复。修复成功以后再执行上述命令
  sudo chown -R $(whoami) ~/.npm
  npm cache clean --force
  # 如果还报错，再删掉缓存目录
  rm -rf ~/.npm/_cacache
  ```
  
* ⏬下载[**cmliu**](https://github.com/cmliu/edgetunnel)源代码到本地磁盘（推荐工具[**Sourcetree**](https://www.sourcetreeapp.com/)）
  
  ![image-20260429111105478](./assets/image-20260429111105478.png)
  
* 命令行授权（跳转浏览器）后部署
  
  ```
  npx wrangler login  # 先登陆 cloudflare (需要授权跳转)
  npx wrangler deploy # 后部署 edgetunnel
  ```
  
  ```shell
  Last login: Wed Apr 29 11:04:38 on ttys000
  ➜  Desktop ../../../../../../edgetunnel 
  ➜  edgetunnel git:(main) npx wrangler login
  
   ⛅️ wrangler 4.86.0
  ───────────────────
  Attempting to login via OAuth...
  Opening a link in your default browser: https://dash.cloudflare.com/oauth2/auth?response_type=code&client_id=54d11594-84e4-41aa-b438-e81b8fa78ee7&redirect_uri=http%3A%2F%2Flocalhost%3A8976%2Foauth%2Fcallback&scope=account%3Aread%20user%3Aread%20workers%3Awrite%20workers_kv%3Awrite%20workers_routes%3Awrite%20workers_scripts%3Awrite%20workers_tail%3Aread%20d1%3Awrite%20pages%3Awrite%20zone%3Aread%20ssl_certs%3Awrite%20ai%3Awrite%20ai-search%3Awrite%20ai-search%3Arun%20queues%3Awrite%20pipelines%3Awrite%20secrets_store%3Awrite%20artifacts%3Awrite%20flagship%3Awrite%20containers%3Awrite%20cloudchamber%3Awrite%20connectivity%3Aadmin%20email_routing%3Awrite%20email_sending%3Awrite%20browser%3Awrite%20offline_access&state=RRwD5Hjh7TFWU-9YDdcvMFhsKXQbl.AK&code_challenge=ieb3htkCUvNboLSQpdC541fNqj8MjVuKmCr88PzrREM&code_challenge_method=S256
  Successfully logged in.
  ➜  edgetunnel git:(main) npx wrangler deploy
  
   ⛅️ wrangler 4.86.0
  ───────────────────
  
  Cloudflare collects anonymous telemetry about your usage of Wrangler. Learn more at https://github.com/cloudflare/workers-sdk/tree/main/packages/wrangler/telemetry.md
  Total Upload: 264.44 KiB / gzip: 56.17 KiB
  Uploaded v20251104 (7.89 sec)
  Deployed v20251104 triggers (6.12 sec)
    https://v20251104.295060456.workers.dev
  Current Version ID: 4b13531b-6726-4044-939e-face0b53002f
  ➜  edgetunnel git:(main) 
  ```
  | 图1 |
  |---|
  | ![image-20260429111847095](./assets/image-20260429111847095.png) |
  | ![image-20260429112010136](./assets/image-20260429112010136.png) |
  | ![image-20260429112300333](./assets/image-20260429112300333.png) |
  
  | 图1 | 图2 |
  |---|---|
  | ![image-20260429112347950](./assets/image-20260429112347950.png) | ![image-20260429112411400](./assets/image-20260429112411400.png) |
  
  🔍快捷搜索：Add a site，[🔝添加上方已经注册好的域名](#域名注册)
  
  | 图1                                                          |
  | ------------------------------------------------------------ |
  | ![image-20260429112919386](./assets/image-20260429112919386.png) |
  | ![image-20260429115223370](./assets/image-20260429115223370.png) |
  | ![image-20260429115532496](./assets/image-20260429115532496.png) |
  | ![image-20260429121727514](./assets/image-20260429121727514.png) |
  | ![image-20260429121811428](./assets/image-20260429121811428.png) |
  | ![image-20260429134107234](./assets/image-20260429134107234.png) |
  | ![image-20260429122611972](./assets/image-20260429122611972.png) |
  | ![image-20260429122456089](./assets/image-20260429122456089.png) |
  | ![image-20260429121033624](./assets/image-20260429121033624.png) |
  | ![image-20260429120940242](./assets/image-20260429120940242.png) |
  | ![image-20260429134351701](./assets/image-20260429134351701.png) |
  | ![image-20260429135757502](./assets/image-20260429135757502.png) |
  | ![image-20260429135928033](./assets/image-20260429135928033.png) |
  | ![image-20260429140748217](./assets/image-20260429140748217.png) |
  | ![image-20260429141144251](./assets/image-20260429141144251.png) |
  | ![image-20260429143242204](./assets/image-20260429143242204.png) |
  
  | 图1 | 图2 |
  |---|---|
  | ![image-20260429143403984](./assets/image-20260429143403984.png) | ![image-20260429143819128](./assets/image-20260429143819128.png) |
  
  | 图1 | 图2 |
  |---|---|
  | ![image-20260429145622399](./assets/image-20260429145622399.png) | ![image-20260429145640989](./assets/image-20260429145640989.png) |

## 三、🧑‍🔬科普

> * 运营商（电信、移动、联通）**很关键**；同一个 **VPS**，不同运营商速度差很大
> * 具体线路（比国家更重要）。<u>例如：同样是东京，有的绕美国（直接废）</u>

### 1、服务器节点

* 通解选取**日本**

  * 网络路径相对稳定：走海底光缆，路径干净、成熟

  * 干扰程度比香港低：稳定 > 低延迟

  *  节点多、质量参差但可选：东京、大阪

* 按照地区不同的最优解

  * 📍华南（广东 / 广西）👉 **🇸🇬新加坡可能更好**
    * 走南向出口
    * 有些线路直连🇸🇬新加坡
  * 📍 华东（上海 / 江苏 / 浙江）👉 **🇯🇵日本最优**
    * 距离近
    * 线路成熟
  * 📍 西南（云/贵/川/渝）👉 **🇯🇵日本 > 🇸🇬新加坡 > 🇭🇰香港**
    * 出口路径通常绕东部
    * 去日本更稳定
  * 📍 华北（北京 / 天津）👉 **🇯🇵日本 / 🇰🇷韩国都可以**
  
* 最优实践（老司机方案）
  
  * 🇯🇵 日本
  * 🇸🇬 新加坡
  

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
