remove_identifiers <- function(dat, type = "p1-3") {
  
  if (type == "p4") {
    dat <- dat %>%
      dplyr::select(-IPAddress, -ResponseId,
                    -RecipientLastName, -RecipientFirstName, -RecipientEmail,
                    -ExternalReference,
                    -LocationLatitude, -LocationLongitude,
                    -DistributionChannel, -UserLanguage)

  } else if (type == "p1-3") {
    dat <- dat %>%
      # Why is qualtrics tracking location?
      dplyr::select(StartDate:Status, Progress:ResponseId, starts_with("Q")) %>% 
      # drop people who do not want to be in the survey
      dplyr::filter(Q1.4 == "Yes. I have read the consent form and this response will serve as my consent to participate in the research study.")

  } else {
    stop(glue::glue("Unknown type: {type}"))

  }

  return(dat)
}
