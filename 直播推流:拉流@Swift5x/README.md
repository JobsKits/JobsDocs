# 直播推流/拉流在**iOS**@[**Swift**](https://www.swift.org/)5x最小实践

* 服务器（本地）以**MacOS**和本地局域网为基础，辅以[**Homebrew**](https://brew.sh/) ➤ [**node**](https://nodejs.org/en) ➤ [**node-media-server@2.3.8**](https://github.com/codivoire/node-media-server)

* 视频采集端：**iOS**@[**Swift**](https://www.swift.org/)5x➕ [**HaishinKit**](https://github.com/HaishinKit/HaishinKit.swift) ➤ 输出视频流

* 服务器端（本地）：利用**Apple主导的HLS技术**切片成<font size=5>`*.ts`</font>格式，➤ 进行推流
  * 因为是直播，所以<font size=5>`*.ts`</font>文件，<font color=red>**滚动生成，阅后即焚**</font>
  
* 推流的效果
  * [**Google@Chrome浏览器**](https://www.google.com/intl/zh-CN/chrome/)不支持**HLS**，[**需要做特殊处理**](#对Chrome的特殊处理)
  
    ![image-20251209102115230](./assets/image-20251209102115230.png)
  
  * Apple自带的Safari浏览器天生支持**HLS**
  
    ![image-20251209102646523](./assets/image-20251209102646523.png)