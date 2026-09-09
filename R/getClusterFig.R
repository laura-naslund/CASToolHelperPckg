#' Get clustering figure for the built-in CASTool comparator site assignment method
#'
#' @param state unabbreviated, capitalized, state name
#' @param clustnum desired number of clusters (default or 1 through 5)
#'
#' @return png of clustering results figure with the requested number of clusters
#' @export

getClusterFig <- function(state, clustnum){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

   if(!(state %in% state.name)){
    stop(paste(state, "is not a valid state name"))
  }

  if(state %in% c("Alaska", "Hawaii")){
    stop(paste(state, "data are not currently available"))
  }

  if(!(as.character(clustnum) %in% c("default", 1:5))){
    stop(paste(clustnum, "is not a valid cluster number"))
  }

  stateAbb <- state.abb[which(state.name == state)]

  state_enc <- URLencode(state, reserved = TRUE)

  if(clustnum == "default"){
    pick_raw <- aws.s3::get_object(
      object = paste(get_s3_prefix(), stateAbb, paste0(state_enc, "_pick_list.csv"), sep = "/"),
      bucket = get_s3_bucket()
    )

    default_clust <- read.csv(text = rawToChar(pick_raw)) |>
      dplyr::pull(fn) |>
      stringr::str_replace("Assignments", "Graphics") |>
      URLencode(reserved = TRUE)

    fig_key_str <- paste0(get_s3_prefix(), "/", stateAbb,"/", default_clust, ".png")

  } else{

    contents <- aws.s3::get_bucket_df(
      bucket = get_s3_bucket(),
      prefix = paste(get_s3_prefix(), stateAbb, sep = "/")
    )

    key_str <- contents |>
      dplyr::filter(stringr::str_detect(Key, "ClusterGraphics")) |>
      dplyr::filter(stringr::str_detect(Key, paste0(clustnum, ".png"))) |>
      dplyr::pull(Key) |>
      basename() |>
      URLencode(reserved = TRUE)

    fig_key_str <- paste0(get_s3_prefix(), "/", stateAbb,"/", key_str)

  }

  return(fig_key_str)
}
