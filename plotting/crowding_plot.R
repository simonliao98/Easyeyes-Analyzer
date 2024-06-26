crowding_by_side <- function(crowding) {

  crowding <- crowding %>% filter(targetEccentricityXDeg != 0) %>% 
    mutate(side = ifelse(targetEccentricityXDeg < 0, 'L', 'R'),
           XDeg = abs(targetEccentricityXDeg))
  print(crowding %>% select("participant","font", 'XDeg'))
    
  # crowding$side <- ifelse(grepl("left", crowding$conditionName), "L", "R")
  crowding_L <- crowding %>% filter(side == "L") %>% select(-conditionName, -side)
  crowding_R <- crowding %>% filter(side == "R") %>% select(-conditionName, -side)
  
  print(crowding_L)
  print(crowding_R)
  
  crowding_L_R <- crowding_L %>% 
    left_join(crowding_R, by = c("participant","font", 'XDeg')) %>% 
    rename("bouma_factor_Left" = "bouma_factor.x",
           "bouma_factor_Right" = "bouma_factor.y",
           "log_crowding_distance_deg_Left" = "log_crowding_distance_deg.x",
           "log_crowding_distance_deg_Right" = "log_crowding_distance_deg.y")
  print('==========================  crowding_L_R ==========================')
  print(crowding_L_R)
  return(crowding_L_R)
}

crowding_scatter_plot <- function(crowding_L_R){
  if (n_distinct(crowding_L_R$font) < 1) {
    return(ggplot())
  }
  if(n_distinct(crowding_L_R$font) == 1) {
    if (is.na(unique(crowding_L_R$bouma_factor_Left)[1])) {
      return(ggplot())
    }
  }
  
  summ <- group_by(crowding_L_R, font) %>% 
    summarize(R = cor(log(bouma_factor_Left), log(bouma_factor_Right)),
              ratio = round(mean(bouma_factor_Right) / mean(bouma_factor_Left),2),
              N = n()) %>%
    mutate(R = formatC(R, format = "fg", digits = 2),
           ratio = formatC(ratio, format = "fg", digits = 2)) %>% 
    mutate(label =  paste0("italic('R=')~", 
                           R,
                           "~italic(', right:left=')~", ratio),
           N = paste0("italic('N=')~", N))
  
  ggplot(crowding_L_R,aes(x = bouma_factor_Left, y = bouma_factor_Right)) + 
    geom_point(size = 1) + 
    facet_wrap(~font) + 
    geom_smooth(method = "lm",formula = y ~ x, se=F) + 
    scale_y_log10(breaks = c(0.1, 0.3, 1, 3)) +
    scale_x_log10(breaks = c(0.1, 0.3, 1, 3)) + 
    annotation_logticks(short = unit(0.1, "cm"),                                                
                        mid = unit(0.1, "cm"),
                        long = unit(0.3, "cm")) + 
    xlab("Left Bouma factor") + 
    ylab("Right Bouma factor") + 
    coord_fixed(ratio = 1) + 
    theme_bw() + 
    ggpp::geom_text_npc(
      data = summ,
      aes(npcx = "left",
          npcy = "bottom",
          label = label), 
      parse = T) + 
    ggpp::geom_text_npc(
      data = summ,
      aes(npcx = "left",
          npcy = "top",
          label = N),
      parse = T)
}

crowding_mean_scatter_plot <- function(crowding_L_R){
  if (n_distinct(crowding_L_R$font) < 1) {
    return(ggplot() + 
             xlab("Left Bouma factor") + 
             ylab("Right Bouma factor") )
  }
  t <- crowding_L_R %>% group_by(font) %>% summarize(avg_bouma_factor_Left = mean(bouma_factor_Left),
                                                     avg_bouma_factor_Right = mean(bouma_factor_Right))
  ggplot(t, aes(x = avg_bouma_factor_Left, y = avg_bouma_factor_Right, color = font)) + 
    geom_point(size = 2) +
    scale_y_log10(limits = c(0.1, ceiling(max(t$avg_bouma_factor_Left, t$avg_bouma_factor_Right)))) +
    scale_x_log10(limits = c(0.1, ceiling(max(t$avg_bouma_factor_Left, t$avg_bouma_factor_Right)))) + 
    geom_smooth(method = "lm",formula = y ~ x, se=F) + 
    stat_cor() +  
    coord_fixed(ratio = 1) + 
    guides(color = guide_legend(title="Font")) + 
    xlab("Left Bouma factor") + 
    ylab("Right Bouma factor") + 
    theme_bw() + 
    ggpp::geom_text_npc(
      aes(npcx = "left",
          npcy = "top",
          label = paste0("italic('R=')~", cor(t$avg_bouma_factor_Left, t$avg_bouma_factor_Left))), 
      parse = T) + 
    ggpp::geom_text_npc(
      aes(npcx = "left",
          npcy = "bottom",
          label = paste0("italic('N=')~", dplyr::n_distinct(crowding_L_R$participant))), 
      parse = T)
}




get_two_fonts_plots <- function(crowding) {
  # Calculate mean and standard deviation for each participant and font
  if (n_distinct(crowding$font) < 1) {
    return(ggplot())
  }
  t <- crowding %>% 
    group_by(participant, font) %>% 
    summarize(
      MEAN = mean(log10(bouma_factor), na.rm = TRUE),
      SD = sd(log10(bouma_factor), na.rm = TRUE)
    ) %>% 
    mutate(
      MEAN = round(MEAN, 2),
      SD = round(SD, 2)
    ) %>% 
    arrange(participant, font)
  
  # Number of unique participants
  n <- n_distinct(crowding$participant)
  if (n_distinct(t$font) == 2) {
    font1 = unique(t$font)[1]
    font2 = unique(t$font)[2]
  } else {
    return(list(
      ggplot(),
      ggplot(),
      'font A vs font B'
    ))
  }
  # Prepare data for mean plot
  for_plot_means <- t %>% pivot_wider(names_from = font, values_from = MEAN)
  font1_means <- for_plot_means %>% filter(!is.na(!!sym(font1))) %>% select(participant, !!sym(font1))
  font2_means <- for_plot_means %>% filter(!is.na(!!sym(font2))) %>% select(participant, !!sym(font2))
  for_plot <- font1_means %>% inner_join(font2_means, by = "participant")
  
  # Mean plot
  mean_plot <- ggplot(for_plot, aes_string(x = paste0("10^(`", font1, "`)"), y = paste0("10^(`", font2, "`)"))) + 
    geom_point() + 
    scale_y_log10() +
    scale_x_log10() + 
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE) + 
    theme_bw() + 
    coord_fixed(ratio = 1) + 
    labs(x = paste0(font1, " Bouma Factor"), y = paste0(font2, " Bouma Factor")) +
    downloadtheme + 
    ggpp::geom_text_npc(
      aes(npcx = "left", npcy = "bottom", label = paste0("italic('N=')~", n)), 
      parse = TRUE
    ) + 
    stat_cor(aes(label = ..r.label..), r.accuracy = 0.001)
  
  # Prepare data for standard deviation plot
  for_plot_sd <- t %>% pivot_wider(names_from = font, values_from = SD)
  font1_sd <- for_plot_sd %>% filter(!is.na(!!sym(font1))) %>% select(participant, !!sym(font1))
  font2_sd <- for_plot_sd %>% filter(!is.na(!!sym(font2))) %>% select(participant, !!sym(font2))
  for_plot <- font1_sd %>% inner_join(font2_sd, by = "participant")
  
  # Standard deviation plot
  sd_plot <- ggplot(for_plot, aes_string(x = paste0("10^(`", font1, "`)"), y = paste0("10^(`", font2, "`)"))) + 
    geom_point() + 
    scale_y_log10() +
    scale_x_log10() + 
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE) + 
    theme_bw() + 
    coord_fixed(ratio = 1) + 
    labs(x = paste0(font1, " Bouma Factor"), y = paste0(font2, " Bouma Factor")) +
    downloadtheme + 
    ggpp::geom_text_npc(
      aes(npcx = "left", npcy = "bottom", label = paste0("italic('N=')~", n)), 
      parse = TRUE
    ) + 
    stat_cor(aes(label = ..r.label..), r.accuracy = 0.001)
  
  title = paste(font1, ' vs ', font2)
  
  return(list(mean_plot = mean_plot, sd_plot = sd_plot, title = title))
}



