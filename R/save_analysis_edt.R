library(ggplot2)

save_analysis_edt <- function(g, analysis_pth, edt_pth, ...) {
  ggplot2::ggsave(filename = analysis_pth,
                  plot = g,
                  ...)
  ggplot2::ggsave(filename = edt_pth,
                  plot = g,
                  ...)
}
