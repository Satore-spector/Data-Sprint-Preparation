# 05_missing_data

Quick index for diagnosing and handling missing values. Reads `out/clean.rds`.

## What's in each script

| Script | Use it for | What's inside (in order) |
|---|---|---|
| `01_diagnose_mechanism.R` | Finding out how much is missing and why (MCAR / MAR / MNAR) | Missingness size and patterns / Little's MCAR test / MAR checks (t-tests, chi-square, logit on a missing flag) / notes on why MNAR can't be tested / decision guide |
| `02_handling_methods.R` | Actually fixing the gaps | A: deletion / B: simple fills (median, flag, "Missing" level, group mean) / C: copy down, copy up, interpolate, spline / D: multiple imputation with `mice` / E: kNN, random forest, Kalman / which method for which mechanism |
| `03_sensitivity_and_reporting.R` | Showing the result doesn't depend on how you handled gaps | Same model under three methods / tipping-point (delta) analysis for MNAR / selection model (commented) / what to write in the presentation |

## Which mechanism am I in?

| Type | Meaning | How to check | What to do |
|---|---|---|---|
| MCAR | Missing at random, unrelated to anything | Little's test p > 0.05 and no variable predicts the missing flag | Dropping rows is fine if the share is small |
| MAR | Missing depends on variables we can see | Other variables predict the missing flag (t-test, chi-square, logit) | Multiple imputation (`mice`) |
| MNAR | Missing depends on the missing value itself | Cannot be tested from the data. Reason about how the data were collected | Impute, then run the sensitivity analysis and state the limit |

## Find it fast

| I want to... | Script | Look for |
|---|---|---|
| Count missing per variable | `01` | `miss_var_summary` |
| Find rows with the most gaps | `01` | `miss_case_summary` |
| See where the gaps are | `01` | `vis_miss` |
| See which variables go missing together | `01` | `gg_miss_upset`, `md.pattern` |
| Test MCAR | `01` | `mcar_test` |
| Test MAR | `01` | section 3: `t.test`, `chisq.test`, `glm` on the missing flag |
| Drop incomplete rows | `02` | A: `drop_na` |
| Fill with median or mean | `02` | B: `replace_na` |
| Keep a flag for what was missing | `02` | B: missing indicator |
| Treat NA as its own category | `02` | B: `fct_na_value_to_level` |
| Fill with the group average | `02` | B: `coalesce` |
| Copy the last value down | `02` | C: `fill(.direction = "down")`, `na.locf` |
| Interpolate between points | `02` | C: `na.approx`, `na.spline`, `na.interp` |
| Limit how long a gap can be filled | `02` | C: `maxgap` |
| Multiple imputation | `02` | D: `mice`, `pool`, `with` |
| Check imputed vs observed values | `02` | D: `densityplot`, `stripplot`, `plot(imp)` |
| Nearest-neighbour imputation | `02` | E: `kNN` |
| Random forest imputation | `02` | E: `missForest` (commented) |
| Compare results across methods | `03` | section 1 |
| Test sensitivity to MNAR | `03` | section 2: delta adjustment |
| Selection model | `03` | section 3: `heckit` (commented) |
| Wording for the presentation | `03` | section 4 |

Marked **(c)** below means the function is inside a commented-out line. Uncomment it to use it.

## Appendix: every function used

Base R basics (`c`, `list`, `round`, `cat`, `paste`, `nrow`, `table`, `head`, `sum`, `summary`, `plot`) are left out.

### naniar
- `naniar::miss_var_summary` - missing count and percent per variable
- `naniar::miss_case_summary` - missing count and percent per row
- `naniar::vis_miss` - picture of every missing cell
- `naniar::gg_miss_upset` - which combinations of variables are missing together
- `naniar::mcar_test` - Little's test (H0: data are MCAR)
- `naniar::geom_miss_point` **(c)** - scatter plot that also shows missing values

### mice
- `mice::md.pattern` - table of missingness patterns
- `mice::mice` - multiple imputation by chained equations
- `mice::complete` - extracts one completed dataset from a `mice` result
- `mice::pool` - combines estimates across imputed datasets (Rubin's rules)
- `mice::with` - fits a model in every imputed dataset
- `mice::densityplot` - compares imputed and observed distributions
- `mice::stripplot` - shows imputed values by imputation number
- `mice::plot` - trace plots to check convergence

### tidyr / dplyr / forcats
- `tidyr::drop_na` - removes rows with missing values
- `tidyr::replace_na` - fills NAs with a chosen value
- `tidyr::fill` - copies the previous (or next) value into gaps
- `tidyr::pivot_longer` - reshapes wide to long
- `dplyr::mutate` / `dplyr::select` - add or change columns / pick columns
- `dplyr::group_by` / `dplyr::ungroup` - apply steps within each group, then stop
- `dplyr::summarise` - collapses to summary numbers
- `dplyr::arrange` - sorts rows (sort before copying down or interpolating)
- `dplyr::coalesce` - takes the first non-missing value
- `forcats::fct_na_value_to_level` - makes NA its own factor level

### zoo / forecast / imputeTS
- `zoo::na.locf` - last observation carried forward (and backward)
- `zoo::na.approx` - linear interpolation
- `zoo::na.spline` - spline interpolation
- `forecast::na.interp` **(c)** - seasonal-aware interpolation for ts objects
- `imputeTS::na_kalman` **(c)** - Kalman smoothing imputation for time series

### VIM / missForest / recipes
- `VIM::kNN` - fills gaps from the k most similar rows
- `missForest::missForest` **(c)** - random forest imputation
- `recipes::step_impute_knn` / `recipes::step_impute_median` / `recipes::step_impute_mode` **(c)** - the same fills inside a tidymodels recipe

### stats / modelling
- `stats::complete.cases` - TRUE for rows with no missing values
- `stats::t.test` - tests if an observed variable differs between missing and non-missing rows
- `stats::chisq.test` **(c)** - same idea for categorical variables
- `stats::glm` - logit of the missing flag on observed variables
- `stats::lm` - regression used to compare handling methods
- `stats::cor` - correlation (pairwise-complete option)
- `base::tryCatch` - keeps a loop running if one test fails
- `sampleSelection::heckit` **(c)** - Heckman selection model for MNAR
- `modelsummary::modelsummary` - side-by-side table of results by method

### ggplot2
- `ggplot2::ggplot` / `ggplot2::aes` - start a plot
- `ggplot2::geom_density` **(c)** - density plot of a variable split by missing or not
