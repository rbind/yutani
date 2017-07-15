.PHONY: all build

all: build

build:
	Rscript -e "blogdown::serve_site(browser = FALSE, daemon = TRUE)"