
get_fluency_histogram <- function(fluency){
  if(nrow(fluency) == 0) return(ggplot() + ggtitle('fluency histogram'))
  fluency$accuracy <- factor(fluency$accuracy, levels = c(0,0.2,0.4,0.6,0.8,1))
  ggplot(fluency %>% count(accuracy, .drop = F), aes(x = accuracy, y = n)) +
    geom_bar(stat = "identity") + 
    xlab("fluency (proportion correct)") + 
    ylab("Count")

}

get_reading_retention_histogram <- function(reading) {
  if(nrow(reading) == 0) return(ggplot() + ggtitle('Reading retention histogram'))
  counts <- reading %>% count(accuracy, .drop=F)
  ggplot(counts) + geom_bar(aes(x = accuracy, y = n), stat = "identity") + 
    ylab("Count") +
    xlab("Reading retention (proportion correct)")
}