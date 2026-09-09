#' Get watershed stressor data
#'
#' @param state unabbreviated, capitalized, state name
#'
#' @return dataframe with watershed stressor summary metrics from StreamCat for NHDPlusV2 reaches in the state and 300 m boundary
#' @export

getWSStressorData <- function(state){
  Sys.setenv("AWS_EC2_METADATA_DISABLED" = "true")

  if(!(state %in% state.name)){
    stop(paste(state, "is not a valid state name"))
  }

  if(state %in% c("Alaska", "Hawaii")){
    stop(paste(state, "data are not currently available"))
  }

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
