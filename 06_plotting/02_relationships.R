# 02_relationships.R - two or more numeric variables. "How are x and y related?"
library(tidyverse); library(ggrepel); library(GGally); library(scales)
theme_set(theme_minimal(base_size = 13))

# ---- DEMO DATA ----
df <- mpg |> mutate(x = hwy, y = cty, z = displ, g = class, f = drv)

# ---- SCATTER ----
ggplot(df, aes(x, y)) + geom_point()
ggplot(df, aes(x, y, colour = f)) + geom_point(size = 2, alpha = .7)
ggplot(df, aes(x, y, colour = f, shape = f)) + geom_point()
ggplot(df, aes(x, y)) + geom_point() + facet_wrap(~ f)

# Bubble: third numeric variable as size
ggplot(df, aes(x, y, size = z, colour = f)) + geom_point(alpha = .5) + scale_size_area(max_size = 8)

# ---- OVERLAPPING POINTS ----
ggplot(df, aes(x, y)) + geom_jitter(width = .3, height = .3, alpha = .5)    # small random shift
ggplot(df, aes(x, y)) + geom_count()                                         # size = how many
ggplot(df, aes(x, y)) + geom_point(alpha = .1)                               # transparency
ggplot(df, aes(x, y)) + geom_bin2d(bins = 20) + scale_fill_viridis_c()       # square bins
ggplot(df, aes(x, y)) + geom_hex(bins = 15) + scale_fill_viridis_c()         # hexagon bins (needs hexbin)
ggplot(df, aes(x, y)) + geom_density_2d()                                    # contour lines
ggplot(df, aes(x, y)) + geom_density_2d_filled(alpha = .8)                   # filled contours

# ---- TREND LINES ----
ggplot(df, aes(x, y)) + geom_point() + geom_smooth(method = "lm")            # straight line + 95% band
ggplot(df, aes(x, y)) + geom_point() + geom_smooth(method = "lm", se = FALSE, colour = "red")
ggplot(df, aes(x, y)) + geom_point() + geom_smooth()                         # loess: flexible curve
ggplot(df, aes(x, y)) + geom_point() + geom_smooth(method = "lm", formula = y ~ poly(x, 2))   # quadratic
ggplot(df, aes(x, y)) + geom_point() + geom_smooth(method = "gam", formula = y ~ s(x))        # spline
ggplot(df, aes(x, y, colour = f)) + geom_point() + geom_smooth(method = "lm", se = FALSE)     # line per group
ggplot(df, aes(x, y)) + geom_point() + geom_smooth(method = "lm") + facet_wrap(~ f)

# ---- SHOW A LINE YOU ESTIMATED YOURSELF ----
fit <- lm(y ~ x, data = df)
ggplot(df, aes(x, y)) + geom_point() +
  geom_abline(intercept = coef(fit)[1], slope = coef(fit)[2], colour = "red") +
  geom_abline(intercept = 0, slope = 1, linetype = 2)                        # 45-degree reference

# ---- LABEL POINTS ----
ggplot(df, aes(x, y)) + geom_point() +
  geom_text_repel(data = filter(df, x > 40), aes(label = model))             # label only some
ggplot(df, aes(x, y)) + geom_point(colour = "grey70") +
  geom_point(data = filter(df, f == "r"), colour = "red") +                  # highlight a subset
  geom_text_repel(data = filter(df, f == "r"), aes(label = model), size = 3)

# ---- RUGS AND REFERENCE LINES ----
ggplot(df, aes(x, y)) + geom_point() + geom_rug(alpha = .3) +
  geom_vline(xintercept = mean(df$x), linetype = 2) +
  geom_hline(yintercept = mean(df$y), linetype = 2)

# ---- CONNECTED POINTS (order matters) ----
df |> group_by(year, cyl) |> summarise(x = mean(x), y = mean(y), .groups = "drop") |>
  ggplot(aes(x, y, colour = factor(year), group = year)) + geom_path() + geom_point()

# ---- CORRELATION HEATMAP ----
cm <- df |> select(x, y, z, cyl, year) |> cor(use = "pairwise.complete.obs") |>
  as.data.frame() |> rownames_to_column("a") |> pivot_longer(-a, names_to = "b", values_to = "r")
ggplot(cm, aes(a, b, fill = r)) + geom_tile(colour = "white") +
  geom_text(aes(label = round(r, 2)), size = 3.5) +
  scale_fill_gradient2(low = "firebrick", mid = "white", high = "steelblue", limits = c(-1, 1)) +
  labs(x = NULL, y = NULL, fill = "Correlation")

# ---- SCATTERPLOT MATRIX ----
ggpairs(df, columns = c("x", "y", "z"))
ggpairs(df, columns = c("x", "y", "z"), mapping = aes(colour = f))

# ---- ONE MEASURE ACROSS TWO CATEGORIES ----
df |> group_by(g, f) |> summarise(m = mean(x), .groups = "drop") |>
  ggplot(aes(f, g, fill = m)) + geom_tile() + scale_fill_viridis_c()
