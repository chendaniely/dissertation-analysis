remove_invalid_rows <- function(dat) {
  # drop test data
  dat <- dat %>%
    dplyr::filter(StartDate >= "2020-07-23")
  
  # if ID is missing, drop, Q2.2 is the ID for all datasets
  dat <- dat %>%
    dplyr::filter(!is.na(Q2.2))
  
  return(dat)
}
