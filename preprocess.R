library(dplyr)
library(stringr)
read_files <- function(file){
  if(is.null(file)) return(list())
  file_list <- file$data
  data_list <- list()
  summary_list <- list()
  n <- length(file_list)
  experiment <- rep(NA,n)
  readingCorpus <- c()
  j = 1
  for (i in 1 : n) {
    if (grepl(".csv", file_list[i])){
      t <- tibble()
      try({t <- readr::read_csv(file_list[i])}, silent = TRUE)
      inf <- file.info(file_list[i])
      if (!('participant' %in% colnames(t))) {
        t <- tibble(participant = str_split(file$name[i], "[_]")[[1]][1],
                    ProlificParticipantID = str_split(file$name[i], "[_]")[[1]][2],
                    experiment = str_split(file$name[i], "[_]")[[1]][3])
        t$error <- "Incomplete"
        t$rows <- 0
        t$cols <- 0
      } else {
        t$cols <- ncol(t)
        t$rows <- ifelse(nrow(t) == 0, 0, nrow(t) + 1)
      }
      t$kb <-round(inf$size/1024)
      
      if (!('ProlificParticipantID' %in% colnames(t))) {
        t$ProlificParticipantID <- ""
      }
      if (!('error' %in% colnames(t))) {
        t$error <- ""
      }
      if (!('questionAndAnswerResponse' %in% colnames(t))) {
        t$questionAndAnswerResponse <- ""
      }
      if (!('warning' %in% colnames(t))) {
        t$warning <- ""
      }
      if (!('readingCorpus' %in% colnames(t))) {
        t$readingCorpus <- ""
      }
      if ('readingPageWords' %in% colnames(t)) {
        t$wordPerMin <- (as.numeric(t$readingPageWords) + as.numeric(t$readingLinesPerPage) - 1) / (as.numeric(t$readingPageDurationOnsetToOffsetSec) / 60)
      }
      if (!('viewingDistanceDesiredCm' %in% colnames(t))) {
        t$viewingDistanceDesiredCm <- NA
      }
      if (!('readingPageWords' %in% colnames(t))) {
        t$wordPerMin <- NA
      }
      if (!('readingNumberOfQuestions' %in% colnames(t))) {
        t$readingNumberOfQuestions <- NA
      }
      if (!('key_resp.keys' %in% colnames(t))) {
        t$key_resp.keys <- NA
      }
      if (!('correctAns' %in% colnames(t))) {
        t$correctAns <- NA
      }
      if (!('readWordIdentifiedBool' %in% colnames(t))) {
        t$readWordIdentifiedBool <- NA
      }
      if (!('targetEccentricityXDeg' %in% colnames(t))) {
        t$targetEccentricityXDeg <- NA
      }
      if (!('targetEccentricityYDeg' %in% colnames(t))) {
        t$targetEccentricityYDeg <- NA
      }
      if (!('targetFinishSec' %in% colnames(t))) {
        t$targetFinishSec <- NA
      }
      if (!('targetStartSec' %in% colnames(t))) {
        t$targetStartSec <- NA
      }
      if (!('targetDurationSec' %in% colnames(t))) {
        t$targetDurationSec <- NA
      }
      if (!('targetMeasuredDurationSec' %in% colnames(t))) {
        t$targetMeasuredDurationSec <- t$targetFinishSec-t$targetStartSec
      }
      if (!('targetMeasuredLatenessSec' %in% colnames(t))) {
        t$targetMeasuredLatenessSec <- NA
      }
      if (!('questMeanAtEndOfTrialsLoop' %in% colnames(t))) {
        t$questMeanAtEndOfTrialsLoop <- NA
      }
      if (!('screenHeightPx' %in% colnames(t))) {
        t$screenHeightPx <- NA
      }
      if (!('screenWidthPx' %in% colnames(t))) {
        t$screenWidthPx <- NA
      }
      if (!('deviceBrowser' %in% colnames(t))) {
        t$deviceBrowser <- ""
      }
      if (!('deviceBrowserVersion' %in% colnames(t))) {
        t$deviceBrowserVersion <- ""
      }
      if (!('deviceType' %in% colnames(t))) {
        t$deviceType <- ""
      }
      if (!('deviceSystemFamily' %in% colnames(t))) {
        t$deviceSystemFamily <- ""
      }
      if (!('deviceLanguage' %in% colnames(t))) {
        t$deviceLanguage <- ""
      }
      if (!('deviceSystem' %in% colnames(t))) {
        t$deviceSystem <- ""
      }
      if (!('date' %in% colnames(t))) {
        t$date <- ""
      }
      if (!('hardwareConcurrency' %in% colnames(t))) {
        t$hardwareConcurrency <- NA
      }
      if (!('experiment' %in% colnames(t))) {
        t$experiment <- str_split(file$name[i], "[_]")[[1]][3]
      }
      if (!('experimentCompleteBool' %in% colnames(t))) {
        t$experimentCompleteBool <- FALSE
      }
      if (!('block' %in% colnames(t))) {
        t$block <- NA
      }
      if (!('conditionName' %in% colnames(t))) {
        t$conditionName <- ""
      }
      if (!('block_condition' %in% colnames(t))) {
        t$block_condition <- ''
      }
      if (!('staircaseName' %in% colnames(t))) {
        t$staircaseName <- NA
      }
      if (!('font' %in% colnames(t))) {
        t$font <- ""
      }
      if (!('targetTask' %in% colnames(t))) {
        t$targetTask <- ""
      }
      if (!('targetKind' %in% colnames(t))) {
        t$targetKind <- ""
      }
      if (!('_needsUnmet' %in% colnames(t))) {
        t$`_needsUnmet` <- ""
      }
      if (!('Loudspeaker survey' %in% colnames(t))) {
        t$`Loudspeaker survey` <- ""
      }
      if (!('ComputerInfoFrom51Degrees' %in% colnames(t))) {
        t$ComputerInfoFrom51Degrees <- ""
      }
      if (!('Microphone survey' %in% colnames(t))) {
        t$`Microphone survey` <- ""
      }
      if (!('thresholdParameter' %in% colnames(t))) {
        t$thresholdParameter <- ""
      }
      if (!('psychojsWindowDimensions' %in% colnames(t))) {
        t$psychojsWindowDimensions <- "NA,NA"
      }
      if (!('QRConnect' %in% colnames(t))) {
        t$QRConnect <- 'column missing'
      }
      t$age <- t$questionAndAnswerResponse[2]
      screenWidth <- ifelse(length(unique(t$screenWidthPx)) > 1,
                            unique(t$screenWidthPx)[!is.na(unique(t$screenWidthPx))] , 
                            NA)
      screenHeight <- ifelse(length(unique(t$screenHeightPx)) > 1,
                             unique(t$screenHeightPx)[!is.na(unique(t$screenHeightPx))] , 
                             NA)
      t <- t %>% mutate(screenWidthPx = screenWidth,
                        screenHeightPx = screenHeight,
                        browser = ifelse(deviceBrowser == "", "", paste0(deviceBrowser, 
                                                                         " ", 
                                                                         str_split(deviceBrowserVersion, "[.]")[[1]][1])),
                        resolution = paste0(screenWidthPx, " x ", screenHeightPx),
                        block_condition = ifelse(block_condition == "",staircaseName, block_condition))
      t$system = str_replace_all(t$deviceSystem, "OS X","macOS")
      t$deviceSystemFamily = str_replace_all(t$deviceSystemFamily, "OS X","macOS")
      psychojsWindowDimensions <- lapply(strsplit(t$psychojsWindowDimensions[1],","), parse_number)[1]
      WindowDimensions <- paste0(psychojsWindowDimensions[[1]][1], " x ", psychojsWindowDimensions[[1]][2])
      t$resolution = ifelse(t$resolution[1] == "NA x NA", WindowDimensions, t$resolution)
      t$resolution = ifelse(t$resolution[1] == "NA x NA", "", t$resolution)
      info <- dplyr::filter(t, is.na(questMeanAtEndOfTrialsLoop)) %>% 
        select(block_condition, conditionName) %>% 
        distinct(block_condition, conditionName) %>% 
        dplyr::filter(conditionName != "" & block_condition != "")
      t <- t %>% 
        rename("cores" = "hardwareConcurrency")
      
      info <- t %>% 
        dplyr::filter(is.na(questMeanAtEndOfTrialsLoop)) %>%
        distinct(participant, block_condition, staircaseName, conditionName, 
                 targetKind, font, experiment)
      
      summaries <- t %>% 
        dplyr::filter(!is.na(questMeanAtEndOfTrialsLoop)) %>% 
        select(
          block_condition,
          staircaseName, 
          thresholdParameter,
          questMeanAtEndOfTrialsLoop
        )
      if(n_distinct(summaries$staircaseName) < n_distinct(summaries$block_condition)) {
        summaries <- summaries %>% 
          select(-staircaseName) %>% 
          left_join(info, by = "block_condition")
      } else {
        summaries <- summaries %>% 
          select(-block_condition)
        summaries <- merge(info, summaries, by = ("staircaseName"))
      }
      summary_list[[j]] <- summaries
      data_list[[j]] <- t
      t$experiment <- trimws(t$experiment[1])
      experiment[j] <- trimws(t$experiment[1])
      j = j + 1
      readingCorpus <- c(readingCorpus,unique(t$readingCorpus))
    }
  }
  for (k in 1:n) {
    if (grepl(".zip", file_list[k])) {
      file_names <- unzip(file_list[k], list = TRUE)$Name
      all_csv <- file_names[grepl(".csv", file_names)]
      all_csv <- all_csv[!grepl("__MACOSX", all_csv)]
      m <- length(all_csv)
      for (u in 1 : m) {
        t <- tibble()
        try({t <- readr::read_csv(unzip(file_list[k], all_csv[u]))}, silent = TRUE)
        if (!('participant' %in% colnames(t))) {
          fileName <- str_split(all_csv[u], "[/]")[[1]][2]
          t <- tibble(participant = str_split(fileName, "[_]")[[1]][1],
                      ProlificParticipantID = str_split(fileName, "[_]")[[1]][2],
                      experiment = str_split(fileName, "[_]")[[1]][3])
          t$error <- "Incomplete"
          t$rows <- 0
          t$cols <- 0
        } else {
          t$cols <- ncol(t)
          t$rows <- ifelse(nrow(t) == 0, 0, nrow(t) + 1)
        }
        inf <- file.info(unzip(file_list[k], all_csv[u]))
        t$kb <-round(inf$size/1024)
        if (!('ProlificParticipantID' %in% colnames(t))) {
          t$ProlificParticipantID <- ""
        }
        if (!('error' %in% colnames(t))) {
          t$error <- ""
        }
        if (!('questionAndAnswerResponse' %in% colnames(t))) {
          t$questionAndAnswerResponse <- ""
        }
        if (!('warning' %in% colnames(t))) {
          t$warning <- ""
        }
        if (!('readingCorpus' %in% colnames(t))) {
          t$readingCorpus <- ""
        }
        if ('readingPageWords' %in% colnames(t)) {
          t$wordPerMin <- (as.numeric(t$readingPageWords) + as.numeric(t$readingLinesPerPage) - 1) / (as.numeric(t$readingPageDurationOnsetToOffsetSec) / 60)
        }
        if (!('viewingDistanceDesiredCm' %in% colnames(t))) {
          t$viewingDistanceDesiredCm <- NA
        }
        if (!('readingPageWords' %in% colnames(t))) {
          t$wordPerMin <- NA
        }
        if (!('readingNumberOfQuestions' %in% colnames(t))) {
          t$readingNumberOfQuestions <- NA
        }
        if (!('key_resp.keys' %in% colnames(t))) {
          t$key_resp.keys <- NA
        }
        if (!('correctAns' %in% colnames(t))) {
          t$correctAns <- NA
        }
        if (!('readWordIdentifiedBool' %in% colnames(t))) {
          t$readWordIdentifiedBool <- NA
        }
        if (!('targetEccentricityXDeg' %in% colnames(t))) {
          t$targetEccentricityXDeg <- NA
        }
        if (!('targetEccentricityYDeg' %in% colnames(t))) {
          t$targetEccentricityYDeg <- NA
        }
        if (!('targetFinishSec' %in% colnames(t))) {
          t$targetFinishSec <- NA
        }
        if (!('targetStartSec' %in% colnames(t))) {
          t$targetStartSec <- NA
        }
        if (!('targetDurationSec' %in% colnames(t))) {
          t$targetDurationSec <- NA
        }
        if (!('targetMeasuredDurationSec' %in% colnames(t))) {
          t$targetMeasuredDurationSec <- t$targetFinishSec-t$targetStartSec
        }
        if (!('targetMeasuredLatenessSec' %in% colnames(t))) {
          t$targetMeasuredLatenessSec <- NA
        }
        if (!('questMeanAtEndOfTrialsLoop' %in% colnames(t))) {
          t$questMeanAtEndOfTrialsLoop <- NA
        }
        if (!('screenHeightPx' %in% colnames(t))) {
          t$screenHeightPx <- NA
        }
        if (!('screenWidthPx' %in% colnames(t))) {
          t$screenWidthPx <- NA
        }
        if (!('deviceBrowser' %in% colnames(t))) {
          t$deviceBrowser <- ""
        }
        if (!('deviceBrowserVersion' %in% colnames(t))) {
          t$deviceBrowserVersion <- ""
        }
        if (!('deviceType' %in% colnames(t))) {
          t$deviceType <- ""
        }
        if (!('deviceSystemFamily' %in% colnames(t))) {
          t$deviceSystemFamily <- ""
        }
        if (!('deviceLanguage' %in% colnames(t))) {
          t$deviceLanguage <- ""
        }
        if (!('deviceSystem' %in% colnames(t))) {
          t$deviceSystem <- ""
        }
        if (!('date' %in% colnames(t))) {
          t$date <- ""
        }
        if (!('hardwareConcurrency' %in% colnames(t))) {
          t$hardwareConcurrency <- NA
        }
        if (!('experiment' %in% colnames(t))) {
          fileName <- str_split(all_csv[u], "[/]")[[1]][2]
          t$experiment <- str_split(fileName, "[_]")[[1]][3]
        }
        if (!('experimentCompleteBool' %in% colnames(t))) {
          t$experimentCompleteBool <- FALSE
        }
        if (!('block' %in% colnames(t))) {
          t$block <- NA
        }
        if (!('conditionName' %in% colnames(t))) {
          t$conditionName <- ""
        }
        if (!('block_condition' %in% colnames(t))) {
          t$block_condition <- ''
        }
        if (!('staircaseName' %in% colnames(t))) {
          t$staircaseName <- NA
        }
        if (!('font' %in% colnames(t))) {
          t$font <- ""
        }
        if (!('targetTask' %in% colnames(t))) {
          t$targetTask <- ""
        }
        if (!('targetKind' %in% colnames(t))) {
          t$targetKind <- ""
        }
        if (!('thresholdParameter' %in% colnames(t))) {
          t$thresholdParameter <- ""
        }
        if (!('psychojsWindowDimensions' %in% colnames(t))) {
          t$psychojsWindowDimensions <- "NA,NA"
        }
        if (!('_needsUnmet' %in% colnames(t))) {
          t$`_needsUnmet` <- ""
        }
        if (!('Loudspeaker survey' %in% colnames(t))) {
          t$`Loudspeaker survey` <- ""
        }
        if (!('ComputerInfoFrom51Degrees' %in% colnames(t))) {
          t$ComputerInfoFrom51Degrees <- ""
        }
        if (!('Microphone survey' %in% colnames(t))) {
          t$`Microphone survey` <- ""
        }
        if (!('QRConnect' %in% colnames(t))) {
          t$QRConnect <- 'column missing'
        }

        t$age <- t$questionAndAnswerResponse[2]
        screenWidth <- ifelse(length(unique(t$screenWidthPx)) > 1,
                              unique(t$screenWidthPx)[!is.na(unique(t$screenWidthPx))] , 
                              NA)
        screenHeight <- ifelse(length(unique(t$screenHeightPx)) > 1,
                               unique(t$screenHeightPx)[!is.na(unique(t$screenHeightPx))] , 
                               NA)
        t <- t %>% mutate(screenWidthPx = screenWidth,
                          screenHeightPx = screenHeight,
                          browser = ifelse(deviceBrowser == "", "", paste0(deviceBrowser, 
                                                                           " ", 
                                                                           str_split(deviceBrowserVersion, "[.]")[[1]][1])),
                          resolution = paste0(screenWidthPx, " x ", screenHeightPx),
                          block_condition = ifelse(block_condition == "",staircaseName, block_condition))
        t$system = str_replace_all(t$deviceSystem, "OS X","macOS")
        t$deviceSystemFamily = str_replace_all(t$deviceSystemFamily, "OS X","macOS")
        psychojsWindowDimensions <- lapply(strsplit(t$psychojsWindowDimensions[1],","), parse_number)[1]
        WindowDimensions <- paste0(psychojsWindowDimensions[[1]][1], " x ", psychojsWindowDimensions[[1]][2])
        t$resolution = ifelse(t$resolution[1] == "NA x NA", WindowDimensions, t$resolution)
        t$resolution = ifelse(t$resolution[1] == "NA x NA", "", t$resolution)
        info <- dplyr::filter(t, is.na(questMeanAtEndOfTrialsLoop)) %>% 
          select(block_condition, conditionName) %>% 
          distinct(block_condition, conditionName) %>% 
          dplyr::filter(conditionName != "" & block_condition != "")
        t <- t %>% 
          rename("cores" = "hardwareConcurrency")
        
        info <- t %>% 
          dplyr::filter(is.na(questMeanAtEndOfTrialsLoop)) %>%
          distinct(participant, block_condition, staircaseName, conditionName, 
                   targetKind, font, experiment)
        
        summaries <- t %>% 
          dplyr::filter(!is.na(questMeanAtEndOfTrialsLoop)) %>% 
          select(
            block_condition,
            staircaseName, 
            thresholdParameter,
            questMeanAtEndOfTrialsLoop
          )
        if(n_distinct(summaries$staircaseName) < n_distinct(summaries$block_condition)) {
          summaries <- summaries %>% 
            select(-staircaseName) %>% 
            left_join(info, by = "block_condition")
        } else {
          summaries <- summaries %>% 
            select(-block_condition)
          summaries <- merge(info, summaries, by = ("staircaseName"))
        }
        summary_list[[j]] <- summaries
        data_list[[j]] <- t
        j = j + 1
        t$experiment <- trimws(t$experiment[1])
        experiment[j] <- trimws(t$experiment[1])
        readingCorpus <- c(readingCorpus,unique(t$readingCorpus))
      }
    }
  }
  readingCorpus <- readingCorpus[readingCorpus!="" & !is.na(readingCorpus)]
  experiment <- experiment[!is.na(experiment)]
  experiment <- experiment[experiment!=""]
  return(list(data_list, 
              summary_list, 
              paste(unique(experiment), collapse = "-"),
              paste(unique(readingCorpus), collapse = "-")
  ))
}
