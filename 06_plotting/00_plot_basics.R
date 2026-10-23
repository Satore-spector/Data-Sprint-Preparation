# 00_plot_basics.R - ggplot2 anatomy, aesthetics, scales, themes, facets, combining, saving.
# Demo data runs as-is. To use your data, rename your columns to x, y, z, g, f (see DEMO DATA).
library(tidyverse); library(scales); library(patchwork)

# ---- DEMO DATA (replace with: df <- readRDS("out/clean.rds") |> rename(x = ..., y = ...)) ----
# x, y = numeric   z = third numeric   g = category (many levels)   f = category (few levels)
df <- mpg |> mutate(x = hwy, y = cty, z = displ, g = class, f = drv)

# ---- ANATOMY: data -> aes -> geom -> scale -> facet -> coord -> theme ----
ggplot(df, aes(x = x, y = y)) + geom_point()
# map a column to a look INSIDE aes():   aes(colour = g)
# set a constant look OUTSIDE aes():     geom_point(colour = "red")

# ---- AESTHETICS: colour, fill, shape, size, alpha, linetype ----
ggplot(df, aes(x, y, colour = g, shape = f, size = z)) + geom_point(alpha = .6)
ggplot(df, aes(x, y)) + geom_point(colour = "steelblue", size = 2, alpha = .5)

# ---- LABELS ----
ggplot(df, aes(x, y, colour = f)) + geom_point() +
  labs(title = "City vs highway mileage", subtitle = "By drive type",
       x = "Highway (mpg)", y = "City (mpg)", colour = "Drive", caption = "Source: mpg data")

# ---- SCALES ----
p <- ggplot(df, aes(x, y, colour = g)) + geom_point()
p + scale_x_continuous(limits = c(10, 50), breaks = seq(10, 50, 10))   # limits DROP data outside
p + coord_cartesian(xlim = c(10, 40))                                    # zoom, keeps all data
p + scale_x_log10() + scale_y_log10()                                    # log axes
p + scale_x_reverse()                                                    # flip direction
p + scale_y_continuous(labels = label_comma())                           # 1,000 style
p + scale_colour_brewer(palette = "Set2")                                # discrete palette
p + scale_colour_viridis_d()                                             # colour-blind friendly
p + scale_colour_manual(values = c("#0072B2", "#E69F00", "#009E73", "#CC79A7",
                                   "#D55E00", "#56B4E9", "#F0E442"))     # Okabe-Ito
ggplot(df, aes(x, y, colour = z)) + geom_point() + scale_colour_viridis_c()          # continuous
ggplot(df, aes(x, y, colour = z)) + geom_point() + scale_colour_gradient(low = "grey80", high = "red")
ggplot(df, aes(x, y, colour = x - mean(x))) + geom_point() +
  scale_colour_gradient2(low = "firebrick", mid = "white", high = "steelblue", midpoint = 0)  # diverging

# ---- THEMES ----
p + theme_minimal(); p + theme_bw(); p + theme_classic(); p + theme_light(); p + theme_void()
theme_set(theme_minimal(base_size = 13))      # set once for the whole session
p + theme(legend.position = "bottom", panel.grid.minor = element_blank(),
          axis.text.x = element_text(angle = 45, hjust = 1))

# ---- FACETS: small multiples ----
ggplot(df, aes(x, y)) + geom_point() + facet_wrap(~ g)
ggplot(df, aes(x, y)) + geom_point() + facet_wrap(~ g, scales = "free")   # free axes per panel
ggplot(df, aes(x, y)) + geom_point() + facet_grid(f ~ year)               # rows ~ columns

# ---- COORDINATES ----
ggplot(df, aes(g)) + geom_bar() + coord_flip()                  # horizontal bars
ggplot(df, aes(x, y)) + geom_point() + coord_fixed()            # equal x and y scale

# ---- COMBINE PLOTS (patchwork) ----
p1 <- ggplot(df, aes(x)) + geom_histogram(bins = 25)
p2 <- ggplot(df, aes(x, y)) + geom_point()
p3 <- ggplot(df, aes(g, x)) + geom_boxplot()
p1 + p2                                   # side by side
p1 / p2                                   # stacked
(p1 | p2) / p3                            # grid layout
(p1 | p2) / p3 + plot_annotation(title = "Overview", tag_levels = "A")
(p2 + aes(colour = f)) + (p3 + aes(fill = f)) + plot_layout(guides = "collect")   # one shared legend

# ---- SAVE ----
dir.create("out", showWarnings = FALSE)
ggsave("out/fig_basic.png", p, width = 8, height = 5, dpi = 300)    # report or doc
ggsave("out/fig_slide.png", p, width = 13.33, height = 7.5, dpi = 200)   # full-slide
ggsave("out/fig_basic.pdf", p, width = 8, height = 5)               # vector
