library(qualtRics)
library(readr)
library(here)
library(tidyr)
library(tibble)
library(rvest)
library(jsonlite)

source(here("R/strip_html.R"))

surveys <- all_surveys()
self_assessment_id <-  surveys$id[stringr::str_detect(surveys$name, "student_survey")]

meta_self_assessment <- qualtRics::metadata(surveyID = self_assessment_id, get = list(questions = TRUE))
questions_self_assessment <- qualtRics::survey_questions(self_assessment_id)
survey_self_assessment <- readr::read_tsv(here("./data/original/surveys/01-self_assessment_persona.tsv"))


# don't need to manually parse questions becuase of the survey_questions function
# meta_self_assessment <- tibble::tibble(survey = "student_survey",
#                                        meta_questions = meta__self_assessment$questions)
# 
# tidyr::hoist(meta_self_assessment, meta_questions,
#              "questionText",
#              "questionName"
#              )

questions_self_assessment$question <- purrr::map_chr(questions_self_assessment$question, strip_html)

survey_self_assessment_w_q <- survey_self_assessment %>%
  dplyr::select(-StartDate, -EndDate, -Status, -Progress) %>%
  tidyr::pivot_longer(starts_with("Q"), names_to = "question", values_to = "response") %>%
  dplyr::mutate(qbase = stringr::str_split_fixed(question, "_", 2)[, 1]) %>%
  dplyr::full_join(questions_self_assessment, by = c("qbase" = "qname"), suffix=c("_part", "_text"))


jsonlite::write_json(meta_self_assessment,
                     here("./data/original/surveys/02-self_assessment_metadata.json"))
readr::write_tsv(questions_self_assessment,
                 here("./data/original/surveys/02-self_assessment_questions_meta.tsv"))
readr::write_tsv(survey_self_assessment_w_q,
                 here("./data/original/surveys/02-self_assessment_with_questions.tsv"))
