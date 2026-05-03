# MacOS_Web服务器学习

![Jobs倾情奉献](https://picsum.photos/1500/400 "Jobs出品，必属精品")

[toc]
## 一、前言

* 资料来源

  * [**Apache 、Tomcat、Nginx的区别**](https://blog.51cto.com/willis/1852083)

* **MacOS** 自带`tomcat`和`apache`，但是建议都用`brew`重新下载进行额外的管理

  ```shell
  which -a apache
  which apache
  ```

* 查找用[**Homebrew**](https://brew.sh/)管理的软件的安装路径（以`tomat`为例）

  ```shell
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

  ```shell
  brew list tomcat
  ```

## 二、`tomcat`

### 1、`tomcat`的安装

```shell
brew install tomcat
```

### 2、`tomcat`的开启/关闭/重启

* 进入**tomcat**安装目录下的`libexec/bin`，执行里面对应的`*.sh`

## 三、`httpd`

### 1、`httpd`的安装

```shell
brew install httpd
```

### 2、`httpd`httpd的启动

```shell
apachectl start
```

### 3、`httpd`的停止

```shell
apachectl stop
```

### 4、`httpd`的重启

```shell
apachectl restart
```

### 5、`httpd`的相关备注和说明

#### 5.1、默认占用系统`8080`端口，俗称`apache`

#### 5.2、因为是只读所以需要加写权限，然后将默认的8080更改为8081，以及80更改为81（防止其他程序抢夺端口）

```shell
open /etc/apache2/httpd.conf
```

```xml
<IfDefine SERVER_APP_HAS_DEFAULT_PORTS>
  Listen 8081
</IfDefine>
<IfDefine !SERVER_APP_HAS_DEFAULT_PORTS>
  Listen 81
</IfDefine>
```

## 四、`nginx`

### 1、`nginx`的安装

```shell
brew install nginx
```

### 2、`nginx`的启动

```shell
nginx
```

### 3、`nginx`的关闭

> 相当于先查出**nginx**的进程**id**再使用**kill**命令强制杀掉进程

```shell
nginx -s stop
```

### 4、`nginx`的重启

```shell
nginx -s reload
```

### 5、`nginx`的停止

> 待**nginx**进程处理任务完毕进行停止

```shell
nginx -s quit
```

### 6、重读`nginx`日志文件

```shell
nginx -s reopen
```

### 7、`nginx`的相关备注和说明

#### 7.1、默认占用系统8080端口

#### 7.2、如果端口被占用则报错如下：

```shell
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:8080 failed (48: Address already in use)
nginx: [emerg] still could not bind()
```

#### 7.3、查询

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

  

