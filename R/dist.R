#' Distance Matrix Computation
#'
#' @description Computes and returns the distance matrix computed by using the
#'   specified distance measure to compute the distances between the rows of a
#'   data matrix.
#'
#' @param x A list of objects of the same class.
#' @param FUN A function used to compute the distances between observations in
#'   sample `x`.
#' @param labels A character vector of labels for the rows of the distance
#'   matrix. If `NULL`, the row names of `x` are used if they exist. Otherwise,
#'   integer labels are used.
#' @param ... Additional arguments passed to `FUN`.
#'
#' @return A [`stats::dist`] object.
#' @export
#'
#' @examples
#' cars |>
#'   apply(1, \(.x) .x, simplify = FALSE) |> # Convert to a list of observations
#'   dist()
dist <- function(x, FUN = \(.x, .y) sqrt(sum(.x - .y)^2), labels = NULL, ...) {
  if (!is.list(x))
    cli::cli_abort("The argument {.arg x} must be a list.")

  N <- length(x)
  obj_class <- class(x[[1]])
  if (N > 1) {
    for (n in seq_len(N)) {
      if (class(x[[n]]) != obj_class)
        cli::cli_abort("The argument {.arg x} must be a list of objects of the same class.")
    }
  }

  if (is.null(labels)) {
    if (length(names(x)) == N) {
      labels <- names(x)
    } else {
      labels <- 1:N
    }
  }

  index_table <- linear_index(N)

  .pairwise_distances <- function(index_table) {
    pb <- progressr::progressor(steps = nrow(index_table))
    furrr::future_map2_dbl(index_table$i, index_table$j, \(i, j) {
      pb()
      FUN(x[[i]], x[[j]], ...)
    }, .options = furrr::furrr_options(seed = TRUE))
  }

  out <- .pairwise_distances(index_table)
  attributes(out) <- NULL
  attr(out, "Labels") <- labels
  attr(out, "Size") <- N
  attr(out, "Diag") <- FALSE
  attr(out, "Upper") <- FALSE
  attr(out, "call") <- match.call()
  class(out) <- "dist"

  out
}
