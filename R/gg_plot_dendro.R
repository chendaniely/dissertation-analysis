library(rlang)
library(ggplot2)
library(ggdendro)
library(cluster)

gg_plot_dendro <- function(hc_data, groupnum) {
  myq <- rlang::enexpr(groupnum)
  mys <- rlang::as_string(myq)
  
  # https://stackoverflow.com/questions/24140339/tree-cut-and-rectangles-around-clusters-for-a-horizontal-dendrogram-in-r
  
  dendr    <- dendro_data(hc_ward, type="rectangle") # convert for ggplot
  clust.df <- numeric_data %>%
    tibble::rownames_to_column("id_person") %>%
    dplyr::select(id_person, {{ groupnum }})
  
  stopifnot(nrow(dendr[["labels"]]) == nrow(clust.df))
  
  dendr[["labels"]] <- dendr[["labels"]] %>%
    dplyr::inner_join(clust.df, by = c("label" = "id_person"))
  
  stopifnot(nrow(dendr[["labels"]]) == nrow(clust.df))
  
  # rectangular bounding box
  rect <- aggregate(as.formula(glue::glue("x ~ {mys}")),
                    label(dendr),
                    range)
  rect <- data.frame(gp = rect[[mys]],
                     rect$x)
  ymax <- mean(hc_ward$height[length(hc_ward$height) - ((2-2):(2-1))])
  
  ggplot() +
    geom_segment(data = segment(dendr),
                 aes(x = x, y = y, xend = xend, yend = yend)) +
    geom_text(data=label(dendr),
              aes(x, y - 0.25,
                  label=label, hjust=0, color=as.factor({{ groupnum }})),
              size=2.5) +
    geom_rect(data = rect,
              aes(xmin = X1-.3,
                  xmax=X2+.3,
                  ymin=0,
                  ymax=ymax, color = as.factor(gp)),
              fill=NA)+
    coord_flip() + scale_y_reverse(expand=c(0.2, 0)) +
    theme_dendro() +
    NULL
}
