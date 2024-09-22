## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
pkgload::load_all()

## ----setup, message=FALSE-----------------------------------------------------
library(scrutiny)

## -----------------------------------------------------------------------------
grim(x = "5.27", n = 43)

## -----------------------------------------------------------------------------
flying_pigs1 <- tibble::tribble(
  ~x,
"8.97",
"2.61",
"7.26",
"3.64",
"9.26",
"10.46",
"7.39"
) %>% 
  dplyr::mutate(n = 28)

## ----error=TRUE---------------------------------------------------------------
grim_map(flying_pigs1)

## ----error=TRUE---------------------------------------------------------------
jpap_1 <- tibble::tribble(
   ~x,
  "5.90",
  "5.71",
  "3.50",
  "3.82",
  "4.61",
  "5.24",
) %>% 
  dplyr::mutate(n = 40)

jpap_1 %>% 
  grim_map()  # default is wrong here!

## ----error=TRUE---------------------------------------------------------------
jpap_1 %>% 
  grim_map(items = 3)

## ----error=TRUE---------------------------------------------------------------
jpap_2 <- tibble::tribble(
   ~x,    ~items,
  "6.92",  1,
  "3.48",  1,
  "1.59",  2,
  "2.61",  2,
  "4.04",  3,
  "4.50",  3,
) %>% 
  mutate(n = 30)

jpap_2 %>% 
  grim_map()

## -----------------------------------------------------------------------------
jpap_3 <- tibble::tribble(
  ~x,     ~n,
  "32.5",  438,
  "35.6",  455,
  "21.7",  501,
  "39.3",  516,
)

jpap_3 %>% 
  grim_map(percent = TRUE)

## -----------------------------------------------------------------------------
pigs1 %>% 
  grim_map(show_rec = TRUE) %>% 
  dplyr::select(4:8)   # output cut down for printing

## -----------------------------------------------------------------------------
flying_pigs1 %>% 
  grim_map() %>% 
  audit() %>% 
  dplyr::select(1:5)   # output cut down for printing

## ----error=TRUE, fig.width=6, fig.height=5.5----------------------------------
jpap_5 <- tibble::tribble(
  ~x,        ~n,
  "7.19",    28,
  "4.56",    34,
  "0.42",    27,
  "1.31",    25,
  "3.48",    34,
  "4.27",    29,
  "6.21",    30,
  "3.11",    18,
  "5.39",    36,
  "5.66",    18,
)


jpap_5 %>% 
  grim_map() %>% 
  grim_plot()

## ----error=TRUE---------------------------------------------------------------
grim_plot(mtcars)

## ----fig.width=6, fig.height=5.5----------------------------------------------
jpap_5 %>% 
  grim_map(rounding = "ceiling") %>% 
  grim_plot()

## -----------------------------------------------------------------------------
out_seq1 <- grim_map_seq(pigs1)
out_seq1

## -----------------------------------------------------------------------------
audit_seq(out_seq1)

## -----------------------------------------------------------------------------
out_seq2 <- grim_map_seq(pigs1, dispersion = 1:10)
audit_seq(out_seq2)

## ----fig.width=6, fig.height=5.5----------------------------------------------
grim_plot(out_seq1)

## ----fig.width=6, fig.height=5.5----------------------------------------------
out_seq1_only_x <- grim_map_seq(pigs1, var = "x")
out_seq1_only_n <- grim_map_seq(pigs1, var = "n")

grim_plot(out_seq1_only_x)
grim_plot(out_seq1_only_n)

## -----------------------------------------------------------------------------
df <- tibble::tibble(x1 = "4.71", x2 = "5.3", n = 40)

# Detailed results:
df_tested <- grim_map_total_n(df)
df_tested

# Summary:
audit_total_n(df_tested)

## -----------------------------------------------------------------------------
grim_probability(x = "1.40", n = 72)

grim_probability(x = "5.93", n = 80, items = 3)

# Enter `x` as a string to preserve trailing zeros:
grim_probability(x = "84.27", n = 40, percent = TRUE)

## -----------------------------------------------------------------------------
grim_total(x = "1.40", n = 72)

grim_total(x = "5.93", n = 80, items = 3)

grim_total(x = "84.27", n = 40, percent = TRUE)  # Enter `x` as string to preserve trailing zero

## -----------------------------------------------------------------------------
grim_probability(x = "0.99", n = 70)

## -----------------------------------------------------------------------------
grim_granularity(n = 80, items = 4)

## -----------------------------------------------------------------------------
grim_items(n = 50, gran = 0.01)

## -----------------------------------------------------------------------------
grim_items(n = c(50, 65, 93), gran = 0.02)

