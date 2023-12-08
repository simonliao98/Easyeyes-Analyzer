plot_profiles <- function(transducerType, t, plotTitle) {
  dt <- tibble()
  if (transducerType == "Microphones") {
    for (i in 1:length(t$linear$Freq)) {
      print(ifelse(t$isDefault[i], "default", t$DateText[i]))
      tmp <- tibble(freq = t$linear$Freq[[i]],
                    gain = t$linear$Gain[[i]],
                    label = ifelse(t$isDefault[i], 
                                   paste0("default/", t$ID[i]),
                                   t$DateText[i])) %>% 
        filter(!is.na(label))
      dt <- dt %>% rbind(tmp)
    }
  } else {
    for (i in 1:length(t$ir$Freq)) {
      tmp <- tibble(freq = t$ir$Freq[[i]],
                    gain = t$ir$Gain[[i]],
                    label = t$CalibrationDate[i]) %>% 
        filter(!is.na(label))
      dt <- dt %>% rbind(tmp)
    }
  }
  legendRows <- ceiling(n_distinct(dt$label)/3)
  maxY <- ceiling(max(dt$gain) /10) * 10
  minY <- floor(min(dt$gain) /10) * 10
  color_options <- c(
    "red", "mediumorchid4", 'blue3', 'forestgreen', 'turquoise4', 'mediumvioletred',
    'orangered3', 'tan4', 'seagreen4', 'aquamarine3', 'darkgoldenrod4'
                     )
  linetype_options <- c("solid", "dashed", "dotted", "twodash","longdash", "dotdash")
  colors <- color_options[0 : n_distinct(dt$label) %% length(color_options) + 1]
  linetypes <- linetype_options[(0 : n_distinct(dt$label) %/% length(color_options)) %% length(linetype_options) + 1]
  p <- ggplot(data = dt, aes(x = freq, y = gain, color = label, linetype = label)) +
    geom_line(linewidth = 0.6) +                  
    scale_y_continuous(limits = c(minY ,maxY), breaks = seq(minY,maxY,10), expand = c(0,0)) + 
    scale_x_log10(limits = c(20, 20000), 
                  breaks = c(20, 100, 200, 1000, 2000, 10000, 20000),
                  expand = c(0, 0)) +
    scale_color_manual(values = colors) + 
    scale_linetype_manual(values = linetypes) +
    theme_bw() + 
    theme(legend.position="top",
          plot.margin = margin(
            t = 1,
            r = .5,
            b = .5,
            l = .5,
            "inch"
          ),
          legend.text = element_text(margin = margin(t = -5, b = -5, unit = "pt"))) +
    sound_theme_display + 
    guides(color=guide_legend(byrow=TRUE, ncol = 3,
                              keyheight=0.3, unit = "inch")) +
    labs(title = plotTitle,
         x = "Frequency (Hz)",
         y = "Gain (dB)",
         color = "",
         linetype = "")
  height = ceiling(( maxY - minY) / 12) + ceiling(legendRows/3)*0.05 + 2
  return (
    list(
      height = height,
      plot = p
    )
  )
}

plot_filtered_profiles <- function(transducerType, t, plotTitle, options) {
  dt <- tibble()
  if (transducerType == "Microphones") {
    for (i in 1:length(t$linear$Freq)) {
      print(ifelse(t$isDefault[i], "default", t$DateText[i]))
      tmp <- tibble(freq = t$linear$Freq[[i]],
                    gain = t$linear$Gain[[i]],
                    label = ifelse(t$isDefault[i], 
                                   paste0("default/", t$ID[i]),
                                   t$DateText[i])) %>% 
        filter(!is.na(label))
      dt <- dt %>% rbind(tmp)
    }
  } else {
    for (i in 1:length(t$ir$Freq)) {
      tmp <- tibble(freq = t$ir$Freq[[i]],
                    gain = t$ir$Gain[[i]],
                    label = t$CalibrationDate[i]) %>% 
        filter(!is.na(label))
      dt <- dt %>% rbind(tmp)
    }
  }
  dt <- dt %>% filter(label %in% options)
  legendRows <- ceiling(n_distinct(dt$label)/3)
  maxY <- ceiling(max(dt$gain)/10) * 10
  minY <- floor(min(dt$gain)/10) * 10
  color_options <- c(
    "red", "mediumorchid4", 'blue3', 'forestgreen', 'turquoise4', 'mediumvioletred',
    'orangered3', 'tan4', 'seagreen4', 'aquamarine3', 'darkgoldenrod4'
  )
  linetype_options <- c("solid", "dashed", "dotted", "twodash","longdash", "dotdash")
  colors <- color_options[0 : n_distinct(dt$label) %% length(color_options) + 1]
  linetypes <- linetype_options[(0 : n_distinct(dt$label) %/% length(color_options)) %% length(linetype_options) + 1]
  p <- ggplot(data = dt, aes(x = freq, y = gain, color = label, linetype = label)) +
    geom_line( linewidth = 0.6) +                  
    scale_y_continuous(limits = c(minY ,maxY), breaks = seq(minY,maxY,10), expand = c(0,0)) + 
    scale_x_log10(limits = c(20, 20000), 
                  breaks = c(20, 100, 200, 1000, 2000, 10000, 20000),
                  expand = c(0, 0)) +
    scale_color_manual(values = colors) + 
    scale_linetype_manual(values = linetypes) +
    theme_bw() + 
    theme(legend.position="top",
          plot.margin = margin(
            t = 1,
            r = .5,
            b = .5,
            l = .5,
            "inch"
          ),
          legend.text = element_text(margin = margin(t = -1, b = -1, unit = "pt"))) +
    sound_theme_display + 
    guides(color=guide_legend(byrow=TRUE, ncol = 3, keyheight=0.3, unit = "inch")) +
    labs(title = plotTitle,
         x = "Frequency (Hz)",
         y = "Gain (dB)",
         color = "",
         linetype = "")
  height = ceiling(( maxY - minY) / 13) + ceiling(legendRows/3)*0.04 + 2
  return (
    list(
      height = height,
      plot = p
    )
  )
}



