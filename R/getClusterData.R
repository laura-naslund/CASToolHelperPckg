#' Get cluster assignment data for the built-in CASTool comparator site assignment method
#'
#' @param state state name
#' @param clustnum desired number of clusters
#'
#' @return a df of cluster assignments for NHDPlusV2 reaches in the state and 300 m boundary
#' @export

getClusterData <- function(state, clustnum){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  stateAbb <- state.abb[which(state.name == state)]

  state_enc <- URLencode(state, reserved = TRUE)

  if(clustnum == "default"){
    pick_raw <- aws.s3::get_object(
      object = paste(get_s3_prefix(), stateAbb, paste0(state_enc, "_pick_list.csv"), sep = "/"),
      bucket = get_s3_bucket()
    )

    default_clust <- read.csv(text = rawToChar(pick_raw)) |> dplyr::pull(fn)

    clust_raw <- 	aws.s3::get_object(
      object = paste(get_s3_prefix(), stateAbb, paste0(default_clust, ".parquet"), sep = "/")|> URLencode(),
      bucket = get_s3_bucket()
    )

    clust_df <- arrow::read_parquet(rawConnection(clust_raw))


  } else{

    contents <- aws.s3::get_bucket_df(
      bucket = get_s3_bucket(),
      prefix = paste(get_s3_prefix(), stateAbb, sep = "/")
    )

    key_str <- contents |>
      dplyr::filter(stringr::str_detect(Key, "ClusterAssignments")) |>
      dplyr::filter(stringr::str_detect(Key, paste0(clustnum, ".parquet"))) |>
      dplyr::pull(Key) |>
      basename() |>
      URLencode(reserved = TRUE)

    clust_raw <- 	aws.s3::get_object(
      object = paste(get_s3_prefix(), stateAbb, key_str, sep = "/")|> URLencode(),
      bucket = get_s3_bucket()
      )

    clust_df <- arrow::read_parquet(rawConnection(clust_raw))

  }

  return(clust_df)

}
#
# getClusterData <- function(state, clustnum){
#   Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")
#
#   stateAbb <- state.abb[which(state.name == state)]
#
#   state_enc <- URLencode(state, reserved = TRUE)
#
#   if(clustnum == "default"){
#     #pick_list_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb,"/", state_enc, "_pick_list.csv")
#     pick_list_fp <- paste0(get_s3_data(), stateAbb,"/", state_enc, "_pick_list.csv")
#     pick_list_fp2 <- file.path(get_s3_data(), stateAbb, paste0(state_enc, "_pick_list.csv"))
#
#
#     default_clust <- arrow::open_dataset(pick_list_fp2, format = "csv") |>
#       dplyr::collect() |>
#       dplyr::pull(fn) |>
#       URLencode(reserved=TRUE)
#
#     #file_str <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb,"/", default_clust, ".parquet")
#     file_str <- paste0(get_s3_data(), stateAbb,"/", default_clust, ".parquet")
#     file_str2 <- file.path(get_s3_data(), stateAbb, paste0(default_clust, ".parquet"))
#
#   } else{
#
#     bucket <- "dmap-data-commons-ow"
#     prefix <- paste0("streamcat/CASTool/", stateAbb) # if problems look here first
#     # prefix <- paste0("data/streamcat/CASTool/", stateAbb)
#
#     contents <- aws.s3::get_bucket_df(
#       bucket = bucket,
#       prefix = prefix
#     )
#
#     key_str <- contents |>
#       dplyr::filter(stringr::str_detect(Key, "ClusterAssignments")) |>
#       dplyr::filter(stringr::str_detect(Key, paste0(clustnum, ".parquet"))) |>
#       dplyr::pull(Key) |>
#       basename() |>
#       URLencode(reserved = TRUE)
#
#     #file_str <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb,"/", key_str)
#     file_str <- paste0(get_s3_data(), stateAbb,"/", key_str)
#     file_str2 <- file.path(get_s3_data(), stateAbb, key_str)
#
#   }
#
#   dput(file_str2)
#
#   ret <- arrow::open_dataset(file_str2) |> dplyr::collect()
#
#   return(ret)
#}
