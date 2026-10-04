# <span id="前言">Details</span>

<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

Details shortcode is a helper for `details` html5 element. To collapse the details either omit the `open`
keyword when using positional arguments or set `open=false` when using parameters.

## Example with positional arguments <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```tpl
{{%/* details "Title" [open] */%}}
## Markdown content
Lorem markdownum insigne...
{{%/* /details */%}}
```

{{% details "Title" open %}}
## Markdown content <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
Lorem markdownum insigne...
{{% /details %}}

## Example with parameters <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
```tpl
{{%/* details title="Title" open=true */%}}
## Markdown content
Lorem markdownum insigne...
{{%/* /details */%}}
```

{{% details title="Title" open=true %}}
## Markdown content <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>
Lorem markdownum insigne...
{{% /details %}}

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
