# A Waechter-Biegler example as described in
# "Failure of global convergence for a class
#  of interior-point methods for nonlinear
#  programming", Andreas Waechter and
# Larry Biegler, Mathematical Programming A,
# number 88, pp. 565-574, 2000.
#
# Implementation: D. Orban, Montreal 2004.

model;

var x {1..3};
param a;
param b >= 0;

minimize objective:
    x[1];

subject to equality1:
    x[1]^2 - x[2] + a = 0;

subject to equality2:
    x[1] - x[3] - b = 0;

subject to bound1:
    x[2] >= 0;

subject to bound2:
    x[3] >= 0;

