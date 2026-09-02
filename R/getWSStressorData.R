#' Get watershed stressor data
#'
#' @param state state name
#'
#' @return df with watershed stressor summary metrics from StreamCat for NHDPlusV2 reaches in the state and 300 m boundary
#' @export

getWSStressorData <- function(state){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  ws_ret <- data(list = "ws_stressors", package = "CASToolHelperPckg", envir = environment())
  ws_stressors <- get(ws_ret, envir = environment())

  ws_stressors_vec <- ws_stressors |> dplyr::pull(SCmetrics)

  stateAbb <- state.abb[which(state.name == state)]

  state_raw <- 	aws.s3::get_object(
    object = paste(get_s3_prefix_sc(), paste0(stateAbb, "_CASTool_StreamCatMetrics.parquet"), sep = "/")|> URLencode(),
    bucket = get_s3_bucket()
  )

  state_df <- arrow::read_parquet(rawConnection(state_raw)) |>
    dplyr::select(!dplyr::ends_with(".x")) |>
    dplyr::rename_with(~ stringr::str_remove(.x, "\\.y$"), .cols = dplyr::ends_with(".y")) |>
    dplyr::rename_all(~ stringr::str_remove(.x, "ws$")) |>
    dplyr::select(dplyr::all_of(c("comid", ws_stressors_vec)))

  boundary_raw <- aws.s3::get_object(
    object = paste0(get_s3_prefix(), "/", stateAbb, "/", stateAbb, "_WSStressor_border_wide.parquet")|> URLencode(),
    bucket = get_s3_bucket()
  )

  boundary_df <- arrow::read_parquet(rawConnection(boundary_raw)) |>
    dplyr::rename_all(~ stringr::str_remove(.x, "ws$")) |>
    dplyr::select(dplyr::all_of(c("comid", ws_stressors_vec)))

  ret <- state_df |>
    dplyr::bind_rows(boundary_df)|>
    tidyr::pivot_longer(cols = !comid, names_to = "SCmetrics", values_to = "WatershedValue") |>
    dplyr::left_join(ws_stressors, by = "SCmetrics") |>
    dplyr::select(comid, StreamCatVar, WatershedValue, Year) |>
    dplyr::rename("COMID" = "comid")

  return(ret)
}

# getWSStressorData <- function(state){
#   Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")
#
#   ws_ret <- data(list = "ws_stressors", package = "CASToolHelperPckg", envir = environment())
#   ws_stressors <- get(ws_ret, envir = environment())
#
#   ws_stressors_vec <- ws_stressors |> dplyr::pull(SCmetrics)
#
#   stateAbb <- state.abb[which(state.name == state)]
#
#   state_fp <- paste0(get_s3_data() |> dirname(), "/CASTool_State_SC/", stateAbb, "_CASTool_StreamCatMetrics.parquet")
#   state_fp2 <- file.path(get_s3_data() |> dirname(), "CASTool_State_SC", paste0(stateAbb, "_CASTool_StreamCatMetrics.parquet"))
#
#   boundary_fp <- paste0(get_s3_data(), stateAbb, "/", stateAbb, "_WSStressor_border_wide.parquet")
#   boundary_fp2 <- file.path(get_s3_data(), stateAbb, paste0(stateAbb, "_WSStressor_border_wide.parquet"))
#
#   dput(state_fp2)
#
#   dput(boundary_fp2)
#
#   # state_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool_State_SC/", stateAbb, "_CASTool_StreamCatMetrics.parquet")
#   # boundary_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb, "/", stateAbb, "_WSStressor_border_wide.parquet")
#   #
#   state_pq <- arrow::open_dataset(state_fp2) |>
#     dplyr::collect() |>
#     dplyr::select(!dplyr::ends_with(".x")) |>
#     dplyr::rename_with(~ stringr::str_remove(.x, "\\.y$"), .cols = dplyr::ends_with(".y")) |>
#     dplyr::rename_all(~ stringr::str_remove(.x, "ws$")) |>
#     dplyr::select(dplyr::all_of(c("comid", ws_stressors_vec)))
#
#   boundary_pq <- arrow::open_dataset(boundary_fp2) |>
#     dplyr::collect() |>
#     dplyr::rename_all(~ stringr::str_remove(.x, "ws$")) |>
#     dplyr::select(dplyr::all_of(c("comid", ws_stressors_vec)))
#
#   ret <- state_pq |>
#     dplyr::bind_rows(boundary_pq)|>
#     tidyr::pivot_longer(cols = !comid, names_to = "SCmetrics", values_to = "WatershedValue") |>
#     dplyr::left_join(ws_stressors, by = "SCmetrics") |>
#     dplyr::select(comid, StreamCatVar, WatershedValue, Year) |>
#     dplyr::rename("COMID" = "comid")
#
#   return(ret)
# }

