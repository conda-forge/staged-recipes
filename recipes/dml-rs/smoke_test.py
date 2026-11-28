import numpy as np

import dml_rs

rng = np.random.default_rng(0)
n = 2000
X = rng.normal(size=(n, 5))

# Partially linear model, built-in learners, theta = 0.5.
d = X[:, 0] + rng.normal(size=n)
y = 0.5 * d + X[:, 1] + rng.normal(size=n)
plr = dml_rs.PLR(dml_rs.Ols(), dml_rs.Ols()).fit(X, y, d)
assert abs(plr.coef_[0] - 0.5) < 4 * plr.se_[0], plr.summary

# Interactive regression model with a binary treatment and a forest, ATE = 1.
p = 1 / (1 + np.exp(-X[:, 0]))
db = (rng.random(n) < p).astype(float)
yb = db + X[:, 1] + rng.normal(size=n)
irm = dml_rs.IRM(
    dml_rs.RandomForestRegressor(n_estimators=50, random_state=0),
    dml_rs.LogisticRegression(),
).fit(X, yb, db)
assert abs(irm.coef_[0] - 1.0) < 4 * irm.se_[0], irm.summary

print(plr.summary)
print(irm.summary)
