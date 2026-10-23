# 02_ols.R - OLS workflow with robust SEs, specification checks, interpretation aids.
library(tidyverse); library(sandwich); library(lmtest); library(car)
library(broom); library(modelsummary)
df <- readRDS("out/clean.rds")

# ---- BASELINE ----
m1 <- lm(y ~ x1 + x2 + x3, data = df)
summary(m1)

# ---- ROBUST INFERENCE (default for reporting) ----
coeftest(m1, vcov = vcovHC(m1, type = "HC1"))
# clustered: coeftest(m1, vcov = vcovCL(m1, cluster = ~ cluster_id, data = df))
# jointly test a set of coefficients:
# linearHypothesis(m1, c("x1 = 0", "x2 = 0"), vcov = vcovHC(m1, "HC1"))

# ---- SPECIFICATION LADDER ----
m2 <- lm(y ~ x1 + x2 + x3 + factor(region), data = df)           # add FE dummies
m3 <- lm(log(y) ~ x1 + x2 + x3, data = df)                       # log-level
m4 <- lm(y ~ x1 * x2 + x3, data = df)                            # interaction
m5 <- lm(y ~ x1 + I(x1^2) + x2 + x3, data = df)                  # nonlinearity
anova(m1, m5)                                                    # nested F-test
AIC(m1, m2, m3, m4, m5)

# ---- PRESENT ----
modelsummary(list(Base = m1, FE = m2, Interact = m4), vcov = "HC1",
             stars = TRUE, output = "out/ols_table.html")
tidy(m1, conf.int = TRUE, vcov = vcovHC(m1, "HC1")) |> filter(term != "(Intercept)") |>
  ggplot(aes(estimate, reorder(term, estimate))) +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high)) +
  geom_vline(xintercept = 0, linetype = 2) + labs(y = NULL, x = "Coefficient (95% CI, HC1)")

# ---- INTERPRETATION CHEAT SHEET ----
# level-level : 1 unit up in x -> beta units change in y
# log-level   : 1 unit up in x -> (100*beta)% change in y
# level-log   : 1% up in x -> beta/100 units change in y
# log-log     : 1% up in x -> beta% change in y (elasticity)

# ---- ENDOGENEITY / IV (if the brief hints at it) ----
# library(fixest); feols(y ~ x2 | 0 | x1 ~ z1 + z2, data = df)   # 2SLS; check first-stage F > 10
