## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----include=FALSE------------------------------------------------------------
# Dev only: load scrutiny from within scrutiny
devtools::load_all(".")

## ----setup--------------------------------------------------------------------
library(scrutiny)

## -----------------------------------------------------------------------------
 schlim_scalar <- function(y, n) {
   y <- as.numeric(y)
   n <- as.numeric(n)
   all(y / 3 > n)
 }

schlim_scalar(y = 30, n = 4)
schlim_scalar(y = 2, n = 7)

## -----------------------------------------------------------------------------
schlim <- Vectorize(schlim_scalar)

schlim(y = 10:15, n = 4)

## -----------------------------------------------------------------------------
schlim_map <- function_map(
  .fun = schlim_scalar,
  .reported = c("y", "n"),
  .name_test = "SCHLIM"
)

# Example data:
df1 <- tibble::tibble(y = 16:25, n = 3:12)

schlim_map(df1)

## ----eval=FALSE---------------------------------------------------------------
#  schlim_map <- function(...) "dummy"
#  
#  .onLoad <- function(lib, pkg) {
#    schlim_map <<- scrutiny::function_map(
#      .fun = schlim_scalar,
#      .reported = c("y", "n"),
#      .name_test = "SCHLIM"
#    )
#  }

## -----------------------------------------------------------------------------
df2 <- df1
names(df2) <- c("foo", "bar")

df2

schlim_map(df2, y = foo, n = bar)

## ---- error=TRUE--------------------------------------------------------------
schlim_map(df2, y = foo)

# With a wrong identification:
schlim_map(df2, n = mike)

## ----eval=FALSE, include=FALSE------------------------------------------------
#  # NOTE: The two diagrams below should have width 585 and a locked aspect ratio.

## ----include=FALSE------------------------------------------------------------
# Just internally, so that the function source code below works:
add_class <- scrutiny:::add_class

## -----------------------------------------------------------------------------
schlim_map_alt1 <- function(data, ...) {
  scrutiny::check_mapper_input_colnames(data, c("y", "n"), "SCHLIM")
  consistency <- purrr::pmap_lgl(data, schlim_scalar, ...)
  out <- tibble::tibble(y = data$y, n = data$n, consistency)
  out <- add_class(out, "scr_schlim_map")  # See section "S3 classes" below
  out
}

## -----------------------------------------------------------------------------
schlim_map_alt2 <- function(data, ...) {
  scrutiny::check_mapper_input_colnames(data, c("y", "n"), "SCHLIM")
  data %>% 
    dplyr::rowwise() %>% 
    dplyr::mutate(consistency = schlim_scalar(y, n, ...)) %>% 
    dplyr::ungroup() %>% 
    dplyr::relocate(y, n, consistency) %>% 
    add_class("scr_schlim_map")  # See section "S3 classes" below
}

## -----------------------------------------------------------------------------
schlim_map_alt1(df1)

schlim_map_alt2(df1)

## ---- eval=FALSE--------------------------------------------------------------
#  add_class <- function(x, new_class) {
#    class(x) <- c(new_class, class(x))
#    x
#  }

## -----------------------------------------------------------------------------
some_object <- tibble::tibble(x = 5)
some_object <- add_class(some_object, "dummy class")
class(some_object)

## -----------------------------------------------------------------------------
df1_tested <- schlim_map(df1)
class(df1_tested)

## ---- error=TRUE--------------------------------------------------------------
# The `name_test` argument is only for the alert
# that might be issued by `check_audit_special()`:
audit.scr_schlim_map <- function(data) {
  audit_cols_minimal(data, name_test = "SCHLIM")
}

# This calls our new method:
audit(df1_tested)

# This doesn't work because no method was defined:
audit(iris)

## -----------------------------------------------------------------------------
audit_grim    <- audit(grim_map(pigs1))
audit_grimmer <- audit(grimmer_map(pigs5))

write_doc_audit(sample_output = audit_grim,  name_test = "GRIM")

write_doc_audit(sample_output = audit_grimmer, name_test = "GRIMMER")

## ---- eval=FALSE--------------------------------------------------------------
#  grim_map_seq <- function_map_seq(
#    .fun = grim_map,
#    .reported = c("x", "n"),
#    .name_test = "GRIM",
#  )
#  
#  grimmer_map_seq <- function_map_seq(
#    .fun = grimmer_map,
#    .reported = c("x", "sd", "n"),
#    .name_test = "GRIMMER"
#  )
#  
#  debit_map_seq <- function_map_seq(
#    .fun = debit_map,
#    .reported = c("x", "sd", "n"),
#    .name_test = "DEBIT",
#  )

## -----------------------------------------------------------------------------
schlim_map_seq <- function_map_seq(
  .fun = schlim_map,
  .reported = c("y", "n"),
  .name_test = "SCHLIM"
)

# Test dispersed sequences:
out_seq <- schlim_map_seq(df1)
out_seq

# Summarize:
audit_seq(out_seq)

## -----------------------------------------------------------------------------
df1 %>% 
  schlim_map_seq(include_consistent = TRUE) %>% 
  audit_seq()

# Compare with the original values:
df1

## ---- eval=FALSE--------------------------------------------------------------
#  grim_map_total_n <- function_map_total_n(
#    .fun = grim_map,
#    .reported = "x",  # don't include `n` here
#    .name_test = "GRIM"
#  )
#  
#  grimmer_map_total_n <- function_map_total_n(
#    .fun = grimmer_map,
#    .reported = c("x", "sd"),  # don't include `n` here
#    .name_test = "GRIMMER"
#  )
#  
#  debit_map_total_n <- function_map_total_n(
#    .fun = debit_map,
#    .reported = c("x", "sd"),  # don't include `n` here
#    .name_test = "DEBIT"
#  )

## -----------------------------------------------------------------------------
schlim_map_total_n <- function_map_total_n(
  .fun = schlim_map,
  .reported = "y",
  .name_test = "SCHLIM"
)

# Example data:
df_groups_schlim <- tibble::tribble(
  ~y1, ~y2, ~n,
   84,  37,  29,
   61,  55,  26
)

# Test dispersed sequences:
out_total_n <- schlim_map_total_n(df_groups_schlim)
out_total_n

# Summarize:
audit_total_n(out_total_n)

## ---- eval=FALSE--------------------------------------------------------------
#  write_doc_audit_seq(key_args = c("x", "n"), name_test = "GRIM")
#  write_doc_audit_seq(key_args = c("x", "sd", "n"), name_test = "GRIMMER")
#  write_doc_audit_seq(key_args = c("x", "sd", "n"), name_test = "DEBIT")

## ---- eval=FALSE--------------------------------------------------------------
#  write_doc_audit_total_n(key_args = c("x", "n"), name_test = "GRIM")
#  write_doc_audit_total_n(key_args = c("x", "sd", "n"), name_test = "GRIMMER")
#  write_doc_audit_total_n(key_args = c("x", "sd", "n"), name_test = "DEBIT")

## ----include=FALSE, eval=FALSE------------------------------------------------
#  # Note: The diagram was made on diagrams.net. The bold margins were created as follows: (1) selecting the respective field, (2) clicking on the `View` symbol at the upper left, (3) selecting `Format Panel`, and (4) setting the line thickness from 1 to 3 pt.

