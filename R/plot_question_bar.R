plot_question_bar <- function(dat) {
  ggplot(data = dat,
         aes(x = stringr::str_wrap(response, 60),
             y = n)
  ) +
    geom_bar(stat = "identity") +
    xlab("") +
    ylab("Count") +
    #labels(line_break(dat$response)) +
    coord_flip() +
    ggtitle(stringr::str_wrap(dat$question_text, 80)) +
    theme_minimal() +
    theme(
      plot.title.position = "plot"
    )
}
