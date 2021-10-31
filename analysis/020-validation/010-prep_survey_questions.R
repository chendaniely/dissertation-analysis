library(here)
library(glue)
library(readr)
library(dplyr)
library(utf8)
library(stringr)
library(tidyr)

source(here::here("./R/question_str_to_int.R"))

persona_wide <- function(dat, qnum = c(3, 4, 5, 6)) {
  qpattern <- glue("Q[{paste0(qnum, collapse = '|')}]")
  
  dat_q_filter <- dat %>%
    dplyr::filter(stringr::str_starts(question_part, qpattern))
  
  # drop "what programming language you have used in the past question
  if (3 %in% qnum) {
    dat_q_filter <- dat_q_filter %>%
      dplyr::filter(!stringr::str_starts(question_part, "Q3.2"))
  }

  # only keep likert questions in Q7
  if (7 %in% qnum) {
    dat_q_filter <- dat_q_filter %>%
      dplyr::filter(!stringr::str_starts(question_part, "Q7\\.[1|3|4]"))
  }
  
  wide <- dat_q_filter %>%
    # fixes curly approstrphe
    # https://stackoverflow.com/questions/46814856/use-gsub-to-replace-curly-apostrophe-with-straight-apostrophe-in-r-list-of-chara
    dplyr::mutate(response = utf8::utf8_normalize(response, map_quote = TRUE)) %>%
    dplyr::mutate(response_numeric = purrr::map2_int(question_part, response, recode_responses_int)) %>%
    dplyr::select(-response) %>%
    tidyr::drop_na() %>%
    tidyr::pivot_wider(names_from = question_part,
                       values_from = response_numeric) %>%
    tidyr::drop_na() %>%
    {.}
  
  return(wide)
}


persona <- readr::read_tsv(here("./data/final/01-surveys/01-self_assessment_persona_with_questions.tsv"))

persona_q_a <- persona %>%
  dplyr::select(id_person, question_part, response)
  
wide_survey_only <- persona_wide(persona_q_a, qnum = 3:6)
wide_survey_likert <- persona_wide(persona_q_a, qnum = 3:7)
wide_likert_only <- persona_wide(persona_q_a, qnum = 7)

dim(wide_survey_likert)

readr::write_csv(wide_survey_only, here::here("./data/final/persona/01-participant_numeric-wide_survey_only.csv"))
readr::write_csv(wide_likert_only, here::here("./data/final/persona/01-participant_numeric-wide_likert_only.csv"))
readr::write_csv(wide_survey_likert, here::here("./data/final/persona/01-participant_numeric-wide_survey_likert.csv"))
