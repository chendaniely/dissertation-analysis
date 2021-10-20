#' does an up fill (backwards fill) and collects the first set of responses
remove_duplicate_ids <- function(dat) {
  dat %>%
    dplyr::group_by(id_person) %>%
    tidyr::fill(-id_person, .direction = "up") %>% 
    dplyr::slice(1) %>%
    dplyr::ungroup()
}
