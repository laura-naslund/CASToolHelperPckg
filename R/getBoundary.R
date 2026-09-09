#' Get state boundary for the CASTool
#'
#' @param state unabbreviated, capitalized, state name
#'
#' @return sf object of state boundary with 300 m buffer
#' @export

getBoundary <- function(state){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  if(!(state %in% state.name)){
    stop(paste(state, "is not a valid state name"))
  }

  if(state %in% c("Alaska", "Hawaii")){
    stop(paste(state, "data are not currently available"))
  }

  stateAbb <- state.abb[which(state.name == state)]

  state_enc <- URLencode(state, reserved = TRUE)

  state_fp <- paste0(get_s3_data_sf(), "/", stateAbb,"/", state_enc, "_boundary.parquet")

  state_pq <- sfarrow::st_read_parquet(state_fp)

  return(state_pq)
}
