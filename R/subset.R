#' Distance Matrix Subset Operator
#'
#' @description Subset operator for the distance matrix stored as an object of
#'   class [`stats::dist`].
#'
#' @param x An object of class [`stats::dist`].
#' @param i An integer vector of row indices. Values must be either all positive
#'   in which case they indicate the rows to select, or all negative in which
#'   case they indicate the rows to omit.
#' @param j An integer vector of column indices. Values must be either all
#'   positive in which case they indicate the columns to select, or all negative
#'   in which case they indicate the columns to omit.
#' @param drop A logical value indicating whether the result should be coerced
#'   to a vector or matrix if possible.
#' @param ... Additional arguments passed to `[.dist`.
#'
#' @return A numeric matrix storing the pairwise distances between the requested
#'   observations.
#' @export
#'
#' @examples
#' D <- cars |>
#'  apply(1, \(.x) .x, simplify = FALSE) |> # Convert to a list of observations
#'  dist()
#' D[2:3, 7:12]
"[.dist" <- function(x, i, j, drop = TRUE, ...) {
  if (missing(i) && missing(j)) {
    return(as.matrix(x))
  }

  N <- attr(x, "Size")
  labels <- attr(x, "Labels")

  if (missing(i)) {
    i <- seq_len(N)
  }

  if (missing(j)) {
    j <- seq_len(N)
  }

  if (is.numeric(i)) {
    i <- as.integer(i)
  }

  if (is.numeric(j)) {
    j <- as.integer(j)
  }

  if (is.null(i)) {
    i <- seq_len(N)
  }

  if (is.null(j)) {
    j <- seq_len(N)
  }

  if (any(i < 0)) {
    if (!all(i < 0)) {
      cli::cli_abort("The row indices must be all non-negative or all negative.")
    }
    i <- seq_len(N)[i]
  }

  if (any(j < 0)) {
    if (!all(j < 0)) {
      cli::cli_abort("The column indices must be all non-negative or all negative.")
    }
    j <- seq_len(N)[j]
  }

  if (any(i < 1L) || any(i > N)) {
    cli::cli_abort("The row indices must be all between 1 and {.arg N}.")
  }

  if (any(j < 1L) || any(j > N)) {
    cli::cli_abort("The column indices must be all between 1 and {.arg N}.")
  }

  index_table <- linear_index(N)
  x <- as.numeric(x)

  out <- expand.grid(j = j, i = i)
  out <- out[, 2:1]

  out <- furrr::future_map2_dbl(out$i, out$j, \(.i, .j) {
    if (.i == .j)
      return(0)
    idx <- if (.i > .j)
      which(index_table$i == .j & index_table$j == .i)
    else
      which(index_table$i == .i & index_table$j == .j)
    x[idx]
  }, .options = furrr::furrr_options(seed = TRUE))

  out <- matrix(out, nrow = length(i), ncol = length(j), byrow = TRUE)
  colnames(out) <- labels[j]
  rownames(out) <- labels[i]
  out
}
