library(qualtRics)
library(dplyr)
library(readr)
library(here)
library(fs)
library(purrr)
library(glue)
library(lubridate)

source(here("./R/remove_identifiers.R"))
source(here("./R/remove_invalid_rows.R"))
source(here("./R/remove_duplicate_ids.R"))
source(here("./analysis/010-qualtrics/survey_search_names.R"))

# https://github.com/ropensci/qualtRics
# QUALTRICS_BASE_URL="virginiatech.ca1.qualtrics.com"
# QUALTRICS_API_KEY="XXXXXXXXXX"
# QUALTRICS_API_KEY in qualtrics > account settings > qualtics IDs > API
# usethis::edit_r_environ()
# or you can use
# qualtrics_api_credentials(api_key = "<YOUR-QUALTRICS_API_KEY>", 
#                           base_url = "virginiatech.ca1.qualtrics.com",
#                           install = TRUE)
readRenviron("~/.Renviron")

## Get qualtrics surveys -----
surveys <- all_surveys()
survey_ids <- purrr::map_chr(.GlobalEnv$survey_names, ~ surveys$id[stringr::str_detect(surveys$name, .)])

survey_info <- data.frame(name = .GlobalEnv$survey_names, qualtrics_id = survey_ids)
survey_info

survey_dfs <- purrr::map(survey_ids,
                         ~ qualtRics::fetch_survey(surveyID = .,
                                                   verbose = FALSE) %>%
                           .GlobalEnv$remove_identifiers() %>%
                           .GlobalEnv$remove_invalid_rows()
                         )

# confirm Q2.2 is the ID column
map(survey_dfs, ~ .$Q2.2)

survey_dfs[[1]] <- .GlobalEnv$remove_duplicate_ids(survey_dfs[[1]], id_col = "Q2.2")


## Recode the unique identifiers -----

# check for no duplicate IDs, excluding NAs
purrr::walk(survey_dfs, ~ stopifnot(all(!duplicated(na.omit(.$Q2.2)))))


survey_info$nrow <- purrr::map_int(survey_dfs, nrow)
print(survey_info)

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
  here("./data/original/surveys/01-03-post_workshop.tsv"),
  here("./data/original/surveys/01-04-longterm_workshop.tsv")
)

fs::dir_create(here("./data/original/surveys"), recurse = TRUE)

purrr::walk2(survey_dfs_deidentified, survey_save_pths, readr::write_tsv)