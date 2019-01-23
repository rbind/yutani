---
title: gather() and spread() Explained By gt
author: ''
date: '2019-01-24'
slug: gather-and-spread-explained-by-gt
categories:
  - R
tags:
  - tidyr
  - gt
---

<style>
table {
  width: 50%;
  font-size: 80%;
}
</style>

This is episode 0 of my long adventure to [multi-spread](https://github.com/tidyverse/tidyr/issues/149) and [multi-gather](https://github.com/tidyverse/tidyr/issues/150) (this is my homework I got at [the tidyverse developer day](https://www.tidyverse.org/articles/2018/11/tidyverse-developer-day-2019/)...).
This post might seem to introduce the different semantics from the current tidyr's one, but it's probably just because my idea is still vague. So, I really appreciate any feedbacks!

## tl;dr

I now think `gather()` and `spread()` are about

1. grouping and
2. `enframe()`ing and `deframe()`ing within each group

Do you get what I mean? Let me explain step by step.

## What does gt teach us?

A while ago, [gt package](https://gt.rstudio.com/), [Richard Iannone](https://twitter.com/riannone)'s work-in-progress great work, was made public.

<img src="/images/2019-01-24-gt-logo.svg" width="35%" />

gt package is wonderful, especially in that it makes us rethink about the possible semantics of columns. I mean, not all columns are equal. No, I don't say anything new; this is what you already know with `spread()` and `gather()`. Take a look at this example data, a simpler version of the one in `?gather`:


```r
library(tibble)
library(gt)

set.seed(1)
# example in ?gather
stocks <- tibble(
  time = as.Date('2009-01-01') + 0:2,
  X = rnorm(3, 0, 1),
  Y = rnorm(3, 0, 2),
  Z = rnorm(3, 0, 4)
)

stocks
#> # A tibble: 3 x 4
#>   time            X      Y     Z
#>   <date>      <dbl>  <dbl> <dbl>
#> 1 2009-01-01 -0.626  3.19   1.95
#> 2 2009-01-02  0.184  0.659  2.95
#> 3 2009-01-03 -0.836 -1.64   2.30
```

### `spread()`ed data explained

Here, `X`, `Y`, and `Z` are the prices of stock X, Y, and Z.
Of course, we can `gather()` the columns as this is the very example for this, but, we also can *bundle* these columns using `tab_spanner()`:


```r
gt(stocks) %>%
  tab_spanner("price", vars(X, Y, Z))
```

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#juyfqdgkaj .gt_table {
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

#juyfqdgkaj .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#juyfqdgkaj .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#juyfqdgkaj .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#juyfqdgkaj .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#juyfqdgkaj .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#juyfqdgkaj .gt_col_heading {
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

#juyfqdgkaj .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#juyfqdgkaj .gt_group_heading {
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

#juyfqdgkaj .gt_empty_group_heading {
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

#juyfqdgkaj .gt_striped {
  background-color: #f2f2f2;
}

#juyfqdgkaj .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#juyfqdgkaj .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#juyfqdgkaj .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#juyfqdgkaj .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#juyfqdgkaj .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#juyfqdgkaj .gt_table_body {
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

#juyfqdgkaj .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#juyfqdgkaj .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#juyfqdgkaj .gt_center {
  text-align: center;
}

#juyfqdgkaj .gt_left {
  text-align: left;
}

#juyfqdgkaj .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#juyfqdgkaj .gt_font_normal {
  font-weight: normal;
}

#juyfqdgkaj .gt_font_bold {
  font-weight: bold;
}

#juyfqdgkaj .gt_font_italic {
  font-style: italic;
}

#juyfqdgkaj .gt_super {
  font-size: 65%;
}

#juyfqdgkaj .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="juyfqdgkaj" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_center' rowspan='2' colspan='1'>time</th>
<th class='gt_col_heading gt_column_spanner gt_center' rowspan='1' colspan='3'>price</th>
</tr>
<tr>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>X</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Y</th>
<th class='gt_col_heading gt_NA' rowspan='1' colspan='1'>Z</th>
</tr>
<tbody class='gt_table_body'>
<tr>
<td class='gt_row gt_left'>2009-01-01</td>
<td class='gt_row gt_right'>-0.6264538</td>
<td class='gt_row gt_right'>3.1905616</td>
<td class='gt_row gt_right'>1.949716</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>2009-01-02</td>
<td class='gt_row gt_right gt_striped'>0.1836433</td>
<td class='gt_row gt_right gt_striped'>0.6590155</td>
<td class='gt_row gt_right gt_striped'>2.953299</td>
</tr>
<tr>
<td class='gt_row gt_left'>2009-01-03</td>
<td class='gt_row gt_right'>-0.8356286</td>
<td class='gt_row gt_right'>-1.6409368</td>
<td class='gt_row gt_right'>2.303125</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

Yet another option is to specify `groupname_col`. We roughly think each row is a group and `time` is the grouping variable here:


```r
gt(stocks, groupname_col = "time")
```

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#wimpmevruc .gt_table {
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

#wimpmevruc .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#wimpmevruc .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#wimpmevruc .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#wimpmevruc .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#wimpmevruc .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#wimpmevruc .gt_col_heading {
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

#wimpmevruc .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#wimpmevruc .gt_group_heading {
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

#wimpmevruc .gt_empty_group_heading {
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

#wimpmevruc .gt_striped {
  background-color: #f2f2f2;
}

#wimpmevruc .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#wimpmevruc .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#wimpmevruc .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#wimpmevruc .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#wimpmevruc .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#wimpmevruc .gt_table_body {
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

#wimpmevruc .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#wimpmevruc .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#wimpmevruc .gt_center {
  text-align: center;
}

#wimpmevruc .gt_left {
  text-align: left;
}

#wimpmevruc .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#wimpmevruc .gt_font_normal {
  font-weight: normal;
}

#wimpmevruc .gt_font_bold {
  font-weight: bold;
}

#wimpmevruc .gt_font_italic {
  font-style: italic;
}

#wimpmevruc .gt_super {
  font-size: 65%;
}

#wimpmevruc .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="wimpmevruc" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>X</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Y</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>Z</th>
</tr>
<tbody class='gt_table_body'>
<tr class='gt_group_heading_row'>
<td colspan='3' class='gt_group_heading'>2009-01-01</td>
</tr>
<tr>
<td class='gt_row gt_right'>-0.6264538</td>
<td class='gt_row gt_right'>3.1905616</td>
<td class='gt_row gt_right'>1.949716</td>
</tr>
<tr class='gt_group_heading_row'>
<td colspan='3' class='gt_group_heading'>2009-01-02</td>
</tr>
<tr>
<td class='gt_row gt_right gt_striped'>0.1836433</td>
<td class='gt_row gt_right gt_striped'>0.6590155</td>
<td class='gt_row gt_right gt_striped'>2.953299</td>
</tr>
<tr class='gt_group_heading_row'>
<td colspan='3' class='gt_group_heading'>2009-01-03</td>
</tr>
<tr>
<td class='gt_row gt_right'>-0.8356286</td>
<td class='gt_row gt_right'>-1.6409368</td>
<td class='gt_row gt_right'>2.303125</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

### `gather()`ed data explained

Let's see the gathered version next. Here's the data:


```r
stocksm <- stocks %>%
  tidyr::gather("name", "value", X:Z)

stocksm
#> # A tibble: 9 x 3
#>   time       name   value
#>   <date>     <chr>  <dbl>
#> 1 2009-01-01 X     -0.626
#> 2 2009-01-02 X      0.184
#> 3 2009-01-03 X     -0.836
#> 4 2009-01-01 Y      3.19 
#> 5 2009-01-02 Y      0.659
#> 6 2009-01-03 Y     -1.64 
#> 7 2009-01-01 Z      1.95 
#> 8 2009-01-02 Z      2.95 
#> 9 2009-01-03 Z      2.30
```

This can be represented in a similar way. This time, a group doesn't consist of a single row, but the rows with the same grouping values.


```r
stocksm %>%
  gt(groupname_col = "time")
```

<!--html_preserve--><style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#skvquonuam .gt_table {
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

#skvquonuam .gt_heading {
  background-color: #FFFFFF;
  /* heading.background.color */
  border-bottom-color: #FFFFFF;
}

#skvquonuam .gt_title {
  color: #000000;
  font-size: 125%;
  /* heading.title.font.size */
  padding-top: 4px;
  /* heading.top.padding */
  padding-bottom: 1px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#skvquonuam .gt_subtitle {
  color: #000000;
  font-size: 85%;
  /* heading.subtitle.font.size */
  padding-top: 1px;
  padding-bottom: 4px;
  /* heading.bottom.padding */
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#skvquonuam .gt_bottom_border {
  border-bottom-style: solid;
  /* heading.border.bottom.style */
  border-bottom-width: 2px;
  /* heading.border.bottom.width */
  border-bottom-color: #A8A8A8;
  /* heading.border.bottom.color */
}

#skvquonuam .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  padding-top: 4px;
  padding-bottom: 4px;
}

#skvquonuam .gt_col_heading {
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

#skvquonuam .gt_sep_right {
  border-right: 5px solid #FFFFFF;
}

#skvquonuam .gt_group_heading {
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

#skvquonuam .gt_empty_group_heading {
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

#skvquonuam .gt_striped {
  background-color: #f2f2f2;
}

#skvquonuam .gt_row {
  padding: 10px;
  /* row.padding */
  margin: 10px;
  vertical-align: middle;
}

#skvquonuam .gt_stub {
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #A8A8A8;
  padding-left: 12px;
}

#skvquonuam .gt_stub.gt_row {
  background-color: #FFFFFF;
}

#skvquonuam .gt_summary_row {
  background-color: #FFFFFF;
  /* summary_row.background.color */
  padding: 6px;
  /* summary_row.padding */
  text-transform: inherit;
  /* summary_row.text_transform */
}

#skvquonuam .gt_first_summary_row {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
}

#skvquonuam .gt_table_body {
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

#skvquonuam .gt_footnote {
  font-size: 90%;
  /* footnote.font.size */
  padding: 4px;
  /* footnote.padding */
}

#skvquonuam .gt_sourcenote {
  font-size: 90%;
  /* sourcenote.font.size */
  padding: 4px;
  /* sourcenote.padding */
}

#skvquonuam .gt_center {
  text-align: center;
}

#skvquonuam .gt_left {
  text-align: left;
}

#skvquonuam .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#skvquonuam .gt_font_normal {
  font-weight: normal;
}

#skvquonuam .gt_font_bold {
  font-weight: bold;
}

#skvquonuam .gt_font_italic {
  font-style: italic;
}

#skvquonuam .gt_super {
  font-size: 65%;
}

#skvquonuam .gt_footnote_glyph {
  font-style: italic;
  font-size: 65%;
}
</style>
<div id="skvquonuam" style="overflow-x:auto;"><!--gt table start-->
<table class='gt_table'>
<tr>
<th class='gt_col_heading gt_left' rowspan='1' colspan='1'>name</th>
<th class='gt_col_heading gt_right' rowspan='1' colspan='1'>value</th>
</tr>
<tbody class='gt_table_body'>
<tr class='gt_group_heading_row'>
<td colspan='2' class='gt_group_heading'>2009-01-01</td>
</tr>
<tr>
<td class='gt_row gt_left'>X</td>
<td class='gt_row gt_right'>-0.6264538</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>Y</td>
<td class='gt_row gt_right gt_striped'>3.1905616</td>
</tr>
<tr>
<td class='gt_row gt_left'>Z</td>
<td class='gt_row gt_right'>1.9497162</td>
</tr>
<tr class='gt_group_heading_row'>
<td colspan='2' class='gt_group_heading'>2009-01-02</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>X</td>
<td class='gt_row gt_right gt_striped'>0.1836433</td>
</tr>
<tr>
<td class='gt_row gt_left'>Y</td>
<td class='gt_row gt_right'>0.6590155</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>Z</td>
<td class='gt_row gt_right gt_striped'>2.9532988</td>
</tr>
<tr class='gt_group_heading_row'>
<td colspan='2' class='gt_group_heading'>2009-01-03</td>
</tr>
<tr>
<td class='gt_row gt_left'>X</td>
<td class='gt_row gt_right'>-0.8356286</td>
</tr>
<tr>
<td class='gt_row gt_left gt_striped'>Y</td>
<td class='gt_row gt_right gt_striped'>-1.6409368</td>
</tr>
<tr>
<td class='gt_row gt_left'>Z</td>
<td class='gt_row gt_right'>2.3031254</td>
</tr>
</tbody>
</table>
<!--gt table end-->
</div><!--/html_preserve-->

You can see the only difference is the rotation. So, theoretically, this can be implemented as grouping + rotating.

## Do it yourself by `enframe()` and `deframe()`

Before entering into the implementations, I explain two tibble's functions, `enframe()` and `deframe()` briefly. They can convert a vector to/from a two-column data.frame.


```r
library(tibble)

x <- 1:3
names(x) <- c("foo", "bar", "baz")

enframe(x)
#> # A tibble: 3 x 2
#>   name  value
#>   <chr> <int>
#> 1 foo       1
#> 2 bar       2
#> 3 baz       3
```


```r
deframe(enframe(x))
#> foo bar baz 
#>   1   2   3
```

### `gather()`

First, split the data by `time`.


```r
d <- dplyr::group_nest(stocks, time)
d
#> # A tibble: 3 x 2
#>   time       data            
#>   <date>     <list>          
#> 1 2009-01-01 <tibble [1 x 3]>
#> 2 2009-01-02 <tibble [1 x 3]>
#> 3 2009-01-03 <tibble [1 x 3]>
```

Then, coerce the columns of the 1-row data.frames to vectors.
(In practice, we should check if the elements are all coercible.)


```r
d$data <- purrr::map(d$data, ~ vctrs::vec_c(!!! .))
d
#> # A tibble: 3 x 2
#>   time       data     
#>   <date>     <list>   
#> 1 2009-01-01 <dbl [3]>
#> 2 2009-01-02 <dbl [3]>
#> 3 2009-01-03 <dbl [3]>
```

Lastly, `enframe()` the vectors and unnest the whole data.


```r
d$data <- purrr::map(d$data, enframe)
d
#> # A tibble: 3 x 2
#>   time       data            
#>   <date>     <list>          
#> 1 2009-01-01 <tibble [3 x 2]>
#> 2 2009-01-02 <tibble [3 x 2]>
#> 3 2009-01-03 <tibble [3 x 2]>
```


```r
tidyr::unnest(d)
#> # A tibble: 9 x 3
#>   time       name   value
#>   <date>     <chr>  <dbl>
#> 1 2009-01-01 X     -0.626
#> 2 2009-01-01 Y      3.19 
#> 3 2009-01-01 Z      1.95 
#> 4 2009-01-02 X      0.184
#> 5 2009-01-02 Y      0.659
#> 6 2009-01-02 Z      2.95 
#> 7 2009-01-03 X     -0.836
#> 8 2009-01-03 Y     -1.64 
#> 9 2009-01-03 Z      2.30
```

Done.

### `spread()`

First step is the same as `gather()`. Just split the data by `time`.


```r
d <- dplyr::group_nest(stocksm, time)
d
#> # A tibble: 3 x 2
#>   time       data            
#>   <date>     <list>          
#> 1 2009-01-01 <tibble [3 x 2]>
#> 2 2009-01-02 <tibble [3 x 2]>
#> 3 2009-01-03 <tibble [3 x 2]>
```

Then, `deframe()` the data.frames.
(In practice, we have to fill the missing rows to ensure all data.frames have the same variables.)


```r
d$data <- purrr::map(d$data, deframe)
d
#> # A tibble: 3 x 2
#>   time       data     
#>   <date>     <list>   
#> 1 2009-01-01 <dbl [3]>
#> 2 2009-01-02 <dbl [3]>
#> 3 2009-01-03 <dbl [3]>
```

Then, convert the vectors to data.frames.


```r
d$data <- purrr::map(d$data, ~ tibble::tibble(!!! .))
d
#> # A tibble: 3 x 2
#>   time       data            
#>   <date>     <list>          
#> 1 2009-01-01 <tibble [1 x 3]>
#> 2 2009-01-02 <tibble [1 x 3]>
#> 3 2009-01-03 <tibble [1 x 3]>
```


Lastly, unnest the whole data.


```r
tidyr::unnest(d)
#> # A tibble: 3 x 4
#>   time            X      Y     Z
#>   <date>      <dbl>  <dbl> <dbl>
#> 1 2009-01-01 -0.626  3.19   1.95
#> 2 2009-01-02  0.184  0.659  2.95
#> 3 2009-01-03 -0.836 -1.64   2.30
```

Done.

## What's next?

I'm not sure... I roughly believe this can be extended to multi-gather and multi-spread (groups can have multiple vectors and data.frames), but I'm yet to see how different (or same) this is from the current tidyr's semantics. Again, any feedbacks are welcome!
