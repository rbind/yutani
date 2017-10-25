---
title: "How Not To Knit All Rmd Files With Blogdown"
date: "2017-10-25"
categories: ["R"]
tags: ["blogdown"]
---

[Blogdown](https://bookdown.org/yihui/blogdown/) is a cool package. But, if I complain about one thing, it will be the default behaviour of `build_site()`, which every blogdownners should execute everytime they wants to publish a new article.

As stated in the documentation, `build_site()` will

> Compile all Rmd files and build the site through Hugo.  
(`?build_site`)

Compiling all Rmd files is "safe" in the sense that we notice if some Rmd becomes impossible to compile due to some breaking changes of some package. But, it may be time-consuming and can be a problem for those who have a lot of .Rmd files.

Though I don't find the best practice yet, I noticed using a custom build script (`R/build.R`) is useful for this purpose. (Note that I've aquired many tips from [Yihui's repo](https://github.com/rbind/yihui). Thanks Yihui for being great as usual!)

## Set `blogdown.method` option to `"custom"`

First, stop `build_site()` compiling all Rmd files by specifying `method = "custom"`.

> `method = "custom"` means it is entirely up to this R script how a website is rendered.  
(`?build_site`)

While this option can be passed as an argument of `build_site()`, it can also be set as a global option `blogdown.method`.
Put this line in `.Rprofile` in the home directory or the top directory of the project for your blog.

```r
options(blogdown.method = 'custom')
```

You may also need to source the default `~/.Rprofile`.

```r
if (file.exists('~/.Rprofile')) sys.source('~/.Rprofile', envir = environment())
```

## Write `R/build.R`

Here is my `R/build.R` (Some explanations follow). You can find other scripts by [searching on GitHub](https://github.com/search?utf8=%E2%9C%93&q=org%3Arbind+path%3AR+filename%3Abuild.R&type=).

```r
# catch "local" arg passed from blogdown::build_site()
local <- commandArgs(TRUE)[1] == "TRUE"

# set common options ofr knitr
knitr::opts_knit$set(
  base.dir = normalizePath("static/", mustWork = TRUE),
  base.url = "/"
)

knitr::opts_chunk$set(
  cache.path = normalizePath("cache/", mustWork = TRUE),
  collapse = TRUE,
  comment  = "#>"
)

# list up Rmd files
Rmd_files <- list.files("content", "\\.Rmd$", recursive = TRUE, full.names = TRUE)

# list up md files
md_files  <- sub("\\.Rmd$", ".md", Rmd_files)
names(md_files) <- Rmd_files

# knit it when:
#   1) the correspondent md file does not exist yet
#   2) the Rmd file was updated after the last time md file had been generated 
needs_knitted <- !file.exists(md_files) | utils::file_test("-ot", md_files, Rmd_files)

message("skip: \n    ", paste(Rmd_files[!needs_knitted], collapse = "\n    "))

for (rmd in Rmd_files[needs_knitted]) {
  base_name <- tools::file_path_sans_ext(basename(rmd))
  knitr::opts_chunk$set(
    fig.path = glue::glue("post/{base_name}_files/figure-html/")
  )
  
  set.seed(1984)
  knitr::knit(input = rmd, output = md_files[rmd], encoding = "UTF-8")
}

blogdown::hugo_build(local = local)
```

(I guess this script is incomplete to handle htmlwidgets correctly. I will improve this someday...)

### Set paths correctly

If we leave the protection of blogdown, we have to face with the complexity of paths by ourselves.

> R plots under `content/*/foo_files/figure-html/` are copied to `static/*/foo_files/figure-html/`, and the paths in HTML tags like `<img src="foo_files/figure-html/bar.png" />` are substituted by `/*/foo_files/figure-html/bar.png`. Note the leading slash indicates the root directory of the published website, and the substitution works because Hugo will copy `*/foo_files/figure-html/` from `static/` to `public/`.  
(https://bookdown.org/yihui/blogdown/dep-path.html)

Fortunately, setting these seems enough in my case (yes, I also cheat here by exporing Yihui's repo):

* `base.url`: `/`
* `base.path`: `static/`
* `fig.path`: `post/{base_name}_files/figure-html/`
* `cache.path`: `cache/` (since I changed `base.path`, `cache/` needs to be translated as an absolute path)

As we need to inject these chunk and knit options, we have to use `knitr::knitr()` directly instead of `rmarkdown::render()`.
But, since blogdown book says this threatening words, I may not see another day... Take care of life.

> You should not modify the knitr chunk option `fig.path` or `cache.path` unless the above process is completely clear to you, and you want to handle dependencies by yourself.  
(https://bookdown.org/yihui/blogdown/dep-path.html)

### Generate markdown files, not HTML files

This is another reason why you don't need to use rmarkdown package. Let knitr generate markdown and let Hugo generate HTML from markdown.
As this job is up to Hugo in Netlify, `public/` directory is not needed anymore. Add it to `.gitignore`.

```
public
```

### Skip files already knitted

If the .md file is newer than the .Rmd file, it is probally unnecessary to compile. `utils::file_test()` can tell this.

```r
# knit it when:
#   1) the correspondent md file does not exist yet
#   2) the Rmd file was updated after the last time md file had been generated 
needs_knitted <- !file.exists(md_files) | utils::file_test("-ot", md_files, Rmd_files)
```

## Feedbacks are welcome!

It seems everything works fine in my repo, I'm not sure whether I'm doing things right or not. Please let me know if you find some problem or better way!
