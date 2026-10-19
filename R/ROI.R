#' Create a Google Earth Engine polygon from coordinate pairs
#'
#' Convert comma-separated `[longitude, latitude]` pairs, such as those copied
#' from the Earth Engine Code Editor, into an `ee$Geometry$Polygon`.
#'
#' @param stri Character scalar containing at least three longitude/latitude
#'   pairs. Coordinates may be separated by commas or whitespace.
#'
#' @return An Earth Engine polygon geometry.
#' @export
#'
#' @examples
#' \dontrun{
#' region <- ROI("[-91.157, 28.628], [-91.157, 20.977],
#'               [-80.433, 20.977], [-80.434, 28.628]")
#' }
ROI <- function(stri = paste(
  "[117.83526716151925, 15.49233818000526],",
  "[117.83526716151925, 6.486174330165204],",
  "[129.74444684901925, 6.486174330165204],",
  "[129.74444684901925, 15.49233818000526]"
)) {
  if (!is.character(stri) || length(stri) != 1L || is.na(stri) ||
      !nzchar(trimws(stri))) {
    stop("`stri` must be a non-empty character scalar.", call. = FALSE)
  }

  coordinates <- .parse_roi_coordinates(stri)
  if (!requireNamespace("rgee", quietly = TRUE)) {
    stop("Package `rgee` is required to create an Earth Engine geometry.",
         call. = FALSE)
  }
  rgee::ee$Geometry$Polygon(coordinates)
}

.parse_roi_coordinates <- function(stri) {
  number <- "[-+]?(?:[0-9]+\\.?[0-9]*|\\.[0-9]+)(?:[eE][-+]?[0-9]+)?"
  pair_pattern <- paste0(
    "\\[\\s*", number, "\\s*,\\s*", number, "\\s*\\]"
  )
  locations <- gregexpr(pair_pattern, stri, perl = TRUE)
  pairs <- regmatches(stri, locations)[[1L]]
  remainder <- gsub(pair_pattern, "", stri, perl = TRUE)
  remainder <- gsub("[[:space:],]", "", remainder)

  if (!length(pairs) || nzchar(remainder)) {
    stop(
      "`stri` must contain only coordinate pairs in [longitude, latitude] format.",
      call. = FALSE
    )
  }
  if (length(pairs) < 3L) {
    stop("A polygon requires at least three coordinate pairs.", call. = FALSE)
  }

  coordinates <- lapply(pairs, function(pair) {
    pair <- substring(pair, 2L, nchar(pair) - 1L)
    pair <- gsub("[[:space:]]", "", pair)
    as.numeric(strsplit(pair, ",", fixed = TRUE)[[1L]])
  })
  longitudes <- vapply(coordinates, `[[`, numeric(1), 1L)
  latitudes <- vapply(coordinates, `[[`, numeric(1), 2L)
  if (any(!is.finite(longitudes)) || any(!is.finite(latitudes))) {
    stop("Coordinates must be finite numbers.", call. = FALSE)
  }
  if (any(longitudes < -180 | longitudes > 180) ||
      any(latitudes < -90 | latitudes > 90)) {
    stop("Longitude must be in [-180, 180] and latitude in [-90, 90].",
         call. = FALSE)
  }

  first <- coordinates[[1L]]
  if (!identical(first, coordinates[[length(coordinates)]])) {
    coordinates <- c(coordinates, list(first))
  }
  coordinates
}
