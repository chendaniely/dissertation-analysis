library(here)
library(readr)
library(dplyr)
library(tidyr)


persona <- read.csv(here("./data/original/surveys/02-self_assessment_with_questions.tsv"),
                    sep = '\t',
                    stringsAsFactors = TRUE) # need numeric matrix to calculate distance

wide <- persona %>%
  dplyr::select(id, question_part, response) %>%
  dplyr::filter(stringr::str_starts(question_part, "Q[3|4|5|6]")) %>%
  tidyr::pivot_wider(names_from = question_part,
                     values_from = response) %>%
  dplyr::select(-starts_with("Q3.2")) %>%
  tidyr::drop_na() %>%
  {.}

# Euclidean distance
dist <- dist(wide[-1, ], diag = TRUE)

# Hierarchical Clustering with hclust
hc <- hclust(dist)

# Plot the result
plot(hc)

