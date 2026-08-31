#' Get state boundary for the CASTool
#'
#' @param state state name
#'
#' @return sf object with state boundary with 300 m buffer
#' @export

getBoundary <- function(state){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  stateAbb <- state.abb[which(state.name == state)]


  state_enc <- URLencode(state, reserved = TRUE)

  #state_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb,"/", state_enc, "_boundary.parquet")
  state_fp <- paste0(get_s3_data(), stateAbb,"/", state_enc, "_boundary.parquet")

  state_fp2 <- file.path(get_s3_data(), stateAbb, paste0(state_enc, "_boundary.parquet"))

  dput(state_fp2)

  state_pq <- sfarrow::st_read_parquet(state_fp2)

  return(state_pq)
}


