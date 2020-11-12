library(here)
library(dplyr)
library(tidyr)
library(stringr)

source(here("./R/get_survey.R"))

self <- get_survey("ds4biomed student self-assessment")
pre <- get_survey("ds4biomed pre-workshop survey")
post <- get_survey("ds4biomed post-workshop survey")

all_ids <- c(self$Q2.2, pre$Q2.2, post$Q2.2) %>%
  stringr::str_to_lower()

multi_survey <- tibble::as_data_frame(all_ids) %>%
  dplyr::count(value) %>%
  dplyr::filter(n > 1) %>%
  tidyr::drop_na()


cool <- multi_survey$value[2]

selfc <- self %>%
  filter(Q2.2 == cool)

prec <- pre %>%
  filter(Q2.2 == cool)
  
postc <- post %>%
  filter(stringr::str_to_lower(Q2.2) == cool)

