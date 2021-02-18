library(qualtRics)
library(dplyr)
library(purrr)

surveys <- all_surveys()

surveys$name

signup_surveys <- c("2020-10-20" = "2020-10-20 ds4biomed workshop signup",
                    "2021-02-02" = "2021-02-02 ds4biomed workshop signup")

self_assessment_id <-  surveys$id[surveys$name %in% signup_surveys]

signup_dfs <- self_assessment_id %>%
  purrr::map(qualtRics::fetch_survey)

signup_dfs <- signup_dfs %>%
  purrr::map2(names(signup_surveys),
              ~ dplyr::mutate(., workshop_date = .y) %>%
                dplyr::select(workshop_date, RecordedDate, Q1.1:Q1.3_3))

purrr::map(signup_dfs, function(x) {
  x %>%
    select(Q1.3_3) %>%
    unique() %>%
    length()
})

df1 <- signup_dfs[[1]]

names(df1)

df1$Q1.2
