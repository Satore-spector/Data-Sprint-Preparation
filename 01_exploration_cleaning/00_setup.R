# 00_setup.R - run once per machine. Installs and loads everything used in the repo.
pkgs <- c("tidyverse", "janitor", "skimr", "naniar", "GGally", "corrplot",
          "broom", "modelsummary", "sandwich", "lmtest", "car", "marginaleffects",
          "fixest", "plm", "tseries", "forecast", "urca", "vars", "zoo", "xts",
          "tidymodels", "ranger", "glmnet", "vip", "lubridate", "scales",
          "patchwork", "rstatix", "readxl", "knitr", "quarto",
          "mice", "VIM", "missForest", "imputeTS", "sampleSelection",
          "ggridges", "ggrepel", "treemapify", "ggalluvial", "hexbin")
new <- setdiff(pkgs, rownames(installed.packages()))
if (length(new)) install.packages(new)
invisible(lapply(pkgs, library, character.only = TRUE))

theme_set(theme_minimal(base_size = 13))
dir.create("out", showWarnings = FALSE)
set.seed(42)
message("Setup complete: ", length(pkgs), " packages loaded.")
