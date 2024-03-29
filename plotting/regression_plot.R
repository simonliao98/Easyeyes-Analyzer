library(dplyr)
library(broom)
library(purrr)
library(ggpp)
prepare_regression_data <- function(df_list){
  reading <- df_list[[1]]
  crowding <- df_list[[2]]
  rsvp_speed <- df_list[[3]]
  crowding_vs_rsvp <- merge(crowding,rsvp_speed, by = c("participant", "font"))
  reading_each <- reading %>% 
    group_by(font, participant, block_condition, thresholdParameter) %>%
    dplyr::summarize(avg_wordPerMin = 10^(mean(log10(wordPerMin), na.rm = T)), .groups = "keep") %>% 
    ungroup()
  
  reading_exceed_1500 <- reading_each %>% 
    filter(avg_wordPerMin > 1500) %>% 
    mutate(warning =  paste("Participant:",
                            participant,
                            "reading speeds removed due to excessive max speed",
                            round(avg_wordPerMin,2),
                            "> 1500 word/min",
                            sep = " "))
  reading_valid <- reading_each %>% 
    filter(!participant %in% reading_exceed_1500$participant) %>% 
    mutate(targetKind = "reading")
  
  crowding_summary <- crowding %>% 
    group_by(participant, font) %>% 
    summarize(bouma_factor = 10^(mean(log10(bouma_factor))))
  
  reading_crowding <- reading_valid %>% 
    select(participant, font, avg_wordPerMin) %>% 
    group_by(participant, font) %>% 
    summarize(avg_log_WPM = mean(log10(avg_wordPerMin))) %>% 
    ungroup() %>% 
    left_join(crowding_summary, by = c("participant", "font")) %>% 
    mutate(targetKind = "reading")
  crowding_vs_rsvp_summary <- crowding_vs_rsvp %>% 
    group_by(participant, font) %>% 
    summarize(bouma_factor = 10^(mean(log10(bouma_factor))), avg_log_WPM = mean(block_avg_log_WPM)) %>% 
    mutate(targetKind = "rsvpReading")
  
  t <- rbind(crowding_vs_rsvp_summary, reading_crowding)
  corr <- t %>% group_by(targetKind) %>% 
    summarize(correlation = round(cor(bouma_factor,avg_log_WPM, 
                                      use = "pairwise.complete.obs",
                                      method = "pearson"),2))
  t <- t %>% left_join(corr, by = "targetKind")
  return(list(t))
}


regression_plot <- function(df_list){
  t <- prepare_regression_data(df_list)[[1]]
  t <- t %>% mutate(targetKind = paste0(targetKind, ", R = ", correlation))
  # plot for the regression
  p <- ggplot(t,aes(x = bouma_factor, y = 10^(avg_log_WPM), color = targetKind)) + 
    geom_point() +
    geom_smooth(method = "lm",formula = y ~ x, se=F) + 
    scale_x_log10() + 
    scale_y_log10() +
    coord_fixed(ratio = 1) + 
    labs(x="Bouma factor", y = "Reading (word/min)") +
    theme_bw() + 
    annotation_logticks() +
    # annotate("text", x = 10^(max(t$bouma_factor)), 
    #          y = 10^(min(t$avg_log_WPM)), 
    #          label = paste("italic(n)==", n_distinct(t$participant)), 
    #          parse = TRUE) +
    guides(color=guide_legend(title="targetKind and correlation"))
  return(p)
}

regression_and_mean_plot <- function(df_list, reading_rsvp_crowding_df){
  t <- prepare_regression_data(df_list)[[1]]
  corr <- prepare_regression_data(df_list)[[2]]
  rsvp_vs_ordinary_vs_crowding <- reading_rsvp_crowding_df[[1]]
  rsvp_vs_ordinary_vs_crowding <-  rsvp_vs_ordinary_vs_crowding %>% 
    left_join(corr, by = "targetKind") %>% 
    mutate(targetKind = paste0(targetKind, ", R =  ", correlation))
  
  # regression and font mean
  p <- ggplot(data = rsvp_vs_ordinary_vs_crowding, aes(x = mean_bouma_factor, 
                                                       y = 10^(avg_log_SpeedWPM))) + 
    geom_point(aes(shape = targetKind, color = font), size = 6) +
    geom_smooth(aes(linetype = targetKind),
                color = "black", method = "lm",formula = y ~ x, se=F,
                fullrange=T) +
    geom_errorbar(aes(ymin=10^(avg_log_SpeedWPM-se),
                      ymax=10^(avg_log_SpeedWPM+se)), width=0) +
    geom_errorbar(aes(xmin=(mean_bouma_factor-se_bouma_factor),
                      xmax=(mean_bouma_factor+se_bouma_factor)), width=0) +
    geom_point(data = t, aes(x = bouma_factor, y = 10^(avg_log_WPM), color = font),alpha = 0.5) +
    geom_smooth(data = t, 
                aes(x = bouma_factor, y = 10^(avg_log_WPM), color = font),
                method = "lm",
                formula = y ~ x, 
                se=F,
                fullrange=T) + 
    scale_y_log10(limits = c(50, 2000)) +
    scale_x_log10() + 
    scale_linetype_manual(values = c(2, 5)) +
    coord_fixed(ratio = 1) +
    labs(x="Bouma factor", y = "Reading speed (word/min)") +
    theme_bw() + 
    annotation_logticks() +
    guides(color=guide_legend(title="font"))
  return(p)
}

regression_and_mean_plot_byfont <- function(df_list, reading_rsvp_crowding_df){
  t <- prepare_regression_data(df_list)[[1]]
  rsvp_vs_ordinary_vs_crowding <- reading_rsvp_crowding_df[[1]]
  corr_means <- rsvp_vs_ordinary_vs_crowding %>% 
    group_by(targetKind) %>% 
    summarize(correlation = cor(avg_log_SpeedWPM, mean_bouma_factor, 
                                method = "pearson")) %>% 
    mutate(correlation = round(correlation,2))
  
  counts = t %>% group_by(font, targetKind) %>% summarize(N = n())
  if (min(counts$N) == max(counts$N)) {
    N_text <-min(counts$N)
  } else {
    N_text <- paste0(min(counts$N),"~to~",max(counts$N))
  }
  result_means <- rsvp_vs_ordinary_vs_crowding %>% 
    group_by(targetKind) %>%
    do(fit = lm(avg_log_SpeedWPM ~ mean_bouma_factor, data = .)) %>% 
    ungroup() %>% 
    transmute(targetKind, coef = map(fit, tidy)) %>% 
    unnest(coef) %>% 
    filter(term == "mean_bouma_factor") %>% 
    select(-statistic, -p.value) %>% 
    rename("slope" = "estimate",
           "SD" = "std.error") %>% 
    mutate(slope = round(slope, 2),
           SD = round(SD, 2)) %>% 
    select(-term)
  
  rsvp_vs_ordinary_vs_crowding <- rsvp_vs_ordinary_vs_crowding %>% 
    inner_join(result_means, by = c("targetKind")) %>% 
    inner_join(corr_means, by = c("targetKind"))
  
  rsvp_vs_ordinary_vs_crowding <- 
    rsvp_vs_ordinary_vs_crowding %>% 
    mutate(legend = paste0(targetKind, ", slope = ", slope, ", R = ", correlation))
  
  
  # regression and font mean
  p <- ggplot(data = rsvp_vs_ordinary_vs_crowding, aes(x = mean_bouma_factor, 
                                                       y = 10^(avg_log_SpeedWPM))) + 
    geom_point(aes(shape = targetKind, color = font), size = 6) +
    geom_smooth(aes(linetype = legend),
                color = "black", method = "lm",formula = y ~ x, se=F,
                fullrange=T) +
    scale_linetype_manual(values = c(1, 2)) +
    geom_errorbar(aes(ymin=10^(avg_log_SpeedWPM-se),
                      ymax=10^(avg_log_SpeedWPM+se)), width=0) +
    geom_errorbar(aes(xmin=(mean_bouma_factor-se_bouma_factor),
                      xmax=(mean_bouma_factor+se_bouma_factor)), width=0) +
    # geom_point(data = t, aes(x = bouma_factor, y = 10^(avg_log_WPM), color = font, shape = targetKind),alpha = 0.5) +
    # geom_smooth(data = t, 
    #             aes(x = bouma_factor, 
    #                 y = 10^(avg_log_WPM), 
    #                 color = font,
    #                 linetype = targetKind),
    #             method = "lm",
    #             formula = y ~ x, 
    #             se=F,
    #             fullrange=T) + 
    scale_y_log10(limits = c(100, 2000)) +
    scale_x_log10() + 
    coord_fixed(ratio = 1) +
    labs(x="Bouma factor", y = "Reading speed (word/min)") +
    theme_bw() + 
    annotation_logticks() +
    guides(color = guide_legend(title="Font"),
           shape = F,
           linetype = guide_legend(title = NULL,
                                   keywidth = unit(2, "cm"))) + 
    ggpp::geom_text_npc(
      aes(npcx = "left",
          npcy = "bottom",
          label = paste0("italic('N=')~", N_text)), 
      parse = T)
  return(p)
}
regression_font <- function(df_list, reading_rsvp_crowding_df){
  t <- prepare_regression_data(df_list)[[1]]
  rsvp_vs_ordinary_vs_crowding <- reading_rsvp_crowding_df[[1]]
  corr_means <- rsvp_vs_ordinary_vs_crowding %>% 
    group_by(targetKind) %>% 
    summarize(correlation = cor(avg_log_SpeedWPM, mean_bouma_factor, 
                                method = "pearson")) %>% 
    mutate(correlation = round(correlation,2))
  
  counts = t %>% group_by(font, targetKind) %>% summarize(N = n())
  if (min(counts$N) == max(counts$N)) {
    N_text <-min(counts$N)
  } else {
    N_text <- paste0(min(counts$N),"~to~",max(counts$N))
  }
  result_means <- rsvp_vs_ordinary_vs_crowding %>% 
    group_by(targetKind) %>%
    do(fit = lm(avg_log_SpeedWPM ~ mean_bouma_factor, data = .)) %>% 
    ungroup() %>% 
    transmute(targetKind, coef = map(fit, tidy)) %>% 
    unnest(coef) %>% 
    filter(term == "mean_bouma_factor") %>% 
    select(-statistic, -p.value) %>% 
    rename("slope" = "estimate",
           "SD" = "std.error") %>% 
    mutate(slope = round(slope, 2),
           SD = round(SD, 2)) %>% 
    select(-term)
  
  rsvp_vs_ordinary_vs_crowding <- rsvp_vs_ordinary_vs_crowding %>% 
    inner_join(result_means, by = c("targetKind")) %>% 
    inner_join(corr_means, by = c("targetKind"))
  
  rsvp_vs_ordinary_vs_crowding <- 
    rsvp_vs_ordinary_vs_crowding %>% 
    mutate(legend = paste0(targetKind, ", slope = ", slope, ", R = ", correlation)) %>% 
    mutate(fontlabel = paste0(font, " - ", substr(font, start = 1, stop = 3)))
  # regression and font mean
  p <- ggplot(data = rsvp_vs_ordinary_vs_crowding, aes(x = mean_bouma_factor, 
                                                       y = 10^(avg_log_SpeedWPM))) + 
    geom_text(aes(label = substr(font, start = 1, stop = 3), 
                  color = targetKind), check_overlap = T) +
    geom_smooth(aes(linetype = legend),
                color = "black", method = "lm",formula = y ~ x, se=F,
                fullrange=T) +
    scale_linetype_manual(values = c(1, 2)) +
    scale_y_log10() +
    scale_x_log10(limits = c(0.1,1)) + 
    coord_fixed(ratio = 1) +
    labs(x="Bouma factor", y = "Reading speed (word/min)") +
    theme_bw() + 
    annotation_logticks() +
    guides(color = guide_legend(title="TargetKind"),
           shape = F,
           linetype = guide_legend(title = NULL,
                                   keywidth = unit(2, "cm")),
           fill = guide_legend(title = "Font")) + 
    ggpp::geom_text_npc(
      aes(npcx = "left",
          npcy = "bottom",
          label = paste0("italic('N=')~", N_text)), 
      parse = T)
  return(p)
}

regression_font_with_label <- function(df_list, reading_rsvp_crowding_df){
  t <- prepare_regression_data(df_list)[[1]]
  rsvp_vs_ordinary_vs_crowding <- reading_rsvp_crowding_df[[1]]
  corr_means <- rsvp_vs_ordinary_vs_crowding %>% 
    group_by(targetKind) %>% 
    summarize(correlation = cor(avg_log_SpeedWPM, mean_bouma_factor, 
                                method = "pearson")) %>% 
    mutate(correlation = round(correlation,2))
  
  counts = t %>% group_by(font, targetKind) %>% summarize(N = n())
  if (min(counts$N) == max(counts$N)) {
    N_text <-min(counts$N)
  } else {
    N_text <- paste0(min(counts$N),"~to~",max(counts$N))
  }
  result_means <- rsvp_vs_ordinary_vs_crowding %>% 
    group_by(targetKind) %>%
    do(fit = lm(avg_log_SpeedWPM ~ mean_bouma_factor, data = .)) %>% 
    ungroup() %>% 
    transmute(targetKind, coef = map(fit, tidy)) %>% 
    unnest(coef) %>% 
    filter(term == "mean_bouma_factor") %>% 
    select(-statistic, -p.value) %>% 
    rename("slope" = "estimate",
           "SD" = "std.error") %>% 
    mutate(slope = round(slope, 2),
           SD = round(SD, 2)) %>% 
    select(-term)
  
  rsvp_vs_ordinary_vs_crowding <- rsvp_vs_ordinary_vs_crowding %>% 
    inner_join(result_means, by = c("targetKind")) %>% 
    inner_join(corr_means, by = c("targetKind"))
  
  rsvp_vs_ordinary_vs_crowding <- 
    rsvp_vs_ordinary_vs_crowding %>% 
    mutate(legend = paste0(targetKind, ", slope = ", slope, ", R = ", correlation)) %>% 
    mutate(fontlabel = paste0(font, " - ", substr(font, start = 1, stop = 3)),
           font_family = case_when(font == "TimesNewRomanRegularMonotype.woff2" ~ "Times New Roman",
                                   font == "Agoesa.woff2" ~ "Agoesa",
                                   font == "Quela.woff2" ~ "Quela",
                                   TRUE ~ "Arial"))
  # regression and font mean
  
  p <- ggplot(data = rsvp_vs_ordinary_vs_crowding, aes(x = mean_bouma_factor, 
                                                       y = 10^(avg_log_SpeedWPM))) + 
    geom_point(aes(fill = fontlabel), alpha = 0)+
    geom_text(aes(label = substr(font, start = 1, stop = 3), 
                  color = targetKind,
                  family = font_family), check_overlap = T) +
    geom_smooth(aes(linetype = legend),
                color = "black", method = "lm",formula = y ~ x, se=F,
                fullrange=T) +
    scale_linetype_manual(values = c(1, 2)) +
    # geom_errorbar(aes(ymin=10^(avg_log_SpeedWPM-se),
    #                   ymax=10^(avg_log_SpeedWPM+se)), width=0) +
    # geom_errorbar(aes(xmin=(mean_bouma_factor-se_bouma_factor),
    #                   xmax=(mean_bouma_factor+se_bouma_factor)), width=0) +
    # geom_point(data = t, 
    #            aes(x = bouma_factor, 
    #                y = 10^(avg_log_WPM), 
    #                color = font, 
    #                shape = targetKind),
    #            alpha = 0.5) +
    # geom_smooth(data = t,
    #             aes(x = bouma_factor,
    #                 y = 10^(avg_log_WPM),
    #                 color = font,
    #                 linetype = targetKind),
    #             method = "lm",
    #             formula = y ~ x,
    #             se=F,
    #             fullrange=T) +
    scale_y_log10() +
    scale_x_log10(limits = c(0.1,1)) + 
    coord_fixed(ratio = 1) +
    labs(x="Bouma factor", y = "Reading speed (word/min)") +
    theme_bw() + 
    annotation_logticks() +
    guides(color = guide_legend(title="TargetKind"),
           shape = F,
           linetype = guide_legend(title = NULL,
                                   keywidth = unit(2, "cm")),
           fill = guide_legend(title = "Font")) + 
    ggpp::geom_text_npc(
      aes(npcx = "left",
          npcy = "bottom",
          label = paste0("italic('N=')~", N_text)), 
      parse = T)
  return(p)
}
