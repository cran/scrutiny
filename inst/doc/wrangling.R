## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----include=FALSE------------------------------------------------------------
# Dev only: load scrutiny from within scrutiny
devtools::load_all(".")

## ----setup, message=FALSE-----------------------------------------------------
library(scrutiny)

## -----------------------------------------------------------------------------
flights1 <- tribble(
  ~x,
"8.97",
"2.61",
"7.26",
"3.64",
"9.26",
"10.46",
"7.39",
)

## -----------------------------------------------------------------------------
flights1 <- flights1 %>% 
  mutate(n = 28)

flights1

## -----------------------------------------------------------------------------
vec <- c(4, 6.9, 5, 4.2, 4.8, 7, 4)

vec %>% 
  decimal_places()

## -----------------------------------------------------------------------------
vec %>% 
  restore_zeros()

vec %>% 
  restore_zeros() %>% 
  decimal_places()

## -----------------------------------------------------------------------------
vec %>% 
  restore_zeros(width = 2)

vec %>% 
  restore_zeros(width = 2) %>% 
  decimal_places()

## -----------------------------------------------------------------------------
flights2 <- tribble(
  ~drone,           ~selfpilot,
  "0.09 (0.21)",    "0.19 (0.13)",
  "0.19 (0.28)",    "0.53 (0.10)",
  "0.62 (0.16)",    "0.50 (0.11)",
  "0.15 (0.35)",    "0.57 (0.16)",
)

flights2 %>% 
  split_by_parens()

## -----------------------------------------------------------------------------
flights2 %>% 
  split_by_parens(.transform = TRUE)

## -----------------------------------------------------------------------------
flights2 %>% 
  split_by_parens(.transform = TRUE) %>% 
  dplyr::mutate(n = 80) %>% 
  debit_map()

## -----------------------------------------------------------------------------
flights2 %>% 
  split_by_parens(.col1 = "beta", .col2 = "se")

## -----------------------------------------------------------------------------
flights2 %>% 
  split_by_parens(.col1 = "beta", .col2 = "se", .transform = TRUE)


## -----------------------------------------------------------------------------
flights3 <- flights2 %>% 
  dplyr::pull(selfpilot)

flights3

flights3 %>% 
  before_parens()

flights3 %>% 
  inside_parens()

## -----------------------------------------------------------------------------
flights1_with_issues <- flights1 %>% 
    dplyr::mutate(n = as.character(n)) %>% 
    tibble::add_row(x = "x", n = "n", .before = 1)

colnames(flights1_with_issues) <- c("Var1", "Var2")

flights1_with_issues

## -----------------------------------------------------------------------------
flights1_with_issues %>% 
  row_to_colnames()

