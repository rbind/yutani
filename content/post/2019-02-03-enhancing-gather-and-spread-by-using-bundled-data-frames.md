---
title: Enhancing gather() and spread() by Using "Bundled" data.frames
author: ''
date: '2019-02-03'
slug: enhancing-gather-and-spread-by-using-bundled-data-frames
categories:
  - R
tags:
  - tidyr
  - tidy data
description: ''
---

<style>
table {
  width: 50%;
  font-size: 80%;
}
</style>

Last month, I tried to explain `gather()` and `spread()` by gt package (<https://yutani.rbind.io/post/gather-and-spread-explained-by-gt/>).
But, after I implemented experimental multi-`gather()` and multi-`spread()`, I realized that I need a bit different way of explanation...
So, please forget the post, and read this with fresh eyes!

## Wait, what is multi-`gather()` and multi-`spread()`??

In short, the current `gather()` and `spread()` has a limitation; they can gather from or spread into one column at once.
So, if we want to handle multiple columns, we need to coerce them to one column before the actual gathering or spreading.

This is especially problematic when the columns have different types.
For example, `date` column is unexpectedly converted to integers with the following code:


```r
library(tibble)
library(tidyr)

# a bit different version of https://github.com/tidyverse/tidyr/issues/149#issue-124411755
d <- tribble(
  ~place, ~censor,                  ~date, ~status,
    "g1",    "c1",  as.Date("2019-02-01"),   "ok",
    "g1",    "c2",  as.Date("2019-02-01"),  "bad",
    "g1",    "c3",  as.Date("2019-02-01"),   "ok",
    "g2",    "c1",  as.Date("2019-02-01"),  "bad",
    "g2",    "c2",  as.Date("2019-02-02"),   "ok"
)

d %>%
  gather(key = element, value = value, date, status) %>%
  unite(thing, place, element, remove = TRUE) %>%
  spread(thing, value, convert = TRUE)
#> Warning: attributes are not identical across measure variables;
#> they will be dropped
#> # A tibble: 3 x 5
#>   censor g1_date g1_status g2_date g2_status
#>   <chr>    <int> <chr>       <int> <chr>    
#> 1 c1       17928 ok          17928 bad      
#> 2 c2       17928 bad         17929 ok       
#> 3 c3       17928 ok             NA <NA>
```

Here, we need better `spread()` and `gather()`, that can handle multiple columns.
For more discussions, you can read the following issues:

* <https://github.com/tidyverse/tidyr/issues/149>
* <https://github.com/tidyverse/tidyr/issues/150>

In this post, I'm trying to explain an approach to solve this by using "bundled" data.frames, which is originally proposed by [Kirill Müller](https://github.com/tidyverse/tidyr/issues/149#issuecomment-452362362).

## "Bundled" data.frames

For convenience, I use a new term "**bundle**" for separating some of the columns of a data.frame to another data.frame, and assigning the new data.frame to a column, and "**unbundle**" for the opposite operation.

For example, "bundling `X`, `Y`, and `Z`" means converting this

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#rljitwalvf .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #000000;
  font-size: 16px;
  background-color: #FFFFFF;
  /* table.background.color */
  width: auto;
  /* table.width */
  border-top-style: solid;
  /* table.border.top.style */
  border-top-width: 2px;
  /* table.border.top.width */
  border-top-color: #A8A8A8;
  /* table.border.top.color */
}

#rljitwalvf .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#rljitwalvf .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#rljitwalvf .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#rljitwalvf .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#rljitwalvf .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#rljitwalvf .gt_col_heading {
  color: #000000;
  background-color: #FFFFFF;
  /* column_labels.background.color */
  font-size: 16px;
  /* column_labels.font.size */
  font-weight: initial;
  /* column_labels.font.weight */
  vertical-align: middle;
  padding: 10px;
  margin: 10px;
}

#rljitwalvf .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#rljitwalvf .gt_group_heading {
  padding: 8px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#rljitwalvf .gt_empty_group_heading {
  padding: 0.5px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#rljitwalvf .gt_striped {
  background-color: #f2f2f2;
}

#rljitwalvf .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#rljitwalvf .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#rljitwalvf .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#rljitwalvf .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#rljitwalvf .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#rljitwalvf .gt_table_body {
  border-top-style: solid;
  /* field.border.top.style */
  border-top-width: 2px;
  /* field.border.top.width */
  border-top-color: #A8A8A8;
  /* field.border.top.color */
  border-bottom-style: solid;
  /* field.border.bottom.style */
  border-bottom-width: 2px;
  /* field.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* field.border.bottom.color */
}

#rljitwalvf .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#rljitwalvf .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#rljitwalvf .gt_center {
  text-align: center;
}

#rljitwalvf .gt_left {
  text-align: left;
}

#rljitwalvf .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#rljitwalvf .gt_font_normal {
  font-weight: normal;
}

#rljitwalvf .gt_font_bold {
  font-weight: bold;
}

#rljitwalvf .gt_font_italic {
  font-style: italic;
}

#rljitwalvf .gt_super {
  font-size: 65%;
}

#rljitwalvf .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="rljitwalvf" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>id</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>X</th>
<th class='gt_col_heading gt_left' rowspan='1' colspan='1'>Y</th>
<th class='gt_col_heading gt_center' rowspan='1' colspan='1'>Z</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_right'>1</td>
<td class='gt_row gt_right'>0.1</td>
<td class='gt_row gt_left'>a</td>
<td class='gt_row gt_center'>TRUE</td>
</tr>
<tr>
<td class='gt_row gt_right gt_striped'>2</td>
<td class='gt_row gt_right gt_striped'>0.2</td>
<td class='gt_row gt_left gt_striped'>b</td>
<td class='gt_row gt_center gt_striped'>FALSE</td>
</tr>
<tr>
<td class='gt_row gt_right'>3</td>
<td class='gt_row gt_right'>0.3</td>
<td class='gt_row gt_left'>c</td>
<td class='gt_row gt_center'>TRUE</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

to something like this:

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#wassfahrxf .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #000000;
  font-size: 16px;
  background-color: #FFFFFF;
  /* table.background.color */
  width: auto;
  /* table.width */
  border-top-style: solid;
  /* table.border.top.style */
  border-top-width: 2px;
  /* table.border.top.width */
  border-top-color: #A8A8A8;
  /* table.border.top.color */
}

#wassfahrxf .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#wassfahrxf .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#wassfahrxf .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#wassfahrxf .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#wassfahrxf .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#wassfahrxf .gt_col_heading {
  color: #000000;
  background-color: #FFFFFF;
  /* column_labels.background.color */
  font-size: 16px;
  /* column_labels.font.size */
  font-weight: initial;
  /* column_labels.font.weight */
  vertical-align: middle;
  padding: 10px;
  margin: 10px;
}

#wassfahrxf .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#wassfahrxf .gt_group_heading {
  padding: 8px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#wassfahrxf .gt_empty_group_heading {
  padding: 0.5px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#wassfahrxf .gt_striped {
  background-color: #f2f2f2;
}

#wassfahrxf .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#wassfahrxf .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#wassfahrxf .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#wassfahrxf .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#wassfahrxf .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#wassfahrxf .gt_table_body {
  border-top-style: solid;
  /* field.border.top.style */
  border-top-width: 2px;
  /* field.border.top.width */
  border-top-color: #A8A8A8;
  /* field.border.top.color */
  border-bottom-style: solid;
  /* field.border.bottom.style */
  border-bottom-width: 2px;
  /* field.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* field.border.bottom.color */
}

#wassfahrxf .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#wassfahrxf .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#wassfahrxf .gt_center {
  text-align: center;
}

#wassfahrxf .gt_left {
  text-align: left;
}

#wassfahrxf .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#wassfahrxf .gt_font_normal {
  font-weight: normal;
}

#wassfahrxf .gt_font_bold {
  font-weight: bold;
}

#wassfahrxf .gt_font_italic {
  font-style: italic;
}

#wassfahrxf .gt_super {
  font-size: 65%;
}

#wassfahrxf .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="wassfahrxf" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_center' rowspan='2' colspan='1'>id</th>
<th class='gt_col_heading gt_column_spanner gt_center' rowspan='1' colspan='3'>foo</th>
</tr>
<tr>
<th class='gt_col_heading gt_left' rowspan='1' colspan='1'>X</th>
<th class='gt_col_heading gt_center' rowspan='1' colspan='1'>Y</th>
<th class='gt_col_heading gt_NA' rowspan='1' colspan='1'>Z</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_right'>1</td>
<td class='gt_row gt_right'>0.1</td>
<td class='gt_row gt_left'>a</td>
<td class='gt_row gt_center'>TRUE</td>
</tr>
<tr>
<td class='gt_row gt_right gt_striped'>2</td>
<td class='gt_row gt_right gt_striped'>0.2</td>
<td class='gt_row gt_left gt_striped'>b</td>
<td class='gt_row gt_center gt_striped'>FALSE</td>
</tr>
<tr>
<td class='gt_row gt_right'>3</td>
<td class='gt_row gt_right'>0.3</td>
<td class='gt_row gt_left'>c</td>
<td class='gt_row gt_center'>TRUE</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

You might wonder if this is really possible without dangerous hacks. But, with tibble package ([2D columns are supported now](https://www.tidyverse.org/articles/2019/01/tibble-2.0.1/#2d-columns)), this is as easy as:


```r
tibble(
  id = 1:3,
  foo = tibble(
    X = 1:3 * 0.1,
    Y = letters[1:3],
    Z = c(TRUE, FALSE, TRUE)
  )
)
#> # A tibble: 3 x 2
#>      id foo$X $Y    $Z   
#>   <int> <dbl> <chr> <lgl>
#> 1     1   0.1 a     TRUE 
#> 2     2   0.2 b     FALSE
#> 3     3   0.3 c     TRUE
```

For more information about data.frame columns, please see [Advanced R](https://adv-r.hadley.nz/vectors-chap.html#matrix-and-data-frame-columns).

## An experimental package for this

I created a package for bundling, **tiedr**. Since this is just an experiment, I don't seriously introduce this.
But, for convenience, let me use this package in this post because, otherwise, the code would be a bit long and hard to read...

<https://github.com/yutannihilation/tiedr>

I need four functions from this package, `bundle()`, `unbundle()`, `gather_bundles()`, and `spread_bundles()`.
`gather_bundles()` and `spread_bundles()` are some kind of the variants of `gather()` and `spread()`, so probably you can guess the usages.
Here, I just explain about the first two functions briefly.

### `bundle()`

`bundle()` bundles columns. It takes data, and the specifications of bundles in the form of `new_col1 = c(col1, col2, ...), new_col2 = c(col3, col4, ...), ...`.


```r
library(tiedr)

d <- tibble(id = 1:3, X = 1:3 * 0.1, Y = letters[1:3], Z = c(TRUE, FALSE, TRUE))

bundle(d, foo = X:Z)
#> # A tibble: 3 x 2
#>      id foo$X $Y    $Z   
#>   <int> <dbl> <chr> <lgl>
#> 1     1   0.1 a     TRUE 
#> 2     2   0.2 b     FALSE
#> 3     3   0.3 c     TRUE
```

`bundle()` also can rename the sub-columns at the same time.


```r
bundle(d, foo = c(x = X, y = Y, z = Z))
#> # A tibble: 3 x 2
#>      id foo$x $y    $z   
#>   <int> <dbl> <chr> <lgl>
#> 1     1   0.1 a     TRUE 
#> 2     2   0.2 b     FALSE
#> 3     3   0.3 c     TRUE
```

### `unbundle()`

`unbundle()` unbundles columns. This operation is almost the opposite of what `bundle()` does;
one difference is that this adds the name of the bundle as prefix by default in order to avoid name collisions.
In case the prefix is not needed, we can use `sep = NULL`.


```r
d %>%
  bundle(foo = X:Z) %>% 
  unbundle(foo)
#> # A tibble: 3 x 4
#>      id foo_X foo_Y foo_Z
#>   <int> <dbl> <chr> <lgl>
#> 1     1   0.1 a     TRUE 
#> 2     2   0.2 b     FALSE
#> 3     3   0.3 c     TRUE
```

## Expose hidden structures in colnames as bundles

One of the meaningful usage of bundled data.frame is to express the structure of a data.
Suppose we have this data (from [tidyverse/tidyr#150](https://github.com/tidyverse/tidyr/issues/150#issuecomment-168829613):


```r
d <- tribble(
  ~Race,~Female_LoTR,~Male_LoTR,~Female_TT,~Male_TT,~Female_RoTK,~Male_RoTK,
  "Elf",        1229,       971,       331,     513,         183,       510,
  "Hobbit",       14,      3644,         0,    2463,           2,      2673,
  "Man",           0,      1995,       401,    3589,         268,      2459
)
```

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#papwuewpno .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #000000;
  font-size: 16px;
  background-color: #FFFFFF;
  /* table.background.color */
  width: auto;
  /* table.width */
  border-top-style: solid;
  /* table.border.top.style */
  border-top-width: 2px;
  /* table.border.top.width */
  border-top-color: #A8A8A8;
  /* table.border.top.color */
}

#papwuewpno .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#papwuewpno .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#papwuewpno .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#papwuewpno .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#papwuewpno .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#papwuewpno .gt_col_heading {
  color: #000000;
  background-color: #FFFFFF;
  /* column_labels.background.color */
  font-size: 16px;
  /* column_labels.font.size */
  font-weight: initial;
  /* column_labels.font.weight */
  vertical-align: middle;
  padding: 10px;
  margin: 10px;
}

#papwuewpno .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#papwuewpno .gt_group_heading {
  padding: 8px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#papwuewpno .gt_empty_group_heading {
  padding: 0.5px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#papwuewpno .gt_striped {
  background-color: #f2f2f2;
}

#papwuewpno .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#papwuewpno .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#papwuewpno .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#papwuewpno .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#papwuewpno .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#papwuewpno .gt_table_body {
  border-top-style: solid;
  /* field.border.top.style */
  border-top-width: 2px;
  /* field.border.top.width */
  border-top-color: #A8A8A8;
  /* field.border.top.color */
  border-bottom-style: solid;
  /* field.border.bottom.style */
  border-bottom-width: 2px;
  /* field.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* field.border.bottom.color */
}

#papwuewpno .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#papwuewpno .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#papwuewpno .gt_center {
  text-align: center;
}

#papwuewpno .gt_left {
  text-align: left;
}

#papwuewpno .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#papwuewpno .gt_font_normal {
  font-weight: normal;
}

#papwuewpno .gt_font_bold {
  font-weight: bold;
}

#papwuewpno .gt_font_italic {
  font-style: italic;
}

#papwuewpno .gt_super {
  font-size: 65%;
}

#papwuewpno .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="papwuewpno" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_left' rowspan='1' colspan='1'>Race</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Female_LoTR</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Male_LoTR</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Female_TT</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Male_TT</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Female_RoTK</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Male_RoTK</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_left'>Elf</td>
<td class='gt_row gt_right'>1229</td>
<td class='gt_row gt_right'>971</td>
<td class='gt_row gt_right'>331</td>
<td class='gt_row gt_right'>513</td>
<td class='gt_row gt_right'>183</td>
<td class='gt_row gt_right'>510</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>Hobbit</td>
<td class='gt_row gt_right gt_striped'>14</td>
<td class='gt_row gt_right gt_striped'>3644</td>
<td class='gt_row gt_right gt_striped'>0</td>
<td class='gt_row gt_right gt_striped'>2463</td>
<td class='gt_row gt_right gt_striped'>2</td>
<td class='gt_row gt_right gt_striped'>2673</td>
</tr>
<tr>
<td class='gt_row gt_left'>Man</td>
<td class='gt_row gt_right'>0</td>
<td class='gt_row gt_right'>1995</td>
<td class='gt_row gt_right'>401</td>
<td class='gt_row gt_right'>3589</td>
<td class='gt_row gt_right'>268</td>
<td class='gt_row gt_right'>2459</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

In this data, the prefixes `Female_` and `Male_` represent the column groups.
Thus, as [Kirill Müller suggests in the comment](https://github.com/tidyverse/tidyr/issues/150#issuecomment-452366429), these columns can be bundled (with the sub-columns renamed) to:

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#yjouakohbf .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #000000;
  font-size: 16px;
  background-color: #FFFFFF;
  /* table.background.color */
  width: auto;
  /* table.width */
  border-top-style: solid;
  /* table.border.top.style */
  border-top-width: 2px;
  /* table.border.top.width */
  border-top-color: #A8A8A8;
  /* table.border.top.color */
}

#yjouakohbf .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#yjouakohbf .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#yjouakohbf .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#yjouakohbf .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#yjouakohbf .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#yjouakohbf .gt_col_heading {
  color: #000000;
  background-color: #FFFFFF;
  /* column_labels.background.color */
  font-size: 16px;
  /* column_labels.font.size */
  font-weight: initial;
  /* column_labels.font.weight */
  vertical-align: middle;
  padding: 10px;
  margin: 10px;
}

#yjouakohbf .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#yjouakohbf .gt_group_heading {
  padding: 8px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#yjouakohbf .gt_empty_group_heading {
  padding: 0.5px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#yjouakohbf .gt_striped {
  background-color: #f2f2f2;
}

#yjouakohbf .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#yjouakohbf .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#yjouakohbf .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#yjouakohbf .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#yjouakohbf .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#yjouakohbf .gt_table_body {
  border-top-style: solid;
  /* field.border.top.style */
  border-top-width: 2px;
  /* field.border.top.width */
  border-top-color: #A8A8A8;
  /* field.border.top.color */
  border-bottom-style: solid;
  /* field.border.bottom.style */
  border-bottom-width: 2px;
  /* field.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* field.border.bottom.color */
}

#yjouakohbf .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#yjouakohbf .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#yjouakohbf .gt_center {
  text-align: center;
}

#yjouakohbf .gt_left {
  text-align: left;
}

#yjouakohbf .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#yjouakohbf .gt_font_normal {
  font-weight: normal;
}

#yjouakohbf .gt_font_bold {
  font-weight: bold;
}

#yjouakohbf .gt_font_italic {
  font-style: italic;
}

#yjouakohbf .gt_super {
  font-size: 65%;
}

#yjouakohbf .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="yjouakohbf" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_center' rowspan='2' colspan='1'>Race</th>
<th class='gt_col_heading gt_column_spanner gt_sep_right gt_center' rowspan='1' colspan='3' style="color:#414487FF;font-weight:bold;">Female</th>
<th class='gt_col_heading gt_column_spanner gt_center' rowspan='1' colspan='3' style="color:#7AD151FF;font-weight:bold;">Male</th>
</tr>
<tr>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>LoTR</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>TT</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>RoTK</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>LoTR</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>TT</th>
<th class='gt_col_heading gt_NA' rowspan='1' colspan='1'>RoTK</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_left'>Elf</td>
<td class='gt_row gt_right'>1229</td>
<td class='gt_row gt_right'>331</td>
<td class='gt_row gt_right'>183</td>
<td class='gt_row gt_right'>971</td>
<td class='gt_row gt_right'>513</td>
<td class='gt_row gt_right'>510</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>Hobbit</td>
<td class='gt_row gt_right gt_striped'>14</td>
<td class='gt_row gt_right gt_striped'>0</td>
<td class='gt_row gt_right gt_striped'>2</td>
<td class='gt_row gt_right gt_striped'>3644</td>
<td class='gt_row gt_right gt_striped'>2463</td>
<td class='gt_row gt_right gt_striped'>2673</td>
</tr>
<tr>
<td class='gt_row gt_left'>Man</td>
<td class='gt_row gt_right'>0</td>
<td class='gt_row gt_right'>401</td>
<td class='gt_row gt_right'>268</td>
<td class='gt_row gt_right'>1995</td>
<td class='gt_row gt_right'>3589</td>
<td class='gt_row gt_right'>2459</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

With `bundle()` we can write this as:


```r
d_bundled <- d %>% 
  bundle(
    Female = c(LoTR = Female_LoTR, TT = Female_TT, RoTK = Female_RoTK),
    Male   = c(LoTR = Male_LoTR,   TT = Male_TT,   RoTK = Male_RoTK)
  )

d_bundled
#> # A tibble: 3 x 3
#>   Race   Female$LoTR   $TT $RoTK Male$LoTR   $TT $RoTK
#>   <chr>        <dbl> <dbl> <dbl>     <dbl> <dbl> <dbl>
#> 1 Elf           1229   331   183       971   513   510
#> 2 Hobbit          14     0     2      3644  2463  2673
#> 3 Man              0   401   268      1995  3589  2459
```

## `gather()` the bundles

Remember `gather()` strips colnames and convert it to a column.
We can do this operation for bundled data.frames in the same manner.
But, unlike `gather()` for flat data.frames, we don't need to specify a colname for values, because the contents in bundles already have their colnames.

Let's gather `Female` and `Male` bundles into `key` column.


```r
d_gathered <- d_bundled %>%
  gather_bundles(Female, Male, .key = "key")

d_gathered
#> # A tibble: 6 x 5
#>   Race   key     LoTR    TT  RoTK
#>   <chr>  <chr>  <dbl> <dbl> <dbl>
#> 1 Elf    Female  1229   331   183
#> 2 Hobbit Female    14     0     2
#> 3 Man    Female     0   401   268
#> 4 Elf    Male     971   513   510
#> 5 Hobbit Male    3644  2463  2673
#> 6 Man    Male    1995  3589  2459
```

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#xhrjgrvlmq .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #000000;
  font-size: 16px;
  background-color: #FFFFFF;
  /* table.background.color */
  width: auto;
  /* table.width */
  border-top-style: solid;
  /* table.border.top.style */
  border-top-width: 2px;
  /* table.border.top.width */
  border-top-color: #A8A8A8;
  /* table.border.top.color */
}

#xhrjgrvlmq .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#xhrjgrvlmq .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#xhrjgrvlmq .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#xhrjgrvlmq .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#xhrjgrvlmq .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#xhrjgrvlmq .gt_col_heading {
  color: #000000;
  background-color: #FFFFFF;
  /* column_labels.background.color */
  font-size: 16px;
  /* column_labels.font.size */
  font-weight: initial;
  /* column_labels.font.weight */
  vertical-align: middle;
  padding: 10px;
  margin: 10px;
}

#xhrjgrvlmq .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#xhrjgrvlmq .gt_group_heading {
  padding: 8px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#xhrjgrvlmq .gt_empty_group_heading {
  padding: 0.5px;
  color: #000000;
  background-color: #FFFFFF;
  /* stub_group.background.color */
  font-size: 16px;
  /* stub_group.font.size */
  font-weight: initial;
  /* stub_group.font.weight */
  border-top-style: solid;
  /* stub_group.border.top.style */
  border-top-width: 2px;
  /* stub_group.border.top.width */
  border-top-color: #A8A8A8;
  /* stub_group.border.top.color */
  border-bottom-style: solid;
  /* stub_group.border.bottom.style */
  border-bottom-width: 2px;
  /* stub_group.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* stub_group.border.bottom.color */
  vertical-align: middle;
}

#xhrjgrvlmq .gt_striped {
  background-color: #f2f2f2;
}

#xhrjgrvlmq .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#xhrjgrvlmq .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#xhrjgrvlmq .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#xhrjgrvlmq .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#xhrjgrvlmq .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#xhrjgrvlmq .gt_table_body {
  border-top-style: solid;
  /* field.border.top.style */
  border-top-width: 2px;
  /* field.border.top.width */
  border-top-color: #A8A8A8;
  /* field.border.top.color */
  border-bottom-style: solid;
  /* field.border.bottom.style */
  border-bottom-width: 2px;
  /* field.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* field.border.bottom.color */
}

#xhrjgrvlmq .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#xhrjgrvlmq .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#xhrjgrvlmq .gt_center {
  text-align: center;
}

#xhrjgrvlmq .gt_left {
  text-align: left;
}

#xhrjgrvlmq .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#xhrjgrvlmq .gt_font_normal {
  font-weight: normal;
}

#xhrjgrvlmq .gt_font_bold {
  font-weight: bold;
}

#xhrjgrvlmq .gt_font_italic {
  font-style: italic;
}

#xhrjgrvlmq .gt_super {
  font-size: 65%;
}

#xhrjgrvlmq .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="xhrjgrvlmq" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_left' rowspan='1' colspan='1'>Race</th>
<th class='gt_col_heading gt_left' rowspan='1' colspan='1'>key</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>LoTR</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>TT</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>RoTK</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_left'>Elf</td>
<td class='gt_row gt_left' style="color:#414487FF;font-weight:bold;">Female</td>
<td class='gt_row gt_right'>1229</td>
<td class='gt_row gt_right'>331</td>
<td class='gt_row gt_right'>183</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>Hobbit</td>
<td class='gt_row gt_left gt_striped' style="color:#414487FF;font-weight:bold;">Female</td>
<td class='gt_row gt_right gt_striped'>14</td>
<td class='gt_row gt_right gt_striped'>0</td>
<td class='gt_row gt_right gt_striped'>2</td>
</tr>
<tr>
<td class='gt_row gt_left'>Man</td>
<td class='gt_row gt_left' style="color:#414487FF;font-weight:bold;">Female</td>
<td class='gt_row gt_right'>0</td>
<td class='gt_row gt_right'>401</td>
<td class='gt_row gt_right'>268</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>Elf</td>
<td class='gt_row gt_left gt_striped' style="color:#7AD151FF;font-weight:bold;">Male</td>
<td class='gt_row gt_right gt_striped'>971</td>
<td class='gt_row gt_right gt_striped'>513</td>
<td class='gt_row gt_right gt_striped'>510</td>
</tr>
<tr>
<td class='gt_row gt_left'>Hobbit</td>
<td class='gt_row gt_left' style="color:#7AD151FF;font-weight:bold;">Male</td>
<td class='gt_row gt_right'>3644</td>
<td class='gt_row gt_right'>2463</td>
<td class='gt_row gt_right'>2673</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>Man</td>
<td class='gt_row gt_left gt_striped' style="color:#7AD151FF;font-weight:bold;">Male</td>
<td class='gt_row gt_right gt_striped'>1995</td>
<td class='gt_row gt_right gt_striped'>3589</td>
<td class='gt_row gt_right gt_striped'>2459</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

Now we have all parts for implementing multi-`gather()`. I did bundling by manual, but we can have a helper to find the common prefix and bundle them automatically. So, multi-`gather()` is something like:


```r
d %>%
  auto_bundle(-Race) %>% 
  gather_bundles()
#> # A tibble: 6 x 5
#>   Race   key     LoTR    TT  RoTK
#>   <chr>  <chr>  <dbl> <dbl> <dbl>
#> 1 Elf    Female  1229   331   183
#> 2 Hobbit Female    14     0     2
#> 3 Man    Female     0   401   268
#> 4 Elf    Male     971   513   510
#> 5 Hobbit Male    3644  2463  2673
#> 6 Man    Male    1995  3589  2459
```

![](/images/2019-02-03-multi-gather.jpg)

## `spread()` to the bundles

As we already saw it's possible to `gather()` multiple bundles, now it's obvious that we can `spread()` multiple columns into multiple bundles vice versa. So, let me skip the details here.

We can multi-`spread()`:


```r
d_bundled_again <- d_gathered %>%
  spread_bundles(key, LoTR:RoTK)

d_bundled_again
#> # A tibble: 3 x 3
#>   Race   Female$LoTR   $TT $RoTK Male$LoTR   $TT $RoTK
#>   <chr>        <dbl> <dbl> <dbl>     <dbl> <dbl> <dbl>
#> 1 Elf           1229   331   183       971   513   510
#> 2 Hobbit          14     0     2      3644  2463  2673
#> 3 Man              0   401   268      1995  3589  2459
```

Then, `unbundle()` flattens the bundles to prefixes.


```r
d_bundled_again %>%
  unbundle(-Race)
#> # A tibble: 3 x 7
#>   Race   Female_LoTR Female_TT Female_RoTK Male_LoTR Male_TT Male_RoTK
#>   <chr>        <dbl>     <dbl>       <dbl>     <dbl>   <dbl>     <dbl>
#> 1 Elf           1229       331         183       971     513       510
#> 2 Hobbit          14         0           2      3644    2463      2673
#> 3 Man              0       401         268      1995    3589      2459
```

It's done. By combining these two steps, multi-`spread()` is something like this:


```r
d_gathered %>%
  spread_bundles(key, LoTR:RoTK) %>% 
  unbundle(-Race)
```

## Considerations

As I described above, multi-`gather()` doesn't need the column name for `value`.
On the other hand, usual `gather()` need a new colname. An atomic column doesn't have inner names, yet it needs a name to become a column.

Similarly, usual `spread()` can be considered as a special version of multi-`spread()`. Consider the case when we multi-`spread()`ing one column:


```r
# an example in ?tidyr::spread
df <- tibble(x = c("a", "b"), y = c(3, 4), z = c(5, 6))

spread_bundles(df, key = x, y, simplify = FALSE)
#> # A tibble: 2 x 3
#>       z   a$y   b$y
#>   <dbl> <dbl> <dbl>
#> 1     5     3    NA
#> 2     6    NA     4
```

Since `y` is the only one column in the data, we can simplify these 1-column data.frames to vectors:


```r
spread_bundles(df, key = x, y, simplify = TRUE)
#> # A tibble: 2 x 3
#>       z     a     b
#>   <dbl> <dbl> <dbl>
#> 1     5     3    NA
#> 2     6    NA     4
```

This is usual `spread()`.

I'm yet to see if we can improve the current `spread()` and `gather()` to handle these differences transparently...

## Future plans

Probably, this post is too much about the implementational details.
I need to think about the interfaces before proposing this on tidyr's repo.

Any suggestions or feedbacks are welcome!
