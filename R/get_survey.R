library(qualtRics)
library(stringr)
library(glue)
library(dplyr)

#' Fetch survey from qualtrics based on pattern match
#' pattern is used to match the survey name
#' col_select_pattern select columns based on pattern
get_survey <- function(pattern, col_select_pattern = "^Q\\d") {
  all_surveys <- all_surveys()
  found_surveys <- stringr::str_detect(all_surveys$name, pattern)

  if (sum(found_surveys) == 0) {
    message(glue::glue("No survey found with pattern: {pattern}"))
    return(NULL)
  } else if (sum(found_surveys) > 1) {
    message("Multiple surveys found:")
    message(all_surveys$name[found_surveys])
    return(NULL)
  } else {
    survey_id <-  all_surveys$id[found_surveys]
  }
  survey <- qualtRics::fetch_survey(surveyID = survey_id) %>%
    # qualtrics collects a lot of other information I do not want to see
    dplyr::select(Progress, Finished, tidyselect::matches(col_select_pattern))
  
  return(survey)
}
