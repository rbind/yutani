---
title: "Publish R Markdown to Medium via An RStudio Addin"
date: "2017-10-26"
categories: ["R"]
tags: ["Medium", "Web API"]
---

I created an experimental package to work with [Medium API](https://github.com/Medium/medium-api-docs).

mediumr:
https://github.com/yutannihilation/mediumr/

mediumr allows you to knit and post R Markdown to Medium.

## Installation

You can install mediumr from github with:

```r
devtools::install_github("yutannihilation/mediumr")
```

## Authentication

Medium API requires a self-issued API token. (While they provide OAuth method, it's hard for R users to use it since `localhost` is not allowed to specify in the callback URL.) Please issue a token in "Integration tokens" section of [settings](https://medium.com/me/settings) and set it as a environmental variable `MEDIUM_API_TOKEN`. If you use `.Renviron`, add this line:

```
MEDIUM_API_TOKEN='<your api token here>'
```

## Usage

The usage is quite simple. Focus on the Rmd file that you want to publish and choose "Post to Medium" from Addins menu:

![](/images/2017-10-26-screenshot_addin.png)

The addin knits the Rmd and shows the preview dialog. If it looks ok, click "Publish":

![](/images/2017-10-26-screenshot.png)

After successfully upload the content to Medium, addin launches a web browser and jumps to the post:

![](/images/2017-10-26-screenshot_medium.png)

## Other usages

mediumr also provides simple bindings for Medium API. Please, read the "Usage" section of [the README](https://github.com/yutannihilation/mediumr/#usage).

## Contribution

If you find any problems, please let me know on [GitHub](https://github.com/yutannihilation/mediumr/), [Twitter](https://twitter.com/yutannihilation), or comment here!