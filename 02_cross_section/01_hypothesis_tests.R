# 01_hypothesis_tests.R - classical tests. Swap in your variable names.
library(tidyverse); library(rstatix)
df <- readRDS("out/clean.rds")

# ---- NORMALITY (decides parametric vs non-parametric) ----
shapiro.test(sample(df$y, min(5000, nrow(df))))      # H0: normal

# ---- ONE-SAMPLE t-test ----
t.test(df$y, mu = 0)

# ---- TWO-SAMPLE t-test (g must have exactly 2 levels) ----
var.test(y ~ g, data = df)                           # H0: equal variances
t.test(y ~ g, data = df)                             # Welch by default (safe)
t.test(y ~ g, data = df, var.equal = TRUE)           # if variances equal
wilcox.test(y ~ g, data = df)                        # non-parametric alternative
# effect size: df |> cohens_d(y ~ g)

# ---- PAIRED t-test ----
# t.test(df$before, df$after, paired = TRUE)

# ---- ANOVA (g with 3+ levels) ----
aov_fit <- aov(y ~ g, data = df); summary(aov_fit)
TukeyHSD(aov_fit)                                    # which groups differ
car::leveneTest(y ~ g, data = df)                    # equal variance check
kruskal.test(y ~ g, data = df)                       # non-parametric alternative

# ---- CHI-SQUARE: independence of two categoricals ----
tab <- table(df$cat1, df$cat2); tab
chisq.test(tab)                                      # H0: independent
chisq.test(tab)$expected                             # need all >= 5
# fisher.test(tab)                                   # if expected counts small
# effect size: rstatix::cramer_v(tab)

# ---- CHI-SQUARE goodness of fit ----
# chisq.test(table(df$cat1), p = c(.25, .25, .5))

# ---- CORRELATION ----
cor.test(df$x, df$y)                                 # Pearson
cor.test(df$x, df$y, method = "spearman")            # rank-based

# ---- PROPORTIONS ----
# prop.test(x = c(40, 55), n = c(100, 100))          # two-group proportion test

# Reading results: p < 0.05 -> reject H0. Always report the effect size too.
