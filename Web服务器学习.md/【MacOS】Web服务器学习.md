# <span id="前言">MacOS_Web服务器学习</span>

<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [一、前言](#jobs-toc-heading-1)
- [二、tomcat](#jobs-toc-heading-2)
  - [1、tomcat的安装](#jobs-toc-heading-3)
  - [2、tomcat的开启/关闭/重启](#jobs-toc-heading-4)
- [三、httpd](#jobs-toc-heading-5)
  - [1、httpd的安装](#jobs-toc-heading-6)
  - [2、httpdhttpd的启动](#jobs-toc-heading-7)
  - [3、httpd的停止](#jobs-toc-heading-8)
  - [4、httpd的重启](#jobs-toc-heading-9)
  - [5、httpd的相关备注和说明](#jobs-toc-heading-10)
    - [5.1、默认占用系统8080端口，俗称apache](#jobs-toc-heading-11)
    - [5.2、因为是只读所以需要加写权限，然后将默认的8080更改为8081，以及80更改为81（防止其他程序抢夺端口）](#jobs-toc-heading-12)
- [四、nginx](#jobs-toc-heading-13)
  - [1、nginx的安装](#jobs-toc-heading-14)
  - [2、nginx的启动](#jobs-toc-heading-15)
  - [3、nginx的关闭](#jobs-toc-heading-16)
  - [4、nginx的重启](#jobs-toc-heading-17)
  - [5、nginx的停止](#jobs-toc-heading-18)
  - [6、重读nginx日志文件](#jobs-toc-heading-19)
  - [7、nginx的相关备注和说明](#jobs-toc-heading-20)
    - [7.1、默认占用系统8080端口](#jobs-toc-heading-21)
    - [7.2、如果端口被占用则报错如下：](#jobs-toc-heading-22)
    - [7.3、查询](#jobs-toc-heading-23)

</details>
<!-- jobs-toc:end -->
## <span id="jobs-toc-heading-1" data-jobs-toc="v2"><span id="前言">一、前言</span></span><!-- jobs-toc:heading-end -->

* 资料来源

  * [**Apache 、Tomcat、Nginx的区别**](https://blog.51cto.com/willis/1852083)

* **MacOS** 自带`tomcat`和`apache`，但是建议都用`brew`重新下载进行额外的管理

  ```shell
  which -a apache
  which apache
  ```

* 查找用[**Homebrew**](https://brew.sh/)管理的软件的安装路径（以`tomat`为例）

  ```shell
  $SYSTEM_BIN_DIR/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

  ```shell
  brew list tomcat
  ```

## <span id="jobs-toc-heading-2" data-jobs-toc="v2">二、`tomcat` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

### <span id="jobs-toc-heading-3" data-jobs-toc="v2">1、`tomcat`的安装 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
brew install tomcat
```

### <span id="jobs-toc-heading-4" data-jobs-toc="v2">2、`tomcat`的开启/关闭/重启 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* 进入**tomcat**安装目录下的`libexec/bin`，执行里面对应的`*.sh`

## <span id="jobs-toc-heading-5" data-jobs-toc="v2">三、`httpd` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

### <span id="jobs-toc-heading-6" data-jobs-toc="v2">1、`httpd`的安装 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
brew install httpd
```

### <span id="jobs-toc-heading-7" data-jobs-toc="v2">2、`httpd`httpd的启动 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
apachectl start
```

### <span id="jobs-toc-heading-8" data-jobs-toc="v2">3、`httpd`的停止 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
apachectl stop
```

### <span id="jobs-toc-heading-9" data-jobs-toc="v2">4、`httpd`的重启 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
apachectl restart
```

### <span id="jobs-toc-heading-10" data-jobs-toc="v2">5、`httpd`的相关备注和说明 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-11" data-jobs-toc="v2">5.1、默认占用系统`8080`端口，俗称`apache` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-12" data-jobs-toc="v2">5.2、因为是只读所以需要加写权限，然后将默认的8080更改为8081，以及80更改为81（防止其他程序抢夺端口） <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
open $SYSTEM_CONFIG_DIR/apache2/httpd.conf
```

```xml
<IfDefine SERVER_APP_HAS_DEFAULT_PORTS>
  Listen 8081
</IfDefine>
<IfDefine !SERVER_APP_HAS_DEFAULT_PORTS>
  Listen 81
</IfDefine>
```

## <span id="jobs-toc-heading-13" data-jobs-toc="v2">四、`nginx` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

### <span id="jobs-toc-heading-14" data-jobs-toc="v2">1、`nginx`的安装 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
brew install nginx
```

### <span id="jobs-toc-heading-15" data-jobs-toc="v2">2、`nginx`的启动 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
nginx
```

### <span id="jobs-toc-heading-16" data-jobs-toc="v2">3、`nginx`的关闭 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> 相当于先查出**nginx**的进程**id**再使用**kill**命令强制杀掉进程

```shell
nginx -s stop
```

### <span id="jobs-toc-heading-17" data-jobs-toc="v2">4、`nginx`的重启 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
nginx -s reload
```

### <span id="jobs-toc-heading-18" data-jobs-toc="v2">5、`nginx`的停止 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

> 待**nginx**进程处理任务完毕进行停止

```shell
nginx -s quit
```

### <span id="jobs-toc-heading-19" data-jobs-toc="v2">6、重读`nginx`日志文件 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
nginx -s reopen
```

### <span id="jobs-toc-heading-20" data-jobs-toc="v2">7、`nginx`的相关备注和说明 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-21" data-jobs-toc="v2">7.1、默认占用系统8080端口 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

#### <span id="jobs-toc-heading-22" data-jobs-toc="v2">7.2、如果端口被占用则报错如下： <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] still could not bind()
```

#### <span id="jobs-toc-heading-23" data-jobs-toc="v2">7.3、查询 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* 查询某个软件（比如：`Nginx`）的进程号

  ```shell
  ps aux|grep nginx
  ```

* 查询端口占用情况（比如查询`8080`端口）

  ```shell
  lsof -i tcp:8080
  ```

* 查询由`brew`管理的`nginx`的安装目录

  ```shell
  brew list nginx
  ```

* 查询`nginx`的配置文件目录

  ```shell
  nginx -t（安装目录 ≠ 配置文件目录）
  ```

  

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
