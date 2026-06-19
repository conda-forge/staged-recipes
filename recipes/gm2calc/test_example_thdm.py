"""ctypes equivalent of GM2Calc's examples/example_thdm.py.

Builds a Two-Higgs-Doublet Model from a physical (mass) basis plus SM input,
then computes a_mu = (g-2)/2 of the muon at 1- and 2-loop and its uncertainty.
This exercises GM2Calc's THDM C API (struct-based input + constructor) through
the ctypes interface (no cppyy/JIT).
"""

import math

import gm2calc

basis = gm2calc.THDMMassBasis()
basis.yukawa_type = gm2calc.YukawaType.type_2
basis.mh = 125.0
basis.mH = 400.0
basis.mA = 420.0
basis.mHp = 440.0
basis.sin_beta_minus_alpha = 0.999
basis.lambda_6 = 0.0
basis.lambda_7 = 0.0
basis.tan_beta = 3.0
basis.m122 = 40000.0
basis.zeta_u = 0.0
basis.zeta_d = 0.0
basis.zeta_l = 0.0
# Delta_* and Pi_* matrices default to zero

sm = gm2calc.SM()
sm.set_alpha_em_mz(1.0 / 128.94579)
sm.set_mu(2, 173.34)  # top
sm.set_mu(1, 1.28)  # charm
sm.set_md(2, 4.18)  # bottom
sm.set_ml(2, 1.77684)  # tau

config = gm2calc.THDMConfig()
config.force_output = False
config.running_couplings = True

model = gm2calc.THDM(basis, sm, config)

amu = model.calculate_amu_1loop() + model.calculate_amu_2loop()
delta_amu = model.calculate_uncertainty_amu_2loop()
print(f"amu = {amu:.8e} +- {delta_amu:.8e}")

assert math.isfinite(amu), "a_mu is not finite"
assert amu > 0, f"expected a positive THDM contribution to a_mu, got {amu}"
assert math.isfinite(delta_amu) and delta_amu >= 0, "invalid a_mu uncertainty"
# Reference values for this mass-basis point (verified against libgm2calc).
assert math.isclose(amu, 1.67323022e-11, rel_tol=1e-3), f"unexpected a_mu: {amu}"
assert math.isclose(delta_amu, 3.36159651e-12, rel_tol=1e-3), (
    f"unexpected a_mu uncertainty: {delta_amu}"
)
