## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
pkgload::load_all()

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

## -----------------------------------------------------------------------------
audit.scr_schlim_map <- function(data) {
  audit_cols_minimal(data, name_test = "SCHLIM")
}

df1 %>% 
  schlim_map() %>% 
  audit()

## -----------------------------------------------------------------------------
schlim_map_seq <- function_map_seq(
  .fun = schlim_map,
  .reported = c("y", "n"),
  .name_test = "SCHLIM"
)

df1 %>% 
  schlim_map_seq()

## -----------------------------------------------------------------------------
df1 %>% 
  schlim_map_seq() %>% 
  audit_seq()

## -----------------------------------------------------------------------------
df2 <- tibble::tribble(
  ~y1, ~y2, ~n,
   84,  37,  29,
   61,  55,  26
)

## -----------------------------------------------------------------------------
schlim_map_total_n <- function_map_total_n(
  .fun = schlim_map,
  .reported = "y",
  .name_test = "SCHLIM"
)

df2 %>% 
  schlim_map_total_n()

## -----------------------------------------------------------------------------
df2 %>% 
  schlim_map_total_n() %>% 
  audit_total_n()

