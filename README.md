# Data-Sprint-Preparation

Prep repo for the SSE CQLA data sprint. Read this before the sprint starts and have the setup done beforehand.

## Why this repo exists

We'll have limited time, one dataset we haven't seen, and other teams to beat. Nobody has told us the exact format, so I'm assuming we'll get a dataset and have to explore it, model it and present it in one sitting.

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

## Step by step: a brand-new dataset

This is the order most analysts and economists work in. The charts show the decisions. Follow the arrows and use the folder named at each step.

### The big picture

```
 Read the brief + data dictionary
              |
              v
 What is ONE row?  What is the question?
              |
              v
 Load and clean  ---------------> 01_exploration_cleaning
              |
              v
 Any missing values? -----------> 05_missing_data
              |
              v
 Explore: plots, summaries -----> 01_exploration_cleaning/02_eda.R
              |
              v
 What shape is the data? (chart 1)
              |
              v
 Pick a method (chart 2, 3 or 4)
              |
              v
 Check it, then stress-test it (chart 5)
              |
              v
 Tell the story: what does it mean in real terms?
```

### Step 1: Understand the data before touching it

Write down three things as a team. What does one row stand for (a person, a firm, a country-year)? What is the outcome we care about? What is the question we are answering? If we cannot say these in one sentence each, stop and ask.

### Step 2: Chart 1, what shape is the data?

```
 Look at the id and time columns
              |
     +--------+---------+
     |                  |
 No time column     Has a time column
     |                  |
     v            +-----+------+
 CROSS-SECTION    |            |
 02_cross_section One unit    Many units
                  over time   over time
                     |            |
                     v            v
                TIME SERIES     PANEL
                03_time_series  04_panel
```

### Step 3: Chart 2, missing values

```
 Any NAs?
    |
    +-- No --> carry on
    |
    Yes
    |
 What share is missing?
    |
    +-- Over 40% in one column --> think about dropping the column
    |
    +-- Under 5%, looks random --> drop those rows (listwise)
    |
    +-- More than that
          |
          v
   Is the data ordered (time or panel)?
          |
     +----+----+
     |         |
    Yes        No
     |         |
     v         v
 Fill inside   Do other variables predict
 each unit:    the missingness? (Little's test,
 copy down or  logit on a missing flag)
 interpolate        |
 (cap the gap)  +---+---+
                |       |
               Yes      No
                |       |
                v       v
        Multiple     Drop rows or
        imputation   simple fill is OK
        (mice)

 Not sure why values are missing, or the missing ones might be
 the high or low values? Impute, then run the sensitivity check
 in 05_missing_data/03 and say so in the presentation.
```

### Step 4: Chart 3, cross-section (no time)

```
 What type is the outcome (y)?
              |
   +----------+-----------+-----------+
   |          |           |           |
 Number     Yes / No    Count      Just comparing
 (income)   (default)   (visits)   groups
   |          |           |           |
   v          v           v           v
  OLS       Logit /     Poisson     t-test (2 groups)
  (use log  Probit      (or neg.    ANOVA (3+ groups)
  if y is   + marginal  binomial)   chi-square (2 category columns)
  skewed)   effects
   |
   v
 Robust standard errors, always
```

### Step 5: Chart 4, time series and panel

```
 TIME SERIES (one unit)               PANEL (many units)
 ----------------------               ------------------
 Plot the series                      Declare id + time
        |                                    |
        v                                    v
 Stationary? (ADF + KPSS)             Run pooled, FE and RE
        |                                    |
   +----+----+                               v
   |         |                       Hausman test
  Yes        No                              |
   |         |                       +-------+-------+
   |   Difference or take            |               |
   |   log-difference, retest      Rejects       Does not reject
   |         |                       |               |
   +----+----+                       v               v
        |                         Use FE          Use RE
        v                            |               |
 One series or several?              +-------+-------+
        |                                    |
   +----+-----+                              v
   |          |                     Cluster SEs by unit, always
 One        Several
   |          |
   v          v
 ARIMA      VAR + Granger
 (compare   (two trending series that move together?
 with a      test cointegration, then use a VECM)
 naive
 forecast)
```

### Step 6: Chart 5, check and stress-test

```
 Model is run
      |
      v
 Run the diagnostics (04_diagnostics.R, 03_tests_robustness.R)
      |
      v
 Any problem?
      |
  +---+---+
  |       |
 No      Yes (non-constant variance, serial correlation, outliers)
  |       |
  |       v
  |   Use robust or clustered errors, transform, or fix the specification
  |       |
  +---+---+
      |
      v
 Change something small and rerun:
   - different controls
   - drop outliers
   - different missing-data method
   - a subsample
      |
      v
 Does the main result survive?
      |
  +---+---+
  |       |
 Yes     No
  |       |
  v       v
 Report  Report that too. Say how fragile it is.
 it      That is still a good finding.
```

### Step 7: Tell the story

- Lead with the one finding that answers the question.
- Say what the number means in real units, such as "one extra year of schooling goes with about 8% higher wages".
- Say if the result is a link or a cause. Name what could make it wrong.
- Show three to five clear figures, not twenty.
- Say how you handled missing data and what you checked.

## Git rules

- Pull before you start working and again before you push.
- Commit small and often, with a message that says what you did.
- Don't edit someone else's file. Make your own copy.
- Don't commit raw data. The `.gitignore` already blocks `.csv`, `.xlsx` and `.dta`.

## Caveats

- The scripts are templates, not finished analyses. Variable names like `y`, `x1` and `id` are placeholders and need changing.
- They have not been tested on real data, so expect to fix small things. Please do that in your own copy, and tell me if something in the originals is broken so I can fix it for everyone.
- A template can't tell us what's important in the data. That part is on us.
