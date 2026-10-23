# 02_stationarity.R - unit root and cointegration tests.
library(tseries); library(urca); library(forecast)
y <- readRDS("out/ts_objects.rds")$y

# ADF: H0 = unit root (non-stationary). p < 0.05 -> stationary.
adf.test(y)
summary(ur.df(y, type = "drift", selectlags = "AIC"))   # type: none / drift / trend

# KPSS: H0 = stationary (opposite null). p < 0.05 -> non-stationary.
kpss.test(y)                                            # level
kpss.test(y, null = "Trend")

# Read together: ADF reject + KPSS fail to reject = stationary.
# Both disagree -> difference once and retest.

# How many differences?
ndiffs(y); nsdiffs(y)
dy <- diff(y); adf.test(dy); kpss.test(dy)

# Structural break (if the series jumps)
# library(strucchange); breakpoints(y ~ 1)

# ---- COINTEGRATION (two I(1) series y1, y2) ----
# Engle-Granger: res <- resid(lm(y1 ~ y2)); adf.test(res)   # use EG critical values in write-up
# Johansen:
# summary(ca.jo(cbind(y1, y2), type = "trace", ecdet = "const", K = 2))
# If cointegrated -> VECM (vars::vec2var / tsDyn::VECM); if not -> VAR in differences.
