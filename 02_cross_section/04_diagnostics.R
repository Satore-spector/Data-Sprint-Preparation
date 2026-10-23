# 04_diagnostics.R - OLS assumption checks. Run on any lm object `m`.
library(lmtest); library(car); library(sandwich)
df <- readRDS("out/clean.rds")
m <- lm(y ~ x1 + x2 + x3, data = df)

par(mfrow = c(2, 2)); plot(m); par(mfrow = c(1, 1))   # resid vs fit, QQ, scale-loc, leverage

# Heteroskedasticity (H0: constant variance). Rejected -> keep robust SEs.
bptest(m)
bptest(m, ~ fitted(m) + I(fitted(m)^2))               # White-style

# Functional form (H0: correctly specified). Rejected -> add squares/logs/interactions.
resettest(m, power = 2:3, type = "fitted")

# Multicollinearity: VIF > 10 is a concern (> 5 worth a look)
vif(m)

# Normality of residuals (matters little for large n)
shapiro.test(sample(resid(m), min(5000, length(resid(m)))))

# Influence: Cook's distance > 4/n
cd <- cooks.distance(m); which(cd > 4 / nrow(df))
influencePlot(m)
# Re-run without influential points as a robustness check.

# Autocorrelation (only meaningful if rows have a natural order)
dwtest(m); bgtest(m, order = 4)

# Quick robustness: does the main coefficient survive?
# - robust vs clustered SEs   - drop outliers   - add controls   - subsample split
