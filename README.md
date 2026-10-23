# Data-Sprint-Preparation

Prep repo for the SSE CQLA data sprint. Read this before the sprint starts and have the setup done beforehand.

## Why this repo exists

We have 6 hours, one dataset we haven't seen, and other teams to beat. Nobody has told us the exact format, so I'm assuming we'll get a dataset and have to explore it, model it and present it in one sitting.

Most of that time should go on thinking about the data, not on remembering syntax or hunting for the right package. So I've put together ready-made R scripts for the things we're most likely to need. When we see the data, we open the right script, change the variable names and run it.

## Why it's split into these folders

The right method depends mostly on the shape of the data, so the folders follow that:

| Folder | Use it when | What's in it |
|---|---|---|
| `01_exploration_cleaning` | Always, in the first hour | Package setup, loading and cleaning, EDA |
| `02_cross_section` | One observation per unit (e.g. firms in one year) | t-tests, chi-square, ANOVA, OLS with robust SEs, logit/probit, diagnostics |
| `03_time_series` | One unit over time (e.g. a country's GDP) | Plots, ADF/KPSS stationarity, ARIMA/ETS, VAR and Granger causality |
| `04_panel` | Many units over time (e.g. countries by year) | Pooled/FE/RE, Hausman test, clustered SEs, diff-in-diff, robustness checks |
| `05_missing_data` | Any dataset with NAs | Testing for MCAR/MAR/MNAR, deleting, copying down, interpolating, multiple imputation, sensitivity checks |

Missing data has its own folder because it can change our results without us noticing. Real datasets almost always have gaps, and the right fix depends on why the values are missing. The scripts show how to check that and how to handle each case.

## Before the sprint (everyone)

1. Clone the repo: `git clone https://github.com/Satore-spector/data-sprint-preparation`
2. Open R and run `01_exploration_cleaning/00_setup.R`. This installs every package we use, so do it on good wifi tonight, not during the sprint.
3. Check that Quarto or R Markdown renders to HTML on your machine, since we may need it for the presentation.
4. Try one script on a practice dataset so you know what the output looks like.

## During the sprint

1. Start with the `01_exploration_cleaning` scripts, then decide the data shape together.
2. Run `05_missing_data/01_diagnose_mechanism.R` early. Agree as a team on how we treat missing values before anyone models.
3. Pick the folder that matches the data. **Copy** the script into your own file instead of editing the original, e.g. `ab_ols.R` (your initials + topic). That avoids merge conflicts and keeps the originals clean.
4. Put outputs (figures, tables) in `out/`. It's gitignored, so share finished figures another way.
5. Whatever model we run, check it with the diagnostics and a robustness check, and write down what the results mean in real units. Explaining the result matters as much as running it.

Suggested split of the 6 hours:

| Time | Focus |
|---|---|
| 0:00 - 0:30 | Read the brief and data dictionary, agree on the research question |
| 0:30 - 1:30 | Clean, handle missing data, EDA |
| 1:30 - 3:30 | Modelling |
| 3:30 - 4:30 | Diagnostics and robustness |
| 4:30 - 5:30 | Build the presentation |
| 5:30 - 6:00 | Rehearse, with no new analysis |

## Git rules

- Pull before you start working and again before you push.
- Commit small and often, with a message that says what you did.
- Don't edit someone else's file. Make your own copy.
- Don't commit raw data. The `.gitignore` already blocks `.csv`, `.xlsx` and `.dta`.

## Caveats

- The scripts are templates, not finished analyses. Variable names like `y`, `x1` and `id` are placeholders and need changing.
- They have not been tested on real data, so expect to fix small things. Please do that in your own copy, and tell me if something in the originals is broken so I can fix it for everyone.
- A template can't tell us what's important in the data. That part is on us.
