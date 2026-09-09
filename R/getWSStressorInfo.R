#' Get watershed stressor metadata
#'
#' @return dataframe of watershed stressor metadata
#' @export
#'
getWSStressorInfo <- function(){
  ret <- data(list = "ws_stressors", package = "CASToolHelperPckg", envir = environment())
  ret_data <- get(ret, envir = environment())
  return(ret_data)
}
