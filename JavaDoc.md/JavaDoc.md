# <span id="前言">JavaDoc</span>

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

- [Lambda](#jobs-toc-heading-1)

</details>
<!-- jobs-toc:end -->

当前总行数：26 行

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">Lambda <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

* Lambda表达式是**Java 8**引入的一种简洁的语法,用于编写函数式接口的实例；
* 在**Java 8**之前没有Lambda表达式的时候，通常使用匿名内部类的方式来实现回调；

* 函数式接口是只有一个抽象方法的接口。Lambda表达式可以让代码变得更加简洁紧凑，更易读；
* 类似于OC中的Block

* 使用Lambda表达式`v -> {...}`书写，来替代了匿名内部类：

  ```java
  Button button = findViewById(R.id.button);
  button.setOnClickListener(v -> {
      // 点击事件处理逻辑
      Toast.makeText(this, "Button clicked!", Toast.LENGTH_SHORT).show();
  });
  ```

* 匿名内部类是一种特殊的内部类，它没有名称，只有在需要创建一个类的实例时才会被定义和实例化。它常用于实现只用一次的简单接口或抽象类；使用匿名内部类书写：

  ```java
  Button button = findViewById(R.id.button);
  /// 使用匿名内部类书写：
  button.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
          Toast.makeText(this, "Button clicked!", Toast.LENGTH_SHORT).show();
      }
  });
  ```

* 此外，Lambda表达式也可以与一些新的Java类和接口一起使用。比如Stream、Optional等，使代码更加函数式。不过在Android开发中，经常会使用一些回调接口。例如设置点击事件监听器、处理异步任务结果等，我们一般更多地使用它来简化回调代码。

  

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
