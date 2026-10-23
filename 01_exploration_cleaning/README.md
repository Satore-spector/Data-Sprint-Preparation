# 01_exploration_cleaning

Quick index so you don't have to open every script. Run these first, on any dataset.

## What's in each script

| Script | Use it for | What's inside (in order) |
|---|---|---|
| `00_setup.R` | Installing and loading every package the repo uses. Run once per machine. | Package list, auto-install of missing ones, plot theme, `out/` folder, seed |
| `01_load_clean.R` | Getting raw data into a tidy, typed data frame | Config (path, outcome) / load csv or xlsx / fix types / duplicates / missing counts / outlier flags + winsorising / log transforms / save `out/clean.rds` |
| `02_eda.R` | First look at the data | Profile / outcome histogram + QQ / all numeric distributions / correlation plot / outcome vs each predictor / categorical counts / group summaries |

## Find it fast

| I want to... | Script | Section |
|---|---|---|
| Install everything | `00_setup.R` | whole file |
| Read a csv or Excel file | `01_load_clean.R` | LOAD |
| Standardise column names | `01_load_clean.R` | LOAD (`clean_names`) |
| Convert text to factor or date | `01_load_clean.R` | TYPES (commented) |
| Remove duplicate rows | `01_load_clean.R` | DUPLICATES |
| Count missing values per column | `01_load_clean.R` | MISSING |
| Flag or cap outliers | `01_load_clean.R` | OUTLIERS (`iqr_flag`, `winsor`) |
| Log-transform a skewed variable | `01_load_clean.R` | TRANSFORMS |
| Summary stats for every variable | `02_eda.R` | PROFILE (`skim`) |
| Check if the outcome is normal | `02_eda.R` | OUTCOME (histogram, QQ) |
| See all variable distributions | `02_eda.R` | NUMERIC DISTRIBUTIONS |
| See which variables correlate | `02_eda.R` | CORRELATIONS |
| Plot outcome against every predictor | `02_eda.R` | OUTCOME VS PREDICTORS |
| Mean of the outcome by group | `02_eda.R` | GROUP SUMMARIES (commented) |

Both scripts read and write `out/clean.rds`. `01_load_clean.R` creates it, and every other folder reads it.

Marked **(c)** below means the function is inside a commented-out line. Uncomment it to use it.

## Appendix: every function used

Base R basics (`c`, `list`, `length`, `sum`, `mean`, `head`, `print`) are left out.

### base / stats / utils
- `base::installed.packages` - lists packages already installed
- `utils::install.packages` - installs packages from CRAN
- `base::setdiff` - items in the first vector but not the second (finds missing packages)
- `base::library` - loads a package
- `base::lapply` - applies a function to each item of a list
- `base::invisible` - runs something without printing the result
- `base::dir.create` - makes a folder (the `out/` folder)
- `base::set.seed` - fixes the random number generator so results repeat
- `base::message` - prints a note to the console
- `base::rownames` - gets row names (used on the installed-packages table)
- `base::grepl` - TRUE if text matches a pattern (checks file extension)
- `base::readRDS` / `base::saveRDS` - read / save a single R object to disk
- `base::colSums` - sums each column (with `is.na`, counts missing values)
- `base::is.na` - TRUE where a value is missing
- `base::duplicated` - TRUE for repeated rows
- `base::sort` - orders a vector
- `base::log` / `base::log1p` - natural log / log(1 + x), safe for zeros
- `base::pmin` / `base::pmax` - element-wise minimum / maximum (used for capping)
- `base::diff` - difference between neighbouring values (here it turns two quantiles into the IQR)
- `stats::quantile` - percentile values
- `stats::median` / `stats::sd` / `stats::cor` - median, standard deviation, correlation
- `base::as.factor` **(c)** - turns text into a category variable

### readr / readxl / haven
- `readr::read_csv` - reads a csv file into a tibble
- `readxl::read_excel` - reads an .xls or .xlsx sheet
- `haven::read_dta` **(c)** - reads a Stata .dta file

### janitor
- `janitor::clean_names` - makes column names lowercase with underscores

### dplyr
- `dplyr::mutate` - adds or changes columns
- `dplyr::select` - picks columns
- `dplyr::distinct` - drops duplicate rows
- `dplyr::group_by` - splits data by group for later summaries
- `dplyr::summarise` - collapses each group to summary numbers
- `dplyr::count` - counts rows per category
- `dplyr::across` - applies a function to many columns at once
- `dplyr::n` - number of rows in the group
- `dplyr::na_if` - turns a chosen value (such as "NA") into a real NA
- `dplyr::glimpse` - compact view of every column and type
- `dplyr::everything` / `dplyr::all_of` / `dplyr::where` - helpers for picking columns by name or type

### tidyr / stringr / lubridate
- `tidyr::drop_na` - removes rows with missing values
- `tidyr::replace_na` - fills NAs with a chosen value
- `tidyr::pivot_longer` - reshapes wide columns into long name/value pairs
- `stringr::str_trim` **(c)** - removes stray spaces around text
- `lubridate::ymd` / `lubridate::dmy` / `lubridate::mdy` **(c)** - parse dates written year-month-day / day-month-year / month-day-year

### skimr / naniar / corrplot / GGally
- `skimr::skim` - one-screen summary of every variable
- `naniar::miss_var_summary` - missing count and percent per variable
- `naniar::gg_miss_var` - bar chart of missing values per variable
- `corrplot::corrplot` - colour matrix of correlations
- `GGally::ggpairs` **(c)** - grid of scatter plots and correlations for a few variables

### ggplot2
- `ggplot2::ggplot` / `ggplot2::aes` - start a plot and map variables to axes
- `ggplot2::geom_histogram` - histogram
- `ggplot2::stat_qq` / `ggplot2::stat_qq_line` - normal QQ plot and its reference line
- `ggplot2::geom_point` / `ggplot2::geom_smooth` - scatter points / fitted trend line
- `ggplot2::facet_wrap` - one small plot per variable
- `ggplot2::geom_boxplot` **(c)** - boxplot by group
- `ggplot2::theme_set` / `ggplot2::theme_minimal` - sets the default plot look
- `ggplot2::ggsave` **(c)** - saves a plot to a file
- `ggplot2::last_plot` **(c)** - the most recent plot

### defined inside the scripts
- `iqr_flag(x)` - TRUE for values beyond 1.5 x IQR (outlier flag)
- `winsor(x, p)` - caps values at the p and 1-p percentiles
