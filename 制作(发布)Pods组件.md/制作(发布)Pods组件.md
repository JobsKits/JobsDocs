# 制作(发布)Pods组件

![Jobs倾情奉献](https://picsum.photos/1500/400 "Jobs出品，必属精品")

## 一、`*.podspec` 模板

* 普通模板

  ```ruby
  Pod::Spec.new do |s|
    s.name         = 'JobsSwiftBaseTools'          # Pod 名
    s.version      = '0.1.0'
    s.summary      = 'Swift@基础工具集'
    s.description  = <<-DESC
                        关于Swift语言下的基础工具集
                     DESC
    s.homepage     = 'https://github.com/JobsKits/JobsSwiftBaseTools'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { 'Jobs' => 'lg295060456@gmail.com' }
    s.platform     = :ios, '15.0'
    s.swift_version = '5.0'
    s.source       = { :git => 'https://github.com/JobsKits/JobsSwiftBaseTools.git',
                       :tag => s.version.to_s }
    # 递归匹配当前目录下所有子目录里的 .swift 文件
    s.source_files = '**/*.swift'
    s.ios.frameworks = 'UIKit',
                       'QuartzCore',
                       'Network',
                       'CoreTelephony',
                       'Photos',
                       'PhotosUI',
                       'AVFoundation',
                       'CoreLocation',
                       'CoreBluetooth',
                       'UniformTypeIdentifiers'
    s.dependency 'RxSwift'
    s.dependency 'RxCocoa'
    s.dependency 'NSObject+Rx'
    s.dependency 'SnapKit'
    s.dependency 'Alamofire'
    s.dependency 'JobsSwiftBaseDefines'
  
  end
  ```

* 带子Pod的模版

  ```ruby
  Pod::Spec.new do |s|
    s.name         = 'JobsSwiftBaseConfig'
    s.version      = '0.1.0'
    s.summary      = 'Jobs 基础配置'
    s.description  = <<-DESC
                      JobsSwiftBaseConfig 配置
                     DESC
    s.homepage     = 'https://github.com/295060456/JobsSwiftBaseConfigDemo'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { 'Jobs' => 'lg295060456@gmail.com' }
  
    s.platform      = :ios, '15.0'
    s.swift_version = '5.0'
    s.source        = {
      :git => 'https://github.com/295060456/JobsSwiftBaseConfig.git',
      :tag => s.version.to_s
    }
  
    # 顶层可以不写 source_files，让子 pod 自己管自己的源码
    # s.source_files = ...
  
    s.frameworks = 'UIKit'
  
    # 公共依赖（所有子 pod 都会带上）
    s.dependency 'SnapKit'
  
    # ==================== 子 Pod：Core ====================
    s.subspec 'Core' do |ss|
      ss.source_files = 'Sources/Core/**/*.{swift}'
      # 这里可以写 Core 独有的依赖
      ss.dependency 'Kingfisher'
    end
  
    # ==================== 子 Pod：UI ====================
    s.subspec 'UI' do |ss|
      ss.source_files = 'Sources/UI/**/*.{swift}'
      # UI 依赖 Core
      ss.dependency 'JobsSwiftBaseConfig/Core'
      ss.dependency 'SDWebImage'
    end
  end
  ```

## 二、自检（QSA@[**Cocoapods**](https://cocoapods.org/)）

> 命令行操作需要定位于此库路径下

* 自检不一定靠谱。因为自检的时候，可能用的是本地源。在最后推送到远端的时候，也会自检，以此为准

  ```shell
  pod lib lint --allow-warnings JobsSwiftBaseTools.podspec
  ```

## 三、推送

> 命令行操作需要定位于此库路径下

* 推送到[**Github**](https://github.com/)，并打对其打**tag**

  ```shell
  git tag 0.1.0
  ```

* 注册邮箱会收到一封短信，需要进行点击确认

  ```shell
  pod trunk register lg295060456@gmail.com 'Jobs' --description='JobsSwiftBaseTools.podspec'
  ```

* 自检成功 + 注册邮箱确认短信成功 +  推送到[**GitHub**](https://github.com/)并打tag（注意版本号对齐） => 发布成功

  ```shell
  pod trunk push JobsSwiftBaseTools.podspec  --allow-warnings
  ```

## 四、查询

> 命令行操作需要定位于此库路径下

```shell
pod trunk info JobsSwiftBaseTools
```

## 五、注意事项

* [**Github**](https://github.com/)和[**Cocoapods**](https://cocoapods.org/)是2套独立的系统。也就意味着，仅仅做了`git push`而没有做`pod trunk push`是不行的（当然可以用[**Github**](https://github.com/)的工作流来解决）

  * 如果在[**Github**](https://github.com/)上单方面的修改了Tag（常见操作是合并Tag，或者删除Tag）那么`pod trunk push`将会找不到这个Tag导致失败

* 如果在[**Cocoapods**](https://cocoapods.org/)有一个和目前版本相同的版本，则推不上去

* 有些时候**CND**没有来得及同步，拉不了最新的版本，需要添加官方源进行处理

  ```ruby
  source 'https://github.com/CocoaPods/Specs.git'
  ```

* 拉不到最新库，需要进行更新

  ```shell
  pod install --repo-update
  ```

* 如果因为缓存出现紊乱，还原**Pods**

  > 删除文件📃 `Podfile.lock`
  >
  > 删除文件📃 `*.xcworkspace`
  >
  > 删除文件夹📁 `Pods`

  ```shell
  pod deintegrate
  ```