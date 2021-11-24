library(tidyverse)
library(here)

block_random <- readr::read_csv(here::here("data/original/exercises/block_randomization-seed_42-4_groups-block_8-n_200.csv"))
survey_links <- readr::read_csv(here::here("data/original/exercises/treatment_arm-qualtrics_bitly.csv"))

block_random <- block_random %>%
  tidyr::separate(treatment, into = c("group", "group_num"), sep = " ") %>%
  dplyr::select(-group) %>%
  dplyr::mutate(group_num = as.double(group_num))

combined <- block_random %>%
  dplyr::left_join(survey_links, by = c("group_num" = "group"))

fs::dir_create(here::here("data/final/exercises/"), recurse = TRUE)

combined %>%
  dplyr::select(code, pre:last_col()) %>%
  readr::write_csv(here::here("data/final/exercises/treatment_arm-code-qualtrics_bitly.csv"))
  
