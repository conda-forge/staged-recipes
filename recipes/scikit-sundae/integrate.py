import numpy as np
import sksundae as sun


# ODE Solvers
# ------------------------------------------------------------------------------
def rhsfn(t, y, yp):
    yp[0] = y[1]
    yp[1] = 1e3*(1. - y[0]**2)*y[1] - y[0]


y0 = np.array([0.5, 0.5])
yp0 = np.zeros_like(y0)
tspan = np.linspace(0., 500., 200)

solver = sun.cvode.CVODE(rhsfn)
soln = solver.solve(tspan, y0)
print(f"CVODE ODE test - {soln.success=}")
assert soln.success


# DAE Solvers (should be able to solve both ODEs and DAEs)
# ------------------------------------------------------------------------------
def resfn(t, y, yp, res):  # ODE example
    res[0] = yp[0] - y[1]
    res[1] = yp[1] - 1e3*(1. - y[0]**2)*y[1] + y[0]


y0 = np.array([0.5, 0.5])
yp0 = np.zeros_like(y0)
tspan = np.linspace(0., 500., 200)

solver = sun.ida.IDA(resfn, calc_initcond='yp0')
soln = solver.solve(tspan, y0, yp0)
print(f"IDA ODE test - {soln.success=}")
assert soln.success


def resfn(t, y, yp, res):  # DAE example
    res[0] = yp[0] + 0.04*y[0] - 1e4*y[1]*y[2]
    res[1] = yp[1] - 0.04*y[0] + 1e4*y[1]*y[2] + 3e7*y[1]**2
    res[2] = y[0] + y[1] + y[2] - 1.


y0 = np.array([1., 0., 0.])
yp0 = np.zeros_like(y0)
tspan = np.hstack([0., 4.*np.logspace(-6, 6)])

solver = sun.ida.IDA(resfn, algebraic_idx=[2], calc_initcond='yp0')
soln = solver.solve(tspan, y0, yp0)
print(f"IDA DAE test - {soln.success=}")
assert soln.success