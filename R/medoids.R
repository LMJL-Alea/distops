#' Finds the medoids from a distance matrix
#'
#' @description This function finds the medoids from a distance matrix. The
#'   medoid is the object that minimizes the sum of distances to all other
#'   objects. This function takes advantage of the **RcppParallel** package to
#'   compute the medoids in parallel.
#'
#' @param D An object of class [`stats::dist`].
#' @param memberships A factor specifying the cluster memberships of the
#'   objects.
#'
#' @return A named integer vector specifying the indices of the medoids.
#' @export
#'
#' @examples
#' D <- stats::dist(iris[, 1:4])
#' find_medoids(D)
#' memberships <- as.factor(rep(1:3, each = 50L))
#' find_medoids(D, memberships)
find_medoids <- function(D, memberships = NULL) {
  if (!inherits(D, "dist"))
    cli::cli_abort("The input argument {.arg D} must be of class {.cls dist}.")
  if (is.null(memberships))
    return(GetMedoid(D))
if (!is.factor(memberships))
    cli::cli_abort("The input argument {.arg memberships} must be of class {.cls factor}.")
  out <- GetMedoids(D, as.numeric(memberships))
  names(out) <- levels(memberships)
  out
}
