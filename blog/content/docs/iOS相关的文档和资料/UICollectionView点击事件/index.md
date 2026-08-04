---
title: "UICollectionView点击事件"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 330
summary: ""
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

```objective-c
UICollectionView 似乎不能直接响应touchBegan
只能用手势

{
    _collectionView.userInteractionEnabled = YES;
    _collectionView.target = self;
    _collectionView.tapGRSEL = NSStringFromSelector(@selector(endEditing));
    _collectionView.numberOfTouchesRequired = 1;
    _collectionView.numberOfTapsRequired = 1;
    _collectionView.tapGR.enabled = YES;
}

-(void)endEditing{
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
      shouldReceiveTouch:(UITouch *)touch{
   // 判断如果点击的View是UICollectionView就可以执行手势方法，否则不执行
   if ([touch.view isKindOfClass:UICollectionView.class]) {
       return YES;
   }return NO;
  }

<UIGestureRecognizerDelegate>
```

