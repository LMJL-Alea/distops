linear_index <- function(n) {
  res <- expand.grid(j = 1:n, i = 1:n)
  res <- subset(res, res$j > res$i)
  res[, 2:1]
}
