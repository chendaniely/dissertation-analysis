library(qualtRics)
library(dplyr)
library(tidyr)
library(stringr)

surveys <- all_surveys() %>%
  dplyr::arrange(isActive, name)

surveys$name
id <-  surveys$id[stringr::str_detect(surveys$name, "2021-11-18 ds4biomed workshop exercise signup")]

signup_dat <- id %>%
  qualtRics::fetch_survey(surveyID = .) %>%
  dplyr::select(starts_with("Q"), Status, StartDate, EndDate)

emails <- signup_dat$Q1.3_3 %>%
  stringr::str_remove_all(" ")
emails

print(length(emails)) # 36

emails %>%
  paste0(collapse = ", ")
