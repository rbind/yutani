rmds <- list.files('content', '[\\.]Rmd$', recursive = TRUE, full.names = TRUE)

for (rmd in rmds) {
  wo_ext <- tools::file_path_sans_ext(rmd)
  md <- glue::glue("{wo_ext}.md")
  
  if (file.exists(md) && utils::file_test("-ot", rmd, md)) {
    message(glue::glue("skip {rmd}"))
    next
  }
  
  knitr::knit(input = rmd, output = md, encoding = "UTF-8")
}

blogdown::hugo_build(local = TRUE)
