#' Computes the pairwise distances between the rows of a data matrix using the
#'  {{{ DistanceName }}} distance
#'
#' @description This function computes and returns the pairwise distance matrix
#'   between the rows of a data matrix using the {{{ DistanceName }}} distance
#'   encapsulated in the [`{{{ DistanceName }}}DistanceClass`] C++ class. It
#'   takes advantage of the **RcppParallel** package to compute the distance
#'   matrix in parallel. The latter is returned as an object of class
#'   [`stats::dist`].
#'
#' @param x A numeric matrix specifying the data matrix. Rows correspond to
#'  observations and columns correspond to variables.
#' @param row_ids A character vector of labels for the rows of the distance
#'   matrix. If `NULL`, the row names of `x` are used if they exist. Otherwise,
#'   integer labels are used. Defaults to `NULL`.
#'
#' @return An object of class [`stats::dist`].
#' @export
#'
#' @examples
#' D <- {{{ DistanceName }}}Distance(iris[, 1:4])
{{{ DistanceName }}}Distance <- function(x, row_ids = NULL) {
  x <- as.matrix(x)
  N <- nrow(x)
  if (is.null(row_ids)) {
    if (length(rownames(x)) == N) {
      row_ids <- rownames(x)
    } else {
      row_ids <- 1:N
    }
  }
  out <- Get{{{ DistanceName }}}DistanceMatrix(x)
  attributes(out) <- NULL
  attr(out, "Labels") <- row_ids
  attr(out, "Size") <- N
  attr(out, "Diag") <- FALSE
  attr(out, "Upper") <- FALSE
  attr(out, "call") <- match.call()
  attr(out, "method") <- "{{{ DistanceName }}}"
  class(out) <- "dist"
  out
}
