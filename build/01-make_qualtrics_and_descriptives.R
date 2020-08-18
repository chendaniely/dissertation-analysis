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

# Qualtrics -----
source(here("analysis/qualtrics/01-process_qualtrics.R"))
source(here("analysis/qualtrics/02-combine_metadata.R"))

rmarkdown::render(
  here("analysis/qualtrics/03-self_assessment_persona_descriptives.Rmd"),
  output_dir = here("./output/survey/01-self_assessment/")
)

# Persona clusters -----
rmarkdown::render(
  here("analysis/persona/01-clustering.Rmd"),
  output_dir = here("./output/persona/")
)

rmarkdown::render(
  here("analysis/persona/02-descriptives_by_group.Rmd"),
  output_dir = here("./output/persona/")
)
