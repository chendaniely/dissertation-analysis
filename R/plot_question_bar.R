library(rlang)

plot_question_bar <- function(dat, fill_var = NULL) {
  if (is.null(fill_var)) {
    ex <- NULL
  } else {
    ex <- rlang::parse_expr(fill_var)
  }
  
  g <- ggplot(data = dat,
         aes(x = stringr::str_wrap(response, 60),
             y = n)
  ) 
  
  if (is.null(ex)) {
    g <- g + geom_bar(stat = "identity",
                      position="dodge")
  } else {
    g <- g + geom_bar(aes(fill = as.factor(!!ex)),
                      stat = "identity",
                      position="dodge")
  }
  
  g <- g +
    scale_fill_discrete(name = "Group") +
    xlab("") +
    ylab("Count") +
    #labels(line_break(dat$response)) +
    coord_flip() +
    ggtitle(stringr::str_wrap(dat$question_text, 80)) +
    theme_minimal() +
    theme(
      plot.title.position = "plot",
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )
  return(g)
}
