test_that("Subset operator works", {
  D <- stats::dist(iris[, 1:4])
  Dsub <- D[1:4, 2:7]
  expect_equal(length(Dsub), 3L)
  expect_equal(names(Dsub), c("D", "R", "C"))
  expect_equal(attr(Dsub$D, "Size"), 3L)
  expect_equal(dim(Dsub$R), c(1L, 6L))
  expect_equal(dim(Dsub$C), c(4L, 3L))
  expect_snapshot(Dsub)
})
