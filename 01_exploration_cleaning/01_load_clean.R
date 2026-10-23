# 01_load_clean.R - load, standardise names, fix types, handle missing/outliers.
library(tidyverse); library(janitor); library(readxl); library(lubridate)

# ---- CONFIG ----
path <- "data.csv"       # .csv / .xlsx / .dta (haven::read_dta)
y_var <- "outcome"

# ---- LOAD ----
df <- if (grepl("\\.xlsx?$", path)) read_excel(path) else read_csv(path)
df <- clean_names(df)
glimpse(df)

# ---- TYPES ----
# df <- df |> mutate(across(where(is.character), str_trim))
# df <- df |> mutate(across(c(region, sector), as.factor))
# df <- df |> mutate(date = ymd(date))            # dmy()/mdy() as needed
# df <- df |> mutate(across(everything(), ~ na_if(.x, "NA")))

# ---- DUPLICATES ----
sum(duplicated(df)); df <- distinct(df)

# ---- MISSING ----
colSums(is.na(df)) |> sort(decreasing = TRUE) |> head(15)
# df <- df |> drop_na(all_of(y_var))                       # drop if y missing
# df <- df |> mutate(across(where(is.numeric), ~ replace_na(.x, median(.x, na.rm = TRUE))))

# ---- OUTLIERS (flag first, decide later) ----
iqr_flag <- function(x) { q <- quantile(x, c(.25, .75), na.rm = TRUE); i <- diff(q)
  x < q[1] - 1.5 * i | x > q[2] + 1.5 * i }
df |> summarise(across(where(is.numeric), ~ sum(iqr_flag(.x), na.rm = TRUE)))
winsor <- function(x, p = .01) { q <- quantile(x, c(p, 1 - p), na.rm = TRUE); pmin(pmax(x, q[1]), q[2]) }
# df <- df |> mutate(across(c(income), winsor))

# ---- TRANSFORMS ----
# df <- df |> mutate(log_y = log(.data[[y_var]]))          # needs y > 0
# df <- df |> mutate(log1p_x = log1p(x))                   # zeros allowed

saveRDS(df, "out/clean.rds")
