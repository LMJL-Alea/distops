test_that("Subset operator works", {
  D <- cars |>
    apply(1, \(x) x, simplify = FALSE) |> # Convert to a list of observations
    dist()
  expect_equal(dim(D[2:3, 7:12]), c(2L, 6L))
})
