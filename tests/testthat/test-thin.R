test_that("thin returns indices for every by-th coordinate", {
  grid <- expand.grid(lon = 1:4, lat = 1:4)
  original <- grid
  indices <- thin(grid, by = 2)

  expect_type(indices, "integer")
  expect_equal(
    unname(as.matrix(grid[indices, ])),
    unname(as.matrix(expand.grid(lon = c(1, 3), lat = c(1, 3))))
  )
  expect_identical(grid, original)
})

test_that("thin validates inputs and handles empty data frames", {
  expect_equal(thin(data.frame(lon = numeric(), lat = numeric()), 1), integer())
  expect_error(thin(data.frame(x = 1), 1), "lon")
  expect_error(thin(data.frame(lon = "1", lat = 1), 1), "must be numeric")
  expect_error(thin(data.frame(lon = 1, lat = 1), 0), "positive whole")
})
