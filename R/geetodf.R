#' Convert an Earth Engine feature collection to a data frame
#'
#' Extract point coordinates and feature properties from the result returned by
#' one of the `*tolist()` functions. Property columns are combined by name, so
#' features with different property sets retain all available values.
#'
#' @param list A list returned by an `*tolist()` function, containing a
#'   `features` element.
#'
#' @return A data frame with numeric `lon` and `lat` columns followed by the
#'   feature properties. Missing properties are represented by `NA`.
#' @export
#'
#' @examples
#' sample <- list(features = list(
#'   list(geometry = list(coordinates = c(-90, 25)),
#'        properties = list(temperature = 20)),
#'   list(geometry = list(coordinates = c(-89, 26)),
#'        properties = list(temperature = 21))
#' ))
#' geetodf(sample)
geetodf <- function(list) {
  if (!is.list(list) || is.null(list$features) ||
      !is.list(list$features)) {
    stop("`list` must contain a list-valued `features` element.",
         call. = FALSE)
  }

  features <- list$features
  n <- length(features)
  coordinates <- vector("list", n)
  properties <- vector("list", n)

  for (i in seq_len(n)) {
    feature <- features[[i]]
    if (!is.list(feature) || !is.list(feature$geometry)) {
      stop("Every feature must contain a geometry.", call. = FALSE)
    }
    coords <- feature$geometry$coordinates
    if (!is.numeric(coords) || length(coords) < 2L ||
        any(!is.finite(coords[1:2]))) {
      stop("Every feature must have finite numeric longitude and latitude.",
           call. = FALSE)
    }
    coordinates[[i]] <- coords[1:2]

    props <- feature$properties
    if (is.null(props)) {
      props <- list()
    }
    if (!is.list(props)) {
      stop("Feature properties must be a uniquely named list.",
           call. = FALSE)
    }
    if (length(props) > 0L) {
      prop_names <- names(props)
      if (is.null(prop_names) || anyNA(prop_names) ||
          any(!nzchar(prop_names)) || anyDuplicated(prop_names)) {
        stop("Feature properties must be a uniquely named list.",
             call. = FALSE)
      }
    }
    properties[[i]] <- props
  }

  if (n == 0L) {
    return(data.frame(lon = numeric(), lat = numeric()))
  }

  data <- data.frame(
    lon = vapply(coordinates, `[[`, numeric(1), 1L),
    lat = vapply(coordinates, `[[`, numeric(1), 2L)
  )
  property_names <- unique(unlist(lapply(properties, names), use.names = FALSE))
  if (any(property_names %in% c("lon", "lat"))) {
    stop("Feature property names cannot replace the `lon` or `lat` columns.",
         call. = FALSE)
  }

  for (name in property_names) {
    values <- lapply(properties, function(props) {
      value <- props[[name]]
      if (is.null(value)) NA else value
    })
    if (all(vapply(values, function(value) {
      is.atomic(value) && length(value) == 1L
    }, logical(1)))) {
      data[[name]] <- do.call(c, values)
    } else {
      data[[name]] <- I(values)
    }
  }
  data
}
