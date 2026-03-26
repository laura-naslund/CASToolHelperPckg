#' Get watershed stressor metadata
#'
#' @return df of watershed stressor metadata
#' @export
#'
getWSStressorInfo <- function(){
  fp_ws_stressors <- system.file("data-raw", "WSStressorInfo.csv", package = "CASToolHelperPckg")
  ws_stressors <- read.csv(fp_ws_stressors)
  return(ws_stressors)
}
