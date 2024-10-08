
#' GRIM-test many cases at once
#'
#' @description Call `grim_map()` to GRIM-test any number of combinations of
#'   mean/proportion, sample size, and number of items. Mapping function for
#'   GRIM-testing.
#'
#'   Set `percent` to `TRUE` if the `x` values are percentages. This will
#'   convert `x` values to decimals and adjust the decimal count accordingly.
#'
#'   Display intermediary numbers from GRIM-testing in columns by setting
#'   `show_rec` to `TRUE`.
#'
#'   For summary statistics, call [`audit()`] on the results.
#'
#' @param data Data frame with columns `x`, `n`, and optionally `items` (see
#'   documentation for [`grim()`]. By default, any other columns in `data` will
#'   be returned alongside GRIM test results (see `extra` below).
#' @param items Integer. If there is no `items` column in `data`, this specifies
#'   the number of items composing the `x` values. Default is 1, the most common
#'   case.
#' @param merge_items Logical. If `TRUE` (the default), there will be no `items`
#'   column in the output. Instead, values from an `items` column or argument
#'   will be multiplied with values in the `n` column. This is only for
#'   presentation and does not affect test results.
#' @param percent Logical. Set `percent` to `TRUE` if the `x` values are
#'   percentages. This will convert them to decimal numbers and adjust the
#'   decimal count (i.e., increase it by 2). It also affects the `ratio` column.
#'   Default is `FALSE`.
#' @param x,n Optionally, specify these arguments as column names in `data`.
#' @param show_rec Logical. If set to `TRUE`, the reconstructed numbers from
#'   GRIM-testing are shown as columns. See section *Reconstructed numbers*
#'   below. Default is `FALSE`.
#' @param show_prob `r lifecycle::badge("deprecated")` Logical. No longer
#'   supported: now, there is always a `probability` column. (It replaces the
#'   earlier `ratio` column.)
#' @param rounding,threshold,symmetric,tolerance Further parameters of
#'   GRIM-testing; see documentation for [`grim()`].
#' @param testables_only Logical. If `testables_only` is set to `TRUE`, only
#'   GRIM-testable cases (i.e., those with a positive GRIM ratio) are included.
#'   Default is `FALSE`.
#' @param extra String or integer. The other column(s) from `data` to be
#'   returned in the output tibble alongside test results, referenced by their
#'   name(s) or number(s). Default is `Inf`, which returns all columns. To
#'   return none of them, set `extra` to 0.

#' @return A tibble with these columns --
#' - `x`, `n`: the inputs.
#' - `consistency`: GRIM consistency of `x`, `n`, and `items`.
#' - `probability`: the probability of GRIM inconsistency; see
#' [`grim_probability()`].
#' - `<extra>`: any columns from `data` other than `x`, `n`, and `items`.
#'
#'   The tibble has the `scr_grim_map` class, which is recognized by the
#'   [`audit()`] generic.

#' @section Reconstructed numbers: If `show_rec` is set to `TRUE`, the output
#'   includes the following additional columns:
#'
#' - `rec_sum`: the sum total from which the mean or proportion was ostensibly
#'   derived.
#' - `rec_x_upper`: the upper reconstructed `x` value.
#' - `rec_x_lower`: the lower reconstructed `x` value.
#' - `rec_x_upper_rounded`: the rounded `rec_x_upper` value.
#' - `rec_x_lower_rounded`: the rounded `rec_x_lower` value.
#'
#' With the default for `rounding`, `"up_or_down"`, each of the last two columns
#' is replaced by two columns that specify the rounding procedures (i.e.,
#' `"_up"` and `"_down"`).

#' @section Summaries with [`audit()`]: There is an S3 method for [`audit()`],
#'   so you can call [`audit()`] following `grim_map()` to get a summary of
#'   `grim_map()`'s results. It is a tibble with one row and these columns --
#'
#' 1. `incons_cases`: number of GRIM-inconsistent value sets.
#' 2. `all_cases`: total number of value sets.
#' 3. `incons_rate`: proportion of GRIM-inconsistent value sets.
#' 4. `mean_grim_prob`: average probability of GRIM inconsistency.
#' 5. `incons_to_prob`: ratio of `incons_rate` to `mean_grim_prob`.
#' 6. `testable_cases`: number of GRIM-testable value sets (i.e., those with a
#' positive `probability`).
#' 7. `testable_rate`: proportion of GRIM-testable value sets.

#' @include audit.R grim.R manage-extra-cols.R restore-zeros.R

#' @references Brown, N. J. L., & Heathers, J. A. J. (2017). The GRIM Test: A
#'   Simple Technique Detects Numerous Anomalies in the Reporting of Results in
#'   Psychology. *Social Psychological and Personality Science*, 8(4), 363–369.
#'   https://journals.sagepub.com/doi/10.1177/1948550616673876
#'
#' @export
#'
#' @examples
#' # Use `grim_map()` on data like these:
#' pigs1
#'
#' # The `consistency` column shows
#' # whether the values to its left
#' # are GRIM-consistent:
#' pigs1 %>%
#'   grim_map()
#'
#' # Display intermediary numbers from
#' # GRIM-testing with `show_rec = TRUE`:
#' pigs1 %>%
#'   grim_map(show_rec = TRUE)
#'
#' # Get summaries with `audit()`:
#' pigs1 %>%
#'   grim_map() %>%
#'   audit()


# Note: All the arguments passed on to the internal testing function
# `grim_scalar()` are listed here as well as in the internal call to
# `purrr::pmap_lgl(grim)` or `purrr::pmap(grim)` instead of simply being passed
# via `...` so that starting to type them will trigger RStudio's autocomplete.


grim_map <- function(data, items = 1, merge_items = TRUE, percent = FALSE,
                     x = NULL, n = NULL, show_rec = FALSE,
                     show_prob = deprecated(),
                     rounding = "up_or_down", threshold = 5,
                     symmetric = FALSE, tolerance = .Machine$double.eps^0.5,
                     testables_only = FALSE, extra = Inf) {

  # If any two arguments called right below are length > 1, they need to have
  # the same length. Otherwise, the call will fail. But even so, there will be a
  # warning that values will get paired:
  check_lengths_congruent(list(
    items, percent, rounding, threshold, symmetric, tolerance
  ))

  # Warn if the user specified a deprecated argument:
  if (lifecycle::is_present(show_prob)) {
    lifecycle::deprecate_warn(
      when = "0.5.0",
      what = "grim_map(show_prob)",
      details = c(
        "The \"probability\" column has replaced the \\
        \"ratio\" column, so now it is always displayed, \\
        and `show_prob` no longer has any effect."
      )
    )
  }

  # Check if the user specified the arguments named after the key columns, `x`
  # and `n`. If so, the user-supplied value for that argument will be checked
  # against the column names of `data`. If the value is one of those column
  # names, that column is renamed to the respective key argument. Otherwise,
  # there is an error.
  if (!missing(x)) {
    x <- rlang::enexpr(x)
    data <- manage_key_colnames(data, x, "mean/proportion")
  }

  if (!missing(n)) {
    n <- rlang::enexpr(n)
    data <- manage_key_colnames(data, n, "sample size")
  }


  # TODO: Optimize `grim_map()` for performance!


  # Check the column names of `data`:
  check_mapper_input_colnames(data, c("x", "n"), "GRIM")
  check_tibble(data)

  data <- manage_helper_col(data = data, var_arg = items, default = 1)

  # Create `other_cols`, which contains all extra columns from `data` (i.e.,
  # those which play no role in the GRIM test), and run it through a specified
  # helper function:
  other_cols <- manage_extra_cols(
    data, extra, dplyr::select(data, -x, -n, -items)
  )

  # Prepare a data frame for the GRIM computations below (steps 4 and 5):
  data_x_n_items <- dplyr::select(data, x, n, items)


  # Create the columns of the resulting tibble --

  # 1.-3.: Define `x`, `n`, and `items` as the respective columns from `data`
  # (these only come into play in the resulting tibble). The `items` column is
  # disabled by default of `merge_items`. Instead, its values are merged into
  # the `n` column:
  x <- data$x

  if (merge_items) {
    n <- data$n * data$items
  } else {
    n <- tibble::tibble(n = data$n, items = data$items)
  }

  # 4.: GRIM-test all sets of `x`, `n`, and `items` by mapping `grim_scalar()`.
  # Instead of using the dots, `...`, the function manually passes the remaining
  # arguments down to `grim_scalar()` so that starting to type these arguments
  # will trigger RStudio's autocomplete. The particular mapping function,
  # `purrr::pmap_lgl()` or `purrr::pmap()`, depends on whether intermediary
  # numbers were chosen to be shown in the resulting tibble because the former
  # only returns a logical value whereas the latter returns a list:
  if (show_rec) {
    consistency <- purrr::pmap(
      data_x_n_items, grim_scalar, percent = percent,
      show_rec = show_rec, rounding = rounding,
      threshold = threshold, symmetric = symmetric,
      tolerance = tolerance
    )
  } else {
    consistency <- purrr::pmap_lgl(
      data_x_n_items, grim_scalar, percent = percent,
      show_rec = show_rec, rounding = rounding,
      threshold = threshold, symmetric = symmetric,
      tolerance = tolerance
    )
  }

  # 5.: Compute the GRIM probabilities for all of the same value sets via
  # `grim_probability()`, which also gets the `percent` argument passed on to:
  probability <- purrr::pmap_dbl(
    .l = data_x_n_items,
    .f = grim_probability,
    percent = percent
  )

  # 6.-?: Any number of other columns from `data` (via the `other_cols` object).


  # Create a tibble with results that also includes extra columns from the input
  # data frame (`other_cols`) unless the `extra` argument has been set to 0 --
  if (is.null(extra)) {
    # (Number:)               1  2       3            4
    results <- tibble::tibble(x, n, consistency, probability)
  } else {
    # (Number:)               1  2       3            4          5(-?)
    results <- tibble::tibble(x, n, consistency, probability, other_cols)
  }

  # In case the user had set `show_rec` to `TRUE` for displaying the
  # reconstructed values from `grim_scalar()`'s internal computations, these
  # were stored in `consistency` until now. The `consistency` column, then, is a
  # list-column of 6 or 8 values per cell, depending on `rounding`. These
  # numbers are now unnested (i.e., turned into their own columns) and
  # given their respective proper names:
  if (show_rec) {
    # The first four names are common to both the short and the long version:
    name1 <- "consistency"
    name2 <- "rec_sum"
    name3 <- "rec_x_upper"
    name4 <- "rec_x_lower"
    length_2ers <- c("up_or_down", "up_from_or_down_from", "ceiling_or_floor")
    if (any(rounding %in% length_2ers)) {
      rounding_split <- rounding %>%
        stringr::str_split("_or_") %>%
        unlist(use.names = FALSE)
      # These names are for the long version only; the short version has
      # different names 5 and 6, and it has no names 7 and 8 at all:
      name5 <- paste0("rec_x_upper_rounded_", rounding_split[1L])
      name6 <- paste0("rec_x_upper_rounded_", rounding_split[2L])
      name7 <- paste0("rec_x_lower_rounded_", rounding_split[1L])
      name8 <- paste0("rec_x_lower_rounded_", rounding_split[2L])
      col_names <- c(
        name1, name2, name3, name4,
        name5, name6, name7, name8
      )
    } else {
      # The alternative names 5 and 6 for the short version:
      name5 <- "rec_x_upper_rounded"
      name6 <- "rec_x_lower_rounded"
      col_names <- c(
        name1, name2, name3, name4,
        name5, name6  # no 7 and 8 here!
      )
    }

    results <- results %>%
      unnest_consistency_cols(col_names, index = TRUE) %>%
      dplyr::relocate(probability, .after = consistency)
  }

  # Prepare to add the "scr_grim_map" class that `audit()` will recognize, as
  # well as a class that is informative about the rounding procedure used for
  # reconstructing `x`:
  classes_to_add <- c("scr_grim_map", paste0("scr_rounding_", rounding))

  # Mediate between `seq_endpoint_df()` or `seq_distance_df()`, on the one hand,
  # and `seq_test_ranking()`, on the other:
  if (inherits(data, "scr_seq_df")) {
    classes_to_add <- c("scr_seq_test", classes_to_add)
  }

  class(results) <- c(classes_to_add, class(results))

  # If `x` is a percentage, divide it by 100 to adjust its value. The resulting
  # decimal numbers will then be the values actually used in GRIM-testing; i.e.,
  # within `grim_scalar()`. Also, issue an alert to the user about the
  # percentage conversion:
  if (percent) {
    digits_original <- decimal_places(results$x)

    results$x <- as.numeric(results$x) / 100
    results$x <- results$x %>%
      restore_zeros(width = digits_original + 2L) %>%
      suppressWarnings()

    class(results) <- c("scr_percent_true", class(results))
    cli::cli_alert_info("`x` converted from percentage")
  }

  # Finally, return either all of the results or only the GRIM-testable ones:
  if (testables_only) {
    dplyr::filter(results, probability > 0)
  } else {
    results
  }

}

