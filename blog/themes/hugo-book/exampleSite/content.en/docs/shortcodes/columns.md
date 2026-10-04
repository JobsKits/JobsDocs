# <span id="前言">Columns</span>

<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

Columns help organize shorter pieces of content horizontally for readability. `columns` shortcode styles markdown list as up to 3 columns.

## Example <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```tpl
{{%/* columns [ratio="1:1"] [class="..."] */%}}
- ### Left Content
  Lorem markdownum insigne...

- ### Mid Content
  Lorem markdownum insigne...

- ### Right Content
  Lorem markdownum insigne...
{{%/* /columns */%}}
```

{{% columns %}}
- ### Left Content
  Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat
  stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa
  protulit, sed sed aere valvis inhaesuro Pallas animam: qui _quid_, ignes.
  Miseratus fonte Ditis conubia.

- ### Mid Content
  Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat
  stringit, frustra Saturnius uteroque inter!

- ### Right Content
  Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat
  stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa
  protulit, sed sed aere valvis inhaesuro Pallas animam: qui _quid_, ignes.
  Miseratus fonte Ditis conubia.
{{% /columns %}}

## Settings size ratio for columns <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```tpl
{{%/* columns ratio="1:2" */%}}
- ## x1 Column
  Lorem markdownum insigne...

- ## x2 Column
  Lorem markdownum insigne...
{{%/* /columns */%}}
```

{{% columns ratio="1:2" %}}
- ### x1 Column
  Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat
  stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa
  protulit, sed sed aere valvis inhaesuro Pallas animam: qui _quid_, ignes.
  Miseratus fonte Ditis conubia.

- ### x2 Column
  Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat
  stringit, frustra Saturnius uteroque inter!
  
  Lorem markdownum insigne. Olympo signis Delphis! Retexi Nereius nova develat
  stringit, frustra Saturnius uteroque inter! Oculis non ritibus Telethusa
  protulit, sed sed aere valvis inhaesuro Pallas animam: qui _quid_, ignes.
  Miseratus fonte Ditis conubia.
{{% /columns %}}

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
