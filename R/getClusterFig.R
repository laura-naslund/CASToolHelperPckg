#' Get clustering figure for the built-in CASTool comparator site assignment method
#'
#' @param state state name
#' @param clustnum desired number of clusters
#'
#' @return png of clustering results figure with the requested number of clusters
#' @export

getClusterFig <- function(state, clustnum){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  stateAbb <- state.abb[which(state.name == state)]

  state_enc <- URLencode(state, reserved = TRUE)

  if(clustnum == "default"){
    pick_list_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb,"/", state_enc, "_pick_list.csv")

    default_clust <- arrow::open_dataset(pick_list_fp, format = "csv") |>
      dplyr::collect() |>
      dplyr::pull(fn) |>
      stringr::str_replace("Assignments", "Graphics") |>
      URLencode(reserved = TRUE)

    fig_key_str <- paste0("streamcat/CASTool/", stateAbb,"/", default_clust, ".png")

  } else{

    bucket <- "dmap-data-commons-ow"
    prefix <- paste0("streamcat/CASTool/", stateAbb)

    contents <- aws.s3::get_bucket_df(
      bucket = bucket,
      prefix = prefix
    )

    key_str <- contents |>
      dplyr::filter(stringr::str_detect(Key, "ClusterGraphics")) |>
      dplyr::filter(stringr::str_detect(Key, paste0(clustnum, ".png"))) |>
      dplyr::pull(Key) |>
      basename() |>
      URLencode(reserved = TRUE)

    fig_key_str <- paste0("streamcat/CASTool/", stateAbb,"/", key_str)

  }

  return(fig_key_str)
}
