poss <- c(letters,
LETTERS,
0:9)


sample(poss, 7, replace = TRUE) %>%
  paste0(collapse = "")
