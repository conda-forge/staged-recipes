# Copied and modified from the README of https://github.com/bmcage/odes
# BSD-3-Clause, scikit-odes authors

import numpy as np
from scikits.odes import ode


def van_der_pol(t, y, ydot):
    ydot[0] = y[1]
    ydot[1] = 1000*(1.0-y[0]**2)*y[1]-y[0]


t0, y0 = 1, np.array([0.5, 0.5])
ts = np.linspace(t0, 500, 200)
solution = ode('cvode', van_der_pol, old_api=False).solve(ts, y0)
print(solution)
