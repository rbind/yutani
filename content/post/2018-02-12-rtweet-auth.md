---
title: "ICYMI: Using rtweet Package Is Super Easy Now!"
date: "2018-02-12"
categories: ["R"]
tags: ["rtweet"]
---

Since the version 0.6.0 (published on Nov 16, 2017), [rtweet package](https://cran.r-project.org/package=rtweet) **no longer requires the users to create their own apps**. Did you notice? I didn't know this until the author, Michael W. Kearney, kindly answered to [my silly question on GitHub](https://github.com/mkearney/rtweet/issues/167). I really appreciate that he is always eager not only to maintain the code but also to communicate with lazy users like me.

Then, I did a quick poll (sorry, in Japanese) about how well known is the fact. The result is here; 91% of people don't know about this coolness! So, I am motivated to write a post about how easy rtweet package is now :)

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">RでTwitter APIからデータを取るためにアプリを登録する必要がある、というのは昔の話。今はTwitterアカウントとrtweetパッケージさえあれば準備は不要、と知ってました？</p>&mdash; Hiroaki Yutani (@yutannihilation) <a href="https://twitter.com/yutannihilation/status/961814194570985472?ref_src=twsrc%5Etfw">2018年2月9日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## All we need to start rtweet package is...

literally this:

> NEW: All you need is a Twitter account and rtweet and you're up and running!
(https://github.com/mkearney/rtweet/tree/7e106d6344d2f816c42365401152d60d1c92bd54#usage)

### Step1: Create a Twitter account

(I can easily assume that you are already Twitter-holic, right?)

### Step2: Install rtweet package

Install the package from CRAN as usual:

```r
install.packages("rtweet")
```

### Step3: Use any function of rtweet package

For example, if you run this first time, the browser will be launched:

```r
tw <- search_tweets("#rstats", include_rts = FALSE)
```

And, all you need to do is just click "Authorise App" button.

![](/images/2018-02-12-rtweet.png)

That's all! Super easy!

## Yet, you need your own app in some cases

As you notice the screenshot above, the default app embeded in rtweet package has read-only permission. So, if you want to do further actions like tweeting and following/unfollowing, you need to create your own app.