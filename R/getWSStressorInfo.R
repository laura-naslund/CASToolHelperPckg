#' Get watershed stressor metadata
#'
#' @return df of watershed stressor metadata
#' @export
#'
getWSStressorInfo <- function(){
  ret <- data(list = "ws_stressors", package = "CASToolHelperPckg", envir = environment())
  ret_data <- get(ret, envir = environment())
  return(ret_data)
}
