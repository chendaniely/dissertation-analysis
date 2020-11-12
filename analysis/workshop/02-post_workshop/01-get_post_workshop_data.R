library(here)
library(dplyr)

source(here::here("./R/get_survey.R"))
source(here::here("./R/survey_q_multi_choice_multi_answer.R"))

post_workshop_oct20 <- get_survey("2020-10-20 ds4biomed post-workshop survey")

finished <- post_workshop_oct20 %>%
  dplyr::filter(Finished == TRUE)

consented <- finished %>%
  dplyr::filter(Q1.4 == "Yes. I have read the consent form and this response will serve as my consent to participate in the research study.")

feedback_only <- pre_workshop_oct20 %>%
  dplyr::filter(Q1.5 == "Yes. I would like to provide feedback about the workshop and its learning materials")

tally_all_that_apply(consented, starts_with("Q2.5"))
