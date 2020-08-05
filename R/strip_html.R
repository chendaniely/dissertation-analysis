strip_html <- function(s) {
  if (stringr::str_detect(s, "<.*?>")) {
    return(rvest::html_text(xml2::read_html(s)))
  } else {
    return(s)
  }
}
