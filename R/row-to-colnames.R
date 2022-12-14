
#' Turn row values into column names
#'
#' @description Data frames sometimes have wrong column names, while the correct
#'   column names are stored in one or more rows in the data frame itself. To
#'   remedy this issue, call `row_to_colnames()` on the data frame: It replaces
#'   the column names by the values of the specified rows (by default, only the
#'   first one). These rows are then dropped by default.
#'
#' @details If multiple rows are specified, the row values for each individual
#'   column are pasted together. Some special characters might then be missing.
#'
#'   This function might be useful when importing tables from PDF, e.g. with
#'   \href{https://cran.r-project.org/package=tabulizer}{tabulizer}. In R, these
#'   data frames (converted from matrices) do sometimes have the issue described
#'   above.
#'
#' @param data Data frame or matrix.
#' @param row Integer. Position of the rows (one or more) that jointly contain
#'   the correct column names. Default is `1`.
#' @param collapse String. If the length of `row` is greater than 1, each new
#'   column name will be that many row values pasted together. `collapse`, then,
#'   is the substring between two former row values in the final column names.
#'   Default is `" "` (a space).
#' @param drop Boolean. If `TRUE` (the default), the rows specified with `row`
#'   are removed.
#'
#' @include utils.R
#'
#' @seealso
#' \href{https://unheadr.liomys.mx/reference/mash_colnames.html}{`unheadr::mash_colnames()`},
#' a more sophisticated solution to the same problem.
#'
#' @return A tibble (data frame).
#' @export

# @examples


row_to_colnames <- function(data, row = 1, collapse = " ", drop = TRUE) {

  # Initial checks ---

  if (!is.data.frame(data)) {
    if (is.matrix(data)) {
      data <- tibble::as_tibble(data)
    } else {
      cli::cli_abort(c(
        "`data` is {an_a_type(data)}",
        "x" = "It needs to be a data frame or a matrix."
      ))
    }
  }

  if (length(row) < 1) {
    cli::cli_abort(c(
      "`row` has length {length(row)}",
      "x" = "It needs to have length 1 or more."
    ))
  }

  if (any(!is_whole_number(row))) {
    row <- wrap_in_backticks(row)
    cli::cli_abort(c(
      "`row` is {row}",
      "x" = "It needs to be a whole number."
    ))
  }


  # Get correct column names ---

  # Restore the vector of correct column names by the values stored in the one
  # or more rows that were specified by the `row` argument:
  correct <- data[row, ]
  correct <- rbind(colnames(data), correct)
  correct <- purrr::map(correct, remove_na)

  correct <- purrr::map(correct, utils::tail, (length(correct[[1]]) - 1))

  # If multiple rows were specified that way, the resulting vector needs to be
  # pasted to one single string per column to restore the correct column names:
  if (length(row) > 1) {
    correct <- purrr::map(correct, paste0, collapse = collapse)
  }


  # Subsequent checks ---

  # Check for empty strings in the "correct" column names:
  correct_is_empty <- stringr::str_length(correct) == 0

  # If any of those strings really are empty, they are unsuitable as column
  # names. An error is then thrown:
  if (any(correct_is_empty)) {
    n_empty <- length(correct_is_empty[correct_is_empty])
    name_names <- dplyr::if_else(n_empty == 1, "name", "names")
    cli::cli_abort(c(
      "{n_empty} empty column {name_names}.",
      "x" = "Each column name must have at least one character.",
      ">" = "Make sure to specify `row` in `row_to_colnames()` accordingly."
    ))
  }


  # Final correction and return ---

  # Reinstate the correct column names:
  colnames(data) <- correct

  # Return the data frame. By default (`drop = TRUE`), remove the specified row
  # or rows beforehand:
  if (drop) {
    return(data[-row, ])
  } else {
    return(data)
  }

}

