#' Get NHDPlusV2 reaches for the CASTool
#'
#' @param state statename
#'
#' @return sf object with NHDPlusV2 reaches within a state boundary with 300 m buffer
#' @export

getReaches <- function(state){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  stateAbb <- state.abb[which(state.name == state)]

  state_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb,"/", state, ".parquet")

  state_pq <- sfarrow::st_read_parquet(state_fp)

  return(state_pq)
}
