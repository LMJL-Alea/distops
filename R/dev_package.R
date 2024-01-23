#' Setups package to use the **distops** package
#'
#' @description This function setups the package to use the **distops** package.
#'   It first creates the `DESCRIPTION` file adding the **Rcpp** and
#'   **RcppParallel** packages to both the `Imports:` and `LinkingTo:` fields
#'   and the **distops** package to the `LinkingTo:` field. It also adds the
#'   `SystemRequirements: GNU make` field. It then creates the `NAMESPACE` file
#'   adding the `importFrom()` directives for the **Rcpp** and **RcppParallel**
#'   packages and the `useDynLib()` directive for packages with compiled code.
#'   It finally creates the `src/Makevars` and `src/Makevars.win` files with the
#'   appropriate compilation flags.
#'
#' @return Nothing.
#' @export
#'
#' @examples
#' \donttest{
#' use_distops()
#' }
use_distops <- function() {
  if (length(list.files(path = "pathname", pattern = "\\.Rproj$")) == 0) return()
  desc_path <- paste0(usethis::proj_path(), "/DESCRIPTION")
  if (!fs::file_exists(desc_path)) return()

  # Check if backup files are present
  backup_files <- fs::dir_ls(
    path = usethis::proj_path(),
    type = "file",
    glob = "*.bak",
    recurse = TRUE
  )
  if (length(backup_files) > 0) {
    usethis::ui_stop(
      "Backup files are present in the project directory. Please remove them ",
      "before running this function."
    )
  }

  desc_class <- desc::desc(usethis::proj_get())
  package_name <- desc_class$get_field("Package")

  # Setup DESCRIPTION file
  usethis::use_directory("src")
  usethis::use_git_ignore(c("*.o", "*.so", "*.dll"), "src")
  fs::file_delete(paste0(usethis::proj_path(), "/DESCRIPTION"))
  fields <- lapply(desc_class$fields(), \(.x) desc_class$get_field(.x))
  names(fields) <- desc_class$fields()
  imports <- strsplit(fields$Imports, ", ")[[1]]
  imports <- sort(unique(c(imports, "Rcpp", "RcppParallel")))
  fields$Imports <- paste(imports, collapse = ", ")
  linkingto <- strsplit(fields$LinkingTo, ", ")[[1]]
  linkingto <- sort(unique(c(linkingto, "Rcpp", "RcppParallel", "distops")))
  fields$LinkingTo <- paste(linkingto, collapse = ", ")
  systemreqs <- strsplit(fields$SystemRequirements, ", ")[[1]]
  systemreqs <- sort(unique(c(systemreqs, "GNU make")))
  fields$SystemRequirements <- paste(systemreqs, collapse = ", ")
  usethis::use_description(fields = fields)

  # Setup NAMESPACE file
  package_doc_file <- paste0(
    usethis::proj_path(),
    glue::glue("/R/{package_name}-package.R")
  )
  handle_existing_file(package_doc_file)
  usethis::use_template(
    template = "packagename-package.R",
    save_as = glue::glue("R/{package_name}-package.R"),
    data = list(Package = package_name),
    open = FALSE,
    package = "distops"
  )

  # Setup Makevars files
  makevars_file <- paste0(usethis::proj_path(), "/src/Makevars")
  handle_existing_file(makevars_file)
  usethis::use_template(
    template = "makevars",
    save_as = glue::glue("src/Makevars"),
    open = FALSE,
    package = "distops"
  )
  makevars_win_file <- paste0(usethis::proj_path(), "/src/Makevars.win")
  handle_existing_file(makevars_win_file)
  usethis::use_template(
    template = "makevars_win",
    save_as = glue::glue("src/Makevars.win"),
    open = FALSE,
    package = "distops"
  )

  # Remove useless backup files
  backup_files <- fs::dir_ls(
    path = usethis::proj_path(),
    type = "file",
    glob = "*.bak",
    recurse = TRUE
  )
  for (bf in backup_files) {
    f <- fs::path_ext_remove(bf)
    if (fs::file_exists(f) && tools::md5sum(f) == tools::md5sum(bf))
      fs::file_delete(bf)
  }
}

handle_existing_file <- function(file) {
  if (!fs::file_exists(file)) return()
  old_file <- paste0(file, ".bak")
  if (fs::file_exists(old_file) && tools::md5sum(file) == tools::md5sum(old_file))
    fs::file_delete(old_file)
  else
    usethis::ui_stop(c(
      'The {usethis::ui_path(file)} file already existed and a backup file',
      '{usethis::ui_path(old_file)} has also been create. Please review and',
      'remove it and try again.'
    ))
  fs::file_copy(file, old_file, overwrite = TRUE)
  usethis::ui_info(c(
    'The {usethis::ui_path(file)} file already existed. A backup was created',
    'at {usethis::ui_path(old_file)}.'
  ))
  fs::file_delete(file)
  usethis::ui_todo(c(
    'Make sure to merge the {usethis::ui_path(old_file)} file into the',
    '{usethis::ui_path(file)} file.'
  ))
}

cap <- function(x) {
  x <- tolower(x)
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

#' Adds a distance function to the package
#'
#' @description This function adds a distance function to the package. It first
#'   creates the `R/{distance_name}Distance.R` file with the R wrapper function
#'   for the distance function. It then creates the
#'   `src/{distance_name}Distance.cpp` file with the C++ implementation of the
#'   distance function. It finally opens the latter file in the default editor.
#'   The user will be able to implement the desired distance function in a way
#'   compatible with the **RcppParallel** workflow.
#'
#' @param distance_name A character string specifying the name of the distance
#'   that the user aims at implementing.
#'
#' @return Nothing.
#' @export
#'
#' @examples
#' \donttest{
#' use_distance("euclidean")
#' }
use_distance <- function(distance_name) {
  if (length(list.files(path = "pathname", pattern = "\\.Rproj$")) == 0) return()
  desc_path <- paste0(usethis::proj_path(), "/DESCRIPTION")
  if (!fs::file_exists(desc_path)) return()

  distance_name <- cap(distance_name)
  usethis::use_template(
    template = "dist.R",
    save_as = glue::glue("R/{distance_name}Distance.R"),
    data = list(DistanceName = distance_name),
    open = FALSE,
    package = "distops"
  )
  # Call usethis::use_template() to create and open a .cpp file in the src/
  # directory where the user will be able to implement the desired distance
  # function in a way compatible with RcppParallel.
  usethis::use_template(
    template = "dist.cpp",
    save_as = glue::glue("src/{distance_name}Distance.cpp"),
    data = list(DistanceName = distance_name),
    open = TRUE,
    package = "distops"
  )
}
