library(here)
library(rmarkdown)
library(fs)
library(purrr)

## Run the qualtrics analysis
rmarkdown::render(
  here("analysis/02-persona/01-self_assessment_persona_descriptives.Rmd"),
  output_dir = here("./output/survey/01-self_assessment/")
)

# Persona clusters -----
rmarkdown::render(
  here("analysis/02-persona/03-clustering.Rmd"),
  output_dir = here("./output/persona/")
)

for (grp_n in 2:5) {
  rmarkdown::render(
    here("analysis/02-persona/04-descriptives_by_group.Rmd"),
    output_dir = here("./output/persona/"),
    output_file = glue::glue("02-descriptives_by_group_{grp_n}"),
    params = list(num_clusters = grp_n)
  )
}

rmarkdown::render(
  here("analysis/02-persona/05-pca_fa.Rmd"),
  output_dir = here("./output/persona/")
)
