#' Get StreamCat data for clustering reaches
#'
#' @param state unabbreviated, capitalized, state name
#'
#' @return a wide dataframe of StreamCat variables used in the clustering algorithm for the state (not including the 300 m boundary)
#' @export
getSCClusterData <- function(state){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  if(!(state %in% state.name)){
    stop(paste(state, "is not a valid state name"))
  }

  if(state %in% c("Alaska", "Hawaii")){
    stop(paste(state, "data are not currently available"))
  }

  clust_ret <- data(list = "cluster_vars", package = "CASToolHelperPckg", envir = environment())
  clust_vars <- get(clust_ret, envir = environment())

  clust_vars_vec <- clust_vars |> dplyr::filter(Source == "StreamCat") |> dplyr::pull(Variable)

  stateAbb <- state.abb[which(state.name == state)]

  #state_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool_State_SC/", stateAbb, "_CASTool_StreamCatMetrics.parquet")

  data_raw <- 	aws.s3::get_object(
    object = paste(get_s3_prefix_sc(), paste0(stateAbb, "_CASTool_StreamCatMetrics.parquet"), sep = "/")|> URLencode(),
    bucket = get_s3_bucket()
  )

  data_df <- arrow::read_parquet(rawConnection(data_raw)) |>
    dplyr::select(dplyr::all_of(c("comid", paste0(clust_vars_vec, "ws"))))

  return(data_df)
}
