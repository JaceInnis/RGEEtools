#' Sample HYCOM salinity
#'
#' Sample mean salinity at a given depth for a region and date interval from
#' the HYCOM dataset hosted on Google Earth Engine. The end date is exclusive.
#'
#' @param ROI An Earth Engine geometry defining the sampling region.
#' @param date Date string in `YYYYMMDD` format; the exclusive end date of the
#'   averaging interval.
#' @param interval Positive whole number of days before `date` to include.
#' @param scale Positive sampling resolution in meters.
#' @param depth Non-negative whole-number depth used to select the HYCOM band.
#'   The requested depth must be available in the upstream dataset.
#'
#' @return The result of Earth Engine's `getInfo()` for a sampled feature
#'   collection.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' region <- ROI()
#' result <- wstolist(region, "20010928", 5, 30000, depth = 10)
#' }
wstolist <- function(ROI, date, interval, scale, depth) {
  .validate_hycom_arguments(ROI, date, interval, scale, depth)
  .hycom_sample(
    ROI, date, interval, scale,
    collection = "HYCOM/sea_temp_salinity",
    bands = paste0("salinity_", depth)
  )
}
