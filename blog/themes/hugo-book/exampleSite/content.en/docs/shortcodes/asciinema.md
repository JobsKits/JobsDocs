# Asciinema

<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

Asciinema shortcode integrates asciinema player into the markdown page.

```tpl
{{</* asciinema
  cast="asciinema-627097.cast"
  or
  cast="https://asciinema.org/a/vJNKUQFjuh7qKI2j3OoaKs8Jk.cast"
  loop=true
  autoplay=true
  speed=2 */>}}
```

{{< asciinema
  cast="asciinema-627097.cast"
  loop=true
  autoplay=true
  speed=2 >}}

## Parameters

All parameters added to the shortcode will be transformed to options for Asciinema player, expect `cast` parameter that is used to locate cast file. Cast file follows same rules as portable image, it could be site resource, page resource or remote file URL.

[List of Asciinema options](https://docs.asciinema.org/manual/player/options/)
