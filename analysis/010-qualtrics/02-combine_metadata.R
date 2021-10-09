library(qualtRics)
library(readr)
library(here)
library(tidyr)
library(tibble)
library(rvest)
library(jsonlite)
library(dplyr)

source(here("R/strip_html.R"))
source(here("./analysis/010-qualtrics/survey_search_names.R"))

## Load raw data from qualtrics -----

surveys <- all_surveys()
ds4biomed_survey_ids <- purrr::map_chr(.GlobalEnv$survey_names, ~ surveys$id[stringr::str_detect(surveys$name, .)])

# meta_self_assessment <- qualtRics::metadata(surveyID = self_assessment_id, get = list(questions = TRUE))
ds4biomed_survey_metadata <- purrr::map(ds4biomed_survey_ids, qualtRics::metadata, get = c("questions"))

# questions_self_assessment <- qualtRics::survey_questions(self_assessment_id)
ds4biomed_survey_questions <- purrr::map(ds4biomed_survey_ids, qualtRics::survey_questions)

## Read deidentified qualtrics data -----

# survey_self_assessment <- readr::read_tsv(here("./data/original/surveys/01-self_assessment_persona.tsv"))
# this is copied from the 01- script
survey_save_pths <- c(
  here("./data/original/surveys/01-01-self_assessment_persona.tsv"),
  here("./data/original/surveys/01-02-pre_workshop.tsv"),
  here("./data/original/surveys/01-03-post_workshop.tsv"),
  here("./data/original/surveys/01-04-longterm_workshop.tsv")
)
ds4biomed_survey_dfs <- purrr::map(survey_save_pths, readr::read_tsv)

purrr::walk(ds4biomed_survey_dfs, ~ print(dim(.)))

## Strip html from question column-----

# questions_self_assessment$question <- purrr::map_chr(questions_self_assessment$question, strip_html)
purrr::walk(ds4biomed_survey_questions, function(x) {x$question %>% head(2) %>% print()})
ds4biomed_survey_questions <- purrr::map(ds4biomed_survey_questions,
                                         function(dat) {
                                           dat %>%
                                             dplyr::mutate(question = purrr::map_chr(question, strip_html), ## this function loses some of the spaces between words
                                                           question = stringr::str_replace_all(question, "\\s{1,}", " ")
                                             )
                                         }
)

purrr::walk(ds4biomed_survey_questions, function(x) {x$question %>% head(2) %>% print()})

## Combine metadata info with deidentified data -----

# survey_self_assessment_w_q <- survey_self_assessment %>%
#   dplyr::select(-StartDate, -EndDate, -Status, -Progress) %>%
#   tidyr::pivot_longer(starts_with("Q"), names_to = "question", values_to = "response") %>%
#   dplyr::mutate(qbase = stringr::str_split_fixed(question, "_", 2)[, 1]) %>%
#   dplyr::full_join(questions_self_assessment, by = c("qbase" = "qname"), suffix=c("_part", "_text"))

ds4biomed_surveys_with_questions <- purrr::map2(ds4biomed_survey_dfs, ds4biomed_survey_questions,
                                                function(survey_dat, question_dat) {
                                                  survey_dat %>%
                                                    dplyr::select(-StartDate, -EndDate, -Status, -Progress) %>%
                                                    tidyr::pivot_longer(starts_with("Q"), names_to = "question", values_to = "response") %>%
                                                    dplyr::mutate(qbase = stringr::str_split_fixed(question, "_", 2)[, 1]) %>%
                                                    dplyr::full_join(question_dat, by = c("qbase" = "qname"), suffix=c("_part", "_text")) %>%
                                                    dplyr::mutate(
                                                      response = stringr::str_replace_all(response, "\\s{1,}", " "),
                                                      question_text = stringr::str_replace_all(question_text, "\\s{1,}", " ")
                                                    )
                                                })

## Deal with dupliate IDs (see duplicate_ids.Rmd for analysis)

## Persona study drop obs
ds4biomed_surveys_with_questions[[1]] %>%
  dplyr::filter(id_person == 41) %>%
  dplyr::count(id_person, id_response)

## TODO: this is hard coded
dim(ds4biomed_surveys_with_questions[[1]])

with_drops <- ds4biomed_surveys_with_questions[[1]] %>%
  dplyr::filter(id_response != 58)

dropped <- ds4biomed_surveys_with_questions[[1]] %>%
  dplyr::filter(id_response == 58)

dim(with_drops)
dim(dropped)

# extra 4 will come from NAs
ds4biomed_surveys_with_questions[[1]] %>% dplyr::filter(is.na(id_response))
4764 - 4690

ds4biomed_surveys_with_questions[[1]] <- with_drops
dim(ds4biomed_surveys_with_questions[[1]])

## Save out data -----

fs::dir_create(here("./data/final/01-surveys"), recurse = TRUE)


# jsonlite::write_json(meta_self_assessment, here("./data/original/surveys/02-self_assessment_metadata.json"))
# readr::write_tsv(questions_self_assessment, here("./data/original/surveys/02-self_assessment_questions_meta.tsv"))
# readr::write_tsv(survey_self_assessment_w_q, here("./data/original/surveys/02-self_assessment_with_questions.tsv"))

survey_meta_pth <- c(here("./data/final/01-surveys/01-self_assessment_persona_metadata.json"),
                     here("./data/final/01-surveys/02-pre_workshop_metadata.json"),
                     here("./data/final/01-surveys/03-post_workshop_metadata.json"),
                     here("./data/final/01-surveys/04-longterm_workshop_metadata.json")
)
purrr::walk2(ds4biomed_survey_metadata, survey_meta_pth, jsonlite::write_json)

question_meta_pth <- c(here("./data/final/01-surveys/01-self_assessment_persona_questions_meta.tsv"),
                       here("./data/final/01-surveys/02-pre_workshop_questions_meta.tsv"),
                       here("./data/final/01-surveys/03-post_workshop_questions_meta.tsv"),
                       here("./data/final/01-surveys/04-longterm_workshop_questions_meta.tsv")
)
purrr::walk2(ds4biomed_survey_questions, question_meta_pth, readr::write_tsv)

# test write/read
ds4biomed_survey_questions_read <- purrr::map(question_meta_pth, readr::read_tsv)
stopifnot(purrr::map_int(ds4biomed_survey_questions, nrow) ==
            purrr::map_int(ds4biomed_survey_questions_read, nrow))


survey_w_question_pth <- c(here("./data/final/01-surveys/01-self_assessment_persona_with_questions.tsv"),
                           here("./data/final/01-surveys/02-pre_workshop_with_questions.tsv"),
                           here("./data/final/01-surveys/03-post_workshop_with_questions.tsv"),
                           here("./data/final/01-surveys/04-longterm_workshop_with_questions.tsv")
)
purrr::walk2(ds4biomed_surveys_with_questions, survey_w_question_pth, readr::write_tsv)

# test write/read
ds4biomed_surveys_with_questions_read <- purrr::map(survey_w_question_pth, readr::read_tsv)
stopifnot(purrr::map_int(ds4biomed_surveys_with_questions, nrow) ==
            purrr::map_int(ds4biomed_surveys_with_questions_read, nrow))
