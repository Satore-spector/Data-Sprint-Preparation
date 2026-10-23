# 01_ts_prep_plots.R - build a ts object and look at it before modelling.
library(tidyverse); library(lubridate); library(forecast); library(zoo)
df <- readRDS("out/clean.rds")   # needs a date column and a value column

# ---- CONFIG ----
date_col <- "date"; val_col <- "value"
freq <- 12                       # 12 monthly, 4 quarterly, 1 annual, 7 daily-weekly
start_y <- c(2000, 1)            # c(year, period)

df <- df |> arrange(.data[[date_col]])
y <- ts(df[[val_col]], start = start_y, frequency = freq)

# ---- LOOK ----
autoplot(y) + labs(title = "Series")
ggseasonplot(y)                  # seasonality (freq > 1 only)
ggsubseriesplot(y)
ggAcf(y); ggPacf(y)
decomp <- stl(y, s.window = "periodic"); autoplot(decomp)

# ---- MISSING / GAPS ----
sum(is.na(y)); # y <- na.interp(y)

# ---- TRANSFORMS ----
ly  <- log(y)                    # stabilise variance (needs y > 0)
dy  <- diff(y)                   # first difference
dly <- diff(log(y))              # growth rate (approx % change)
# seasonal diff: diff(y, lag = freq)
# rolling mean: rollmean(y, k = 12, fill = NA)

# ---- TRAIN/TEST FOR FORECASTING ----
h <- 12
train <- head(y, length(y) - h); test <- tail(y, h)
saveRDS(list(y = y, train = train, test = test, h = h), "out/ts_objects.rds")
