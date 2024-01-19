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
#' D <- stats::dist(iris[, 1:4])
#' D[2:3, 7:12]
"[.dist" <- function(x, i, j, drop = TRUE, ...) {
  if (missing(i) && missing(j)) {
    return(x)
  }

  N <- attr(x, "Size")
  row_ids <- attr(x, "Labels")
  if (length(row_ids) == 0) {
    row_ids <- 1:N
  }

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

  if (is.logical(i)) {
    i <- which(i)
  }

  if (is.logical(j)) {
    j <- which(j)
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
    cli::cli_abort("The row indices must be all between 1 and {.arg {N}}.")
  }

  if (any(j < 1L) || any(j > N)) {
    cli::cli_abort("The column indices must be all between 1 and {.arg {N}}.")
  }

  common_indices <- intersect(i, j)
  if (length(common_indices) == 0) {
    out <- OffDiagonalSubsetter(x, i, j)
    rownames(out) <- row_ids[i]
    colnames(out) <- row_ids[j]
    return(out)
  }

  i_diff <- setdiff(i, common_indices)
  j_diff <- setdiff(j, common_indices)

  if (length(i_diff) > 0 || length(j_diff) > 0)
    cli::cli_abort(c(
      "The subset opertor only works if the row and column indices are either",
      "all the same or all different."
    ))

  D <- DiagonalSubsetter(x, common_indices)
  attributes(D) <- attributes(x)
  attr(D, "Labels") <- row_ids[common_indices]
  attr(D, "Size") <- length(common_indices)
  class(D) <- "dist"
  D
}
