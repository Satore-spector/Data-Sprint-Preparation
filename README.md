# Data-Sprint-Preparation
A repository made to prepare for SSE CQLA data sprint

Scripts for the 6-hour data sprint (R). Each script is self-contained: edit the CONFIG block at the top and run section by section.
| Folder | Use when | Scripts |
|---|---|---|
| `01_exploration_cleaning` | First hour, any dataset | setup, load/clean, EDA |
| `02_cross_section` | One observation per unit | t-tests, chi-square, ANOVA, OLS, logit, diagnostics |
| `03_time_series` | One unit over time | plots, stationarity, ARIMA, VAR/Granger |
| `04_panel` | Many units over time | pooled/FE/RE, Hausman, clustered SEs |
| `05_missing_data` | Any dataset with NAs | MCAR/MAR/MNAR diagnosis, deletion, LOCF, interpolation, multiple imputation, sensitivity |

## Workflow
1. Run `01_exploration_cleaning/00_setup.R` once on every teammate's machine tonight.
2. Pick the folder matching the data shape. Copy the script, do not edit the original (avoids merge conflicts).
3. Name your working copies `<initials>_<topic>.R` and keep outputs in `out/`.

## Git etiquette for the sprint
- Pull before you start, commit small, push often.
- Never commit the raw data if it is large or restricted (add it to `.gitignore`).

Scripts are written from memory and untested on your data; expect to adjust variable names.
