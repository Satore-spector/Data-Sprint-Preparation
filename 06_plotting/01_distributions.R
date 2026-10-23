# 01_distributions.R - one variable (x), optionally split by group (g, f). "What does it look like?"
library(tidyverse); library(ggridges); library(scales)
theme_set(theme_minimal(base_size = 13))

# ---- DEMO DATA ----
df <- mpg |> mutate(x = hwy, y = cty, g = class, f = drv)

# ---- HISTOGRAMS ----
ggplot(df, aes(x)) + geom_histogram(bins = 30, fill = "steelblue", colour = "white")
ggplot(df, aes(x)) + geom_histogram(binwidth = 2)                          # set bin width instead
ggplot(df, aes(x, fill = f)) + geom_histogram(bins = 30, position = "identity", alpha = .5)
ggplot(df, aes(x)) + geom_histogram(bins = 30) + facet_wrap(~ f)           # one panel per group
ggplot(df, aes(x)) + geom_histogram(bins = 30) + scale_x_log10()           # skewed variable

# Histogram with density and a normal curve on top
ggplot(df, aes(x)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "grey85", colour = "white") +
  geom_density(colour = "steelblue", linewidth = 1) +
  stat_function(fun = dnorm, args = list(mean = mean(df$x), sd = sd(df$x)),
                colour = "red", linetype = 2)

# ---- DENSITY / FREQUENCY LINES ----
ggplot(df, aes(x)) + geom_density(fill = "steelblue", alpha = .4)
ggplot(df, aes(x, fill = f)) + geom_density(alpha = .4)
ggplot(df, aes(x, colour = f)) + geom_freqpoly(bins = 30)
ggplot(df, aes(x, after_stat(count), fill = f)) + geom_density(position = "stack")   # stacked counts

# ---- BOXPLOT FAMILY ----
ggplot(df, aes(g, x)) + geom_boxplot()
ggplot(df, aes(fct_reorder(g, x, .fun = median), x)) + geom_boxplot() + coord_flip()  # ordered
ggplot(df, aes(g, x, fill = f)) + geom_boxplot()                                       # dodged by 2nd group
ggplot(df, aes(g, x)) + geom_boxplot(outlier.shape = NA) + geom_jitter(width = .15, alpha = .4)
ggplot(df, aes(g, x)) + geom_violin(fill = "steelblue", alpha = .4)
ggplot(df, aes(g, x)) + geom_violin(trim = FALSE, fill = "grey90") +
  geom_boxplot(width = .12, outlier.shape = NA)                                        # violin + box
ggplot(df, aes(g, x)) + stat_summary(fun.data = mean_se, geom = "pointrange")          # mean +/- 1 SE
ggplot(df, aes(g, x)) + geom_dotplot(binaxis = "y", stackdir = "center", binwidth = 1) # every point

# Rain-cloud style: half density + box + raw points
ggplot(df, aes(f, x, fill = f)) +
  geom_violin(alpha = .4, colour = NA) +
  geom_boxplot(width = .12, outlier.shape = NA, fill = "white") +
  geom_jitter(width = .08, alpha = .4, size = 1) + guides(fill = "none")

# ---- RIDGELINES (many groups, one variable) ----
ggplot(df, aes(x, y = fct_reorder(g, x, .fun = median), fill = g)) +
  geom_density_ridges(alpha = .7, scale = 1.2) + guides(fill = "none") + labs(y = NULL)

# ---- CUMULATIVE ----
ggplot(df, aes(x, colour = f)) + stat_ecdf()                               # share of data below x

# ---- NORMALITY (QQ) ----
ggplot(df, aes(sample = x)) + stat_qq() + stat_qq_line(colour = "red")
ggplot(df, aes(sample = x, colour = f)) + stat_qq() + stat_qq_line()       # by group

# ---- RUG: raw positions under any plot ----
ggplot(df, aes(x)) + geom_density() + geom_rug(alpha = .3)

# ---- COUNTS OF A CATEGORY ----
ggplot(df, aes(g)) + geom_bar()
ggplot(df, aes(fct_infreq(g))) + geom_bar() + coord_flip() + labs(x = NULL)  # sorted by size

# ---- MANY VARIABLES AT ONCE ----
df |> select(where(is.numeric)) |> pivot_longer(everything()) |>
  ggplot(aes(value)) + geom_histogram(bins = 25) + facet_wrap(~ name, scales = "free")
df |> select(where(is.numeric)) |> pivot_longer(everything()) |>
  ggplot(aes(name, value)) + geom_boxplot() + facet_wrap(~ name, scales = "free") +
  theme(axis.text.x = element_blank())

# ---- OUTLIER VIEW ----
ggplot(df, aes(x)) + geom_histogram(bins = 40) + coord_cartesian(xlim = c(10, 40))   # zoom
