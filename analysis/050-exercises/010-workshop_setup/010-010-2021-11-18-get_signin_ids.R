library(qualtRics)
library(dplyr)
library(tidyr)
library(stringr)

surveys <- all_surveys() %>%
  dplyr::arrange(isActive, name)

surveys$name
id <-  surveys$id[stringr::str_detect(surveys$name, "ds4biomed exercise - 020 - sign in")]

signin <- id %>%
  qualtRics::fetch_survey(surveyID = ., force_request = TRUE) %>%
  dplyr::select(tidyselect::starts_with("Q"), StartDate:Status, Progress:RecordedDate)

# filter dates and times for when the workshop started
qualify <- signin %>%
  filter(stringr::str_starts(Q1.3, "Yes"),
         stringr::str_starts(Q1.4, "Yes"),
         RecordedDate >= "2021-11-18",
         RecordedDate <= "2021-11-19"
         )

qualify_ids <- qualify %>%
  select(Q2.2)

qualify_ids

qualify_ids %>%
  readr::write_csv("~/../Desktop/ds4biomed_exercises_notes/2021-11-18.csv")


unqualify <- signin %>%
  filter(!stringr::str_starts(Q1.3, "Yes"),
         !stringr::str_starts(Q1.4, "Yes"),
         RecordedDate >= "2021-11-18",
         RecordedDate <= "2021-11-19"
  )
unqualify_ids <- unqualify %>%
  select(Q2.2)

unqualify_ids

unqualify_ids %>%
  readr::write_csv("~/../Desktop/ds4biomed_exercises_notes/2021-11-18-unqualify.csv")
