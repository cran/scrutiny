## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE-----------------------------------------------------
library(scrutiny)

## -----------------------------------------------------------------------------
debit(x = "0.35", sd = "0.18", n = 20)

## -----------------------------------------------------------------------------
flying_pigs <- tibble::tibble(
    x  = runif(5, 0.2, 1) %>% round(2) %>% restore_zeros(),
    sd = runif(5, 0, 0.3) %>% round(2) %>% restore_zeros(),
    n = 1000
)


flying_pigs

## -----------------------------------------------------------------------------
flying_pigs %>% 
  debit_map()

## ----error=TRUE---------------------------------------------------------------
pigs3  # data saved within the package

pigs3 %>% 
  debit_map()

## ----error=TRUE---------------------------------------------------------------
pigs5  # no binary means / SDs!

pigs5 %>% 
  debit_map()

## -----------------------------------------------------------------------------
pigs3 %>% 
  debit_map() %>% 
  audit()

## -----------------------------------------------------------------------------
# Determine plot theme for the remaining session:
ggplot2::theme_minimal(base_size = 12) %>% 
  ggplot2::theme_set()

pigs3 %>% 
  debit_map() %>% 
  debit_plot()

## -----------------------------------------------------------------------------
pigs3 %>% 
  debit_map() %>% 
  debit_plot(show_outer_boxes = FALSE)

## -----------------------------------------------------------------------------
out_seq1 <- debit_map_seq(pigs3)
out_seq1

## -----------------------------------------------------------------------------
audit_seq(out_seq1)

## -----------------------------------------------------------------------------
out_seq2 <- debit_map_seq(pigs3, dispersion = 1:7, include_consistent = TRUE)
audit_seq(out_seq2)

## -----------------------------------------------------------------------------
out_total_n <- tibble::tribble(
  ~x1,     ~x2,   ~sd1,   ~sd2,  ~n,
  "0.30", "0.28", "0.17", "0.10", 70,
  "0.41", "0.39", "0.09", "0.15", 65
)

out_total_n <- debit_map_total_n(out_total_n)
out_total_n

audit_total_n(out_total_n)

