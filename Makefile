.PHONY: all build

all: build

build:
	Rscript -e "blogdown::build_site()"