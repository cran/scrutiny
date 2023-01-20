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
reround(x = c(5.812, 7.249), digits = 2, rounding = "up")

## -----------------------------------------------------------------------------
round_up(x = 1.24, digits = 1)

round_up(x = 1.25, digits = 1)

round_up(x = 1.25)  # default for `digits` is 0

## -----------------------------------------------------------------------------
round_up_from(x = 4.28, digits = 1, threshold = 9)

round_up_from(x = 4.28, digits = 1, threshold = 1)

## -----------------------------------------------------------------------------
round_down(x = 1.24, digits = 1)

round_down(x = 1.25, digits = 1)

round_down(x = 1.25)  # default for `digits` is 0

## -----------------------------------------------------------------------------
round_down_from(x = 4.28, digits = 1, threshold = 9)

round_down_from(x = 4.28, digits = 1, threshold = 1)

## -----------------------------------------------------------------------------
vec1 <- seq(from = 0.5, to = 9.5)
up1 <- round_up(vec1)
down1 <- round_down(vec1)
even1 <- round(vec1)

vec1
up1
down1
even1

# Original mean
mean(vec1)

# Means when rounding up or down: bias!
mean(up1)
mean(down1)

# Mean when rounding to even: no bias
mean(even1)

## -----------------------------------------------------------------------------
vec2 <- seq(from = 4.5, to = 10.5)

up2 <- round_up(vec2)
down2 <- round_down(vec2)
even2 <- round(vec2)

vec1
up2
down2
even2  # No symmetry here...

mean(vec2)
mean(up2)
mean(down2)
mean(even2)  # ... and the mean is slightly biased downward!


vec3 <- c(
  1.05, 1.15, 1.25, 1.35, 1.45,
  1.55, 1.65, 1.75, 1.85, 1.95
)

# No bias here, though:
round(vec3, 1)
mean(vec3)
mean(round(vec3, 1))

## -----------------------------------------------------------------------------
unround(x = "8.0")

## -----------------------------------------------------------------------------
unround(x = "3.50", rounding = "up")

## -----------------------------------------------------------------------------
unround(x = 3.5, digits = 2, rounding = "up")

## -----------------------------------------------------------------------------
vec2 <- c(2, 3.1, 3.5) %>% 
  restore_zeros()

vec2   # `restore_zeros()` returns "2.0" for 2

vec2 %>% 
  unround(rounding = "even")

## -----------------------------------------------------------------------------
reround_to_fraction(x = 0.4, denominator = 2, rounding = "up")

## -----------------------------------------------------------------------------
reround_to_fraction_level(
  x = 0.777, denominator = 5, digits = 0, rounding = "down"
)
reround_to_fraction_level(
  x = 0.777, denominator = 5, digits = 1, rounding = "down"
)
reround_to_fraction_level(
  x = 0.777, denominator = 5, digits = 2, rounding = "down"
)

## -----------------------------------------------------------------------------
vec3 <- seq(from = 0.6, to = 0.7, by = 0.01)

vec3

# The mean before rounding...
mean(vec3)

# ...is not the same as afterwards...
mean(round_up(vec3))

# ...and the difference is bias:
rounding_bias(x = vec3, digits = 0, rounding = "up")

## -----------------------------------------------------------------------------
rounding_bias(x = vec3, digits = 0, rounding = "up", mean = FALSE)

## -----------------------------------------------------------------------------
vec4 <- rnorm(50000, 100, 15)

rounding_bias(vec4, digits = 2)

## ----echo=FALSE---------------------------------------------------------------
up_1   <- rounding_bias(vec4, digits = 1, rounding = "up")
up_2   <- rounding_bias(vec4, digits = 2, rounding = "up")
up_3   <- rounding_bias(vec4, digits = 3, rounding = "up")
up_4   <- rounding_bias(vec4, digits = 4, rounding = "up")
up_5   <- rounding_bias(vec4, digits = 5, rounding = "up")

even_1 <- rounding_bias(vec4, digits = 1, rounding = "even")
even_2 <- rounding_bias(vec4, digits = 2, rounding = "even")
even_3 <- rounding_bias(vec4, digits = 3, rounding = "even")
even_4 <- rounding_bias(vec4, digits = 4, rounding = "even")
even_5 <- rounding_bias(vec4, digits = 5, rounding = "even")


bias <- abs(c(
  up_1, up_2, up_3, up_4, up_5,
  even_1, even_2, even_3, even_4, even_5
))

decimal_digits <- rep(1:5, 2)
rounding <- c(rep("up", 5), rep("even", 5))

decimal_digits <- paste(decimal_digits, rounding)

df <- tibble::tibble(bias, decimal_digits, rounding)

# Display simulated data:
df

df <- df %>% 
  dplyr::mutate(
    rounding = paste0("(", rounding, ")"),
    decimal_digits = paste(c(1:5, 1:5), rounding)
    # decimal_digits = paste0("(", decimal_digits, ")"),
    # rounding = paste0("(", rounding, ")")
  )

`%+replace%` <- ggplot2::`%+replace%`

# Set ggplot2 theme for the remaining part of the session:
ggplot2::theme_minimal(base_size = 12) %+replace%
    ggplot2::theme(
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.minor.x = ggplot2::element_blank(),
    legend.position = "none"
  ) %>% 
  ggplot2::theme_set()

# Visualize:
ggplot2::ggplot(df, ggplot2::aes(x = decimal_digits, y = bias,
                                 fill = rounding)) +
  ggplot2::geom_col(ggplot2::aes(fill = rounding)) +
  ggplot2::scale_y_continuous(expand = ggplot2::expansion(add = c(0, 0))
                              # labels = scales::comma
                              ) +
  ggplot2::scale_fill_discrete(name = "Rounding") +
  ggplot2::labs(
    x = "Decimal places (rounding procedure)",
    y = "Mean absolute bias",
    title = "Directly from random numbers",
    subtitle = "Raw \"data\" mostly have 12 or 13 decimal places "
  )


## ----echo=FALSE---------------------------------------------------------------
vec5 <- round(vec4, 2)

up_1   <- rounding_bias(vec5, digits = 1, rounding = "up")
up_2   <- rounding_bias(vec5, digits = 2, rounding = "up")
up_3   <- rounding_bias(vec5, digits = 3, rounding = "up")
up_4   <- rounding_bias(vec5, digits = 4, rounding = "up")
up_5   <- rounding_bias(vec5, digits = 5, rounding = "up")

even_1 <- rounding_bias(vec5, digits = 1, rounding = "even")
even_2 <- rounding_bias(vec5, digits = 2, rounding = "even")
even_3 <- rounding_bias(vec5, digits = 3, rounding = "even")
even_4 <- rounding_bias(vec5, digits = 4, rounding = "even")
even_5 <- rounding_bias(vec5, digits = 5, rounding = "even")

bias <- abs(c(
  up_1, up_2, up_3, up_4, up_5,
  even_1, even_2, even_3, even_4, even_5
))

decimal_digits <- rep(1:5, 2)
rounding <- c(rep("up", 5), rep("even", 5))

decimal_digits <- paste(decimal_digits, rounding)

df_new <- tibble::tibble(bias, decimal_digits, rounding)

# Display simulated data:
df_new

df_new <- df_new %>% 
  dplyr::mutate(
    rounding = paste0("(", rounding, ")"),
    decimal_digits = paste(c(1:5, 1:5), rounding)
    # decimal_digits = paste0("(", decimal_digits, ")"),
    # rounding = paste0("(", rounding, ")")
  )

# Visualize:
ggplot2::ggplot(df_new, ggplot2::aes(x = decimal_digits, y = bias, fill = rounding)) +
  ggplot2::geom_col(ggplot2::aes(fill = rounding)) +
  ggplot2::scale_y_continuous(expand = ggplot2::expansion(add = c(0, 0))) +
  ggplot2::scale_fill_discrete(name = "Rounding") +
  # ggplot2::theme_minimal() +
  # ggplot2::theme(
  #   panel.grid.major.x = ggplot2::element_blank(),
  #   panel.grid.minor.x = ggplot2::element_blank(),
  #   legend.position = "none"
  # ) +
  ggplot2::labs(
    x = "Decimal places (rounding procedure)",
    y = "Mean absolute bias",
    title = "After previous rounding to 2 decimal places"
  )


