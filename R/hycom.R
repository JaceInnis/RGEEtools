.validate_hycom_arguments <- function(ROI, date, interval, scale, depth = NULL) {
  if (is.null(ROI)) {
    stop("`ROI` must be an Earth Engine geometry.", call. = FALSE)
  }
  if (!is.character(date) || length(date) != 1L || is.na(date) ||
      !grepl("^[0-9]{8}$", date)) {
    stop("`date` must be one valid date in YYYYMMDD format.", call. = FALSE)
  }
  parsed_date <- as.Date(date, format = "%Y%m%d")
  if (is.na(parsed_date) || format(parsed_date, "%Y%m%d") != date) {
    stop("`date` must be one valid date in YYYYMMDD format.", call. = FALSE)
  }
  if (!is.numeric(interval) || length(interval) != 1L || is.na(interval) ||
      !is.finite(interval) || interval <= 0 || interval != floor(interval)) {
    stop("`interval` must be one positive whole number of days.",
         call. = FALSE)
  }
  if (!is.numeric(scale) || length(scale) != 1L || is.na(scale) ||
      !is.finite(scale) || scale <= 0) {
    stop("`scale` must be one positive, finite number of meters.",
         call. = FALSE)
  }
  if (!is.null(depth)) {
    valid_depth <- length(depth) == 1L && !is.na(depth) &&
      grepl("^[0-9]+$", as.character(depth))
    if (!valid_depth) {
      stop("`depth` must be one non-negative whole number.", call. = FALSE)
    }
  }
  invisible(parsed_date)
}

.hycom_sample <- function(ROI, date, interval, scale, collection, bands) {
  .validate_hycom_arguments(ROI, date, interval, scale)
  if (!requireNamespace("rgee", quietly = TRUE)) {
    stop("Package `rgee` is required to query Google Earth Engine.",
         call. = FALSE)
  }

  end_date <- as.Date(date, format = "%Y%m%d")
  start_date <- end_date - interval
  rgee::ee$ImageCollection(collection)$
    filterDate(as.character(start_date), as.character(end_date))$
    select(bands)$
    mean()$
    sample(region = ROI, scale = scale, geometries = TRUE, seed = 10)$
    getInfo()
}
