# 04_panel

Quick index for many units observed over several periods (e.g. countries by year). Scripts run in order, and later ones read `out/pdata.rds` made by `01`.

## What's in each script

| Script | Use it for | What's inside (in order) |
|---|---|---|
| `01_panel_prep.R` | Declaring the panel and understanding it | Config (id, time) / `pdata.frame` + dimensions / balance and attrition / within vs between variation / line plots / panel unit-root tests (commented) / save `out/pdata.rds` |
| `02_pooled_fe_re.R` | Estimating and choosing between panel models | Pooled, entity FE, two-way FE, RE / F-test, LM test, Hausman test / clustered SEs / `fixest` versions / diff-in-diff + event study (commented) / results table / dynamic panel GMM (commented) |
| `03_tests_robustness.R` | Checking the FE model and fixing standard errors | Serial correlation / cross-sectional dependence / heteroskedasticity / clustered and Driscoll-Kraay SEs / robustness menu / write-up reminders |

## Find it fast

| I want to... | Script | Look for |
|---|---|---|
| Tell R which column is the id and which is time | `01` | `pdata.frame` |
| Check balanced vs unbalanced | `01` | `pdim`, `punbalancedness` (commented) |
| Find duplicate id-time rows | `01` | comment under `pdata.frame` |
| See within vs between variation | `01` | `summary(pdata$x)` |
| Test unit roots in a panel | `01` | `purtest` (commented) |
| Run pooled, FE or RE | `02` | `plm(model = "pooling" / "within" / "random")` |
| Add time effects | `02` | `effect = "twoways"` |
| Fixed effects or pooled? | `02` | `pFtest` |
| Random effects or pooled? | `02` | `plmtest` |
| Fixed or random effects? | `02` | `phtest` (Hausman) |
| Clustered standard errors | `02` | `vcovHC(cluster = "group")`, `feols(cluster = ~id)` |
| Fast fixed effects | `02` | `feols(y ~ x \| id + year)` |
| Compare fixest models | `02` | `etable` |
| Difference-in-differences | `02` | `feols(y ~ treated:post \| id + year)` (commented) |
| Event study | `02` | `i(rel_time, treated)` + `iplot` (commented) |
| Lagged dependent variable | `02` | `pgmm` (commented) |
| Test for serial correlation | `03` | `pwartest`, `pbgtest` |
| Test for cross-sectional dependence | `03` | `pcdtest` |
| Test for heteroskedasticity | `03` | `bptest` |
| Driscoll-Kraay standard errors | `03` | `vcovSCC` |
| Ideas for robustness checks | `03` | ROBUSTNESS MENU |

Marked **(c)** below means the function is inside a commented-out line. Uncomment it to use it.

## Appendix: every function used

Base R basics (`c`, `list`, `factor`, `mean`, `summary`, `as.data.frame`) are left out.

### plm
- `plm::pdata.frame` - declares the id and time columns of a panel
- `plm::pdim` - number of units, periods, and whether it's balanced
- `plm::punbalancedness` **(c)** - how unbalanced the panel is
- `plm::purtest` **(c)** - panel unit-root tests (Levin-Lin-Chu, IPS)
- `plm::plm` - estimates pooled, within (FE), random, and two-way models
- `plm::pFtest` - F-test for fixed effects vs pooled
- `plm::plmtest` - Breusch-Pagan LM test for random effects vs pooled
- `plm::phtest` - Hausman test (reject means use FE)
- `plm::pgmm` **(c)** - dynamic panel GMM (Arellano-Bond)
- `plm::pwartest` - Wooldridge test for serial correlation in FE models
- `plm::pbgtest` - Breusch-Godfrey test for panels
- `plm::pcdtest` - Pesaran CD test for cross-sectional dependence
- `plm::vcovSCC` - Driscoll-Kraay standard errors
- `stats::lag` **(c)** - lags a variable by a number of periods (used in `pgmm` and the robustness ideas)

### sandwich / lmtest
- `sandwich::vcovHC` - robust or clustered covariance matrix (has a `plm` method)
- `lmtest::coeftest` - coefficient table using a chosen covariance matrix
- `lmtest::bptest` - Breusch-Pagan heteroskedasticity test

### fixest
- `fixest::feols` - fast OLS with fixed effects and clustering
- `fixest::etable` - side-by-side table of fixest models
- `fixest::iplot` **(c)** - event-study coefficient plot
- `fixest::i` **(c)** - interacts a factor with a treatment, used for event studies

### modelsummary
- `modelsummary::modelsummary` - regression table for several models

### dplyr / ggplot2
- `dplyr::count` - counts rows per group (units per period, duplicate checks)
- `dplyr::group_by` / `dplyr::summarise` - mean of the outcome per period
- `dplyr::filter` **(c)** - keeps rows meeting a condition
- `ggplot2::ggplot` / `ggplot2::aes` - start a plot
- `ggplot2::geom_line` - line plot (one line per unit, or the average over time)
