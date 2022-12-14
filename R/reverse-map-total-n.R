
#' Reverse the `*_map_total_n()` process
#'
#' @description `reverse_map_total_n()` takes the output of a function created
#'   by `function_map_total_n()` and reconstructs the original data frame.
#'
#'   See `audit_total_n()`, which takes `reverse_map_total_n()` as a basis.
#'
#' @param data Data frame that inherits the `"scr_map_total_n"` class.
#'
#' @return The reconstructed tibble (data frame) which a factory-made
#'   `*_map_total_n()` function took as its `data` argument.
#'
#' @export
#'
#' @examples
#' # Originally reported summary data...
#' df <- tibble::tribble(
#'   ~x1,    ~x2,   ~n,
#'   "3.43", "5.28", 90,
#'   "2.97", "4.42", 103
#' )
#' df
#'
#' # ...GRIM-tested with dispersed `n` values...
#' out <- grim_map_total_n(df)
#' out
#'
#' # ...and faithfully reconstructed:
#' reverse_map_total_n(out)


reverse_map_total_n <- function(data) {

  if (!inherits(data, "scr_map_total_n")) {
    cli::cli_abort(c(
      "Invalid `data` argument.",
      "x" = "It needs to be the output of a function that ends on \\
      `*_map_seq()`, like `grim_map_seq()`."
    ))
  }

  # Take the first row of each original-`n` block:
  data_reduced <- data %>%
    dplyr::group_by(case) %>%
    dplyr::slice(1:2)

  n_was_even <- data_reduced %>%
    dplyr::summarise(n_sum = sum(n)) %>%
    dplyr::pull(n_sum) %>%
    rep(each = 2) %>%
    is_even()

  # Negate the evenness and convert the results from Boolean to numeric, which
  # returns `0` as a correction for even original `n` values because they don't
  # need to be corrected, and `1` for odd original `n` values, because these
  # ones do need a correction:
  n_was_odd <- as.numeric(!n_was_even)

  data_reduced <- data_reduced %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      n_was_odd, .after = n,
      n = (2 * n) - n_was_odd
    )

  nrow_data_reduced <- nrow(data_reduced)

  locations1 <- seq(from = 1, to = nrow_data_reduced - 1, by = 2)
  locations2 <- seq(from = 2, to = nrow_data_reduced,     by = 2)

  data1 <- data_reduced %>% dplyr::slice(locations1)
  data2 <- data_reduced %>% dplyr::slice(locations2)

  # Number of columns before `n` (i.e., the columns with hypothetical values
  # dispersed from the reported statistics):
  ncol_before_n <- match("n", colnames(data)) - 1

  colnames_reported <- colnames(data_reduced)[1:ncol_before_n]

  data_reported_1 <- data1[, colnames_reported]
  data_reported_2 <- data2[, colnames_reported]

  colnames(data_reported_1) <- paste0(colnames_reported, "1")
  colnames(data_reported_2) <- paste0(colnames_reported, "2")

  colnames_in_order <- colnames_reported %>%
    rep(each = 2) %>%
    paste0(c("1", "2"))

  out <- dplyr::bind_cols(data_reported_1, data_reported_2)

  out <- out %>%
    dplyr::relocate(all_of(colnames_in_order)) %>%
    dplyr::mutate(n = data2$n)

  return(out)
}

