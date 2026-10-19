#' Sample HYCOM sea surface elevation
#'
#' Sample mean sea surface elevation for a region and date interval from the
#' HYCOM dataset hosted on Google Earth Engine. The end date is exclusive, as
#' in Earth Engine's `filterDate()` method.
#'
#' @param ROI An Earth Engine geometry defining the sampling region.
#' @param date Date string in `YYYYMMDD` format; this is the exclusive end date
#'   of the averaging interval.
#' @param interval Positive whole number of days before `date` to include.
#' @param scale Positive sampling resolution in meters. Earth Engine may limit
#'   the number of returned points for large regions or fine resolutions.
#'
#' @return The result of Earth Engine's `getInfo()` for a sampled feature
#'   collection.
#' @export
#'
#' @examples
#' \dontrun{
#' region <- ROI()
#' result <- ssetolist(region, "20010928", 5, 30000)
#' }
ssetolist <- function(ROI, date, interval, scale) {
  .hycom_sample(
    ROI, date, interval, scale,
    collection = "HYCOM/sea_surface_elevation",
    bands = "surface_elevation"
  )
}
