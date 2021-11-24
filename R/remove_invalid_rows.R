remove_invalid_rows <- function(dat, type = "p1-3") {
  
  if (type == "p4") {

    dat <- dat %>%
      dplyr::filter(lubridate::date(StartDate) == "2021-11-18" | lubridate::date(StartDate) == "2021-11-23") # only ran experiments on certain days

    
    if ("Q2.2" %in% names(dat)) {
      # the sign-in survey
      dat <- dat %>%
        dplyr::filter(!is.na(Q2.2))
    } else {
      # the exercise questions
      dat <- dat %>%
        dplyr::filter(!is.na(Q1))
    }

    
  } else if (type == "p1-3") {
    # drop test data
    dat <- dat %>%
      dplyr::filter(StartDate >= "2020-07-23")
    
    # if ID is missing, drop, Q2.2 is the ID for all datasets
    dat <- dat %>%
      dplyr::filter(!is.na(Q2.2))
  }
  
  else {
    stop(glue::glue("Unknown type: {type}"))
  }
  
  return(dat)
}
