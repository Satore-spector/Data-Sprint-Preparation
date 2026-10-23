# 03_categorical_comparison.R - categories: counts, group means, shares, flows. "How do groups compare?"
library(tidyverse); library(scales); library(treemapify); library(ggalluvial)
theme_set(theme_minimal(base_size = 13))

# ---- DEMO DATA ----
df <- mpg |> mutate(x = hwy, g = class, f = drv)
# Pre-summarised table used by many plots below: mean, SE and 95% CI per group
s <- df |> group_by(g) |>
  summarise(n = n(), m = mean(x), se = sd(x) / sqrt(n), lo = m - 1.96 * se, hi = m + 1.96 * se)

# ---- BARS: COUNTS ----
ggplot(df, aes(g)) + geom_bar()
ggplot(df, aes(y = fct_infreq(g))) + geom_bar() + labs(y = NULL)                    # sorted, horizontal
ggplot(df, aes(g)) + geom_bar() + geom_text(stat = "count", aes(label = after_stat(count)), vjust = -.4)

# ---- BARS: SPLIT BY A SECOND CATEGORY ----
ggplot(df, aes(g, fill = f)) + geom_bar()                                            # stacked
ggplot(df, aes(g, fill = f)) + geom_bar(position = position_dodge(preserve = "single"))   # side by side
ggplot(df, aes(g, fill = f)) + geom_bar(position = "fill") +                         # shares, sum to 100%
  scale_y_continuous(labels = percent) + labs(y = "Share")

# ---- BARS: SHARES WITH LABELS ----
df |> count(g) |> mutate(p = n / sum(n)) |>
  ggplot(aes(fct_reorder(g, p), p)) + geom_col() + coord_flip() +
  geom_text(aes(label = percent(p, accuracy = 1)), hjust = -.1) +
  scale_y_continuous(labels = percent, expand = expansion(mult = c(0, .15))) + labs(x = NULL)

# ---- BARS: GROUP MEANS WITH ERROR BARS ----
ggplot(s, aes(fct_reorder(g, m), m)) + geom_col(fill = "steelblue") +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = .3) + coord_flip() + labs(x = NULL, y = "Mean (95% CI)")
ggplot(df, aes(g, x)) + stat_summary(fun = mean, geom = "col") +                    # same, without pre-summarising
  stat_summary(fun.data = mean_se, geom = "errorbar", width = .3)
ggplot(s, aes(m, fct_reorder(g, m), xmin = lo, xmax = hi)) + geom_pointrange() + labs(y = NULL)   # dots + CI

# ---- LOLLIPOP / CLEVELAND DOT (cleaner than bars) ----
s |> mutate(g = fct_reorder(g, m)) |> ggplot(aes(m, g)) +
  geom_segment(aes(x = 0, xend = m, yend = g), colour = "grey70") + geom_point(size = 3) + labs(y = NULL)
ggplot(s, aes(m, fct_reorder(g, m))) + geom_point(size = 3) + labs(y = NULL)

# ---- DIVERGING BAR: above / below the average ----
s |> mutate(dev = m - mean(m)) |>
  ggplot(aes(dev, fct_reorder(g, dev), fill = dev > 0)) + geom_col() +
  scale_fill_manual(values = c("firebrick", "steelblue"), guide = "none") + labs(y = NULL, x = "Gap to average")

# ---- BEFORE / AFTER ----
w <- df |> group_by(g, year) |> summarise(m = mean(x), .groups = "drop")
ggplot(w, aes(factor(year), m, group = g, colour = g)) + geom_line() + geom_point()        # slope chart
w |> pivot_wider(names_from = year, values_from = m, names_prefix = "y") |>                # dumbbell
  mutate(g = fct_reorder(g, y2008)) |> ggplot(aes(y = g)) +
  geom_segment(aes(x = y1999, xend = y2008, yend = g), colour = "grey70") +
  geom_point(aes(x = y1999), colour = "grey40", size = 3) +
  geom_point(aes(x = y2008), colour = "steelblue", size = 3) + labs(x = "Mean", y = NULL)

# ---- HEATMAP: two categories ----
df |> count(g, f) |> ggplot(aes(f, g, fill = n)) + geom_tile() +
  geom_text(aes(label = n), colour = "white") + scale_fill_viridis_c()

# ---- COMPOSITION: TREEMAP ----
df |> count(g) |> ggplot(aes(area = n, fill = g, label = g)) +
  geom_treemap() + geom_treemap_text(colour = "white", place = "centre") + guides(fill = "none")

# ---- COMPOSITION: PIE / DONUT (use sparingly; bars are easier to read) ----
pie <- df |> count(f)
ggplot(pie, aes(x = "", y = n, fill = f)) + geom_col(width = 1) + coord_polar(theta = "y") + theme_void()
ggplot(pie, aes(x = 2, y = n, fill = f)) + geom_col(width = 1) + coord_polar(theta = "y") +
  xlim(.5, 2.5) + theme_void()                                                              # donut

# ---- FLOWS: ALLUVIAL / SANKEY STYLE ----
df |> count(f, g) |>
  ggplot(aes(axis1 = f, axis2 = g, y = n)) +
  geom_alluvium(aes(fill = f)) + geom_stratum() +
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 3) +
  scale_x_discrete(limits = c("Drive", "Class"), expand = c(.1, .1)) + guides(fill = "none")

# ---- COMPARE A NUMBER ACROSS GROUPS: see 01_distributions.R for box / violin / ridgeline ----
