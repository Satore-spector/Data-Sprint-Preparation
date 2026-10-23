# 02_handling_methods.R - dropping, filling, interpolating, and multiple imputation.
library(tidyverse); library(zoo); library(forecast); library(mice); library(VIM)
df <- readRDS("out/clean.rds")

# ============ A. DELETION ============
# Listwise (complete-case). Unbiased under MCAR; loses power; biased under MAR/MNAR.
df_cc <- drop_na(df)
# Only drop where the variables you actually use are missing:
df_cc2 <- df |> drop_na(y, x1, x2)
# Drop a column that is mostly empty:
# df <- df |> select(where(~ mean(is.na(.x)) < .4))
# Pairwise: cor(df, use = "pairwise.complete.obs")  (different n per pair; can give a non-PSD matrix)

# ============ B. SIMPLE FILLS (quick, but shrink variance) ============
# Constant / mean / median
df |> mutate(x1 = replace_na(x1, median(x1, na.rm = TRUE)))
# Missing indicator + fill (keeps the information that it was missing; good for prediction)
df |> mutate(x1_miss = is.na(x1), x1 = replace_na(x1, median(x1, na.rm = TRUE)))
# Categorical: make "Missing" its own level
df |> mutate(region = fct_na_value_to_level(region, level = "Missing"))
# Group mean (better than global mean if groups differ)
df |> group_by(region) |> mutate(x1 = coalesce(x1, mean(x1, na.rm = TRUE))) |> ungroup()

# ============ C. ORDERED DATA: COPY DOWN / INTERPOLATE ============
# Sort first! These only make sense for time series or panels.
df <- df |> arrange(id, year)

# Copy down (last observation carried forward) / copy up (next observation carried back)
df |> group_by(id) |> fill(x1, .direction = "down") |> ungroup()      # LOCF
df |> group_by(id) |> fill(x1, .direction = "downup") |> ungroup()    # down, then up for leading NAs
# zoo version: na.locf(x, na.rm = FALSE); na.locf(x, fromLast = TRUE) for NOCB

# Linear interpolation (smooth series: GDP, prices, population)
df |> group_by(id) |> mutate(x1 = na.approx(x1, na.rm = FALSE)) |> ungroup()
# Spline (curved series; can overshoot)
# df |> group_by(id) |> mutate(x1 = na.spline(x1)) |> ungroup()
# Seasonal-aware for ts objects: forecast::na.interp(y)
# Limit the gap size so you don't invent long stretches:
# na.approx(x, maxgap = 3, na.rm = FALSE)

# When to use which:
#   LOCF          : stock-like, slow-changing (status, policy rate, category)
#   Interpolation : flows with smooth trends
#   Neither       : if the gap itself is informative, or the series is a rate that jumps
# Caution: LOCF/interpolation of the OUTCOME can create fake persistence and bias dynamic models.

# ============ D. MULTIPLE IMPUTATION (the default for MAR) ============
# Predictive mean matching works for numeric vars and keeps values realistic.
imp <- mice(df |> select(y, x1, x2, x3, region), m = 5, method = "pmm", maxit = 10, seed = 42)
plot(imp)                                    # trace plots: lines should mix, no trend
densityplot(imp)                             # imputed (red) vs observed (blue) distributions
stripplot(imp, x1 ~ .imp)

# Fit the model in each completed dataset and pool with Rubin's rules
fit <- with(imp, lm(y ~ x1 + x2 + x3 + region))
summary(pool(fit))
# Include the outcome and all analysis variables in the imputation model.
# Panel data: add the id as a predictor or impute within-unit (mice 2l.pmm for multilevel).
# complete(imp, 1) gives one completed dataset if you only need a single fill.

# ============ E. OTHER IMPUTERS ============
# kNN (fast, nonparametric)
df_knn <- VIM::kNN(df, k = 5, imp_var = FALSE)
# Random forest (handles nonlinearity and mixed types; slower)
# library(missForest); df_rf <- missForest(as.data.frame(df))$ximp
# Inside tidymodels recipes: step_impute_knn(), step_impute_median(), step_impute_mode()
# Time series with structural model: imputeTS::na_kalman(y)

# ============ WHICH METHOD FOR WHICH MECHANISM ============
#   MCAR, small share  : listwise deletion is fine
#   MAR                : multiple imputation (mice) conditioning on observed predictors
#   Ordered data       : interpolation / LOCF within unit, with a max gap
#   MNAR               : no method is safe; use MI plus sensitivity analysis and say so
