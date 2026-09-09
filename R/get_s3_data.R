#' Get S3 path for sf
#'
#' @return path to remote storage of CASTool helper data
#' @export
get_s3_data_sf <- function(){
  "https://dmap-data-commons-ow.s3.amazonaws.com/streamcat/CASTool"
}

#' Get s3 bucket
#'
#' @return name of S3 bucket containing CASTool helper data
#' @export
get_s3_bucket <- function(){
  "dmap-data-commons-ow"
}


#' Get s3 prefix
#'
#' @return path to folder within S3 bucket containing most CASTool helper data
#' @export
get_s3_prefix <- function(){
  "streamcat/CASTool"
}

#' Get s3 prefix raw sc
#'
#' @return path to folder within S3 bucket containing relevant StreamCat data
#' @export
get_s3_prefix_sc <- function(){
  "streamcat/CASTool_State_SC"
}
