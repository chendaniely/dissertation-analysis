library(readr)
library(fs)
library(here)
library(purrr)

exercise_fns <- fs::dir_ls(here("data/original/exercises/020-qualtrics/"),
                           regexp = "\\d{3}.*\\.xlsx$")

stopifnot(length(exercise_fns) == 15)

dat_all <- purrr::map(exercise_fns,
                      readr::read_delim,
                      delim = "\t",
                      lazy = FALSE,
                      escape_backslash = TRUE)
