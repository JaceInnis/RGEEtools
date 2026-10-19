#' Select a regularly thinned set of grid rows
#'
#' Return row indices whose longitude and latitude are each among every
#' `by`-th sorted unique coordinate. The input data frame is not modified.
#'
#' @param df Data frame containing numeric `lon` and `lat` columns.
#' @param by Positive whole-number spacing between selected unique coordinate
#'   values.
#'
#' @return Integer row indices into `df`.
#' @export
#'
#' @examples
#' grid <- expand.grid(lon = 1:4, lat = 1:4)
#' thin(grid, by = 2)
thin <- function(df, by) {
  if (!is.data.frame(df) || !all(c("lon", "lat") %in% names(df))) {
    stop("`df` must be a data frame with `lon` and `lat` columns.",
         call. = FALSE)
  }
  if (!is.numeric(df$lon) || !is.numeric(df$lat)) {
    stop("`df$lon` and `df$lat` must be numeric.", call. = FALSE)
  }
  if (!is.numeric(by) || length(by) != 1L || is.na(by) ||
      !is.finite(by) || by < 1 || by != floor(by)) {
    stop("`by` must be one positive whole number.", call. = FALSE)
  }
  if (nrow(df) == 0L) {
    return(integer())
  }

  longitudes <- sort(unique(df$lon[is.finite(df$lon)]))
  latitudes <- sort(unique(df$lat[is.finite(df$lat)]))
  if (!length(longitudes) || !length(latitudes)) {
    return(integer())
  }
  selected_longitudes <- longitudes[seq.int(1L, length(longitudes), by = by)]
  selected_latitudes <- latitudes[seq.int(1L, length(latitudes), by = by)]
  as.integer(which(df$lon %in% selected_longitudes &
                   df$lat %in% selected_latitudes))
}
