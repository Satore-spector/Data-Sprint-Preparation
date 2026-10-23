# 03_time_series

Quick index for one unit observed over time. Scripts run in order, and later ones read `out/ts_objects.rds` made by `01`.

## What's in each script

| Script | Use it for | What's inside (in order) |
|---|---|---|
| `01_ts_prep_plots.R` | Turning a column into a `ts` object and looking at it | Config (date, value, frequency, start) / time, season, ACF/PACF plots / STL decomposition / fill gaps / log, difference, growth rate / train-test split / save `out/ts_objects.rds` |
| `02_stationarity.R` | Deciding if you need to difference | ADF / KPSS / how many differences / retest / structural breaks (commented) / cointegration: Engle-Granger and Johansen (commented) |
| `03_arima.R` | Forecasting one series | Auto ARIMA / ETS / naive benchmarks / accuracy on held-out data / refit and forecast ahead / ARMA errors with regressors / GARCH pointer (commented) |
| `04_var_granger.R` | Several series moving together | Lag selection / VAR estimate / stability + residual checks / Granger causality / impulse responses + variance decomposition / forecast |

## Find it fast

| I want to... | Script | Look for |
|---|---|---|
| Set the data frequency (monthly, quarterly) | `01` | CONFIG: `freq`, `start_y` |
| See seasonality | `01` | `ggseasonplot`, `ggsubseriesplot` |
| See autocorrelation | `01` | `ggAcf`, `ggPacf` |
| Split trend / season / noise | `01` | `stl` |
| Fill gaps in a series | `01` | `na.interp` |
| Log, difference, growth rate | `01` | TRANSFORMS |
| Hold out the last h periods | `01` | `train` / `test` |
| Test for a unit root | `02` | `adf.test`, `ur.df` |
| Test for stationarity (opposite null) | `02` | `kpss.test` |
| Count differences needed | `02` | `ndiffs`, `nsdiffs` |
| Find structural breaks | `02` | `breakpoints` (commented) |
| Test cointegration | `02` | `ca.jo`, Engle-Granger (commented) |
| Fit ARIMA automatically | `03` | `auto.arima` |
| Fit ARIMA by hand | `03` | `Arima(order = ...)` (commented) |
| Fit exponential smoothing | `03` | `ets` |
| Make benchmark forecasts | `03` | `naive`, `snaive`, `rwf` |
| Compare forecast accuracy | `03` | `accuracy` |
| Check ARIMA residuals | `03` | `checkresiduals` |
| Add exogenous regressors | `03` | `Arima(xreg = ...)` (commented) |
| Volatility / GARCH | `03` | `rugarch` (commented) |
| Pick VAR lag length | `04` | `VARselect` |
| Estimate a VAR | `04` | `VAR` |
| Check VAR stability and residuals | `04` | `roots`, `serial.test`, `arch.test`, `normality.test` |
| Granger causality | `04` | `causality` |
| Impulse responses | `04` | `irf` |
| Variance decomposition | `04` | `fevd` |

Marked **(c)** below means the function is inside a commented-out line. Uncomment it to use it.

## Appendix: every function used

Base R basics (`c`, `list`, `length`, `head`, `tail`, `sum`, `summary`, `plot`, `cbind`, `do.call`, `lapply`) are left out.

### stats / base
- `stats::ts` - builds a time-series object from a vector
- `stats::stl` - splits a series into trend, season and remainder
- `base::diff` - differences a series (change from the previous period)
- `base::log` - natural log
- `base::is.na` - TRUE where a value is missing
- `stats::na.omit` - drops missing values
- `stats::lm` - linear regression (used in Engle-Granger)
- `stats::predict` - forecast from a fitted model
- `stats::resid` / `stats::residuals` - model residuals

### forecast
- `forecast::autoplot` - quick plot for ts and forecast objects
- `forecast::autolayer` - adds a series on top of an autoplot
- `forecast::ggseasonplot` - plot of each year's seasonal pattern
- `forecast::ggsubseriesplot` - one panel per season
- `forecast::ggAcf` / `forecast::ggPacf` - autocorrelation and partial autocorrelation plots
- `forecast::na.interp` **(c)** - fills gaps by interpolation (seasonal aware)
- `forecast::ndiffs` - number of ordinary differences needed for stationarity
- `forecast::nsdiffs` - number of seasonal differences needed
- `forecast::auto.arima` - picks and fits the best ARIMA
- `forecast::Arima` **(c)** - fits an ARIMA with chosen orders
- `forecast::ets` - fits exponential smoothing (ETS)
- `forecast::forecast` - forecasts from a fitted model
- `forecast::naive` - forecast equal to the last value
- `forecast::snaive` - forecast equal to the same season last year
- `forecast::rwf` - random walk forecast, with optional drift
- `forecast::accuracy` - RMSE, MAE, MAPE on train and test data
- `forecast::checkresiduals` - residual plots plus the Ljung-Box test
- `forecast::dm.test` **(c)** - Diebold-Mariano test of two forecasts

### tseries / urca / strucchange / zoo
- `tseries::adf.test` - Augmented Dickey-Fuller test (H0: unit root)
- `tseries::kpss.test` - KPSS test (H0: stationary)
- `urca::ur.df` - ADF test with lag selection and drift/trend options
- `urca::ca.jo` **(c)** - Johansen cointegration test
- `strucchange::breakpoints` **(c)** - finds structural breaks
- `zoo::rollmean` **(c)** - rolling average

### vars / tsDyn / lmtest
- `vars::VARselect` - suggests VAR lag length (AIC, BIC and others)
- `vars::VAR` - fits a vector autoregression
- `vars::roots` - stability check (all roots must be under 1)
- `vars::serial.test` - tests residuals for serial correlation
- `vars::arch.test` - tests residuals for ARCH effects
- `vars::normality.test` - tests residual normality
- `vars::causality` - Granger causality test within a VAR
- `vars::irf` - impulse response functions
- `vars::fevd` - forecast error variance decomposition
- `vars::vec2var` **(c)** - converts a cointegrated model back into a VAR
- `tsDyn::VECM` **(c)** - vector error correction model
- `lmtest::grangertest` **(c)** - pairwise Granger test

### rugarch / dplyr
- `rugarch::ugarchspec` / `rugarch::ugarchfit` **(c)** - specify and fit a GARCH volatility model
- `dplyr::arrange` - sorts rows (sort by date first)
