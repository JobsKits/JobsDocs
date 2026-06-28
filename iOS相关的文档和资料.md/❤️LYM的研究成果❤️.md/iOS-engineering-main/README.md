# iOS项目工程化

<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

- [iOS项目工程化](#ios项目工程化)
  - [1. Git配置](#1-git配置)
  - [2. rbenv安装和shell设置](#2-rbenv安装和shell设置)
  - [3. rbenv配置项目的ruby环境](#3-rbenv配置项目的ruby环境)
  - [4. Bundler 安装和使用](#4-bundler-安装和使用)
  - [5. Cocoapods](#5-cocoapods)
  - [6. 利用脚本完成整套开发环境的搭建](#6-利用脚本完成整套开发环境的搭建)
  - [7. xccongif构建配置⽂件配置项目和多环境支持](#7-xccongif构建配置件配置项目和多环境支持)
  - [8. xcconfig 使用中的一些问题](#8-xcconfig-使用中的一些问题)
  - [9. demo运行](#9-demo运行)
  - [10. Fastlane](#10-fastlane)

iOS开发过程中，经常会遇到每次打开一个项目都需要手动搭建开发环境，常见的问题有ruby版本不正确、CocoaPods、fastlane、CI、项目配置等等。这些其实最应该是在项目之初就统一配置好，包括经常修改的Build Settings。

统一配置就是所有配置信息都用文件的格式存放到git，这样可以随时查看修改记录对比差异。不同项目所依赖的环境可以能自动配置，并且保证每个人的开发环境都一样。通过 Git、rbenv、RubyGems 和 Bundler 搭建⼀个统⼀的 iOS 开发和构建环境。

|工具  |  |
|--|--|
| Git | 开源的分布式版本控制系统 |
| RubyGems | 简称gems，是一个用于对 Ruby组件进行打包的 Ruby 打包系统。 |
|Bundler|安装所需的特定版本的 gem。根据gemfile文件定义去管理这些gem(比如CocoaPods、fastlane的版本)。|
|rbenv|Ruby环境管理⼯具, 能够安装、管理、隔离以及在多个 Ruby 版本之间切换. 这是区别于rvm的地方。 千万注意, 团队内部不要同时使⽤不同的 Ruby 环境管理⼯具。|
|CocoaPods|iOS管理第三方依赖库的工具|
|fastlane|自动打包发布工具|
|xcconfig|xcode构建配置文件|

自动化配置步骤：

## 1. Git配置

 [gitignore](https://www.toptal.com/developers/gitignore) ⾥⾯输⼊关键字, 例如 swift, xcode, cocoapods, fastlane等, 然后该⽹站会帮我们⽣成⼀个默认的 .gitignore ⽂件.

## 2. rbenv安装和shell设置

[rbenv](https://github.com/rbenv/rbenv)

[rbenv使用指南](https://ruby-china.org/wiki/rbenv-guide)

[安装新的 Ruby 版本需要 构建环境。请检查您的构建环境是否具有必要的工具和库  Ruby 3.1 及更高版本需要 OpenSSL 3](https://github.com/rbenv/ruby-build/wiki#suggested-build-environment)

安装rbenv

```
brew install rbenv ruby-build
```

shell 中设置 rbenv

```
#rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
```

安装ruby  
```
#list latest stable versions:
rbenv install -l

#install a Ruby version:
rbenv install 3.2.2
```

⚠️ rbenv install 3.2.0 报错 ：
```
error: failed to download ruby-3.2.0.tar.gz
BUILD FAILED (macOS 14.0 using ruby-build 20230202)
```

解决：
1. 终端开启代理模式 proxy
2. 更新brew 
brew update && brew doctor

如果出现报错
```
Already up-to-date.
==> Tapping homebrew/core
Cloning into '$(brew --prefix)/Homebrew$SYSTEM_LIBRARY_DIR/Taps/homebrew/homebrew-core'...
remote: Enumerating objects: 1725002, done.
remote: Counting objects: 100% (97675/97675), done.
remote: Compressing objects: 100% (1197/1197), done.
error: RPC failed; curl 18 Transferred a partial file | 445.00 KiB/s
error: 4190 bytes of body are still expected
fetch-pack: unexpected disconnect while reading sideband packet
fatal: early EOF
fatal: fetch-pack: invalid index-pack output
Error: Failure while executing; `git clone https://github.com/Homebrew/homebrew-core $(brew --prefix)/Homebrew$SYSTEM_LIBRARY_DIR/Taps/homebrew/homebrew-core --origin=origin --template= --config core.fsmonitor=false` exited with 128.
```

则需要执行
```
rm -rf “$(brew --prefix)/Homebrew$SYSTEM_LIBRARY_DIR/Taps/Homebrew/homebrew-core”
```
然后执行
```
brew tap Homebrew/core
```

接着安装新的 Ruby 版本需要 构建环境。请检查您的构建环境是否具有必要的工具和库  Ruby 3.1 及更高版本需要 OpenSSL 3：
```
brew install openssl@3 readline libyaml gmp
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
```

最后在安装ruby
```
rbenv install 3.2.2
```

设置系统ruby
```
rbenv global 3.2.2
```

## 3. rbenv配置项目的ruby环境

```
cd 到项目目录
rbenv install 3.2.2
rbenv local 3.2.2
```

这里把该项目的ruby环境配置为2.7.7，rbenv会生成.ruby-version的文件, 这个文件通过git管理，这样就保证了所有人的该项目的ruby环境一致。

## 4. Bundler 安装和使用

安装 Bundler

```
gem install bundler
```

使用Bundler，在项目目录中执⾏**bundle init**⽣成⼀个 Gemfile ⽂件, 像 CocoaPods 和 fastlane 等依赖包

```
bundle init
```

Gemfile添加三方工具CocoaPods 和 fastlane 

```
source "https://rubygems.org"

gem "cocoapods", "1.30.0"
gem "fastlane", "2.211.0"
```

为了保证使⽤版本号⼀致的 Gem, 需要把 Gemfile 和 Gemfile.lock ⼀同保存到 Git ⾥⾯统⼀管理起来.

## 5. Cocoapods

官网 https://cocoapods.org/

安装：

```
sudo gem install cocoapods
```

安装报网络错误
```
ERROR:  Could not find a valid gem 'cocoapods' (>= 0), here is why:
          Unable to download data from https://rubygems.org/ - Net::OpenTimeout: Net::OpenTimeout (https://rubygems.org/specs.4.8.gz)
^CERROR:  Interrupted
```
处理方法就是添加国内的源
```
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
```

⚠️ ruby更新到3.2.2后 pod --version 报错
```
$HOME/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.1.1/lib/active_support/core_ext/array/conversions.rb:108:in `<class:Array>': undefined method `deprecator' for ActiveSupport:Module (NoMethodError)

  deprecate to_default_s: :to_s, deprecator: ActiveSupport.deprecator
                                                          ^^^^^^^^^^^
Did you mean?  deprecate_constant
    from $HOME/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.1.1/lib/active_support/core_ext/array/conversions.rb:8:in `<top (required)>'
    from <internal:$HOME/.rbenv/versions/3.2.2/lib/ruby/site_ruby/3.2.0/rubygems/core_ext/kernel_require.rb>:86:in `require'
    from <internal:$HOME/.rbenv/versions/3.2.2/lib/ruby/site_ruby/3.2.0/rubygems/core_ext/kernel_require.rb>:86:in `require'
    from $HOME/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/cocoapods-1.13.0/lib/cocoapods.rb:9:in `<top (required)>'
    from <internal:$HOME/.rbenv/versions/3.2.2/lib/ruby/site_ruby/3.2.0/rubygems/core_ext/kernel_require.rb>:86:in `require'
    from <internal:$HOME/.rbenv/versions/3.2.2/lib/ruby/site_ruby/3.2.0/rubygems/core_ext/kernel_require.rb>:86:in `require'
    from $HOME/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/cocoapods-1.13.0/bin/pod:36:in `<top (required)>'
    from $HOME/.rbenv/versions/3.2.2/bin/pod:25:in `load'
    from $HOME/.rbenv/versions/3.2.2/bin/pod:25:in `<main>'
```

处理方法：
```
sudo gem uninstall activesupport

sudo gem install activesupport --version 7.0.8
```


generate_multiple_pod_projects 是CocoaPods 1.7.0 加入的新的属性，主要是将pod中的文件以project的形式加入到项目中。在使用post_install 中配置三方库的时候需要注意pod下面的文件是以project形式存在的。

```
install! 'cocoapods',
         :generate_multiple_pod_projects => true,
         :incremental_installation => true 

post_install do |installer|
  puts "🚀 post_install start 🚀"
  installer.generated_projects.each do |project|
    puts "#{project.targets}"
    project.targets.each do |target|
      puts "#{target.name}"
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] ='NO'
        config.build_settings['VALID_ARCHS'] = 'arm64'
        config.build_settings['VALID_ARCHS[sdk=iphonesimulator*]'] = 'x86_64'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
  puts "🚀 post_install end 🚀"
end
```

## 6. 利用脚本完成整套开发环境的搭建

在项目目录中创建scripts目录存放了setup.sh脚本。执行脚本cd到项目目录后，在终端执行

```
$ ./scripts/setup.sh
```

脚本内容：

```
# shell: sh

# Install ruby using rbenv
ruby_version=`cat .ruby-version`
if [[ ! -d "$HOME/.rbenv/versions/$ruby_version" ]]; then
  rbenv install $ruby_version;
  rbenv init
fi

# Install bunlder
gem install bundler

# Install all gems
bundle install

# Install all pods
bundle exec pod install
```

第⼀步是对比.ruby-version文件中的ruby版本，如果版本不同就在 rbenv 下安装特定版本的 Ruby 开发环境, 
然后通过 RubyGems 安装 Bunlder, 
接着使⽤ Bundler 安装 CocoaPods 和 fastlane, 
最后通过CocoaPods安装各个 Pod. 

## 7. xccongif构建配置⽂件配置项目和多环境支持

⼀般在构建⼀个 iOS App 的时候，需要⽤到 Xcode Project，Xcode Target，Build Settings，Build Configuration 和 Xcode Scheme 等构建配置。

**Xcode Project**
⽤于组织源代码⽂件和资源⽂件。⼀个 Project 可以包含多个 Target，例如当我们新建⼀个 Xcode Project 的时候，它会⾃动⽣成 App 的主 Target，Unit Test Target 和 UI Test Target。

**Xcode Target**
⽤来定义如何构建出⼀个产品（例如 App， Extension 或者 Framework），Target 可以指定需 要编译的源代码⽂件和需要打包的资源⽂件，以及构建过程中的步骤。

**Build Setting**
保存了构建过程中需要⽤到的信息，它以⼀个变量的形式⽽存在，例如所⽀持的设备平台，或 者⽀持操作系统的最低版本等。

**Build Configuration**
就是⼀组 Build Setting。 我们可以通过 Build Configuration 来分组和管理不同组合的 Build Setting 集合，然后传递给 Xcode 构建系统进⾏编译。

**Xcode Scheme**
⽤于定义⼀个完整的构建过程，其包括指定哪些 Target 需要进⾏构建，构建过程中使⽤了哪 个 Build Configuration ，以及需要执⾏哪些测试案例等等。在项⽬新建的时候只有⼀个 Scheme，但可以为 同⼀个项⽬建⽴多个 Scheme。

**xcconfig**
⼀般修改 Build Setting 的办法是在 Xcode 的 Build Settings 界⾯上进⾏。 这样做有⼀些不好的地⽅，⾸先是⼿⼯修改很容易出错，其次，最关键的是每次修改完毕以后都会修改了 xcodeproj 项⽬⽂档，导致 Git 历史很难查看和对⽐。Xcode 为我们提供了⼀个统⼀管理这些 Build Setting 的便利⽅法，那就是使⽤ xcconfig 配置⽂件 来管理。

xcconfig也叫作 Build configuration file（构建配置⽂件），我们可以使⽤它来为 Project 或 Target 定义⼀组 Build Setting。由于它是⼀个纯⽂本⽂件，我们可以使⽤ Xcode 以外的其他⽂本编辑器来修改，⽽且可以保 存到 Git 进⾏统⼀管理。 这样远⽐我们在 Xcode 的 Build Settings 界⾯上⼿⼯修改要⽅便很多，⽽且还不容 易出错。

Apple官网： https://help.apple.com/xcode/mac/11.4/#/dev745c5c974

关于config的key值，可以查看官网的构建设置参考：https://help.apple.com/xcode/mac/11.4/#/itcaec37c2a6?sub=devec8d38b11

关于xcconfig使用和配置，AFNetworker 和 Alamofire 的作者写了一个使用教程 https://nshipster.com/xcconfig/ ，具体配置可以看这个教程，和源码查看。

## 8. xcconfig 使用中的一些问题

🔥🔥🔥 关于PRODUCT_BUNDLE_IDENTIFIER设置后不生效的问题？很多国内的网上说不能用xcconfig来配置，这是不正确的。

如果您要更改xcconfig中 PRODUCT_BUNDLE_IDENTIFIER 的值，您将看不到构建设置中反映的更改。那是因为包标识符当前在目标设置中是硬编码的。要解决此问题，请返回项目编辑器并选择 iOS-engineering Target。在build settings中搜索bundle字段，找到Product Bundle Identifier, 将值改为：

```
$(PRODUCT_BUNDLE_IDENTIFIER)
```

🔥🔥🔥 bundle display name, 可以自定义一个APP_NAME的值，然后在iOS-engineering Target的General 把Display Nmae修改为：

```
$(APP_NAME)
```

🔥🔥🔥 同样关于APP Version 和 build Version用xcconfig来管理, 要解决此问题，请返回项目编辑器并选择 iOS-engineering Target -> General -> identity里面。将Version和Build的值分别改为Common.xcconfig中的字段：

```
$(PRODUCT_VERSION_BASE)
```

```
$(PRODUCT_VERSION_SUFFIX)
```

注意：当您从Info.plist或.entitlements文件中引用构建设置时，您使用相同的引用语法。$(xxx)

这里的详细操作可以查看源码配置，或者下面的配置出处：
 https://www.kodeco.com/21441177-building-your-app-using-build-configurations-and-xcconfig

## 9. demo运行

1. clone源码
2. 先安装rbenv
3. cd到项目目录，运行脚本安装所有必需的组件并设置开发环境

```
./scripts/setup.sh
```

## 10. Fastlane

[All fastlane docs](https://docs.fastlane.tools/)
