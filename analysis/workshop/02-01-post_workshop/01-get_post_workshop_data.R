library(here)
library(dplyr)

source(here::here("./R/get_survey.R"))
source(here::here("./R/survey_q_multi_choice_multi_answer.R"))

post_workshop <- get_survey("post-workshop survey")

finished <- post_workshop %>%
  dplyr::filter(Finished == TRUE)

consented <- finished %>%
  dplyr::filter(Q1.4 == "Yes. I have read the consent form and this response will serve as my consent to participate in the research study.")

feedback_only <- post_workshop %>%
  dplyr::filter(Q1.5 == "Yes. I would like to provide feedback about the workshop and its learning materials")
