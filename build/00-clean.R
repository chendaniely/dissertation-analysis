library(here)
library(rmarkdown)
library(fs)
library(purrr)

# Clean -----

analysis_html <- fs::dir_ls(here("analysis"), recurse = TRUE, glob = "*.html")
qualtrics_files <- fs::dir_ls(here("output", "survey", "01-self_assessment"), recurse = TRUE)
persona_files <- fs::dir_ls(here("output", "persona"), recurse = TRUE)

files_to_delete <- c(analysis_html, qualtrics_files, persona_files)

purrr::walk(files_to_delete, fs::file_delete)
