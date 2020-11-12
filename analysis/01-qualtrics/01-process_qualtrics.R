library(qualtRics)
library(dplyr)
library(readr)
library(here)
library(fs)
library(purrr)
library(glue)

source(here("./R/remove_identifiers.R"))

# https://github.com/ropensci/qualtRics
# QUALTRICS_BASE_URL="virginiatech.ca1.qualtrics.com"
# QUALTRICS_API_KEY in qualtrics > account settings > qualtics IDs > API
# usethis::edit_r_environ()
readRenviron("~/.Renviron")

## Get qualtrics surveys -----

surveys <- all_surveys()
survey_names <- c("persona",
                  "pre-workshop survey",
                  "post-workshop survey")

survey_ids <- purrr::map_chr(survey_names, ~ surveys$id[stringr::str_detect(surveys$name, .)])

survey_dfs <- purrr::map(survey_ids,
                         ~ qualtRics::fetch_survey(surveyID = .,
                                                   verbose = FALSE) %>%
                           remove_identifiers()
                         )

## Recode the unique identifiers -----
print(purrr::map(survey_dfs, nrow))

all_ids <- purrr::map_df(survey_dfs, dplyr::select, Q2.2)
print(glue("Total number responses: {nrow(all_ids)}"))

all_ids_unique <- unique(all_ids)
print(glue("Unique number responses: {nrow(all_ids_unique)}"))

# create unique integer IDs
ids <- all_ids_unique %>%
  dplyr::mutate(id = 1:nrow(all_ids_unique))

survey_dfs_deidentified <- purrr::map(survey_dfs,
                                      ~ dplyr::left_join(., ids, by = "Q2.2") %>%
                                        dplyr::select(-ResponseId, -Q2.2) %>%
                                        dplyr::select(id, everything())
                                        )

## Save out the survey data -----

survey_dfs_deidentified[[2]]


survey_save_pths <- c(
  here("./data/original/surveys/01-01-self_assessment_persona.tsv"),
  here("./data/original/surveys/01-02-pre_workshop.tsv"),
  here("./data/original/surveys/01-03-post_workshop.tsv")
)

fs::dir_create(here("./data/original/surveys"), recurse = TRUE)

purrr::walk2(survey_dfs_deidentified, survey_save_pths, readr::write_tsv)
