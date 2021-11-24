library(here)
library(readr)
library(tidyr)
library(dplyr)
library(janitor)

d1_rand <- readr::read_tsv(here::here("data", "original", "exercises",
                                      "010-experiment_setup",
                                      "2021-11-18-tidy_data_workshop_exercise_links.tsv"),
                           lazy = FALSE)

d2_rand <- readr::read_tsv(here::here("data", "original", "exercises",
                                      "010-experiment_setup",
                                      "2021-11-23-tidy_data_workshop_exercise_links.tsv"),
                           lazy = FALSE)


rand_day1_block_8 <- readr::read_csv(here::here("data", "original", "exercises",
                                                "010-experiment_setup",
                                                "wkshp-1-block_randomization-seed_42-4_groups-block_8-n_200.csv"),
                                     lazy = FALSE)

rand_day2_block_8_10 <- readr::read_csv(here::here("data", "original", "exercises",
                                                   "010-experiment_setup",
                                                   "wkshp-2-randomization.csv"),
                                        lazy = FALSE)

d1 <- dplyr::bind_cols(rand_day1_block_8, d1_rand) %>%
  tidyr::drop_na()

d2 <- dplyr::bind_cols(rand_day2_block_8_10, d2_rand) %>%
  tidyr::drop_na()

# col bind does adds col num when column values are the same
# check to make sure the values all match before droping duplicate columns
# did not use merge/join because d2 generated codes repeated from d1 codes
stopifnot(all(d1$code...5 == d1$code...6))
stopifnot(all(d2$rand_id...5 == d2$rand_id...13))
stopifnot(all(d2$code...6 == d2$code...6))

d1 <- d1 %>%
  dplyr::rename(code = code...5,
                pre = pre_workshop,
                ex1 = exercise_1,
                ex2 = exercise_2,
                ex3 = exercise_3,
                sum = summative) %>%
  dplyr::select(-code...6) %>%
  janitor::clean_names()

d2 <- d2 %>%
  dplyr::rename(rand_id = rand_id...5,
                code = code...6) %>%
  dplyr::select(-rand_id...13, -code...14) %>%
  janitor::clean_names()

arms <- dplyr::bind_rows(d1, d2)

arms

readr::write_tsv(arms, here::here("data/final/exercises/workshop_arm_randomizations.tsv"))
