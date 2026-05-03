---
title: "SwiftPackageDependence使用指南🧭"
date: 2026-01-12T17:08:55+07:00
draft: false
weight: 350
summary: "一、集成 Xcode 👉 File 👉 Add Package Dependencies ## 二、删除（涉及到3处） Xcode 👉 File 👉 Add Package Dependencies 工程x.xcodeproj 👉 PROJECT 👉 Package Dependencies 工程x.xcodeproj 👉 TARGETS 👉 General"
bookCollapseSection: false
---

# SwiftPackageDependence使用指南🧭


## 一、集成

* `Xcode` 👉 `File` 👉 `Add Package Dependencies`

  <table style="width:100%; table-layout:fixed;">
    <tr>
      <td><img src="./assets/image-20251114133113053.png" style="width:80%; height:auto;"></td>
      <td><img src="./assets/image-20251114133201979.png" style="width:100%; height:auto;"></td>
    </tr>
    <tr>
      <td><img src="./assets/image-20251114133251910.png" style="width:80%; height:auto;"></td>
      <td><img src="./assets/image-20251114133315318.png" style="width:100%; height:auto;"></td>
    </tr>
  </table>

## 二、删除（涉及到3处）

* `Xcode` 👉 `File` 👉 `Add Package Dependencies`

  ![image-20251114134004382](./assets/image-20251114134004382.png)

* 工程`x.xcodeproj `👉 `PROJECT` 👉 `Package Dependencies`

  ![image-20251114133615837](./assets/image-20251114133615837.png)

* 工程`x.xcodeproj `👉 `TARGETS` 👉 `General `👉 `Frameworks,Libraries,and Embedded Content`

  ![image-20251114132659685](./assets/image-20251114132659685.png)

## 三、清理缓存

* 每一次修改由<font color=red>**S**</font>wift<font color=red>**P**</font>ackage<font color=red>**D**</font>ependence管理的第三方，都需要：Xcode ➤ File ➤ Packages ➤ Reset Package Caches ➤ Resolve Package Visions

## 四、编译

```shell
swift package reset
swift package resolve
swift build
```



