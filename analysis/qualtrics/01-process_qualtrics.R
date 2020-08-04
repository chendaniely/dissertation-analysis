library(qualtRics)
library(dplyr)
library(readr)
library(here)
library(fs)

remove_identifiers <- function(dat) {
  dat <- dat %>%
    # Why is qualtrics tracking location?
    dplyr::select(StartDate:Status, Progress:ResponseId, starts_with("Q")) %>% 
    # drop people who do not want to be in the survey
    dplyr::filter(Q1.4 == "Yes. I have read the consent form and this response will serve as my consent to participate in the research study.")
  
  dat <- dat %>%
    # drop test data
    dplyr::filter(StartDate >= "2020-07-23")
  
  # check for no duplicate IDs, excluding NAs
  stopifnot(all(!duplicated(na.omit(dat$Q2.2))))
  
  # create unique integer IDs
  dat <- dat %>%
    dplyr::mutate(id = 1:nrow(dat)) %>%
    dplyr::select(-ResponseId, -Q2.2) %>%
    # re-order columns
    dplyr::select(id, everything())
  
  return(dat)
}

# https://github.com/ropensci/qualtRics
# QUALTRICS_BASE_URL="virginiatech.ca1.qualtrics.com"
# QUALTRICS_API_KEY in qualtrics > account settings > qualtics IDs > API
# usethis::edit_r_environ()
readRenviron("~/.Renviron")

surveys <- all_surveys()

self_assessment_id <-  surveys$id[stringr::str_detect(surveys$name, "student_survey")]

survey_self_assessment <- self_assessment_id %>%
  qualtRics::fetch_survey(surveyID = .) %>%
  remove_identifiers()

fs::dir_create(here("./data/original/surveys"), recurse = TRUE)
readr::write_tsv(survey_self_assessment, here("./data/original/surveys/01-self_assessment_persona.tsv"))
#readr::write_tsv(labels, here("./data/original/surveys/01-self_assessment_persona_labels.tsv"))
