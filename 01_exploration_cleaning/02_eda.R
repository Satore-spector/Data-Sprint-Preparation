# 02_eda.R - fast, systematic EDA. Reads out/clean.rds.
library(tidyverse); library(skimr); library(naniar); library(corrplot); library(GGally)
df <- readRDS("out/clean.rds")
y_var <- "outcome"

# ---- PROFILE ----
skim(df); miss_var_summary(df); gg_miss_var(df)

# ---- OUTCOME ----
ggplot(df, aes(.data[[y_var]])) + geom_histogram(bins = 40, fill = "steelblue")
ggplot(df, aes(sample = .data[[y_var]])) + stat_qq() + stat_qq_line()

# ---- NUMERIC DISTRIBUTIONS ----
df |> select(where(is.numeric)) |> pivot_longer(everything()) |>
  ggplot(aes(value)) + geom_histogram(bins = 30) + facet_wrap(~name, scales = "free")

# ---- CORRELATIONS ----
num <- df |> select(where(is.numeric)) |> drop_na()
corrplot(cor(num), method = "color", type = "upper", tl.cex = .7)
# ggpairs(num[, 1:6])   # keep to <= 6 vars

# ---- OUTCOME VS PREDICTORS ----
df |> select(where(is.numeric)) |> pivot_longer(-all_of(y_var)) |>
  ggplot(aes(value, .data[[y_var]])) + geom_point(alpha = .3) +
  geom_smooth(method = "lm", se = FALSE) + facet_wrap(~name, scales = "free_x")

# ---- CATEGORICAL ----
cats <- df |> select(where(is.factor)) |> names()
for (v in cats) print(df |> count(.data[[v]], sort = TRUE))
# df |> ggplot(aes(.data[[cats[1]]], .data[[y_var]])) + geom_boxplot()

# ---- GROUP SUMMARIES ----
# df |> group_by(.data[[cats[1]]]) |>
#   summarise(n = n(), mean = mean(.data[[y_var]], na.rm = TRUE), sd = sd(.data[[y_var]], na.rm = TRUE))

# ggsave("out/eda_fig1.png", last_plot(), width = 8, height = 5, dpi = 200)
