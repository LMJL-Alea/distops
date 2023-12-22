test_that("dist() works", {
  out <- cars |>
    apply(1, \(x) x, simplify = FALSE) |> # Convert to a list of observations
    dist()
  expect_equal(attr(out, "Size"), 50)
  expect_snapshot(out)
})
