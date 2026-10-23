# 03_sensitivity_and_reporting.R - show the result does not hinge on how you handled missingness.
library(tidyverse); library(mice); library(modelsummary)
df <- readRDS("out/clean.rds")
f <- y ~ x1 + x2 + x3

# ---- 1. SAME MODEL, DIFFERENT HANDLING ----
m_cc   <- lm(f, data = drop_na(df, y, x1, x2, x3))                       # complete case
m_med  <- lm(f, data = df |> mutate(across(c(x1, x2, x3), ~ replace_na(.x, median(.x, na.rm = TRUE)))))
imp    <- mice(df |> select(y, x1, x2, x3), m = 5, method = "pmm", seed = 42, printFlag = FALSE)
m_mi   <- pool(with(imp, lm(f)))

modelsummary(list("Complete case" = m_cc, "Median fill" = m_med, "Multiple imp." = m_mi),
             stars = TRUE, output = "out/missing_robustness.html")
# If the key coefficient barely moves across columns, missingness is not driving your result.
# If it moves a lot, say so and lead with the multiple-imputation estimate.

# ---- 2. MNAR SENSITIVITY: DELTA ADJUSTMENT (tipping-point analysis) ----
# Ask: how much lower/higher would the missing values need to be, relative to what MAR
# imputation predicts, before my conclusion changes?
ini  <- mice(df |> select(y, x1, x2, x3), maxit = 0)
post <- ini$post
for (delta in c(0, -0.5, -1, -2)) {                      # in units of x1; try both signs
  post["x1"] <- paste("imp[[j]][, i] <- imp[[j]][, i] +", delta)
  imp_d <- mice(df |> select(y, x1, x2, x3), m = 5, method = "pmm", post = post,
                seed = 42, printFlag = FALSE)
  est <- summary(pool(with(imp_d, lm(f))), conf.int = TRUE)
  cat("delta =", delta, " beta_x2 =", round(est$estimate[est$term == "x2"], 3), "\n")
}
# Report the delta at which significance or sign flips. A large tipping point = robust result.

# ---- 3. SELECTION MODEL (MNAR, needs an exclusion restriction) ----
# library(sampleSelection)
# heckit(selection = observed ~ z + x2 + x3,      # z affects whether y is seen, not y itself
#        outcome   = y ~ x2 + x3, data = df)
# Significant inverse Mills ratio -> selection bias is present.

# ---- 4. WHAT TO WRITE IN THE PRESENTATION ----
# - X% of rows had at least one missing value; variables A, B were most affected.
# - Little's test p = ___, and ___ predicted missingness, so we treated the data as MCAR / MAR.
# - We used ___ (listwise / MI with m = 5 / within-unit interpolation capped at 3 periods).
# - Results are (not) sensitive: complete-case and imputed estimates are ___.
# - MNAR cannot be ruled out; tipping-point analysis shows conclusions flip only if ___.
