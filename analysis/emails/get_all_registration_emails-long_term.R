library(qualtRics)
library(dplyr)
library(purrr)

surveys <- all_surveys()

signup_survey_names <- c(
  "2020-10-20 ds4biomed workshop signup", # 1
                                          # 2 was business of healthcare
  "2021-02-02 ds4biomed workshop signup", # 3
                                          # 4 was the UVA workshop
  "2021-06-29 ds4biomed workshop signup"  # 5
  # "2021-09 ds4biomed workshop signup"     # 6, 7, 8 # see 2021-sept-workshop_email script
)

signup_surveys <- surveys %>%
  dplyr::filter(name %in% signup_survey_names)

stopifnot(length(signup_survey_names) == nrow(signup_surveys))


signups_df <- purrr::map(signup_surveys$id, qualtRics::fetch_survey, force_request = TRUE)

signups_df_sub <- purrr::map2(signups_df, seq_along(signup_surveys$id), ~ .x %>% mutate(survey_id = .y) %>% select(survey_id, RecordedDate, Q1.1, Q1.2, Q1.3_1, Q1.3_2, Q1.3_3))

purrr::map(signups_df_sub, head)

signups_all <- do.call(rbind, signups_df_sub)

signups_valid <- signups_all %>%
  filter(Q1.1 == "Yes")

table(signups_valid$survey_id)

table(signups_valid$Q1.1)
table(signups_valid$Q1.2)

# fix domains:
# vtc.vet.edu -> vtc.vt.edu 
# vtc.vt.edu -> @vt.edu
# eservices.virginia.edu accounts seem to be no longer active

signups_valid$Q1.3_3 %>%
  unique() %>%
  paste0(collapse = ", ")


