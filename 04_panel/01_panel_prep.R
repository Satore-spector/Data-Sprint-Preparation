# 01_panel_prep.R - declare the panel, check balance, look at within vs between variation.
library(tidyverse); library(plm)
df <- readRDS("out/clean.rds")

# ---- CONFIG ----
id <- "id"; time <- "year"

pdata <- pdata.frame(df, index = c(id, time))
pdim(pdata)                                   # balanced? N, T, n
# duplicates in (id, time) will error here: df |> count(id, year) |> filter(n > 1)

# ---- BALANCE / ATTRITION ----
df |> count(.data[[time]])                    # units per period
# punbalancedness(pdata)

# ---- WITHIN vs BETWEEN VARIATION (FE needs within variation) ----
summary(pdata$x)                              # overall / between / within
# time-invariant regressors get absorbed by FE

# ---- PLOTS ----
df |> ggplot(aes(.data[[time]], y, group = .data[[id]])) + geom_line(alpha = .3)
df |> group_by(.data[[time]]) |> summarise(m = mean(y, na.rm = TRUE)) |>
  ggplot(aes(.data[[time]], m)) + geom_line()

# ---- STATIONARITY (long T panels) ----
# purtest(pdata$y, test = "levinlin", exo = "intercept", lags = "AIC")
# purtest(pdata$y, test = "ips", exo = "intercept", lags = "AIC")   # unbalanced ok? check docs

saveRDS(pdata, "out/pdata.rds")
