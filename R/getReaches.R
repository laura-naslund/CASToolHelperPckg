#' Get NHDPlusV2 reaches for the CASTool
#'
#' @param state unabbreviated, capitalized, state name
#'
#' @return sf object with NHDPlusV2 reaches within a state boundary with 300 m buffer
#' @export

getReaches <- function(state){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  if(!(state %in% state.name)){
    stop(paste(state, "is not a valid state name"))
  }

  stateAbb <- state.abb[which(state.name == state)]

  state_enc <- URLencode(state, reserved = TRUE)

  state_fp <- paste0(get_s3_data_sf(), "/", stateAbb,"/", state_enc, ".parquet")

  state_pq <- sfarrow::st_read_parquet(state_fp)

  return(state_pq)
}
