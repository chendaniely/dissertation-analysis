library(here)
library(fs)
library(readxl)
library(purrr)
library(lubridate)
library(stringr)
library(writexl)
library(dplyr)

treatment_arms <- readr::read_tsv(here::here("data/final/exercises/workshop_arm_randomizations.tsv"))

dup <- treatment_arms$your_id[duplicated(treatment_arms$your_id)]

# hard code 1 duplicate drop
stopifnot(length(dup) == 1) 
stopifnot(nrow(treatment_arms) == 30)
treatment_arms <- treatment_arms %>%
  dplyr::filter(!(block_size == 10 & your_id == dup))
stopifnot(nrow(treatment_arms) == 29)

stopifnot(!any(duplicated(treatment_arms$your_id )))
  

exercise_data_pth <- fs::dir_ls(here::here("data/original/exercises/020-qualtrics/"), regexp = "0[2,3,4]0-.*\\.xlsx")
exercise_data_pth <- exercise_data_pth[-1] # drop the 010-signin.xlsx
stopifnot(length(exercise_data_pth) == 14)


exercise_data_names <- exercise_data_pth %>%
  fs::path_file() %>%
  fs::path_ext_remove()

exercise_data_df <- purrr::map2_dfr(
  exercise_data_names,
  exercise_data_pth,
  function(nm, pth) {
    dat <- readxl::read_excel(pth) %>%
      dplyr::mutate(fn = nm)
  }
)

stopifnot(nrow(exercise_data_df) == 121)
exercise_data_df <- exercise_data_df %>%
  filter(!(lubridate::date(start_date) == "2021-11-23" & q1 %in% dup))
stopifnot(nrow(exercise_data_df) == 120)

exercise_data_df <- exercise_data_df %>%
  filter(!is.na(q2))

exercise_dat_arms <- dplyr::full_join(exercise_data_df, treatment_arms, by = c("q1" = "your_id")) %>%
  dplyr::mutate(q1 = stringr::str_to_lower(q1))


# 1 person not randomized
# 11 people signed in, but did not take exercise surveys

stopifnot(nrow(exercise_dat_arms) == 77)

exercise_dat_arms <- exercise_dat_arms %>%
  dplyr::select(-rand_id) %>%
  tidyr::drop_na()

stopifnot(nrow(exercise_dat_arms) == 65)


# drop bad code values

patterns <- c("^It will not paste RIP",
              "^Shiny app hung, can't get code",
              "^http",
              "^ttp"
)

ptrn <- paste0(patterns, collapse = "|")

exercise_dat_arms

stopifnot(stringr::str_detect(exercise_dat_arms$q2, ptrn) %>% sum() == 8)
stopifnot(nrow(exercise_dat_arms) == 65)

exercise_dat_arms <- exercise_dat_arms %>%
  filter(!stringr::str_detect(q2, ptrn))

stopifnot(nrow(exercise_dat_arms) == 57)


dat_all <- exercise_dat_arms %>%
  tidyr::separate(fn, into = c("part", "arm", "ex"), sep = "-", remove = FALSE) %>%
  dplyr::mutate(
    is_group_match = (as.integer(arm) / 10) == readr::parse_number(treatment)
  ) %>%
  dplyr::filter(is_group_match %in% c(TRUE, NA)) %>%
  dplyr::arrange(part, ex) %>%
  dplyr::mutate(
    ex = dplyr::case_when(
      ex == "workshop" ~ "pre",
      is.na(ex) ~ "sum",
      TRUE ~ ex
    ),
    id = dplyr::row_number()
  ) %>%
  dplyr::select(id, everything())


# only keep columns needed to grade code
dat_grade <- dat_all %>%
  dplyr::select(id, part, ex, q1, q2) %>%
  dplyr::arrange(part, ex)


writexl::write_xlsx(dat_all, here::here("data/final/exercises/exercise_data_all.xlsx"))
writexl::write_xlsx(dat_grade, here::here("data/final/exercises/exercise_data_code.xlsx"))
