# 04_var_granger.R - multivariate: VAR, Granger causality, IRFs.
library(vars); library(tseries)

# ---- DATA: matrix of stationary series (difference first if I(1)) ----
# X <- cbind(y1, y2, y3) built from your ts objects; X <- diff(X) if needed
X <- na.omit(X)

# ---- LAG SELECTION ----
sel <- VARselect(X, lag.max = 8, type = "const"); sel$selection   # use AIC or SC (BIC)
p <- sel$selection["SC(n)"]

# ---- ESTIMATE ----
var_fit <- VAR(X, p = p, type = "const"); summary(var_fit)

# ---- DIAGNOSTICS ----
roots(var_fit)                          # all < 1 -> stable
serial.test(var_fit, lags.pt = 12)      # H0: no serial correlation
arch.test(var_fit)                      # H0: no ARCH
normality.test(var_fit)

# ---- GRANGER CAUSALITY (H0: cause does NOT Granger-cause the rest) ----
causality(var_fit, cause = "y1")
# pairwise: lmtest::grangertest(y2 ~ y1, order = p)
# Predictive precedence only, not true causality: say so in the write-up.

# ---- IMPULSE RESPONSE + VARIANCE DECOMPOSITION ----
irf1 <- irf(var_fit, impulse = "y1", response = "y2", n.ahead = 12, boot = TRUE)
plot(irf1)
plot(fevd(var_fit, n.ahead = 12))
# Ordering matters for orthogonalised IRFs: put the most exogenous variable first.

# ---- FORECAST ----
plot(predict(var_fit, n.ahead = 12))
