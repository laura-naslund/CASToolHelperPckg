#' Get StreamCat data for clustering reaches
#'
#' @param state
#'
#' @return a wide dataframe of StreamCat variables used in the clustering algorithm for the state (not including the 300 m boundary)
#' @export
getSCClusterData <- function(state){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  clust_ret <- data(list = "cluster_vars", package = "CASToolHelperPckg", envir = environment())
  clust_vars <- get(clust_ret, envir = environment())

  clust_vars_vec <- clust_vars |> dplyr::filter(Source == "StreamCat") |> dplyr::pull(Variable)

  stateAbb <- state.abb[which(state.name == state)]

  state_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool_State_SC/", stateAbb, "_CASTool_StreamCatMetrics.parquet")

  state_pq <- arrow::open_dataset(state_fp) |>
    dplyr::collect() |>
    dplyr::select(dplyr::all_of(c("comid", paste0(clust_vars_vec, "ws"))))

  return(state_pq)
}
