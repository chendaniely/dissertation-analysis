library(here)
library(rmarkdown)

source(here("analysis/qualtrics/01-process_qualtrics.R"))
source(here("analysis/qualtrics/02-combine_metadata.R"))

rmarkdown::render(
  here("analysis/qualtrics/03-self_assessment_persona_descriptives.Rmd"),
  output_dir = here("./output/survey/01-self_assessment/")
)
