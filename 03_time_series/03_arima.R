# 03_arima.R - ARIMA, ETS, benchmarks, and forecast accuracy.
library(forecast); library(lmtest)
obj <- readRDS("out/ts_objects.rds"); y <- obj$y; train <- obj$train; test <- obj$test; h <- obj$h

# ---- ARIMA (auto-select, then sanity check) ----
fit_arima <- auto.arima(train, seasonal = TRUE, stepwise = FALSE, approx = FALSE)
summary(fit_arima)
checkresiduals(fit_arima)               # want white noise; Ljung-Box p > 0.05
# manual: Arima(train, order = c(p, d, q), seasonal = c(P, D, Q))

# ---- ETS ----
fit_ets <- ets(train); summary(fit_ets)

# ---- BENCHMARKS (a fancy model must beat these) ----
fit_naive  <- naive(train, h = h)
fit_snaive <- snaive(train, h = h)
fit_drift  <- rwf(train, h = h, drift = TRUE)

# ---- FORECAST + COMPARE ON HELD-OUT DATA ----
fc <- list(ARIMA = forecast(fit_arima, h = h), ETS = forecast(fit_ets, h = h),
           Naive = fit_naive, SNaive = fit_snaive, Drift = fit_drift)
do.call(rbind, lapply(fc, function(f) accuracy(f, test)["Test set", c("RMSE", "MAE", "MAPE")]))

autoplot(fc$ARIMA) + autolayer(test, series = "Actual")
# Diebold-Mariano: dm.test(residuals(fc$ARIMA), residuals(fc$Naive), h = h)

# ---- FINAL: refit on full sample, forecast the future ----
final <- auto.arima(y); autoplot(forecast(final, h = h))

# ---- REGRESSION WITH ARMA ERRORS (exogenous x) ----
# Arima(train, xreg = x_train); forecast(fit, xreg = x_future)
# ---- VOLATILITY (finance returns) ----  library(rugarch)  ugarchspec / ugarchfit
