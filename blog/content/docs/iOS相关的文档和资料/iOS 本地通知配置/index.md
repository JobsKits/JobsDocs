---
title: "iOS 本地通知配置"
date: 2026-10-18T23:42:55+08:00
draft: false
weight: 520
summary: "📚 目录（点击展开 / 收起） - 一、在AppDelegate里面进行配置 - 二、相关工具类 - 三、相关调用 ## 一、在AppDelegate里面进行配置 🔼 🔽 ## 二、相关工具类 🔼 🔽 JobsLocalNotificationModel JobsMakeLocalNotification ## 三、相关调用 🔼 🔽 * ```objecti"
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

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [一、在AppDelegate里面进行配置](#jobs-toc-heading-1)
- [二、相关工具类](#jobs-toc-heading-2)
- [三、相关调用](#jobs-toc-heading-3)

</details>
<!-- jobs-toc:end -->

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">一、在`AppDelegate`里面进行配置 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

  ```objective-c
  #import "AppDelegate.h"
  
  @import UserNotifications;
  
  @interface AppDelegate () <UNUserNotificationCenterDelegate>
  @end
  
  @implementation AppDelegate
  
  - (BOOL)application:(NSApplication *)application didFinishLaunchingWithOptions:(NSDictionary<NSApplicationLaunchOptionsKey, id> *)launchOptions {
     UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
     center.delegate = self;
     [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                           completionHandler:^(BOOL granted, NSError * _Nullable error) {
         if (granted) {
             NSLog(@"Notification permission granted.");
         } else {
             NSLog(@"Notification permission denied.");
         }
     }];return YES;
  }
  
  // Handle notification when app is running
  - (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
     completionHandler(UNAuthorizationOptionAlert + UNAuthorizationOptionSound);
  }
  
  @end
  ```

## <span id="jobs-toc-heading-2" data-jobs-toc="v2">二、相关工具类 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* **JobsLocalNotificationModel**

  ```objective-c
  @interface JobsLocalNotificationModel : NSObject
  
  @property(nonatomic,copy)NSString *identifier;
  @property(nonatomic,copy)NSString *title;
  @property(nonatomic,copy)NSString *body;
  @property(nonatomic,strong)UNNotificationSound *sound API_UNAVAILABLE(tvos);
  @property(nonatomic,assign)NSTimeInterval triggerWithTimeInterval;// 时间间隔必须大于0，否则崩溃
  @property(nonatomic,assign)BOOL repeats;
  
  @end
  ```

  ```objective-c
  @implementation JobsLocalNotificationModel
  
  -(NSString *)identifier{
      if (!_identifier) {
          _identifier = @"DemoNotification";
      }return _identifier;
  }
  
  -(NSString *)title{
      if (!_title) {
          _title = JobsInternationalization(@"本地通知");
      }return _title;
  }
  
  -(NSString *)body{
      if (!_body) {
          _body = JobsInternationalization(@"这是一个示例本地通知");
      }return _body;
  }
  
  -(UNNotificationSound *)sound{
      if (!_sound) {
          _sound = UNNotificationSound.defaultSound;
      }return _sound;
  }
  
  -(NSTimeInterval)triggerWithTimeInterval{
      if (_triggerWithTimeInterval <= 0) {
          _triggerWithTimeInterval = 1;
      }return _triggerWithTimeInterval;
  }
  
  @end
  ```

* **JobsMakeLocalNotification**

  ```objective-c
  @interface JobsMakeLocalNotification : NSObject
  
  - (void)triggerLocalNotification:(JobsLocalNotificationModel *)localNotificationModel;
  
  @end
  ```

  ```objective-c
  #import "JobsMakeLocalNotification.h"
  
  @interface JobsMakeLocalNotification ()
  
  @end
  
  @implementation JobsMakeLocalNotification
  
  - (void)triggerLocalNotification:(JobsLocalNotificationModel *)localNotificationModel{
      UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
      UNMutableNotificationContent *content = UNMutableNotificationContent.new;
      content.title = localNotificationModel.title;
      content.body = localNotificationModel.body;
      content.sound = localNotificationModel.sound;
      UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:localNotificationModel.triggerWithTimeInterval
                                                                                                      repeats:localNotificationModel.repeats];
      UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:localNotificationModel.identifier
                                                                            content:content
                                                                            trigger:trigger];
      [center addNotificationRequest:request
               withCompletionHandler:^(NSError * _Nullable error) {
          if (error) {
              NSLog(@"Error adding notification: %@", error);
          } else {
              NSLog(@"Notification scheduled.");
          }
      }];
  }
  
  @end
  ```

## <span id="jobs-toc-heading-3" data-jobs-toc="v2">三、相关调用 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* ```objective-c
  [JobsMakeLocalNotification.new triggerLocalNotification:JobsLocalNotificationModel.new];
  ```

  

  

  

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
