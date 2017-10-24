# catch "local" arg passed from blogdown::build_site()
local <- commandArgs(TRUE)[1] == "TRUE"

# set common options ofr knitr
knitr::opts_knit$set(
  base.dir = normalizePath("static/", mustWork = TRUE),
  base.url = "/"
)

knitr::opts_chunk$set(
  cache.path = normalizePath("cache/", mustWork = TRUE)
)

# knit only ones that needs updated
rmds <- list.files("content", "[\\.]Rmd$", recursive = TRUE, full.names = TRUE)
mds <- sub("\\.Rmd$", ".md", rmds)
already_knitted <- file.exists(mds) & utils::file_test("-ot", rmds, mds)

message("Skip:\n\t", paste(rmds[already_knitted], collapse = "\n\t"))

for (rmd in rmds[!already_knitted]) {
  wo_ext <- tools::file_path_sans_ext(rmd)
  md <- glue::glue("{wo_ext}.md")
  
  knitr::opts_chunk$set(
    fig.path = glue::glue("post/{basename(wo_ext)}_files/figure-html/")
  )
  
  set.seed(1984)
  knitr::knit(input = rmd, output = md, encoding = "UTF-8")
}

blogdown::hugo_build(local = local)
