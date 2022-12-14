
# Helper; not exported:
manage_key_args <- function(key_args) {
  key_args_bt <- wrap_in_backticks(key_args) # function from utils.R
  vars <- commas_and(key_args_bt)    # function from utils.R

  arg1 <- key_args[1]
  arg2 <- key_args[2]

  arg1_bt <- key_args_bt[1]
  arg2_bt <- key_args_bt[2]

  if (length(key_args) == 2) {
    var_ge_3 <- ""
    var_ge_3_line <- ""
  } else {
    var_ge_3 <- key_args[-(1:2)]  # used to be: `key_args_bt[-(1:2)]`
    var_ge_3_line <- "#'   - Accordingly for {commas_and(var_ge_3)}."
  }

  list(arg1, arg2, arg1_bt, arg2_bt, vars, var_ge_3)
}



# Helper; not exported:
manage_var_ge_3 <- function(var_ge_3, prefix, suffix, segway = "as well as") {

  for (i in seq_along(prefix)) {
    if (prefix[i] != "") {
      prefix[i] <- paste0(prefix[i], "_")
    }
  }

  for (i in seq_along(suffix)) {
    if (suffix[i] != "") {
      suffix[i] <- paste0("_", suffix[i])
    }
  }


  if (all(var_ge_3 != "")) {
    if (length(var_ge_3) == 1) {
      var_ge_3_line <- glue::glue(
        "`{prefix}{var_ge_3}{suffix}`"  # used to have: `hits_{var_ge_3}`
      )
      var_ge_3_line <- commas_and(var_ge_3_line)
      var_ge_3_line <- paste(wrap_in_backticks(var_ge_3), "and", var_ge_3_line)
      var_ge_3_line <- paste(segway, var_ge_3_line)
    } else {
      var_ge_3_line <- glue::glue("`{var_ge_3}` and `{prefix}{var_ge_3}{suffix}`")
      var_ge_3_line_without_last <- paste(
        var_ge_3_line[1:(length(var_ge_3_line) - 1)],
        collapse = "; "
      )
      var_ge_3_line <- glue::glue(
        " {segway} {var_ge_3_line_without_last}; \\
      and finally {var_ge_3_line[length(var_ge_3_line)]}"
      )
    }
  } else {
    var_ge_3_line <- ""
  }

  return(var_ge_3_line)
}





#' Documentation template for `audit()`
#'
#' @description `write_doc_audit()` creates a roxygen2 block section to be
#'   inserted into the documentation of a mapper function such as `grim_map()`
#'   or `debit_map()`: functions for which there are, or should be, `audit()`
#'   methods. The section informs users about the ways in which `audit()`
#'   summarizes the results of the respective mapper function.
#'
#'   Copy the output from your console and paste it into the roxygen2 block of
#'   your `*_map()` function. To preserve the numbered list structure when
#'   indenting roxygen2 comments with `Ctrl`+`Shift`+`/`, leave empty lines
#'   between the pasted output and the rest of the block.
#'
#' @param sample_output Data frame. Result of a call to `audit()` on a data
#'   frame that resulted from a call to the mapper function for which you wrote
#'   the `audit()` method, such as `audit(grim_map(pigs1))` or
#'   `audit(debit_map(pigs3))`.
#' @param name_test String (length 1). Name of the consistency test which the
#'   mapper function applies, such as `"GRIM"` or `"DEBIT"`.
#'
#' @export
#'
#' @return A string vector formatted by `glue::glue()`.
#'
#' @examples
#' # Start by running `audit()`:
#' out_grim  <- audit(grim_map(pigs1))
#' out_debit <- audit(debit_map(pigs3))
#'
#' out_grim
#' out_debit
#'
#' # Documenting the `audit()` method for `grim_map()`:
#' write_doc_audit(sample_output = out_grim, name_test = "GRIM")
#'
#' # Documenting the `audit()` method for `debit_map()`:
#' write_doc_audit(sample_output = out_debit, name_test = "DEBIT")


write_doc_audit <- function(sample_output, name_test) {

  check_class(sample_output, "data.frame")
  check_class(sample_output, "tbl_df")
  check_length(name_test, 1)

  if (length(sample_output) < 3) {
    cli::cli_abort(c(
      "Invalid `sample_output` argument.",
      "x" = "It needs to be the output of `audit()` applied \\
      to a scrutiny-style mapper function, such as `grim_map()`.",
      ">" = "(These outputs always have at least three columns.)",
      ">" = "Create it like this:",
      "pigs1 %>%
           grim_map() %>%
           audit() %>%
           write_doc_audit(name_test = \"GRIM\")"
    ))
  }

  output_name <- colnames(sample_output)
  output_number <- 1:length(output_name)
  output_text <- c(
    glue::glue("number of {name_test}-inconsistent value sets."),
    "total number of value sets.",
    glue::glue("proportion of {name_test}-inconsistent value sets.")
  )

  length_other_cols <- length(sample_output) - 3
  output_text <- append(output_text, rep("", length_other_cols))

  output_name_expected <- c("incons_cases", "all_cases", "incons_rate")

  if (any(output_name[1:3] != output_name_expected)) {
    cli::cli_abort(c(
      "Invalid output names.",
      "x" = "The first three columns in the output need to be named \\
      \"incons_cases\", \"all_cases\", and \"incons_rate\"."
    ))
  }

  name_test_lower <- tolower(name_test)

  if (nrow(sample_output) == 1) {
    msg_nrow <- "a single row"
  } else {
    msg_nrow <- paste(nrow(sample_output), "rows")
  }

  intro <- glue::glue(
    "#' @section Summaries with `audit()`: There is an S3 method for `audit()`, so \n",
    "#'   you can call `audit()` following `{name_test_lower}_map()` to get a summary of \n",
    "#'   `{name_test_lower}_map()`'s results. It is a tibble with {msg_nrow} and these \n",
    "#'   columns -- \n",
    "#' \n"
  )

  line <- "#' {output_number}. `{output_name}`: {output_text}\n"
  lines_all <- glue::glue(line)

  out <- c(intro, lines_all)
  out <- glue::as_glue(out)
  out
}




#' Documentation template for `audit_seq()`
#'
#' @description `write_doc_audit_seq()` creates a roxygen2 block section to be
#'   inserted into the documentation of functions created with
#'   `function_map_seq()`. The section informs users about the ways in which
#'   `audit_seq()` summarizes the results of the manufactured `*_map_seq()`
#'   function.
#'
#'   Copy the output from your console and paste it into the roxygen2 block of
#'   your `*_map_seq()` function. To preserve the bullet-point structure when
#'   indenting roxygen2 comments with `Ctrl`+`Shift`+`/`, leave empty lines
#'   between the pasted output and the rest of the block.
#'
#' @param key_args String vector with the names of the key columns that are
#'   tested for consistency by the `*_map_seq()` function. The values need to
#'   have the same order as in that function's output.
#' @param name_test String (length 1). Name of the consistency test which the
#'   `*_map_seq()` function applies, such as `"GRIM"`.
#'
#' @include utils.R
#'
#' @export
#'
#' @return A string vector formatted by `glue::glue()`.
#'
#' @seealso The sister function `write_doc_audit_total_n()` and, for context,
#'   `vignette("consistency-tests")`.
#'
#' @examples
#' # For GRIM and `grim_map_seq()`:
#' write_doc_audit_seq(key_args = c("x", "n"), name_test = "GRIM")
#'
#' # For DEBIT and `debit_map_seq()`:
#' write_doc_audit_seq(key_args = c("x", "sd", "n"), name_test = "DEBIT")


write_doc_audit_seq <- function(key_args, name_test) {

  check_length(name_test, 1)

  key_args_list <- manage_key_args(key_args)

  arg1 <- key_args_list[1]
  arg2 <- key_args_list[2]
  arg1_bt <- key_args_list[3]
  arg2_bt <- key_args_list[4]
  vars <- key_args_list[5]
  var_ge_3 <- key_args_list[6][[1]]

  var_ge_3_line_hits <- manage_var_ge_3(
    var_ge_3, prefix = "hits", suffix = "", segway = "as well as"
  )

  if (var_ge_3_line_hits != "") {
    var_ge_3_line_hits <- paste0(" ", var_ge_3_line_hits)
  }

  suffix <- c("", "up", "down")
  # var_ge_3_line_diff <- ""

  semicolons_as_well_as <- function(x) {
    x[-length(x)] <- paste0(x[-length(x)], "; ")
    x[length(x)]  <- paste0("as well as ", x[length(x)])
    stringr::str_flatten(x)
  }

  if (all(var_ge_3 == "")) {
    var_ge_3_line_diff <- ""
  } else {
    var_ge_3_line_diff <- purrr::map(var_ge_3, ~ paste0("diff_", .))
    var_ge_3_line_diff <- purrr::map(var_ge_3_line_diff, paste0, c("", "_up", "_down"))
    var_ge_3_line_diff <- purrr::map(var_ge_3_line_diff, list(wrap_in_backticks, commas_and))
    if (all(length(var_ge_3) > 1)) {
      var_ge_3_line_diff <- semicolons_as_well_as(var_ge_3_line_diff)
    }
    var_ge_3_line_diff <- paste0(" Likewise with ", var_ge_3_line_diff, ".")
  }

  var_ge_3_line_diff_all <-
    "#'   - `diff_{arg2}`, `diff_{arg2}_up`, and `diff_{arg2}_down` do the same for {arg2_bt}. \n"

  if (var_ge_3_line_diff != "") {
    var_ge_3_line_diff_all <- paste0(var_ge_3_line_diff_all, "#'   - {var_ge_3_line_diff} \n")
  }

  glue::glue(
    "#' @section Summaries with `audit_seq()`: You can call `audit_seq()` following \n",
    "#'   `{tolower(name_test)}_map_seq()`. It will return a data frame with these columns: \n",
    "#'   - {vars} are the original inputs, \n",
    "#'   tested for `consistency` here. \n",
    "#'   - `hits_total` is the total number of {name_test}-consistent value sets \n" ,
    "#'   found within the specified `dispersion` range. \n",
    "#'   - `hits_{arg1}` is the number of {name_test}-consistent value sets \n",
    "#'   found by varying {arg1_bt}. \n",
    "#'   - Accordingly with {arg2_bt} and `hits_{arg2}`{var_ge_3_line_hits}. \n",
    "#'   - (Note that any consistent reported cases will be counted by the \n",
    "#'   `hits_*` columns if both `include_reported` and `include_consistent` \n",
    "#'   are set to `TRUE`.) \n",
    "#'   - `diff_{arg1}` reports the absolute difference between {arg1_bt} and the next \n",
    "#'   consistent dispersed value (in dispersion steps, not the actual numeric \n"   ,
    "#'   difference). `diff_{arg1}_up` and `diff_{arg1}_down` report the difference to the \n",
    "#'   next higher or lower consistent value, respectively. \n",
    var_ge_3_line_diff_all,
    "#' \n",
    "#'   Call `audit()` following `audit_seq()` to summarize results even further. \n"
  )
}





#' Documentation template for `audit_total_n()`
#'
#' @description `write_doc_audit_total_n()` creates a roxygen2 block section to
#'   be inserted into the documentation of functions created with
#'   `function_map_total_n()`. The section informs users about the ways in which
#'   `audit_seq()` summarizes the results of the manufactured `*_map_total_n()`
#'   function.
#'
#'   Copy the output from your console and paste it into the roxygen2 block of
#'   your `*_map_total_n()` function. To preserve the bullet-point structure
#'   when indenting roxygen2 comments with `Ctrl`+`Shift`+`/`, leave empty lines
#'   between the pasted output and the rest of the block.
#'
#' @param key_args String vector with the names of the key columns that are
#'   tested for consistency by the `*_map_seq()` function. (These are the
#'   original variable names, without `"1"` and `"2"` suffixes.) The values need
#'   to have the same order as in that function's output.
#' @param name_test String (length 1). Name of the consistency test which the
#'   `*_map_seq()` function applies, such as `"GRIM"`.
#'
#' @export
#'
#' @return A string vector formatted by `glue::glue()`.
#'
#' @seealso The sister function `write_doc_audit_seq()` and, for context,
#'   `vignette("consistency-tests")`.
#'
#' @examples
#' # For GRIM and `grim_map_total_n()`:
#' write_doc_audit_total_n(key_args = c("x", "n"), name_test = "GRIM")
#'
#' # For DEBIT and `debit_map_total_n()`:
#' write_doc_audit_total_n(key_args = c("x", "sd", "n"), name_test = "DEBIT")


write_doc_audit_total_n <- function(key_args, name_test) {

  # Checks ---

  check_length(name_test, 1)

  if (!length(key_args) > 1) {
    cli::cli_abort(c(
      "`key_args` must have length > 1.",
      "x" = "Consistency testing requires at least two values."
    ))
  }

  if (key_args[length(key_args)] != "n") {
    cli::cli_abort(c(
      "`\"n\"` missing from `key_args`.",
      "x" = "It needs to be the last value in `key_args`."
    ))
  }


  # Main part ---

  key_args_num <- key_args[-length(key_args)]
  key_args_num <- key_args_num %>%
    rep(each = 2) %>%
    paste0(c("1", "2")) %>%
    wrap_in_backticks()

  key_args_num1 <- key_args_num[stringr::str_detect(key_args_num, "1")]
  key_args_num2 <- key_args_num[stringr::str_detect(key_args_num, "2")]

  key_args_num_commas  <- commas_and(key_args_num)
  key_args_num1_commas <- commas_and(key_args_num1)
  key_args_num2_commas <- commas_and(key_args_num2)

  key_args_all <- append(key_args_num, "`n`")
  key_args_all_commas <- commas_and(key_args_all)

  key_args_bt <- wrap_in_backticks(key_args)
  vars <- commas_and(key_args_bt)

  name_test_lower <- tolower(name_test)

  if (length(key_args_num) == 2) {
    both_all_of <- "both"
  } else {
    both_all_of <- "all of"
  }

  if (length(key_args_num1) == 1) {
    is_are_nums <- "is"
  } else {
    is_are_nums <- "are"
  }

  if (length(key_args_num1) == 1) {
    and_as_well_as <- "and"
  } else {
    and_as_well_as <- "as well as"
  }


  # Return documentation section:
  glue::glue(
    "#' @section Summaries with `audit_total_n()`: You can call \n",
    "#'   `audit_total_n()` following up on `{name_test_lower}_map_total_n()` \n",
    "#'   to get a tibble with summary statistics. It will have these columns: \n",
    "#'  - {key_args_all_commas} are the original inputs. \n",
    "#'  - `hits_total` is the number of scenarios in which {both_all_of} \n",
    "#'  {key_args_num_commas} are {name_test}-consistent. It is the sum \n",
    "#'  of `hits_forth` and `hits_back` below. \n",
    "#'  - `hits_forth` is the number of both-consistent cases that result \n",
    "#'  from pairing {key_args_num2_commas} with the larger dispersed `n` value. \n",
    "#'  - `hits_back` is the same, except {key_args_num1_commas} {is_are_nums} \n",
    "#'  paired with the larger dispersed `n` value. \n",
    "#'  - `scenarios_total` is the total number of test scenarios, \n",
    "#'  whether or not both {key_args_num1_commas} {and_as_well_as} {key_args_num2_commas} \n",
    "#'  are {name_test}-consistent. \n",
    "#'  - `hit_rate` is the ratio of `hits_total` to `scenarios_total`. \n",
    "#' \n",
    "#'  Call `audit()` following `audit_total_n()` to summarize results \n",
    "#'  even further. \n"
  )
}






#' Documentation template for `*_map()` function factory conventions
#'
#' @description `write_doc_factory_map_conventions()` creates a roxygen2 block
#'   section to be inserted into the documentation of a function factory such as
#'   `function_map_seq()` or `function_map_total_n()`. It lays out the naming
#'   guidelines that users of your function factory should follow when creating
#'   new manufactured functions.
#'
#'   Copy the output from your console and paste it into the roxygen2 block of
#'   your function factory.
#'
#' @param ending String (length 1). The part of your function factory's name
#'   after `function_map_`.
#' @param name_test1,name_test2 Strings (length 1). Plain-text names of example
#'   consistency tests. Defaults are `"GRIM"` and `"DEBIT"`, respectively.
#'
#' @export
#'
#' @return A string vector formatted by `glue::glue()`.
#'
#' @seealso For context, see `vignette("consistency-tests")`.
#'
#' @examples
#' # For `function_map_seq()`:
#' write_doc_factory_map_conventions(ending = "seq")
#'
#' # For `function_map_total_n()`:
#' write_doc_factory_map_conventions(ending = "total_n")


write_doc_factory_map_conventions <- function(ending, name_test1 = "GRIM",
                                              name_test2 = "DEBIT") {

  # Checks ---
  check_length(ending, 1)
  check_length(name_test1, 1)
  check_length(name_test2, 1)

  # Main part ---

  name_test1_lower <- tolower(name_test1)
  name_test2_lower <- tolower(name_test2)

  # Return documentation section:
  glue::glue(
    "#' @section Conventions: The name of a function manufactured with \n",
    "#'   `function_map_{ending}()` should mechanically follow from that of the input \n",
    "#'   function. For example, `{name_test1_lower}_map_{ending}()` derives from `{name_test1_lower}_map()`. \n",
    "#'   This pattern fits best if the input function itself is named after the test \n",
    "#'   it performs on a data frame, followed by `_map`: `{name_test1_lower}_map()` applies {name_test1}, \n",
    "#'   `{name_test2_lower}_map()` applies {name_test2}, etc. \n",
    "#' \n",
    "#'   Much the same is true for the classes of data frames returned by the \n",
    "#'   manufactured function via the `.name_class` argument of \n",
    "#'   `function_map_{ending}()`. It should be the function's own name preceded by \n",
    "#'   the name of the package that contains it or by an acronym of that package's \n",
    "#'   name. In this way, existing classes are `scr_{name_test1_lower}_map_{ending}` and \n",
    "#'   `scr_{name_test2_lower}_map_{ending}`. \n"
  )
}

