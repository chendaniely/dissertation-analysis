library(tidyverse)
library(readxl)
library(here)

exercises_graded <- readxl::read_xlsx(here::here("data/original/exercises/exercise_data_code-graded.xlsx")) %>%
  dplyr::select(-q2)

exercises_all <- readxl::read_xlsx(here::here("data/final/exercises/exercise_data_all.xlsx"))

# only 1 person seemed to have answered a question more than once
# we'll keep the version of the highest score, the times are similar enough that it's just easier to drop the "repeated" row
# if the scores are the same we kept the version with the longest time

exercises_graded %>%
  count(ex, q1, sort = TRUE)


# took exercise more than once
dup_ex_ids <- exercises_all %>%
  dplyr::count(ex, q1, sort = TRUE) %>%
  dplyr::filter(n > 1) %>%
  dplyr::pull(q1)

dup_ex_df <- exercises_all %>%
  filter(q1 %in% dup_ex)
dup_ex_df


exercises_all_scored <- dplyr::inner_join(exercises_all, exercises_graded, by = c("id", "part", "ex", "q1"))
stopifnot(nrow(exercises_all_scored) == nrow(exercises_graded))

exercises_all_scored %>%
  dplyr::filter(q1 %in% dup_ex) %>%
  dplyr::select(id, start_date, duration_s, ex, treatment, q1, score)

exercises_all_scored_clean <- exercises_all_scored %>%
  dplyr::filter(!id %in% c(45))

exercises_all_scored_clean

writexl::write_xlsx(exercises_all_scored_clean, here::here("data/final/exercises/exercise_data_all_clean.xlsx"))
