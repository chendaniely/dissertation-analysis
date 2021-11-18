remove_invalid_rows <- function(dat, type = "p1-3") {
  
  if (type == "p4") {
    
    dat <- dat %>%
      dplyr::filter(StartDate %in% c("2021-11-18", "2021-11-23")) # only ran experiments on certain days
    
    tryCatch(
      expr = {
        dat <- dat %>%
          dplyr::filter(!is.na(Q1))
      },
      error = {
        # for the sign-in survey
        dat <- dat %>%
          dplyr::filter(!is.na(Q2.2))
      }
      
    )

    
  } else if (type == "p4-test") {
    
    # do nothing just put in all the values
    
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
