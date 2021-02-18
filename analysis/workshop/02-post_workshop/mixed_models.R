library(here)
library(readr)
library(dplyr)
library(tidyr)
library(corrplot)
library(forcats)
library(broom)

preworkshop <- readr::read_tsv(here("./data/final/01-surveys/02-pre_workshop_with_questions.tsv"))
postworkshop <- readr::read_tsv(here("./data/final/01-surveys/03-post_workshop_with_questions.tsv"))


pre_likert <- preworkshop %>%
  dplyr::filter(qbase == "Q5.2" | qbase == "Q5.3") %>%
  #dplyr::filter(qbase == "Q5.3") %>% # LOs only
  dplyr::select(id, question_part, response) %>%
  dplyr::mutate(pre_post = 0)

post_likert <- postworkshop %>%
  dplyr::filter(qbase == "Q4.1" | qbase == "Q4.2") %>%
  #dplyr::filter(qbase == "Q4.2") %>% # LOs only
  dplyr::select(id, question_part, response)%>%
  dplyr::mutate(pre_post = 1)

df <- dplyr::bind_rows(pre_likert, post_likert)

df <- df %>%
  dplyr::mutate(question_short_text = dplyr::case_when(
    question_part == "Q5.2_1" ~ "Original data",
    question_part == "Q5.2_2" ~ "Write program",
    question_part == "Q5.2_3" ~ "Search help",
    question_part == "Q5.2_4" ~ "Overcome problem",
    question_part == "Q5.2_5" ~ "Confident programming",
    question_part == "Q5.2_6" ~ "R/Python reproduce",
    question_part == "Q5.2_7" ~ "R/Python efficient",
    
    question_part == "Q5.3_1" ~ "Name tidy",
    question_part == "Q5.3_2" ~ "Transform data",
    question_part == "Q5.3_3" ~ "Identify spreadsheets",
    question_part == "Q5.3_4" ~ "Assess spreadsheets",
    question_part == "Q5.3_5" ~ "Break down steps",
    question_part == "Q5.3_6" ~ "Construct plot",
    question_part == "Q5.3_7" ~ "Build pipeline",
    question_part == "Q5.3_8" ~ "Calculate analysis",
    
    question_part == "Q4.1_1" ~ "Original data",
    question_part == "Q4.1_2" ~ "Write program",
    question_part == "Q4.1_3" ~ "Search help",
    question_part == "Q4.1_4" ~ "Overcome problem",
    question_part == "Q4.1_5" ~ "Confident programming",
    question_part == "Q4.1_6" ~ "R/Python reproduce",
    question_part == "Q4.1_7" ~ "R/Python efficient",

    question_part == "Q4.2_1" ~ "Name tidy",
    question_part == "Q4.2_2" ~ "Transform data",
    question_part == "Q4.2_3" ~ "Identify spreadsheets",
    question_part == "Q4.2_4" ~ "Assess spreadsheets",
    question_part == "Q4.2_5" ~ "Break down steps",
    question_part == "Q4.2_6" ~ "Construct plot",
    question_part == "Q4.2_7" ~ "Build pipeline",
    question_part == "Q4.2_8" ~ "Calculate analysis"
  )) %>%
  dplyr::mutate(
    response_num = dplyr::case_when(
      response == "Strongly Disagree" ~ 1,
      response == "Disagree" ~ 2,
      response == "Somewhat Disagree" ~ 3,
      response == "Neither Agree nor Disagree" ~ 4,
      response == "Somewhat Agree" ~ 5,
      response == "Agree" ~ 6,
      response == "Strongly Agree" ~ 7,
    )
  )

# drop ids
# 56 is the only paired observation
# 56 has 1 missing value
drop <- c(29, 60, 56, 57)

df <- df %>%
  dplyr::filter(!id %in% drop)

responses <- df %>%
  dplyr::filter(!id %in% drop) %>%
  dplyr::select(id, pre_post, question_short_text, response_num) %>%
  tidyr::pivot_wider(names_from = question_short_text,
                     values_from = response_num)

readr::write_csv(responses, here("./data/final/01-surveys/likert_analysis.tsv"))

png(here("./output/survey/03-post_workshop/pre-post-correlation.png"),
    width = 800, height = 800, units = "px")
responses %>%
  dplyr::select(`Original data`:last_col()) %>%
  cor() %>%
  corrplot(method="number")
dev.off()

responses %>%
  dplyr::select(-id) %>%
  dplyr::group_by(pre_post) %>%
  dplyr::group_map(~ summary(.x))

plot_df <- responses %>%
  tidyr::pivot_longer(`Original data`:last_col(),
                      names_to = "question_short_text",
                      values_to = "response_num")%>%
  dplyr::mutate(pre_post = as.factor(pre_post))


ggplot(plot_df, aes(x = question_short_text, y = response_num)) +
  geom_boxplot(aes(fill = factor(pre_post, levels = rev(levels(pre_post))))) +
  #facet_wrap(~pre_post) +
  theme_minimal() +
  labs(x = "Question (short form)",
       y = "Likert Response") +
  scale_fill_discrete(breaks=c(0, 1),
                      labels=c("Pre-workshop", "Post-workshop"))+
  theme(legend.title=element_blank()) +
  coord_flip() +
  NULL

ggsave(filename = here("./output/survey/03-post_workshop/pre-post-boxplot.png"), width = 8, height = 5)




#http://www.sthda.com/english/wiki/paired-samples-wilcoxon-test-in-r


stat_df <- responses %>%
  dplyr::select(-id, -pre_post)

pre_post <- responses$pre_post


purrr::map_df(stat_df, ~ tidy(wilcox.test(pre_post, ., paired = FALSE, alternative = "two.sided"))) %>%
  dplyr::mutate(short_question = names(stat_df)) %>%
  dplyr::select(short_question, statistic, p.value)

m <- purrr::map_df(stat_df, mean) %>% tidyr::pivot_longer(everything(), names_to = "variable", values_to = "mean")
s <- purrr::map_df(stat_df, sd) %>% tidyr::pivot_longer(everything(), names_to = "variable", values_to = "sd")

ms <- dplyr::full_join(m, s, by = "variable")

responses[responses$pre_post == 0, "Assess spreadsheets", drop = TRUE] %>% mean()
responses[responses$pre_post == 1, "Assess spreadsheets", drop = TRUE] %>% mean()
responses[responses$pre_post == 0, "Assess spreadsheets", drop = TRUE] %>% sd()
responses[responses$pre_post == 1, "Assess spreadsheets", drop = TRUE] %>% sd()

library(MKpower)


ry_fns <- purrr::map2(ms$mean, ms$sd,
                      ~ rlang::new_function(args = exprs(n =),
                                            quote(
                                              rnorm(n, enquo(.x), enquo(.y))
                                            )
                      ))
ry_fns

rlang::new_function(args = exprs(n =), quote(rnorm(n, .x, .y)))

rx <- function(n) rbinom(n, 1, 0.5)
ry <- function(n) rnorm(n, 6.6, 0.699)
sim.ssize.wilcox.test(rx = rx, ry = ry, n.max = 100, iter = 1000)

rx <- function(n) rnorm(n, mean = 0, sd = 1)
ry <- function(n) rnorm(n, mean = 0.5, sd = 1)
sim.ssize.wilcox.test(rx = rx, ry = ry, n.max = 100, iter = 1000)


pre_post %>% paste(collapse = ",")
stat_df$`Original data` %>% paste(collapse = ", ")
