library(qualtRics)
library(dplyr)
library(readr)
library(here)
library(fs)
library(purrr)
library(glue)
library(lubridate)
library(stringr)
library(janitor)
library(lubridate)

source(here("./R/remove_identifiers.R"))
source(here("./R/remove_invalid_rows.R"))
source(here("./R/remove_duplicate_ids.R"))
source(here("./analysis/010-qualtrics/survey_search_names.R"))
source(here("./R/offset_number.R"))

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
survey_ids_exercise <- purrr::map_chr(.GlobalEnv$survey_names_exercise, ~ surveys$id[stringr::str_detect(surveys$name, .)])

survey_info <- data.frame(name = c(.GlobalEnv$survey_names, .GlobalEnv$survey_names_exercise),
                          qualtrics_id = c(survey_ids, survey_ids_exercise))
survey_info


survey_dfs_exercise <- purrr::map(survey_ids_exercise,
                                  ~ qualtRics::fetch_survey(surveyID = .,
                                                            verbose = FALSE) %>%
                                    .GlobalEnv$remove_identifiers(type = "p4") %>%
                                    .GlobalEnv$remove_invalid_rows(type = "p4") %>%
                                    dplyr::mutate(id_response = row_number()) %>% ## add an identifier for each response
                                    dplyr::select(id_response, everything()) %>%
                                    janitor::clean_names() %>%
                                    dplyr::rename(duration_s = duration_in_seconds) %>%
                                    {.}
)

survey_dfs_exercise

exercise_info <- survey_info %>%
  dplyr::filter(qualtrics_id %in% survey_ids_exercise) %>%
  dplyr::mutate(fn = stringr::str_extract(name, "\\d{3}.*"),
                fn = stringr::str_remove_all(fn, "\\s*")
  )

stopifnot(length(survey_dfs_exercise) == nrow(exercise_info))


exercise_info <- exercise_info %>%
  dplyr::mutate(
    fn = stringr::str_sub(fn, 1L, 3L) %>%
      offset_number(-10, 0) %>%
      stringr::str_c(stringr::str_sub(fn, 4L))
  )

purrr::walk2(survey_dfs_exercise,
             here("data", "original", "exercises", "020-qualtrics", glue::glue("{exercise_info$fn}.xlsx")),
             writexl::write_xlsx
             )
