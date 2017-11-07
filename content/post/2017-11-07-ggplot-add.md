---
title: "An Example Usage of ggplot_add()"
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

## `geom_*()` doesn't know about the other layers

`geom_highlight_point(value > 20)` is passed `value > 20` without the data `d`, with which the expression should be evaluated. 
It needs `d` specified in `ggplot(...)`.

But, considering the structure of the above code, `geom_highlight_point(...)` cannot access to the result of `ggplot(...)` in any usual way:

```r
`+`(ggplot(...), geom_highlight_point(...))
```

If ggplot2 were designed pipe-friendly, this 

```r
`%>%`(ggplot(...), geom_highlight_point(...))
```

would be evaluated as this, which means `geom_highlight_point(...)` could take `d` from `ggplot(...)`...

```r
geom_highlight_point(ggplot(...), ...)
```

Anyway, let's give up here. All I have to do is set this expression as an attribute of a custom `Geom` and pray that it will be evaluated with the proper data in the phase of building a plot.

## `*Geom` doesn't know about the original data

Take a look at the simplest example in [the vignette "Extending ggplot2"](http://ggplot2.tidyverse.org/articles/extending-ggplot2.html):

```r
StatChull <- ggproto("StatChull", Stat,
  compute_group = function(data, scales) {
    data[chull(data$x, data$y), , drop = FALSE]
  },

  required_aes = c("x", "y")
)
```

You may notice that `compute_group()` expects `data` has the fixed column `x` and `y`. Actually, `data` is not the original data but the one the mapping is already applied. So, there is no column `value` anymore; it is renamed to `y`.

## Overwrite `+.gg`?