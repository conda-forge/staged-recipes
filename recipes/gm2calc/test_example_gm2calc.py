"""ctypes equivalent of GM2Calc's examples/example_gm2calc.py.

Builds an on-shell MSSM point through the GM2Calc-specific input scheme, then
computes a_mu = (g-2)/2 of the muon at 1- and 2-loop and its uncertainty.
This exercises loading libgm2calc and calling its C API through ctypes -- no
cppyy, no JIT.  The expected value matches the C++/cppyy example for the same
input point.
"""

import math

import gm2calc

model = gm2calc.MSSMNoFV()

# SM parameters
model.set_alpha_MZ(0.0077552)
model.set_alpha_thompson(0.00729735)
model.set_g3(math.sqrt(4.0 * math.pi * 0.1184))
model.set_MT_pole(173.34)  # top
model.set_MB_running(4.18)  # mb(mb) MS-bar
model.set_MM_pole(0.1056583715)  # muon
model.set_ML_pole(1.777)  # tau
model.set_MW_pole(80.385)
model.set_MZ_pole(91.1876)

# DR-bar parameters
model.set_TB(10)
model.set_Ae(1, 1, 0)

# on-shell parameters
model.set_Mu(350)
model.set_MassB(150)
model.set_MassWB(300)
model.set_MassG(1000)

# diagonal soft-mass matrices with (500 GeV)^2 entries (off-diagonals default
# to zero), equivalent to the Identity * 500^2 used in the C++ example
soft_mass_sq = 500.0 * 500.0
for i in range(3):
    model.set_mq2(i, i, soft_mass_sq)
    model.set_ml2(i, i, soft_mass_sq)
    model.set_md2(i, i, soft_mass_sq)
    model.set_mu2(i, i, soft_mass_sq)
    model.set_me2(i, i, soft_mass_sq)

model.set_Au(2, 2, 0)
model.set_Ad(2, 2, 0)
model.set_Ae(2, 2, 0)
model.set_MAh_pole(1500)
model.set_scale(454.7)

model.calculate_masses()

amu = model.calculate_amu_1loop() + model.calculate_amu_2loop()
delta_amu = model.calculate_uncertainty_amu_2loop()
print(f"amu = {amu:.8e} +- {delta_amu:.8e}")

assert math.isfinite(amu), "a_mu is not finite"
assert amu > 0, f"expected a positive SUSY contribution to a_mu, got {amu}"
assert math.isfinite(delta_amu) and delta_amu >= 0, "invalid a_mu uncertainty"
# Same input point as the C++/cppyy example, so the result must agree.
assert math.isclose(amu, 7.96420843e-10, rel_tol=1e-3), f"unexpected a_mu: {amu}"
