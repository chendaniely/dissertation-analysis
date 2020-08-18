library(here)
library(readr)
library(dplyr)
library(tidyr)


persona <- readr::read_tsv(here("./data/original/surveys/02-self_assessment_with_questions.tsv"), )

wide <- persona %>%
  dplyr::select(id, question_part, response) %>%
  dplyr::filter(stringr::str_starts(question_part, "Q[3|4|5|6]")) %>%
  tidyr::pivot_wider(names_from = question_part,
                     values_from = response) %>%
  dplyr::select(-starts_with("Q3.2")) %>%
  tidyr::drop_na() %>%
  {.}

# make sure the row names are the same as the IDs before dropping
rownames(wide) <- wide$id
stopifnot(all(rownames(wide) == wide$id))

wide <- dplyr::select(wide, -id)

# should only have the text responses to convert to factors
stopifnot(all(lapply(wide, class) == "character"))
q3.1_unique <- length(wide$Q3.1 %>% unique())
numeric_data <- purrr::map_df(wide, ~as.numeric(as.factor(.)))
stopifnot(length(unique(numeric_data$Q3.1)) == q3.1_unique)


pca_persona <- prcomp(numeric_data)

summary(pca_persona)

# Euclidean distance, drops the first column of IDs
dist <- dist(numeric_data, method = "euclidean")

class(dist)

# Hierarchical Clustering with hclust
hc_complete <- hclust(dist, method = "complete")
# Plot the result
plot(hc_complete)



hc_ward <- hclust(dist, method = "ward.D")
# Plot the result
plot(hc_ward)

