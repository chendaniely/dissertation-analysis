library(rlang)
library(dplyr)

tally_all_that_apply <- function(dat, cols) {
  subset <- dat %>%
    dplyr::select({{cols}})
  return(subset)
}

list_other_responses <- function(dat) {
  
}