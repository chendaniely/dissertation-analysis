library(qualtRics)
library(dplyr)

surveys <- all_surveys()

surveys$name

self_assessment_id <-  surveys$id[stringr::str_detect(surveys$name, "2021-02-02")]

signup <- self_assessment_id %>%
  qualtRics::fetch_survey(surveyID = ., force_request = TRUE)

signup_emails <- signup %>%
  pull(Q1.3_3)

length(signup_emails)
length(unique(signup_emails))

bcc <- paste(signup_emails[1:14], collapse=", ")
cat(bcc)

signup_emails[[14]] # round 1 end
signup_emails[[15]] # round 2 start
signup_emails[[38]] # round 2 end

bcc <- paste(signup_emails[15:38], collapse=", ")
cat(bcc)

bcc <- paste(signup_emails[39:40], collapse=", ")
cat(bcc)

bcc <- paste(signup_emails[41], collapse=", ")
cat(bcc)

bcc <- paste(signup_emails[42:43], collapse=", ")
cat(bcc)

bcc <- paste(signup_emails[44], collapse=", ")
cat(bcc)

bcc <- paste(signup_emails, collapse=", ")
cat(bcc)


signup %>%
  dplyr::select(Q1.3_1, Q1.3_2, Q1.3_3) %>%
  readr::write_csv("~/../Desktop/ds4biomed-02-02-attendee_list.csv")
