# 01_diagnose_mechanism.R - how much is missing, where, and is it MCAR / MAR / MNAR?
library(tidyverse); library(naniar); library(mice)
df <- readRDS("out/clean.rds")

# ---- 1. SIZE AND SHAPE OF THE PROBLEM ----
miss_var_summary(df)                     # % missing per variable
miss_case_summary(df) |> head(10)        # rows with the most missing
n_complete <- sum(complete.cases(df)); n_complete / nrow(df)   # share of rows that survive listwise deletion
vis_miss(df, cluster = TRUE)             # where the holes are
gg_miss_upset(df)                        # which variables go missing together
md.pattern(df, rotate.names = TRUE)      # exact missingness patterns

# Rule of thumb: <5% missing and plausibly random -> deletion is usually fine.
# 5-40% -> impute. >40% in a variable -> consider dropping the variable.

# ---- 2. TEST FOR MCAR ----
# Little's test. H0 = data are MCAR.  p < 0.05 -> NOT MCAR (so MAR or MNAR).
# Needs numeric variables; keep a sensible subset. Failing to reject does not PROVE MCAR.
df |> select(where(is.numeric)) |> mcar_test()

# ---- 3. TEST FOR MAR: does missingness depend on OBSERVED variables? ----
# Pick the variable with missing values, make an indicator, and see what predicts it.
target <- "income"                                     # CHANGE ME
d <- df |> mutate(miss = as.integer(is.na(.data[[target]])))

# 3a. Compare observed variables across missing / not missing (t-tests)
d |> select(miss, where(is.numeric), -all_of(target)) |>
  pivot_longer(-miss) |>
  group_by(name) |>
  summarise(p_value = tryCatch(t.test(value ~ miss)$p.value, error = function(e) NA_real_),
            mean_obs = mean(value[miss == 0], na.rm = TRUE),
            mean_miss = mean(value[miss == 1], na.rm = TRUE)) |>
  arrange(p_value)

# 3b. Categorical predictors of missingness (chi-square)
# chisq.test(table(d$region, d$miss))

# 3c. Logit of the indicator on everything observed. Significant predictors -> MAR (at least).
m_miss <- glm(miss ~ ., data = d |> select(miss, where(is.numeric), -all_of(target)) |> drop_na(),
              family = binomial)
summary(m_miss)
# If ANY observed variable predicts missingness, you can rule out MCAR.

# 3d. Visual: distribution of an observed variable split by missingness
# ggplot(d, aes(age, fill = factor(miss))) + geom_density(alpha = .4)
# naniar::geom_miss_point() shows missing values on a scatter

# ---- 4. MNAR: CANNOT BE TESTED FROM THE DATA ----
# MNAR = missingness depends on the unobserved value itself (high earners hide income).
# The data you have cannot confirm or rule this out. Instead:
#   - Argue from the data-generating process: why would this value be absent?
#   - Look for a sign: missingness rising with the observed extremes of related variables
#   - Run sensitivity analysis (see 03_sensitivity_and_reporting.R)
#   - Selection-model option: sampleSelection::heckit (needs an exclusion restriction)
#
# QUICK DECISION GUIDE
#   Little's p > .05 and no observed variable predicts missingness -> treat as MCAR
#   Observed variables predict missingness                         -> treat as MAR (use MI)
#   Missingness plausibly tied to the value itself                 -> MNAR (sensitivity analysis)
