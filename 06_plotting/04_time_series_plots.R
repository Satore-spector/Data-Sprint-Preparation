# 04_time_series_plots.R - change over time: lines, areas, seasonality, panels. Needs a date column.
library(tidyverse); library(scales); library(zoo)
theme_set(theme_minimal(base_size = 13))

# ---- DEMO DATA ----
# one series: date, value        many series: economics_long (date, variable, value, value01)
# panel:      txhousing (city, year, month, date, sales)
df <- economics |> transmute(date, value = unemploy)
long <- economics_long
tx <- txhousing |> filter(city %in% c("Austin", "Dallas", "Houston", "San Antonio"))

# ---- LINES ----
ggplot(df, aes(date, value)) + geom_line()
ggplot(df |> slice_tail(n = 24), aes(date, value)) + geom_line() + geom_point()      # few points: show them
ggplot(long, aes(date, value01, colour = variable)) + geom_line()                    # several series, one scale
ggplot(long, aes(date, value)) + geom_line() + facet_wrap(~ variable, scales = "free_y")   # own scale each
ggplot(df, aes(date, value)) + geom_step()                                           # steps (rates, policies)

# ---- DATE AXIS ----
ggplot(df, aes(date, value)) + geom_line() +
  scale_x_date(date_breaks = "10 years", date_labels = "%Y") +
  scale_y_continuous(labels = label_comma())
# limits: scale_x_date(limits = as.Date(c("2000-01-01", "2015-01-01")))

# ---- TREND, BANDS, ROLLING AVERAGE ----
ggplot(df, aes(date, value)) + geom_line(colour = "grey70") + geom_smooth(span = .2, colour = "red", se = FALSE)
ggplot(df, aes(date, value)) + geom_line(colour = "grey70") +
  geom_line(aes(y = rollmean(value, 12, fill = NA, align = "right")), colour = "steelblue", linewidth = 1)
ggplot(df, aes(date, value)) + geom_ribbon(aes(ymin = value * .9, ymax = value * 1.1), alpha = .2) + geom_line()
# ^ replace ymin / ymax with real confidence or forecast bands

# ---- AREAS ----
ggplot(df, aes(date, value)) + geom_area(fill = "steelblue", alpha = .5)
ggplot(tx, aes(date, sales, fill = city)) + geom_area()                              # stacked totals
ggplot(tx, aes(date, sales, fill = city)) + geom_area(position = "fill") +           # shares over time
  scale_y_continuous(labels = percent)

# ---- MARK EVENTS AND PERIODS ----
ggplot(df, aes(date, value)) +
  annotate("rect", xmin = as.Date("2007-12-01"), xmax = as.Date("2009-06-01"),
           ymin = -Inf, ymax = Inf, alpha = .2, fill = "grey40") +                   # shaded period
  geom_vline(xintercept = as.Date("2008-09-15"), linetype = 2) +                     # single event
  annotate("text", x = as.Date("2008-09-15"), y = max(df$value), label = "Event", hjust = 1.1) +
  geom_line()

# ---- TWO UNITS ON ONE PLOT: second axis (use with care) ----
ggplot(economics, aes(date)) +
  geom_line(aes(y = unemploy), colour = "steelblue") +
  geom_line(aes(y = psavert * 500), colour = "firebrick") +                          # rescale the second series
  scale_y_continuous(name = "Unemployed", sec.axis = sec_axis(~ . / 500, name = "Saving rate (%)"))

# ---- INDEX AND GROWTH ----
long |> group_by(variable) |> mutate(idx = value / first(value) * 100) |>
  ggplot(aes(date, idx, colour = variable)) + geom_line() + scale_y_log10() + labs(y = "Index (start = 100)")
df |> mutate(yoy = value / lag(value, 12) - 1) |>
  ggplot(aes(date, yoy)) + geom_col() + scale_y_continuous(labels = percent)         # growth rate bars

# ---- SEASONALITY ----
au <- txhousing |> filter(city == "Austin")
ggplot(au, aes(month, sales, group = year, colour = factor(year))) + geom_line() +   # one line per year
  scale_x_continuous(breaks = 1:12)
ggplot(au, aes(factor(month), factor(year), fill = sales)) + geom_tile() +           # calendar heatmap
  scale_fill_viridis_c() + labs(x = "Month", y = NULL)
ggplot(au, aes(factor(month), sales)) + geom_boxplot()                               # typical month pattern

# ---- PANEL DATA: MANY UNITS OVER TIME ----
ggplot(txhousing, aes(date, sales, group = city)) + geom_line(alpha = .3)            # spaghetti
ggplot(txhousing, aes(date, sales, group = city)) + geom_line(colour = "grey80") +
  geom_line(data = filter(txhousing, city == "Austin"), colour = "red", linewidth = 1)   # highlight one
ggplot(tx, aes(date, sales)) + geom_line() + facet_wrap(~ city)                      # small multiples
txhousing |> group_by(date) |> summarise(m = mean(sales, na.rm = TRUE)) |>           # average over units
  ggplot(aes(date, m)) + geom_line()

# ---- AUTOCORRELATION PLOT ----
a <- acf(df$value, lag.max = 36, plot = FALSE)
ggplot(tibble(lag = a$lag[, 1, 1], acf = a$acf[, 1, 1]), aes(lag, acf)) + geom_col(width = .2) +
  geom_hline(yintercept = c(-1, 1) * qnorm(.975) / sqrt(a$n.used), linetype = 2, colour = "blue")

# ---- DECOMPOSITION ----
dec <- stl(ts(df$value, start = c(1967, 7), frequency = 12), s.window = "periodic")
bind_cols(date = df$date, as.data.frame(dec$time.series), observed = df$value) |>
  pivot_longer(-date) |> ggplot(aes(date, value)) + geom_line() + facet_wrap(~ name, ncol = 1, scales = "free_y")
