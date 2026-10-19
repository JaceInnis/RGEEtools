test_that("geetodf combines feature coordinates and properties", {
  result <- geetodf(list(features = list(
    list(
      geometry = list(coordinates = c(-90, 25)),
      properties = list(temperature = 20, salinity = 35)
    ),
    list(
      geometry = list(coordinates = c(-89, 26)),
      properties = list(temperature = 21)
    )
  )))

  expect_equal(result$lon, c(-90, -89))
  expect_equal(result$lat, c(25, 26))
  expect_equal(result$temperature, c(20, 21))
  expect_equal(result$salinity, c(35, NA_real_))
})

test_that("geetodf handles empty collections and rejects malformed input", {
  expect_equal(
    geetodf(list(features = list())),
    data.frame(lon = numeric(), lat = numeric())
  )
  expect_error(geetodf(list()), "features")
  expect_error(
    geetodf(list(features = list(list(geometry = list(coordinates = c(1)))))),
    "finite numeric longitude and latitude"
  )
  expect_error(
    geetodf(list(features = list(
      list(
        geometry = list(coordinates = c(1, 2)),
        properties = list(lon = 3)
      )
    ))),
    "cannot replace"
  )
})
