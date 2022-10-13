library(renv)
library(tidyverse)

deps_010_qualtrics <- renv::dependencies(path = "analysis/010-qualtrics/") %>%
  dplyr::distinct(Package) %>%
  dplyr::pull(Package)

deps_020_validation <- renv::dependencies(path = "analysis/020-validation/") %>%
  dplyr::distinct(Package) %>%
  dplyr::pull(Package)


deps_030_persona <- renv::dependencies(path = "analysis/030-persona/") %>%
  dplyr::distinct(Package) %>%
  dplyr::pull(Package)

deps_040_workshop <- renv::dependencies(path = "analysis/040-workshop/") %>%
  dplyr::distinct(Package) %>%
  dplyr::pull(Package)

deps_050_exercises <- renv::dependencies(path = "analysis/050-exercises/") %>%
  dplyr::distinct(Package) %>%
  dplyr::pull(Package)



paper1 <- c(deps_010_qualtrics, deps_020_validation, deps_030_persona) %>% unique()
paper1
purrr::walk(paper1, ~ print(citation(.), bibtex = TRUE))

paper2 <- c(deps_010_qualtrics, deps_040_workshop) %>% unique()
paper2
purrr::walk(paper2, ~ print(citation(.), bibtex = TRUE))

paper3 <- c(deps_010_qualtrics, deps_050_exercises) %>% unique()
paper3
purrr::walk(paper3, ~ print(citation(.), bibtex = TRUE))

