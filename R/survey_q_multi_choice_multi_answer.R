library(rlang)
library(dplyr)
library(tidyr)
library(tibble)

tally_all_that_apply <- function(dat, cols) {
  subset <- dat %>%
    dplyr::select({{cols}}) %>%
    tibble::rownames_to_column(var = "participant") %>%
    tidyr::pivot_longer({{cols}}) %>%
    dplyr::filter(value != "<NA>") %>%
    dplyr::count(value) %>%
    dplyr::arrange(-n)
  return(subset)
}

list_other_responses <- function(dat) {
  
}