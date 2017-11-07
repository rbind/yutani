---
title: "ggplot_add() Will Allow Us to Create More Flexible ggplot2 Extension"
date: "2017-11-07"
categories: ["R"]
tags: ["gghighlight", "ggplot2", "package"]
---

A generic function `ggplot_add()` was added to ggplot2 by this PR:

[Allow addition of custom objects by thomasp85 · Pull Request #2309 · tidyverse/ggplot2](https://github.com/tidyverse/ggplot2/pull/2309)

I think creating a custom `Geom` or `Stat` and its constructor (`geom_*()` or `stat_*()`) is enough for the most of the extension packages of ggplot2, but some people, including me, need this.

## Why are there no `geom_highlight()`?

Here is an example code of my package [gghighlight](https://yutani.rbind.io/post/2017-10-06-gghighlight/):

```r
gghighlight_point(d, aes(idx, value), predicate = value > 10)
```

You may wonder why this can't be written like this:

```r
ggplot(d, aes(idx, value)) +
  geom_highlight_point(value > 20)
```

Let me explain a bit.

### `geom_*()` doesn't know about the other layers

`geom_highlight_point(value > 20)` is passed `value > 20` without the data `d`, with which the expression should be evaluated. 
`d` is specified in `ggplot(...)`.

Considering the structure of the above code, `geom_highlight_point(...)` cannot access to the result of `ggplot(...)` in any usual way:

```r
`+`(ggplot(...), geom_highlight_point(...))
```

If ggplot2 were designed pipe-friendly, this 

```r
`%>%`(ggplot(...), geom_highlight_point(...))
```

will be evaluated as this, which means `geom_highlight_point(...)` could take `d` from `ggplot(...)`...

```r
geom_highlight_point(ggplot(...), ...)
```