library(qualtRics)
library(dplyr)

surveys <- all_surveys()

surveys$name

self_assessment_id <-  surveys$id[stringr::str_detect(surveys$name, "workshop signup")]

signup_emails <- self_assessment_id %>%
  qualtRics::fetch_survey(surveyID = .) %>%
  pull(Q1.3_3)

length(signup_emails)

bcc <- paste(signup_emails, collapse=", ")

cat(bcc)
