remove_duplicate_ids <- function(dat, id_col = "Q2.2") {
  # person answered persona survey twice over the 2 years, keeping first instance
  duplicated_response_ids <- dat[duplicated(dat[id_col]), id_col] %>%
    pull(id_col)
  
  # only expecting 1 person to answer survey twice
  stopifnot(length(duplicated_response_ids) == 1)

  # select all that isn't the first row (one I want to keep)
  drop_rows <- which(dat$Q2.2 == "1whlak")[-1] 
  dat <- dat[-drop_rows, ]
  return(dat)
}
