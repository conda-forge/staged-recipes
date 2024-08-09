import numpy as np
from scikits_odes_sundials import ida, idas, cvode, cvodes


class sun:
    ida = ida
    idas = idas
    cvode = cvode
    cvodes = cvodes


# ODE Solvers
# ------------------------------------------------------------------------------
def resfn(t, y, yp):
    yp[0] = y[1]
    yp[1] = 1e3*(1. - y[0]**2)*y[1] - y[0]


y0 = np.array([0.5, 0.5])
yp0 = np.zeros_like(y0)
tspan = np.linspace(0., 500., 200)

solver = sun.cvode.CVODE(resfn)
soln = solver.solve(tspan, y0)
assert soln.flag >= 0

solver = sun.cvodes.CVODES(resfn)
soln = solver.solve(tspan, y0)
assert soln.flag >= 0


# DAE Solvers (should be able to solve both ODEs and DAEs)
# ------------------------------------------------------------------------------
def resfn(t, y, yp, res):  # ODE example
    res[0] = yp[0] - y[1]
    res[1] = yp[1] - 1e3*(1. - y[0]**2)*y[1] + y[0]


y0 = np.array([0.5, 0.5])
yp0 = np.zeros_like(y0)
tspan = np.linspace(0., 500., 200)

solver = sun.ida.IDA(resfn, compute_initcond='yp0')
soln = solver.solve(tspan, y0, yp0)
assert soln.flag >= 0

solver = sun.idas.IDAS(resfn, compute_initcond='yp0')
soln = solver.solve(tspan, y0, yp0)
assert soln.flag >= 0


def resfn(t, y, yp, res):  # DAE example
    res[0] = yp[0] + 0.04*y[0] - 1e4*y[1]*y[2]
    res[1] = yp[1] - 0.04*y[0] + 1e4*y[1]*y[2] + 3e7*y[1]**2
    res[2] = y[0] + y[1] + y[2] - 1.


y0 = np.array([1., 0., 0.])
yp0 = np.zeros_like(y0)
tspan = np.hstack([0., 4.*np.logspace(-6, 6)])

solver = sun.ida.IDA(resfn, algebraic_vars_idx=[2], compute_initcond='yp0')
soln = solver.solve(tspan, y0, yp0)
assert soln.flag >= 0

solver = sun.idas.IDAS(resfn, algebraic_vars_idx=[2], compute_initcond='yp0')
soln = solver.solve(tspan, y0, yp0)
assert soln.flag >= 0
