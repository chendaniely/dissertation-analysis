library(qualtRics)
library(dplyr)

surveys <- all_surveys()

self_assessment_id <-  surveys$id[stringr::str_detect(surveys$name, "October 20")]

signup_emails <- self_assessment_id %>%
  qualtRics::fetch_survey(surveyID = .) %>%
  pull(Q1.3_3)

length(signup_emails)

bcc <- paste(signup_emails, collapse=", ")

cat(bcc)
