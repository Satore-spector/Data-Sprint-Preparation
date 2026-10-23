# 03_tests_robustness.R - panel diagnostics and robustness checks.
library(plm); library(lmtest); library(sandwich); library(fixest)
pdata <- readRDS("out/pdata.rds"); df <- as.data.frame(pdata)
fe <- plm(y ~ x1 + x2 + x3, data = pdata, model = "within")

# ---- SERIAL CORRELATION (Wooldridge; H0: none) ----
pwartest(fe)
pbgtest(fe)                    # Breusch-Godfrey for panels

# ---- CROSS-SECTIONAL DEPENDENCE (long T; H0: none) ----
pcdtest(fe, test = "cd")

# ---- HETEROSKEDASTICITY ----
bptest(y ~ x1 + x2 + x3 + factor(id), data = df)

# ---- FIX: clustered / Driscoll-Kraay SEs ----
coeftest(fe, vcov = vcovHC(fe, cluster = "group", type = "HC1"))
coeftest(fe, vcov = vcovSCC(fe, type = "HC1"))       # Driscoll-Kraay

# ---- ROBUSTNESS MENU ----
# 1. Add time FE            -> feols(... | id + year)
# 2. Drop outlier units     -> filter, refit
# 3. Lag the regressor      -> lag(x1, 1) to soften reverse causality
# 4. Subsample / balanced only
# 5. Alternative outcome definition or log transform
# 6. Placebo: regress on a lead of x1 (should be ~0)

# ---- WRITE-UP REMINDERS ----
# - State what variation identifies the effect (within-unit over time).
# - FE removes time-invariant confounders, not time-varying ones.
# - Cluster at the level treatment varies (usually the unit).
