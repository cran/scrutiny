## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE-----------------------------------------------------
library(scrutiny)

## -----------------------------------------------------------------------------
decimal_places("2.80")

decimal_places(c(55.1, 6.493, 8))

vec1 <- iris %>% 
  dplyr::slice(1:10) %>% 
  dplyr::pull(Sepal.Length)

vec1

vec1 %>% 
  decimal_places()

## -----------------------------------------------------------------------------
decimal_places(7.200)

decimal_places("7.200")

## -----------------------------------------------------------------------------
vec2 <- c(4, 6.9, 5, 4.2, 4.8, 7, 4)

vec2 %>% 
  decimal_places()

## -----------------------------------------------------------------------------
vec2 %>% 
  restore_zeros()

vec2 %>% 
  restore_zeros() %>% 
  decimal_places()

## -----------------------------------------------------------------------------
vec2 %>% 
  restore_zeros(width = 2)

vec2 %>% 
  restore_zeros(width = 2) %>% 
  decimal_places()

## -----------------------------------------------------------------------------
seq_endpoint(from = 4.1, to = 6)

seq_endpoint(from = 4.1, to = 4.15)

## -----------------------------------------------------------------------------
seq_distance(from = 4.1, length_out = 3)

# Default for `length_out` is `10`:
seq_distance(from = 4.1)

## -----------------------------------------------------------------------------
seq_disperse(from = 4.1, dispersion = 1:3)

# Default for `dispersion` if `1:5`:
seq_disperse(from = 4.1)

## -----------------------------------------------------------------------------
is_seq_linear(x = 8:15)
is_seq_linear(x = c(8:15, 16))
is_seq_linear(x = c(8:15, 17))

## -----------------------------------------------------------------------------
is_seq_ascending(x = 8:15)
is_seq_ascending(x = 15:8)

# Default also tests for linearity:
is_seq_ascending(x = c(8:15, 17))
is_seq_ascending(x = c(8:15, 17), test_linear = FALSE)

## -----------------------------------------------------------------------------
is_seq_descending(x = 8:15)
is_seq_descending(x = 15:8)

# Default also tests for linearity:
is_seq_descending(x = c(15:8, 2))
is_seq_descending(x = c(15:8, 2), test_linear = FALSE)

## -----------------------------------------------------------------------------
is_seq_dispersed(x = 3:7, from = 2)

# Direction doesn't matter here:
is_seq_dispersed(x = 3:7, from = 5)
is_seq_dispersed(x = 7:3, from = 5)

# Dispersed from `50`, but not linear:
x_nonlinear <- c(49, 42, 47, 44, 50, 56, 53, 58, 51)

# Default also tests for linearity:
is_seq_dispersed(x = x_nonlinear, from = 50)
is_seq_dispersed(x = x_nonlinear, from = 50, test_linear = FALSE)

## -----------------------------------------------------------------------------
is_seq_linear(x = c(1, 2, NA, 4))
is_seq_linear(x = c(1, 2, NA, NA, NA, 6))

## -----------------------------------------------------------------------------
is_seq_linear(x = c(1, 2, 3, 4))
is_seq_linear(x = c(1, 2, 7, 4))

is_seq_linear(x = c(1, 2, 3, 4, 5, 6))
is_seq_linear(x = c(1, 2, 17, 29, 32, 6))

## -----------------------------------------------------------------------------
is_seq_linear(x = c(1, 2, NA, 10))
is_seq_linear(x = c(1, 2, NA, NA, NA, 10))


## -----------------------------------------------------------------------------
is_seq_linear(x = c(NA, NA, 1, 2, 3, 4, NA))
is_seq_linear(x = c(NA, NA, 1, 2, NA, 4, NA))

## -----------------------------------------------------------------------------
# `TRUE` because `x` is symmetrically dispersed
# from 5 and contains no `NA` values:
is_seq_dispersed(x = c(3:7), from = 5)

# `NA` because it might be dispersed from 5,
# depending on the values hidden behind the `NA`s:
is_seq_dispersed(x = c(NA, 3:7, NA), from = 5)
is_seq_dispersed(x = c(NA, NA, 3:7, NA, NA), from = 5)

# `FALSE` because it's not symmetrically dispersed
# around 5, no matter what the `NA`s stand in for:
is_seq_dispersed(x = c(NA, 3:7), from = 5)
is_seq_dispersed(x = c(3:7, NA), from = 5)
is_seq_dispersed(x = c(3:7, NA, NA), from = 5)
is_seq_dispersed(x = c(NA, NA, 3:7), from = 5)

## -----------------------------------------------------------------------------
# With an even total...
disperse_total(n = 70)

# ...and with an odd total:
disperse_total(n = 83)

