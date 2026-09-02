#' Get S3 path for sf
#'
#' @return
#' @export
#'
#' @examples
get_s3_data_sf <- function(){
  "https://dmap-data-commons-ow.s3.amazonaws.com/streamcat/CASTool"

  #"https://dmap-data-commons-ow.s3.amazonaws.com/streamcat/CASTool"
  # old
  #"s3://dmap-data-commons-ow/streamcat/CASTool"
  #  "s3://dmap-data-commons-ow/streamcat/CASTool/"
  #"https://dmap-data-commons-ow.s3.us-east-1.amazonaws.com/index.html#streamcat/"
  # new
  #"https://dmap-data-commons-ow.s3.us-east-1.amazonaws.com/index.html#data/streamcat/"
}

#
# get_s3_data <- function(){
#   "s3://dmap-data-commons-ow/streamcat/CASTool"
# }

#' Get s3 bucket
#'
#' @return
#' @export
#'
#' @examples
get_s3_bucket <- function(){
  "dmap-data-commons-ow"
}


#' Get s3 prefix
#'
#' @return
#' @export
#'
#' @examples
get_s3_prefix <- function(){
  "streamcat/CASTool"
}

#' Get s3 prefix raw sc
#'
#' @return
#' @export
#'
#' @examples
get_s3_prefix_sc <- function(){
  "streamcat/CASTool_State_SC"
}
