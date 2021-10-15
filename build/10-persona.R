library(here)
library(rmarkdown)
library(fs)
library(purrr)
library(glue)

survey_data_types <- c("survey_likert", "survey_only", "likert_only")
gps = 2:5

## Run the qualtrics analysis
rmarkdown::render(
  here("analysis/02-persona/01-self_assessment_persona_descriptives.Rmd"),
  output_dir = here("./output/survey/01-self_assessment/")
)

# Validation -----

for (data_type in survey_data_types) {
  rmarkdown::render(
    here("analysis/020-validation/020-010-cronbah.Rmd"),
    output_dir = here("./output/validation/"),
    output_file = glue::glue("020-010-cronbah-{data_type}"),
    params = list(survey_data = data_type)
  )
}


# Persona clusters -----

rmarkdown::render(
  here("analysis/02-persona/05-pca_fa.Rmd"),
  output_dir = here("./output/persona/")
)

for (data_type in survey_data_types) {
  rmarkdown::render(
    here("analysis/030-persona/03-pca_clustering.Rmd"),
    output_dir = here(glue::glue("./output/persona/{data_type}")),
    params = list(survey_data = data_type)
  )
}

for (grp_n in 2:5) {
  for (data_type in survey_data_types) {
    rmarkdown::render(
      here("analysis/030-persona/04-descriptives_by_group.Rmd"),
      output_dir = here(glue::glue("./output/persona/{data_type}")),
      output_file = glue::glue("04-descriptives_by_group_{grp_n}"),
      params = list(num_clusters = grp_n,
                    survey_data = data_type)
    )
  }
}

for (grp_n in 2:5) {
  for (data_type in survey_data_types) {
    rmarkdown::render(
      here("analysis/030-persona/05-clinician_subanalysis.Rmd"),
      output_dir = here(glue::glue("./output/persona/{data_type}")),
      output_file = glue::glue("05-clinician_subanalysis_{grp_n}"),
      params = list(num_clusters = grp_n,
                    survey_data = data_type)
    )
  }
}
