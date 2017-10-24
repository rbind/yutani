# functions -------------------------------

library(shiny)
library(miniUI)
library(purrr)

select_Rmd <- function(Rmd_files) {
  # knit only ones that needs updated
  md_files  <- sub("\\.Rmd$", ".md", Rmd_files)
  needs_knitted <- !file.exists(md_files) | utils::file_test("-ot", md_files, Rmd_files)
  
  if (!interactive()) {
    message("skip: \n    ", paste(Rmd_files[!needs_knitted], collapse = "\n    "))
    return(Rmd_files[needs_knitted])
  }
  
  # TODO
  labels <- Rmd_files %>%
    set_names() %>% 
    map(rmarkdown::yaml_front_matter, encoding = "UTF-8") %>%
    map_dfr(`[`, c("title", "date"), .id = "filename") %>%
    glue::glue_data("{title} ({date}, {filename})")
  
  ui <- miniPage(
    gadgetTitleBar("Choose Rmd files to knit"),
    miniContentPanel(
      uiOutput('choose_file')
    )
  )
  
  server <- function(input, output) {
    output$choose_file <- renderUI({
      checkboxGroupInput("files",
                         label = "",
                         width = "100%",
                         choiceNames = labels,
                         choiceValues = Rmd_files,
                         selected = Rmd_files[needs_knitted])
    })
    
    shiny::observe({
      if (input$done > 0)   shiny::stopApp(shiny::isolate(input$files))
      if (input$cancel > 0) shiny::stopApp(NULL)
    })
  }
  
  shiny::runApp(
    shiny::shinyApp(
      ui = ui,
      server = server
    )
  )
}


# main ------------------------------------

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

Rmd_files <- list.files("content", "[\\.]Rmd$", recursive = TRUE, full.names = TRUE)

for (rmd in select_Rmd(Rmd_files)) {
  wo_ext <- tools::file_path_sans_ext(rmd)
  md <- glue::glue("{wo_ext}.md")
  
  knitr::opts_chunk$set(
    fig.path = glue::glue("post/{basename(wo_ext)}_files/figure-html/")
  )
  
  set.seed(1984)
  knitr::knit(input = rmd, output = md, encoding = "UTF-8")
}

blogdown::hugo_build(local = local)
