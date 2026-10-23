# 02_pooled_fe_re.R - pooled OLS, fixed effects, random effects, and the tests to choose.
library(plm); library(fixest); library(lmtest); library(sandwich); library(modelsummary)
pdata <- readRDS("out/pdata.rds")
df <- as.data.frame(pdata)

f <- y ~ x1 + x2 + x3

# ---- plm models ----
pool <- plm(f, data = pdata, model = "pooling")
fe   <- plm(f, data = pdata, model = "within")                       # entity FE
fe2  <- plm(f, data = pdata, model = "within", effect = "twoways")   # entity + time FE
re   <- plm(f, data = pdata, model = "random")

# ---- MODEL SELECTION ----
pFtest(fe, pool)        # H0: no entity effects. Reject -> FE beats pooled
plmtest(pool, type = "bp")   # H0: no random effects. Reject -> RE beats pooled
phtest(fe, re)          # Hausman H0: RE consistent. Reject -> use FE
pFtest(fe2, fe)         # are time effects needed?

# ---- CLUSTERED SEs (always, in panels) ----
coeftest(fe, vcov = vcovHC(fe, type = "HC1", cluster = "group"))

# ---- fixest: faster, cleaner, same answers ----
m_fe  <- feols(y ~ x1 + x2 + x3 | id + year, data = df, cluster = ~id)
m_fe1 <- feols(y ~ x1 + x2 + x3 | id, data = df, cluster = ~id)
etable(m_fe1, m_fe)
# Add a second cluster: cluster = ~id + year
# Two-way FE with a binary treatment = difference-in-differences:
#   feols(y ~ treated:post | id + year, data = df, cluster = ~id)
# Event study: feols(y ~ i(rel_time, treated, ref = -1) | id + year, data = df); iplot(...)

# ---- COMPARE ----
modelsummary(list(Pooled = pool, FE = fe, RE = re), stars = TRUE, output = "out/panel_table.html")

# ---- DYNAMIC PANEL (lagged y; FE biased if T is short) ----
# pgmm(y ~ lag(y, 1) + x1 | lag(y, 2:4), data = pdata, effect = "individual", transformation = "d")
