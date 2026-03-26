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

  state_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool_State_SC/", stateAbb, "_CASTool_StreamCatMetrics.parquet")
  boundary_fp <- paste0("s3://dmap-data-commons-ow/streamcat/CASTool/", stateAbb, "/", stateAbb, "_WSStressor_border_wide.parquet")

  state_pq <- arrow::open_dataset(state_fp) |>
    dplyr::collect() |>
    dplyr::select(!dplyr::ends_with(".x")) |>
    dplyr::rename_with(~ stringr::str_remove(.x, "\\.y$"), .cols = dplyr::ends_with(".y")) |>
    dplyr::rename_all(~ stringr::str_remove(.x, "ws$")) |>
    dplyr::select(dplyr::all_of(c("comid", ws_stressors_vec)))

  boundary_pq <- arrow::open_dataset(boundary_fp) |>
    dplyr::collect() |>
    dplyr::rename_all(~ stringr::str_remove(.x, "ws$")) |>
    dplyr::select(dplyr::all_of(c("comid", ws_stressors_vec)))

  ret <- state_pq |>
    dplyr::bind_rows(boundary_pq)|>
    tidyr::pivot_longer(cols = !comid, names_to = "SCmetrics", values_to = "WatershedValue") |>
    dplyr::left_join(ws_stressors, by = "SCmetrics") |>
    dplyr::select(comid, StreamCatVar, WatershedValue, Year) |>
    dplyr::rename("COMID" = "comid")

  return(ret)
}
