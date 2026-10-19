test_that("ROI coordinate parsing validates and closes the polygon ring", {
  coordinates <- RGEEtools:::.parse_roi_coordinates(
    "[-91.5, 28], [-91.5, 20], [-80, 20], [-80, 28]"
  )

  expect_length(coordinates, 5)
  expect_identical(coordinates[[1]], coordinates[[5]])
  expect_equal(coordinates[[2]], c(-91.5, 20))
})

test_that("ROI coordinate parsing rejects malformed or out-of-range input", {
  expect_error(
    RGEEtools:::.parse_roi_coordinates("[0, 0], [1, 1], [2, 2] ; stop('bad')"),
    "only coordinate pairs"
  )
  expect_error(
    RGEEtools:::.parse_roi_coordinates("[0, 0], [1, 1]"),
    "at least three"
  )
  expect_error(
    RGEEtools:::.parse_roi_coordinates("[181, 0], [1, 1], [2, 2]"),
    "Longitude"
  )
})

test_that("HYCOM arguments reject malformed dates and invalid ranges", {
  validate <- RGEEtools:::.validate_hycom_arguments

  expect_invisible(validate(ROI = list(), date = "20240229",
                            interval = 5, scale = 30000, depth = 0))
  expect_error(validate(list(), "20230229", 5, 30000), "valid date")
  expect_error(validate(list(), "20240101", 0, 30000), "positive whole")
  expect_error(validate(list(), "20240101", 5, Inf), "positive, finite")
  expect_error(validate(list(), "20240101", 5, 30000, -1), "non-negative")
})
