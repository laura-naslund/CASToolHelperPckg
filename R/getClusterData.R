#' Get cluster assignment data for the built-in CASTool comparator site assignment method
#'
#' @param state
#' @param clustnum
#'
#' @return a df of cluster assignments for NHDPlusV2 reaches in the state and 300 m boundary

getClusterData <- function(state, clustnum){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  stateAbb <- state.abb[which(state.name == state)]

  if(clustnum == "default"){
    pick_list_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb,"/", state, "_pick_list.csv")

    default_clust <- arrow::open_dataset(pick_list_fp, format = "csv") |>
      dplyr::collect() |>
      dplyr::pull(fn)

    file_str <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb,"/", default_clust, ".parquet")

  } else{

    bucket <- "dmap-data-commons-ow"
    prefix <- "streamcat/CASTool/AL"

    contents <- aws.s3::get_bucket_df(
      bucket = bucket,
      prefix = prefix
    )

    key_str <- contents |>
      dplyr::filter(stringr::str_detect(Key, "ClusterAssignments")) |>
      dplyr::filter(stringr::str_detect(Key, paste0(clustnum, ".parquet"))) |>
      dplyr::pull(Key)

    file_str <- paste0("s3://dmap-data-commons-ow/", key_str)

  }

  ret <- arrow::open_dataset(file_str) |> dplyr::collect()

  return(ret)
}
