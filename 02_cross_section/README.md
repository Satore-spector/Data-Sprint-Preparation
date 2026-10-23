# 02_cross_section

Quick index for data with one observation per unit (no time dimension). Reads `out/clean.rds`.

## What's in each script

| Script | Use it for | What's inside (in order) |
|---|---|---|
| `01_hypothesis_tests.R` | Classical tests comparing groups or checking association | Normality / one-sample t / two-sample t (+ Wilcoxon) / paired t / ANOVA + Tukey + Kruskal / chi-square independence + goodness of fit / correlation / proportions |
| `02_ols.R` | Linear regression with honest standard errors | Baseline OLS / robust and clustered SEs / specification ladder (FE dummies, log, interaction, square) / results table + coefficient plot / interpretation cheat sheet / IV (commented) |
| `03_binary_models.R` | Yes/no outcomes (also pointers for counts, censored) | Logit and probit / odds ratios / average marginal effects / pseudo-R2 / confusion table + accuracy / ROC (commented) |
| `04_diagnostics.R` | Checking OLS assumptions | Diagnostic plots / heteroskedasticity / RESET / VIF / normality / Cook's distance / autocorrelation |

## Find it fast

| I want to... | Script | Look for |
|---|---|---|
| Test if a variable is normal | `01` | `shapiro.test` |
| Compare means of 2 groups | `01` | `t.test(y ~ g)`, `wilcox.test` if not normal |
| Check equal variances | `01` | `var.test`, `leveneTest` |
| Compare means of 3+ groups | `01` | `aov`, `TukeyHSD`, `kruskal.test` |
| Test association of two categories | `01` | `chisq.test`, `fisher.test` if counts small |
| Effect sizes | `01` | `cohens_d`, `cramer_v` (commented) |
| Correlation with a p-value | `01` | `cor.test` |
| Compare two proportions | `01` | `prop.test` |
| Run a regression | `02` | `lm` |
| Get robust or clustered SEs | `02` | `coeftest` + `vcovHC` / `vcovCL` |
| Test several coefficients together | `02` | `linearHypothesis` (commented) |
| Compare nested models | `02` | `anova`, `AIC` |
| Make a regression table | `02` | `modelsummary` |
| Plot coefficients | `02` | PRESENT section, `tidy` + `geom_pointrange` |
| Interpret log models | `02` | INTERPRETATION CHEAT SHEET |
| Instrumental variables | `02` | `feols(... \| x ~ z)` (commented) |
| Logit / probit | `03` | `glm(..., family = binomial)` |
| Marginal effects | `03` | `avg_slopes` |
| Odds ratios | `03` | `exp(coef(logit))` |
| Count or censored outcome | `03` | last lines (`glm.nb`, `tobit`, commented) |
| Heteroskedasticity test | `04` | `bptest` |
| Wrong functional form test | `04` | `resettest` |
| Multicollinearity | `04` | `vif` |
| Influential points | `04` | `cooks.distance`, `influencePlot` |

Marked **(c)** below means the function is inside a commented-out line. Uncomment it to use it.

## Appendix: every function used

Base R basics (`c`, `list`, `length`, `mean`, `min`, `which`, `nrow`, `sample`, `table`, `summary`, `plot`, `par`) are left out.

### stats (base R)
- `stats::shapiro.test` - tests if data are normal (H0: normal)
- `stats::t.test` - t-test for means (one-sample, two-sample Welch, paired)
- `stats::var.test` - tests if two groups have equal variance
- `stats::wilcox.test` - rank-based alternative to the t-test
- `stats::aov` - one-way ANOVA across groups
- `stats::TukeyHSD` - which pairs of groups differ after ANOVA
- `stats::kruskal.test` - rank-based alternative to ANOVA
- `stats::chisq.test` - chi-square test of independence or goodness of fit
- `stats::fisher.test` **(c)** - exact test for small-count tables
- `stats::cor.test` - correlation with a p-value (Pearson or Spearman)
- `stats::prop.test` **(c)** - tests one or two proportions
- `stats::lm` - linear regression
- `stats::glm` - generalised linear model (logit, probit, poisson)
- `stats::binomial` - the family argument that makes `glm` a logit/probit
- `stats::anova` - F-test comparing nested models
- `stats::AIC` - model comparison score (lower is better)
- `stats::logLik` - model log-likelihood (used for pseudo-R2)
- `stats::predict` - fitted or predicted values from a model
- `stats::coef` / `stats::resid` / `stats::fitted` - coefficients / residuals / fitted values
- `stats::cooks.distance` - influence of each observation
- `stats::reorder` - sorts a factor by another variable (for tidy plots)
- `base::exp` - exponential (turns log-odds into odds ratios)
- `base::as.integer` - turns TRUE/FALSE into 1/0

### car
- `car::vif` - variance inflation factor (multicollinearity)
- `car::leveneTest` - tests equal variance across groups
- `car::linearHypothesis` **(c)** - joint test of several coefficients
- `car::influencePlot` - plot of influential, high-leverage points

### sandwich / lmtest
- `sandwich::vcovHC` - heteroskedasticity-robust covariance matrix
- `sandwich::vcovCL` - cluster-robust covariance matrix
- `lmtest::coeftest` - coefficient table using a chosen covariance matrix
- `lmtest::bptest` - Breusch-Pagan heteroskedasticity test
- `lmtest::resettest` - RESET test for wrong functional form
- `lmtest::dwtest` - Durbin-Watson autocorrelation test
- `lmtest::bgtest` - Breusch-Godfrey higher-order autocorrelation test

### broom / modelsummary / marginaleffects
- `broom::tidy` - model results as a tidy data frame
- `modelsummary::modelsummary` - side-by-side regression table (html, word, etc.)
- `marginaleffects::avg_slopes` - average marginal effects
- `marginaleffects::plot_predictions` **(c)** - plot predictions across one variable

### rstatix / pROC / fixest / MASS / AER
- `rstatix::cohens_d` **(c)** - effect size for a two-group mean difference
- `rstatix::cramer_v` **(c)** - effect size for a chi-square table
- `pROC::roc` **(c)** - builds a ROC curve
- `pROC::auc` **(c)** - area under the ROC curve
- `fixest::feols` **(c)** - fast OLS / IV with fixed effects
- `MASS::glm.nb` **(c)** - negative binomial regression for overdispersed counts
- `AER::tobit` **(c)** - regression for censored outcomes

### ggplot2 / dplyr
- `ggplot2::ggplot` / `ggplot2::aes` - start a plot and map variables
- `ggplot2::geom_pointrange` - point with confidence interval bars
- `ggplot2::geom_vline` - vertical reference line
- `ggplot2::labs` - axis and plot labels
- `dplyr::filter` - keeps rows meeting a condition
