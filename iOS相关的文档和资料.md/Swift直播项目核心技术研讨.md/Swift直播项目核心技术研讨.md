# Swift直播项目核心技术研讨

[toc]

## 一、前言

* 直播项目的核心难点，在于视频数据的处理，以及礼物特效

* 音视频这块是一个独立的领域，没有涉及过的技术人员，从理解基本原理到相关概念入手会比较吃力（在没有AI为辅助的基础上，目测需要3个月时间）

  * 寻找相关文档
  * 验证文档内容的真实可靠性
  * 寻找适合的SDK或者相关开源框架
  * 后端同样需要统一的齐平配合（统一的数据封装协议，流媒体服务器）

* 对于海外项目，特别是涉灰产业，直播这块如果定位于长期战略，<font color=red>**强烈建议自建播放器**</font>

  * 需要将最核心的组件部分，牢牢掌控在自己手里，防止因为政策变动，导致不可用
  * 一定是有内容过滤。是否启用全凭政策，而政策又是摇摆的
  * 大厂的播放器虽然稳定，对程序员来讲极度友好，但是代价（或者是隐患）就是：核心部分还是会打成`*.framework`或者`*.a`/`*.o`文件，如果涉及到特殊需求，可能难以入手

* 音视频的控制粒度很细，全球公认的一个基础起点是[**ffmpeg**](https://www.ffmpeg.org/)（持续更新中...）**至今无人超越**

  * 核心代码为C/C++。针对硬件加速（硬解码）的部分，会涉及到汇编

    * 在具体的绑定层，才涉及到具体的特殊的语言转译

  * 依据支持的音视频格式的不一，在代码层，提供了用户自定义的选择（意味着，需要根据自己的实际场景需求去打包）

  * 中国内地大厂的播放器（比如：QQ影音、爱奇艺...），均是在此基础上构建起来的（[**ffmpeg**](https://www.ffmpeg.org/)要求免费开源，而中国大陆项目在商业上使用（收费），所以被[**ffmpeg**](https://www.ffmpeg.org/)钉上了**耻辱柱**）

  * 在中国大陆，涉及到音视频相关产业的工程师的起薪，同级别要比其他要高1～1.5个层次（面试的时候，需要能准确说出[**ffmpeg**](https://www.ffmpeg.org/)指定函数的原理和机制）

  * 因为这个过程非常复杂，传统的做法就是在一些开源的框架上去进行二次封装和开发（深度修改和定制化开发，耗时耗力）我们需要在成本与产出之间寻求一个合理的平衡点

  * 那么，对**普通的用户端**来讲，其实只需要面对一个稳定的播放器（避免卡屏、蓝屏、有声音无图像、有图像无声音、音视频没对齐）足矣（面对一个URL来完成播放），**特效都是建立在播放器控制层来完成的**（比如水印）

    * 对移动端iOS@**OC**，播放器推荐选用[**ZFPlayer**](https://github.com/renzifeng/ZFPlayer)。推荐理由：稳定、Star高、支持高度自定义、内部解耦合理，来自社区9个贡献者

      ![image-20251207133934957](./assets/image-20251207133934957.png)

    * 对移动端iOS@**Swift**，播放器推荐选用[**BMPlayer**](https://github.com/BrikerMan/BMPlayer)。推荐理由：参考[**ZFPlayer**](https://github.com/renzifeng/ZFPlayer)，作为一个稳定库最近一年也在更新，Star不低，来自社区24个贡献者

      ![image-20251207134321098](./assets/image-20251207134321098.png)

  * 对主播端来讲，情况就有些复杂，我们要面对复杂的数据采集编码，其中包括但不仅限于：

    * 摄像头采集
  * 麦克风采集
    * 视频/音频编码参数（分辨率、码率、帧率、GOP）：
  * RTMP/WebRTC 推流
    * 美颜/滤镜/贴纸（两端都可以做滤镜，**但是更为主流的做法是放在主播端**。云端美颜 / 特效理论上可以，但成本和延迟都很高，一般是大厂、特定业务才会玩）
  * 弱网自适应码率、断线重连（推流侧那一套）
    * 把声音和图像合二为一（**只有多路混流（PK、连麦、大合唱）在服务器端做整合**）
  * 媒体流加密 / 自定义加密：第一层加密肯定是在主播端，服务器只做路由和内容转发。加密也分传输层（协议层）的加密➕内容加密
  
* 服务器端：内容转发、路由、**水印**

  * 对数据进行切片，形成`*.m3u8`，对客户端（HLS）

## 二、推流端（主播）架构

* **采集模块**

  * 摄像头采集
  * 麦克风采集
  * 输入参数：分辨率、fps、前/后摄像头、采样率等

* 处理模块

  * 美颜、滤镜、贴纸
  * 通常基于 GPUImage（历史包袱，已被逐步被淘汰） / **Metal** / 内置美颜 SDK

* **编码模块**

  * H.264 / H.265 视频编码
  * AAC 音频编码
  * 码率、GOP、profile-level 设置

* **网络推流模块（服务器集群）**

  * RTMP / SRT / WebRTC / 自家协议
  * 重连、网络切换（4G ↔ Wi-Fi）

* 会话控制模块

  * 状态机

    ```swift
    enum LivePusherState {
        case idle           // 初始态，什么都没干
        case preparing      // 正在做准备（申请权限、配置 session）
        case ready          // 采集和编码都就绪了，可以 start
        case connecting     // 正在连接推流服务器（RTMP/WebRTC/SRT）
        case publishing     // 推流中（音视频数据在往外发）
        case reconnecting   // 断线重连中
        case stopped        // 正常停止
        case error(LiveError) // 异常终止（权限拒绝/网络挂了/编码失败）
    }
    ```

  * 错误上报、码率统计、丢帧统计、日志上报

## 三、推流端（主播）开源框架

### 1、传统直播（RTMP/SRT/CDN）

![image-20251207142142317](./assets/image-20251207142142317.png)

*  [**HaishinKit.swift**](https://github.com/HaishinKit/HaishinKit.swift)的推荐理由
  * 纯[**Swift**](https://www.swift.org/)开发，社区很活跃（79名贡献者，159个正式版本，最近一次提交位于2日前）
  * [**HaishinKit.kt**](https://github.com/HaishinKit/HaishinKit.kt)支持**Android**
  * [**haishin_kit**](https://pub.dev/packages/haishin_kit)支持**Flutter**
  * Camera + Mic 采集
  * H.264 视频 + AAC 音频编码
  * RTMP / RTMPS / SRT 推流
  * 支持 iOS / macOS / tvOS / visionOS，一直在更新，10 年老项目。

### 2、互动直播 / 连麦（WebRTC 路线）

![image-20251207143654489](./assets/image-20251207143654489.png)

* [**livekit**](https://github.com/livekit/client-sdk-swift)推荐理由
  * 纯[**Swift**](https://www.swift.org/)开发，社区很活跃（28名贡献者，59个正式版本，最近一次提交位于3日前）
  * [**client-sdk-flutter**](https://github.com/livekit/client-sdk-flutter)支持**Flutter**
  * [**client-sdk-android**](https://github.com/livekit/client-sdk-android)支持**Android**
  * 基于 WebRTC 的实时音视频框架，**客户端 SDK + 开源服务器**。
  * 整体代码基本开源（只是它同时卖一个托管的 Cloud 服务而已,<font color=red>**付费**</font>），服务端是Go
    * 采集摄像头 / 麦克风
    * 发布本地 tracks（主播）
    * 订阅远端 tracks（观众 / 其他麦位）
