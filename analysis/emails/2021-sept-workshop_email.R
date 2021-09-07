library(qualtRics)
library(dplyr)
library(tidyr)
library(stringr)

#' returns a vector of emails for a particular workshop: r1, r2, py
#' the vector can be passed into
#' paste0 with collapse = ", "
#' to get something to copy/paste into the address field
get_emails <- function(emails_dat, workshop) {
  emails %>%
    select(Q3_1, Q3_2, Q3_3, {{ workshop }}, EndDate) %>%
    filter(stringr::str_detect({{ workshop }}, "^I will attend")) %>%
    pull(Q3_3) %>%
    unique()
}

# data processing -----

surveys <- all_surveys()

surveys$name
id <-  surveys$id[stringr::str_detect(surveys$name, "2021-09 ds4biomed workshop signup")]

signup_dat <- id %>%
  qualtRics::fetch_survey(surveyID = .) %>%
  dplyr::select(Q2:Q7, Status, StartDate, EndDate) %>%
  dplyr::rename(r1 = Q5, py = Q6, r2 = Q7)

emails <- signup_dat %>%
  select(Q2:r2, EndDate) %>%
  filter(stringr::str_detect(Q2, "^Yes")) %>%
  select(-Q2)

# R1
count(signup_dat, r1)

# Py1
count(signup_dat, py)

# R2
count(signup_dat, r2)


workshop_reponses <- signup_dat %>%
  dplyr::select(r1, r2, py) %>%
  tidyr::pivot_longer(r1:py) %>%
  dplyr::mutate(
    responses = dplyr::recode(value,
                              "I will attend this class virtually" = "yes_virtual",
                              "I will attend this class in-person" = "yes_in_person",
                              "I will not attend this class" = "no")
  ) %>%
  dplyr::select(-value)

# workshop counts -----

workshop_reponses %>%
  dplyr::count(name, responses) %>%
  tidyr::pivot_wider(names_from = responses, values_from = n)

# email domain -----
signup_dat %>%
  select(Q3_3) %>%
  mutate(domain = stringr::str_extract(Q3_3, "(?<=@).*")) %>%
  count(domain) %>%
  arrange(n)

# r1 emails -----

emails %>%
  select(Q3_1, Q3_2, Q3_3, r1, EndDate) %>%
  filter(stringr::str_detect(r1, "^I will attend")) %>%
  pull(Q3_3) %>%
  unique()

emails %>%
  get_emails(r1) %>%
  paste0(collapse = ", ")

# py emails -----

emails %>%
  select(Q3_1, Q3_2, Q3_3, py, EndDate) %>%
  filter(stringr::str_detect(py, "^I will attend")) %>%
  pull(Q3_3) %>%
  unique()

emails %>%
  get_emails(py) %>%
  paste0(collapse = ", ")

# r2 emails -----

emails %>%
  select(Q3_1, Q3_2, Q3_3, r2, EndDate) %>%
  filter(stringr::str_detect(r2, "^I will attend")) %>%
  pull(Q3_3) %>%
  unique()

emails %>%
  get_emails(r2) %>%
  paste0(collapse = ", ")
