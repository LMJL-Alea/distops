test_that("Subset operator works", {
  D <- stats::dist(iris[, 1:4])
  expect_error(D[1:4, 2:7])
  Dsub <- D[1:3, 1:3]
  expect_equal(class(Dsub), "dist")
  Dsub <- D[1:3, 4:6]
  expect_equal(class(Dsub), c("matrix", "array"))
})
