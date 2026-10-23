# 06_plotting

Quick index for ggplot2 charts. Every script runs on built-in demo data, so you can test it before the sprint. To use your own data, load it and rename your columns to match the demo: `x`, `y` (numbers), `z` (a third number), `g` (category with many levels), `f` (category with few levels). Then the code works unchanged.

## Which chart do I need?

```
 What do I want to show?
          |
   +------+--------+-----------+------------+-------------+--------------+
   |               |           |            |             |              |
 How one       How two      How groups   How parts    How things    How well the
 variable      variables    compare      make a       change over   model works
 is spread     relate                    whole        time
   |               |           |            |             |              |
   v               v           v            v             v              v
 01_distri-    02_relation-  03_categor-  03_categor-   04_time_      05_model_
 butions       ships         ical         ical          series        results
   |               |           |            |             |              |
 histogram      scatter      bars +       stacked or    line          coefficient
 density        + trend      error bars   100% bars     area          plot
 box/violin     hex / 2D     dot plot     treemap       seasonal      residual
 ridgeline      density      lollipop     (pie last)    heatmap       plots
 QQ plot        heatmap      dumbbell                   spaghetti     ROC, forecast
                pairs                                   facets        event study
```

Then use `06_polish_and_export.R` to make it presentation-ready and save it.

## What's in each script

| Script | Use it for | Charts inside |
|---|---|---|
| `00_plot_basics.R` | How ggplot2 works | Anatomy, aesthetics, labels, scales (log, reverse, palettes, diverging), themes, facets, coords, combining with patchwork, saving |
| `01_distributions.R` | One variable, spread and shape | Histogram (overlay, facet, log, with normal curve), density, freqpoly, box, violin, jitter, rain cloud, ridgeline, ECDF, QQ, dotplot, rug, bar counts, all-variables-at-once |
| `02_relationships.R` | Two or more numeric variables | Scatter, bubble, jitter, count, bin2d, hex, 2D density, trend lines (lm, loess, poly, gam, per group), labelled points, highlight, correlation heatmap, scatterplot matrix, connected path |
| `03_categorical_comparison.R` | Categories and groups | Bars (counts, stacked, dodged, 100%, labelled), means with error bars, pointrange, lollipop, Cleveland dot, diverging bar, slope chart, dumbbell, heatmap, treemap, pie/donut, alluvial |
| `04_time_series_plots.R` | Change over time | Line, step, multi-series, date axis, trend and rolling mean, ribbon, area (stacked and share), event shading, second axis, index and growth, seasonal plot, calendar heatmap, spaghetti, small multiples, ACF, decomposition |
| `05_model_results_plots.R` | Showing model output | Coefficient plot, cross-model comparison, residual/QQ/scale-location/Cook's/leverage, predicted vs actual, effect curve with band, probability curve, odds ratios, ROC, confusion matrix, importance, bootstrap, forecast band, event study / IRF, ellipses |
| `06_polish_and_export.R` | Final presentation quality | Team theme, fixed colours, finding-style titles, number formats, ordering and lumping categories, annotation, highlight, direct labels, legends, facet labels, patchwork layouts, export sizes, checklist |

## Find it fast

| I want to... | Script | Look for |
|---|---|---|
| Change axis to log | `00` | `scale_x_log10`, `scale_y_log10` |
| Zoom without dropping data | `00` | `coord_cartesian` |
| Put plots side by side | `00` | `p1 + p2`, `p1 / p2` |
| Use one legend for several plots | `00` | `plot_layout(guides = "collect")` |
| Histogram or density | `01` | `geom_histogram`, `geom_density` |
| Compare a variable across groups | `01` | `geom_boxplot`, `geom_violin`, `geom_density_ridges` |
| Check normality | `01` | `stat_qq` |
| Scatter with a trend line | `02` | `geom_smooth(method = "lm")` |
| Too many overlapping points | `02` | `geom_hex`, `geom_bin2d`, `geom_jitter` |
| Label only some points | `02` | `geom_text_repel` |
| Correlation heatmap | `02` | section CORRELATION HEATMAP (`geom_tile`) |
| All pairs of variables | `02` | `ggpairs` |
| Bar chart with error bars | `03` | `geom_errorbar`, `stat_summary` |
| Sorted horizontal bars | `03` | `fct_infreq`, `fct_reorder`, `coord_flip` |
| Shares that sum to 100% | `03` | `position = "fill"` |
| Before vs after by group | `03` | slope chart, dumbbell |
| Parts of a whole | `03` | treemap, stacked bar |
| Flows between categories | `03` | `geom_alluvium` |
| Line chart with a date axis | `04` | `scale_x_date` |
| Shade a recession or event | `04` | `annotate("rect")`, `geom_vline` |
| Two y-axes | `04` | `sec_axis` |
| Index to 100 / growth rates | `04` | INDEX AND GROWTH |
| Seasonal pattern | `04` | seasonal lines, calendar heatmap |
| Many units over time | `04` | spaghetti, highlight one, facet |
| Coefficient plot | `05` | `tidy(conf.int = TRUE)` + `geom_pointrange` |
| Regression diagnostics | `05` | `augment` + residual plots |
| Effect of one variable with a band | `05` | `predict(interval = "confidence")` + `geom_ribbon` |
| ROC curve | `05` | `roc` tibble, `auc` |
| Forecast with a band | `05` | FORECAST section |
| Event-study plot | `05` | `es` tibble |
| Format axis as %, $, 1M | `06` | `label_percent`, `label_dollar`, `label_number` |
| Keep the same colours everywhere | `06` | `cols` + `scale_colour_manual` |
| Slide-sized or report-sized export | `06` | `ggsave` sizes |

Marked **(c)** below means the function is inside a commented-out line. Uncomment it to use it.

## Appendix: every function used

Base R basics (`c`, `list`, `mean`, `sd`, `sum`, `round`, `paste0`, `seq`, `head`, `tail`, `max`, `min`, `sample`) are left out. `theme_sprint()` is defined in `06_polish_and_export.R`.

### ggplot2: building a plot
- `ggplot2::ggplot` - starts a plot
- `ggplot2::aes` - maps columns to x, y, colour, fill, size, shape
- `ggplot2::labs` - titles, axis labels, legend titles, caption
- `ggplot2::annotate` - adds a one-off text, rectangle, segment or arrow
- `ggplot2::after_stat` - uses a statistic the plot computed (such as count or density)
- `ggplot2::ggsave` - saves the last plot to png, pdf and so on

### ggplot2: geoms (the shapes)
- `ggplot2::geom_point` - scatter points
- `ggplot2::geom_jitter` - points with a small random shift
- `ggplot2::geom_count` - point size shows how many overlap
- `ggplot2::geom_line` / `ggplot2::geom_path` - line in x order / line in data order
- `ggplot2::geom_step` - step line
- `ggplot2::geom_smooth` - trend line (lm, loess, gam) with a band
- `ggplot2::geom_abline` / `ggplot2::geom_hline` / `ggplot2::geom_vline` - reference lines
- `ggplot2::geom_segment` - a straight line between two points
- `ggplot2::geom_rug` - tick marks along the axes for each observation
- `ggplot2::geom_histogram` / `ggplot2::geom_freqpoly` - counts in bins as bars / as a line
- `ggplot2::geom_density` - smoothed distribution
- `ggplot2::geom_density_2d` / `ggplot2::geom_density_2d_filled` - 2D density contours / filled
- `ggplot2::geom_bin2d` / `ggplot2::geom_hex` - 2D counts in square / hexagon bins (hex needs `hexbin`)
- `ggplot2::geom_bar` - bar height = row count
- `ggplot2::geom_col` - bar height = a value you supply
- `ggplot2::geom_boxplot` / `ggplot2::geom_violin` - box summary / mirrored density
- `ggplot2::geom_dotplot` - one dot per observation
- `ggplot2::geom_errorbar` / `ggplot2::geom_pointrange` - interval bars / point with interval
- `ggplot2::geom_ribbon` / `ggplot2::geom_area` - shaded band between two lines / filled area
- `ggplot2::geom_tile` - coloured squares (heatmaps)
- `ggplot2::geom_text` - text labels

### ggplot2: stats and summaries
- `ggplot2::stat_summary` - computes a summary (mean, mean +/- SE) inside the plot
- `ggplot2::stat_ecdf` - cumulative distribution
- `ggplot2::stat_qq` / `ggplot2::stat_qq_line` - normal QQ points / reference line
- `ggplot2::stat_function` - draws a function such as a normal curve
- `ggplot2::stat_ellipse` - confidence ellipse around a cloud of points
- `ggplot2::mean_se` (used as `fun.data`) - mean with a standard-error interval

### ggplot2: scales
- `ggplot2::scale_x_continuous` / `ggplot2::scale_y_continuous` - limits, breaks, labels, second axis, padding
- `ggplot2::scale_x_log10` / `ggplot2::scale_y_log10` - log axes
- `ggplot2::scale_x_reverse` - reverses an axis
- `ggplot2::scale_x_date` - date axis breaks and labels
- `ggplot2::scale_x_discrete` - category axis settings
- `ggplot2::sec_axis` - second y-axis
- `ggplot2::expansion` - space between the data and the axis edge
- `ggplot2::xlim` - quick x limits (used for the donut)
- `ggplot2::scale_colour_manual` / `ggplot2::scale_fill_manual` - your own colours
- `ggplot2::scale_colour_brewer` - ColorBrewer palettes
- `ggplot2::scale_colour_viridis_d` / `ggplot2::scale_colour_viridis_c` / `ggplot2::scale_fill_viridis_c` - colour-blind friendly palettes
- `ggplot2::scale_colour_gradient` - two-colour continuous scale
- `ggplot2::scale_colour_gradient2` / `ggplot2::scale_fill_gradient2` - diverging scale around a midpoint
- `ggplot2::scale_size_area` - bubble size proportional to area

### ggplot2: layout, coordinates, themes
- `ggplot2::facet_wrap` / `ggplot2::facet_grid` - one panel per group / rows by columns
- `ggplot2::as_labeller` - relabels facet panels
- `ggplot2::coord_flip` - swaps x and y
- `ggplot2::coord_cartesian` - zooms without dropping data
- `ggplot2::coord_fixed` - equal scale on both axes
- `ggplot2::coord_polar` - polar coordinates (pie, donut)
- `ggplot2::theme` - fine control of text, legend, grid lines
- `ggplot2::element_text` / `ggplot2::element_blank` - style text / remove an element
- `ggplot2::theme_set` - sets the default theme for the session
- `ggplot2::theme_minimal` / `ggplot2::theme_bw` / `ggplot2::theme_classic` / `ggplot2::theme_light` / `ggplot2::theme_void` - ready-made looks
- `ggplot2::guides` / `ggplot2::guide_legend` - legend layout and removal
- `ggplot2::position_dodge` - places bars side by side
- `grid::arrow` / `grid::unit` - arrow heads and sizes for `annotate("segment")`

### Combining plots and special charts
- `patchwork::plot_layout` - sets widths, heights and shared legends
- `patchwork::plot_annotation` - overall title and panel tags (A, B, C)
- `patchwork::inset_element` - places a small plot inside a larger one
- `ggridges::geom_density_ridges` - stacked density ridgelines
- `ggrepel::geom_text_repel` - labels that don't overlap
- `GGally::ggpairs` - scatterplot matrix with distributions and correlations
- `treemapify::geom_treemap` / `treemapify::geom_treemap_text` - treemap boxes / labels
- `ggalluvial::geom_alluvium` / `ggalluvial::geom_stratum` - flow ribbons / category blocks
- `marginaleffects::plot_predictions` **(c)** - one-line effect plot with a band
- `pROC::ggroc` **(c)** - ROC curve from a `pROC` object
- `vip::vip` **(c)** - variable importance plot for a fitted model

### scales
- `scales::label_comma` / `scales::label_dollar` / `scales::label_percent` / `scales::percent` - format axis numbers
- `scales::label_number` with `scales::cut_short_scale` - shorten to 1K, 1M, 1B

### dplyr / tidyr / forcats / tibble
- `dplyr::mutate` / `dplyr::transmute` / `dplyr::select` / `dplyr::filter` - add, keep and pick columns and rows
- `dplyr::group_by` / `dplyr::summarise` / `dplyr::count` - group and summarise
- `dplyr::arrange` - sorts rows
- `dplyr::slice_max` / `dplyr::slice_tail` - rows with the largest value / the last rows
- `dplyr::lag` / `dplyr::first` / `dplyr::last` / `dplyr::n` - previous value / first / last / group size
- `dplyr::bind_rows` / `dplyr::bind_cols` - stack tables / join side by side
- `tidyr::pivot_longer` / `tidyr::pivot_wider` - wide to long / long to wide
- `forcats::fct_reorder` - orders categories by another variable
- `forcats::fct_infreq` / `forcats::fct_rev` - orders by frequency / reverses order
- `forcats::fct_lump_n` - keeps the top n categories, groups the rest as "Other"
- `tibble::tibble` / `tibble::as_tibble` / `tibble::rownames_to_column` - build tables / convert / turn row names into a column

### models and time series used for plotting
- `broom::tidy` - model coefficients as a table (`conf.int = TRUE` for intervals)
- `broom::augment` - adds fitted values, residuals, leverage, Cook's distance to the data
- `stats::lm` / `stats::glm` / `stats::predict` / `stats::coef` - models, predictions, coefficients
- `stats::acf` - autocorrelation values
- `stats::stl` / `stats::ts` - decomposition / time-series object
- `stats::poly` - polynomial terms for `geom_smooth`
- `stats::qnorm` / `stats::rnorm` / `stats::quantile` - normal quantile / random draws / percentiles
- `zoo::rollmean` - rolling average
