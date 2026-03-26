#' Get watershed stressor metadata
#'
#' @return df of watershed stressor metadata
#' @export
#'
getWSStressorInfo <- function(){
  ws_stressors <- read.csv("data-raw/WSStressorInfo.csv")
  return(ws_stressors)
}
