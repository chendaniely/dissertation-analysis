library(dplyr)
library(tibble)
library(purrr)
library(ggplot2)
library(viridis)
library(shadowtext)

get_qid_from_qbase <- function(dat, qbase_str) {
  dat %>%
    dplyr::filter(qbase == qbase_str) %>%
    dplyr::select(qbase, qid) %>%
    unique() %>%
    dplyr::pull(qid)
}

likert_calculation <- function(data, metadata, qbase, meta_qid, grp_var = NULL) {
  likert <- data %>%
    dplyr::filter(qbase == qbase)
  
  if (!is.null(grp_var)) {
    likert_questions <- metadata[["questions"]][[meta_qid]][["subQuestions"]] %>%
      purrr::map(magrittr::extract2, "choiceText") %>%
      purrr::map_chr(magrittr::extract2, 1) %>%
      tibble::tibble(text = .) %>%
      dplyr::mutate(part = rownames(.)) %>%
      dplyr::mutate(question_part = paste0(qbase, "_", part)) %>%
      dplyr::full_join(likert, by = c("question_part")) %>%
      dplyr::select(id, {{grp_var}}, qbase, qid, text, response)
    
    likert_q_count <- likert_questions %>%
      dplyr::group_by(!!sym(gp_col), text) %>%
      dplyr::count(response) %>%
      dplyr::filter(!is.na({{grp_var}}))

  } else {
    likert_questions <- metadata[["questions"]][[meta_qid]][["subQuestions"]] %>%
      purrr::map(magrittr::extract2, "choiceText") %>%
      purrr::map_chr(magrittr::extract2, 1) %>%
      tibble::tibble(text = .) %>%
      dplyr::mutate(part = rownames(.)) %>%
      dplyr::mutate(question_part = paste0(qbase, "_", part)) %>%
      dplyr::full_join(likert, by = c("question_part")) %>%
      dplyr::select(id, qbase, qid, text, response)
    
    likert_q_count <- likert_questions %>%
      dplyr::group_by(text) %>%
      dplyr::count(response)
  }

  return(likert_q_count)
}

likert_plot <- function(likert_q_count,
                        count_col = "n",
                        level_names = c(NA,
                                   "Strongly Disagree", "Disagree", "Somewhat Disagree",
                                   "Neither Agree nor Disagree",
                                   "Somewhat Agree", "Agree", "Strongly Agree"),
                        facet_1 = NULL,
                        scale = "viridis",
                        label_type = "circle",
                        level_wrap_len = 10,
                        x_text_angle = -45,
                        x_text_hjust = 0,
                        x_text_vjust = 1) {
  # word wrap and re-order the x axis before plotting
  x_wrap_len <- level_wrap_len
  x_levels <- stringr::str_wrap(level_names,
                                x_wrap_len)
  x_factor <- factor(stringr::str_wrap(likert_q_count$response, x_wrap_len),
                     levels = x_levels)
  
  g <- ggplot(likert_q_count,
              aes(x = x_factor,
                  y = stringr::str_wrap(text, 50))) +
    geom_tile(aes_string(fill = count_col)) +
    xlab("") +
    ylab("") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = x_text_angle, hjust = x_text_hjust, vjust = x_text_vjust)) +
    NULL
  
  # different ways to make the number more visiable
  if (label_type == "dropshadow") {
    g <- g + shadowtext::geom_shadowtext(aes_string(label = count_col), size = 5)
  } else if (label_type == "plain") {
    g <- g + geom_text(aes_string(label = count_col))
  } else if (label_type == "label") {
    g <- g + geom_label(aes_string(label = count_col), colour = "black")
  } else if (label_type == "fx") {
    #g <- g + ggfx::with_shadow(geom_text(aes_string(label = count_col), color = "white"), radius = 1, x_offset = .1, y_offset = .1)
    g <- g +
      ggfx::with_blur(geom_text(aes_string(label = count_col), color = "white"), sigma = 1, stack = TRUE) +
      geom_text(aes_string(label = count_col))
  } else if (label_type == "circle") {
    g <-  g +
      geom_point(size = 8, color = "white") +
      geom_text(aes_string(label = count_col))
  }
  
  if (scale == "viridis") {
    g <- g + scale_fill_viridis()
  } else if (scale == "diverging") {
    g <- g + scale_fill_gradient2()
  } else {
    stop(glue::glue("Unknown scale: {scale}"))
  }
  
  if (!is.null(facet_1)) {
    g <- g + facet_wrap(as.formula(paste("~", facet_1)))
  }
  
  return(g)
}
