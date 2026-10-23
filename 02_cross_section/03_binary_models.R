# 03_binary_models.R - logit/probit with marginal effects and classification metrics.
library(tidyverse); library(marginaleffects); library(modelsummary)
df <- readRDS("out/clean.rds")   # y must be 0/1

logit  <- glm(y ~ x1 + x2 + x3, data = df, family = binomial("logit"))
probit <- glm(y ~ x1 + x2 + x3, data = df, family = binomial("probit"))
summary(logit)

# Coefficients are log-odds; report one of these instead:
exp(coef(logit))                       # odds ratios
avg_slopes(logit)                      # average marginal effects (preferred)
# plot_predictions(logit, condition = "x1")

# Robust SEs
# avg_slopes(logit, vcov = "HC1")

# Fit
null <- glm(y ~ 1, data = df, family = binomial)
1 - logLik(logit) / logLik(null)       # McFadden pseudo R2

# Classification (in-sample; use a train/test split for honest numbers)
df$p <- predict(logit, type = "response")
df$pred <- as.integer(df$p > .5)
table(Actual = df$y, Predicted = df$pred)
mean(df$pred == df$y)                  # accuracy
# ROC/AUC: library(pROC); roc(df$y, df$p) |> auc()

modelsummary(list(Logit = logit, Probit = probit), stars = TRUE, output = "out/binary_table.html")

# Count outcome: glm(y ~ x, family = poisson); check overdispersion, else MASS::glm.nb
# Censored outcome: AER::tobit
