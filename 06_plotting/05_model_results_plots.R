# 05_model_results_plots.R - plot regression results, diagnostics, predictions, classification, forecasts.
library(tidyverse); library(broom); library(scales)
theme_set(theme_minimal(base_size = 13))

# ---- DEMO MODELS (replace with your own lm / glm objects) ----
fit  <- lm(mpg ~ wt + hp + factor(cyl), data = mtcars)
fit0 <- lm(mpg ~ wt, data = mtcars)
fitl <- glm(am ~ wt + hp, data = mtcars, family = binomial)

# ---- COEFFICIENT PLOT ----
tidy(fit, conf.int = TRUE) |> filter(term != "(Intercept)") |>
  ggplot(aes(estimate, fct_reorder(term, estimate), xmin = conf.low, xmax = conf.high)) +
  geom_pointrange() + geom_vline(xintercept = 0, linetype = 2) + labs(x = "Coefficient (95% CI)", y = NULL)
# robust CIs: tidy(lmtest::coeftest(fit, vcov = sandwich::vcovHC(fit, "HC1")), conf.int = TRUE)

# Compare coefficients across models
bind_rows(tidy(fit0, conf.int = TRUE) |> mutate(model = "Simple"),
          tidy(fit,  conf.int = TRUE) |> mutate(model = "Full")) |>
  filter(term == "wt") |>
  ggplot(aes(estimate, model, xmin = conf.low, xmax = conf.high)) + geom_pointrange() +
  geom_vline(xintercept = 0, linetype = 2) + labs(title = "Effect of weight across specifications", y = NULL)

# ---- OLS DIAGNOSTICS (ggplot versions of plot(lm)) ----
a <- augment(fit)
ggplot(a, aes(.fitted, .resid)) + geom_point() + geom_hline(yintercept = 0, linetype = 2) +
  geom_smooth(se = FALSE) + labs(title = "Residuals vs fitted")                       # want: no pattern
ggplot(a, aes(sample = .std.resid)) + stat_qq() + stat_qq_line(colour = "red")        # want: on the line
ggplot(a, aes(.fitted, sqrt(abs(.std.resid)))) + geom_point() + geom_smooth(se = FALSE) +
  labs(title = "Scale-location", y = "sqrt |standardised residual|")                  # want: flat
ggplot(a, aes(seq_along(.cooksd), .cooksd)) + geom_col() +
  geom_hline(yintercept = 4 / nrow(a), linetype = 2) + labs(x = "Observation", y = "Cook's distance")
ggplot(a, aes(.hat, .std.resid, size = .cooksd)) + geom_point(alpha = .6) + labs(x = "Leverage")
ggplot(a, aes(.resid)) + geom_histogram(bins = 15)                                    # residual shape

# ---- PREDICTED VS ACTUAL ----
ggplot(a, aes(.fitted, mpg)) + geom_point() + geom_abline(slope = 1, intercept = 0, linetype = 2)

# ---- EFFECT OF ONE VARIABLE WITH A CONFIDENCE BAND ----
nd <- tibble(wt = seq(min(mtcars$wt), max(mtcars$wt), length.out = 100), hp = mean(mtcars$hp), cyl = 6)
pr <- bind_cols(nd, as_tibble(predict(fit, nd, interval = "confidence")))
ggplot(pr, aes(wt, fit)) + geom_ribbon(aes(ymin = lwr, ymax = upr), alpha = .2) + geom_line() +
  geom_point(data = mtcars, aes(wt, mpg), alpha = .4, inherit.aes = FALSE) + labs(y = "Predicted mpg")
# easier: marginaleffects::plot_predictions(fit, condition = "wt")

# ---- BINARY OUTCOME: PROBABILITY CURVE, ODDS RATIOS ----
mtcars |> mutate(p = predict(fitl, type = "response")) |>
  ggplot(aes(wt, p)) + geom_point(aes(y = am), alpha = .4) + geom_line() + labs(y = "P(am = 1)")
tidy(fitl, conf.int = TRUE, exponentiate = TRUE) |> filter(term != "(Intercept)") |>
  ggplot(aes(estimate, term, xmin = conf.low, xmax = conf.high)) + geom_pointrange() +
  geom_vline(xintercept = 1, linetype = 2) + scale_x_log10() + labs(x = "Odds ratio (log scale)", y = NULL)

# ---- CLASSIFICATION: ROC AND CONFUSION MATRIX ----
p <- predict(fitl, type = "response"); y <- mtcars$am
roc <- bind_rows(lapply(c(0, sort(unique(p)), 1), function(t)
  tibble(thr = t, tpr = mean(p[y == 1] >= t), fpr = mean(p[y == 0] >= t)))) |> arrange(fpr, tpr)
auc <- sum(diff(roc$fpr) * (head(roc$tpr, -1) + tail(roc$tpr, -1)) / 2)
ggplot(roc, aes(fpr, tpr)) + geom_line() + geom_abline(linetype = 2) + coord_fixed() +
  labs(title = paste0("ROC curve (AUC = ", round(auc, 2), ")"), x = "False positive rate", y = "True positive rate")
tibble(actual = factor(y), pred = factor(as.integer(p > .5))) |> count(actual, pred) |>
  ggplot(aes(pred, actual, fill = n)) + geom_tile() + geom_text(aes(label = n), colour = "white", size = 6) +
  scale_fill_viridis_c(guide = "none") + labs(x = "Predicted", y = "Actual")
# if you used pROC: ggroc(pROC::roc(y, p))

# ---- VARIABLE IMPORTANCE (swap in vip / ranger output) ----
tibble(var = c("wt", "hp", "disp", "qsec"), imp = c(.42, .31, .15, .08)) |>
  ggplot(aes(imp, fct_reorder(var, imp))) + geom_col() + labs(x = "Importance", y = NULL)
# tidymodels: vip::vip(final_fit); tuning curve: autoplot(tune_results)

# ---- BOOTSTRAP / SIMULATION DISTRIBUTION ----
set.seed(1)
boot <- tibble(b = replicate(1000, coef(lm(mpg ~ wt, data = mtcars[sample(nrow(mtcars), replace = TRUE), ]))[2]))
ggplot(boot, aes(b)) + geom_histogram(bins = 30) +
  geom_vline(xintercept = quantile(boot$b, c(.025, .975)), linetype = 2, colour = "red")

# ---- FORECAST: ACTUAL, FORECAST, BAND ----
set.seed(2)
act <- tibble(t = 1:60, v = cumsum(rnorm(60)))
fc  <- tibble(t = 61:72, v = last(act$v)) |> mutate(lo = v - 1.96 * sqrt(seq_along(v)), hi = v + 1.96 * sqrt(seq_along(v)))
ggplot() + geom_line(data = act, aes(t, v)) +
  geom_ribbon(data = fc, aes(t, ymin = lo, ymax = hi), alpha = .2, fill = "steelblue") +
  geom_line(data = fc, aes(t, v), colour = "steelblue", linetype = 2) +
  geom_vline(xintercept = 60.5, linetype = 3)
# forecast package: autoplot(forecast(fit, h = 12))

# ---- IMPULSE RESPONSE / EVENT STUDY (coefficient path with band) ----
es <- tibble(rel = -4:4, est = c(.02, -.01, .03, 0, .4, .6, .7, .65, .6)) |> mutate(se = .1, lo = est - 1.96 * se, hi = est + 1.96 * se)
ggplot(es, aes(rel, est)) + geom_ribbon(aes(ymin = lo, ymax = hi), alpha = .2) + geom_line() + geom_point() +
  geom_hline(yintercept = 0, linetype = 2) + geom_vline(xintercept = -.5, linetype = 3) +
  labs(x = "Periods relative to treatment", y = "Effect")
# vars::irf object i:  tibble(h = 0:12, irf = i$irf[[1]][, 1], lo = i$Lower[[1]][, 1], hi = i$Upper[[1]][, 1])

# ---- CLUSTERS / PCA-STYLE SCATTER WITH ELLIPSES ----
ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) + geom_point() + stat_ellipse()
