# 06_polish_and_export.R - make figures presentation-ready: theme, colour, labels, annotation, layout, export.
library(tidyverse); library(scales); library(patchwork)

df <- mpg |> mutate(x = hwy, y = cty, g = class, f = drv)

# ---- ONE TEAM THEME: define once, add to every plot ----
theme_sprint <- function(base_size = 14) {
  theme_minimal(base_size = base_size) +
    theme(plot.title = element_text(face = "bold"),
          plot.title.position = "plot",              # title aligned to the left edge, not the panel
          plot.caption = element_text(colour = "grey40"),
          panel.grid.minor = element_blank(),
          legend.position = "bottom")
}
theme_set(theme_sprint())

# ---- SAME COLOUR FOR THE SAME GROUP IN EVERY FIGURE ----
cols <- c(`4` = "#0072B2", f = "#E69F00", r = "#009E73")            # name -> colour
ggplot(df, aes(x, y, colour = f)) + geom_point() + scale_colour_manual(values = cols)
# Colour-blind safe: viridis (scale_*_viridis_d/c), brewer "Set2" / "Dark2", Okabe-Ito vector above.
# Avoid rainbow palettes and red-green pairs.

# ---- TITLE THAT STATES THE FINDING ----
ggplot(df, aes(x, y, colour = f)) + geom_point() + scale_colour_manual(values = cols) +
  labs(title = "Four-wheel drives are the least efficient",
       subtitle = "City vs highway mileage by drive type",
       x = "Highway (mpg)", y = "City (mpg)", colour = NULL, caption = "Source: mpg data")

# ---- FORMAT NUMBERS ON AXES ----
big <- tibble(g = LETTERS[1:5], v = c(1.2e6, 8e5, 5.5e5, 3e5, 1e5), p = c(.31, .24, .19, .15, .11))
ggplot(big, aes(g, v)) + geom_col() + scale_y_continuous(labels = label_comma())
ggplot(big, aes(g, v)) + geom_col() + scale_y_continuous(labels = label_number(scale_cut = cut_short_scale()))  # 1M, 500K
ggplot(big, aes(g, v)) + geom_col() + scale_y_continuous(labels = label_dollar())
ggplot(big, aes(g, p)) + geom_col() + scale_y_continuous(labels = label_percent(accuracy = 1))
ggplot(big, aes(g, v)) + geom_col() + scale_y_continuous(expand = expansion(mult = c(0, .05)))  # bars start at the axis

# ---- ORDER AND GROUP CATEGORIES ----
ggplot(df, aes(fct_infreq(g))) + geom_bar()                            # by frequency
ggplot(df, aes(fct_rev(fct_infreq(g)))) + geom_bar() + coord_flip()    # biggest on top when flipped
ggplot(df, aes(fct_lump_n(g, 4))) + geom_bar()                         # keep top 4, rest = "Other"
ggplot(df, aes(fct_reorder(g, x, median), x)) + geom_boxplot()         # order by another variable

# ---- ANNOTATE ----
ggplot(df, aes(x, y)) + geom_point(colour = "grey60") +
  annotate("text", x = 40, y = 20, label = "Efficient cars", fontface = "italic") +
  annotate("segment", x = 38, xend = 42, y = 22, yend = 28, arrow = arrow(length = unit(.2, "cm"))) +
  annotate("rect", xmin = 35, xmax = 45, ymin = 25, ymax = 37, alpha = .15, fill = "steelblue") +
  geom_hline(yintercept = mean(df$y), linetype = 2)

# ---- HIGHLIGHT ONE GROUP, GREY THE REST ----
df |> mutate(hl = f == "r") |>
  ggplot(aes(x, y, colour = hl)) + geom_point() +
  scale_colour_manual(values = c(`FALSE` = "grey75", `TRUE` = "red"), guide = "none")

# ---- DIRECT LABELS INSTEAD OF A LEGEND ----
ends <- df |> group_by(f) |> slice_max(x, n = 1, with_ties = FALSE)
ggplot(df, aes(x, y, colour = f)) + geom_point() +
  geom_text(data = ends, aes(label = f), hjust = -.3, show.legend = FALSE) + theme(legend.position = "none")

# ---- LEGENDS AND AXES ----
p <- ggplot(df, aes(x, y, colour = g)) + geom_point()
p + theme(legend.position = "right")
p + theme(legend.position = "none")
p + guides(colour = guide_legend(nrow = 2, override.aes = list(size = 3)))
p + theme(axis.text.x = element_text(angle = 45, hjust = 1))
p + scale_x_continuous(position = "top")
p + theme(axis.title = element_blank())

# ---- FACET LABELS ----
ggplot(df, aes(x, y)) + geom_point() + facet_wrap(~ f, labeller = as_labeller(c(`4` = "4WD", f = "Front", r = "Rear")))
ggplot(df, aes(x, y)) + geom_point() + facet_wrap(~ g, nrow = 2) + theme(strip.text = element_text(face = "bold"))

# ---- LAYOUT FOR A SLIDE OR REPORT PAGE ----
p1 <- ggplot(df, aes(x)) + geom_histogram(bins = 25)
p2 <- ggplot(df, aes(x, y)) + geom_point()
p3 <- ggplot(df, aes(g, x)) + geom_boxplot()
(p1 + p2) / p3 + plot_layout(heights = c(1, 1.2)) + plot_annotation(title = "Summary", tag_levels = "A")
p1 + p2 + plot_layout(widths = c(1, 2))
p1 + inset_element(p2, left = .55, bottom = .5, right = 1, top = 1)    # small plot inside a big one

# ---- EXPORT ----
dir.create("out", showWarnings = FALSE)
ggsave("out/fig_report.png", p, width = 6.5, height = 4, dpi = 300)            # Word / PDF report
ggsave("out/fig_slide.png",  p, width = 13.33, height = 7.5, dpi = 200)        # full slide
ggsave("out/fig_half.png",   p, width = 6.5, height = 5, dpi = 200)            # half slide
ggsave("out/fig_vector.pdf", p, width = 8, height = 5)                         # scales without blur
# In Quarto / R Markdown chunks:  #| fig-width: 8   #| fig-height: 5   #| fig-cap: "..."

# ---- CHECKLIST BEFORE YOU SHOW IT ----
# [ ] title says the finding   [ ] axes labelled with units   [ ] bars start at zero
# [ ] readable at the back of the room (base_size >= 14)   [ ] colour-blind safe
# [ ] no pie or dual axis unless there is no better option [ ] source in the caption
