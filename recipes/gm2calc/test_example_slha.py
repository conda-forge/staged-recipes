"""ctypes equivalent of GM2Calc's examples/example_slha.py.

Unlike the gm2calc-input example, this defines the MSSM point through physical
pole masses (smuons, charginos, neutralinos, CP-odd Higgs) plus DR-bar guesses,
then runs the on-shell conversion (``convert_to_onshell``) before computing
a_mu = (g-2)/2 of the muon.  This exercises a different GM2Calc code path than
test_python_interface.py, again through the ctypes interface (no cppyy/JIT).
"""

import math

import gm2calc

model = gm2calc.MSSMNoFV()

squark_mass_sq = 7000.0 * 7000.0
slepton_mass_sq = 500.0 * 500.0

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

# pole masses
model.set_MSvmL_pole(5.18860573e02)
model.set_MSm_pole(0, 5.05095249e02)
model.set_MSm_pole(1, 5.25187016e02)
model.set_MChi_pole(0, 2.01611468e02)
model.set_MChi_pole(1, 4.10040273e02)
model.set_MChi_pole(2, -5.16529941e02)
model.set_MChi_pole(3, 5.45628749e02)
model.set_MCha_pole(0, 4.09989890e02)
model.set_MCha_pole(1, 5.46057190e02)
model.set_MAh_pole(1.50000000e03)

# DR-bar parameters (Mu, MassB, MassWB are initial guesses for the conversion)
model.set_TB(40)
model.set_Mu(500)
model.set_MassB(200)
model.set_MassWB(400)
model.set_MassG(2000)
# squark soft masses as a full 3x3 matrix (mirrors the C++ example's
# Identity * 7000^2); sleptons set element-wise on the diagonal
squark_matrix = [
    [squark_mass_sq if i == j else 0.0 for j in range(3)] for i in range(3)
]
model.set_mq2(squark_matrix)
model.set_md2(squark_matrix)
model.set_mu2(squark_matrix)
for i in range(3):
    model.set_ml2(i, i, slepton_mass_sq)
    model.set_me2(i, i, slepton_mass_sq)
model.set_Au(2, 2, 0)
model.set_Ad(2, 2, 0)
model.set_Ae(1, 1, 0)
model.set_Ae(2, 2, 0)
model.set_scale(1000)

# convert the DR-bar parameters to the on-shell scheme
model.convert_to_onshell()

if model.have_warning():
    print(model.get_warnings())
if model.have_problem():
    print(model.get_problems())

amu = model.calculate_amu_1loop() + model.calculate_amu_2loop()
delta_amu = model.calculate_uncertainty_amu_2loop()
print(f"amu = {amu:.8e} +- {delta_amu:.8e}")

assert math.isfinite(amu), "a_mu is not finite"
assert amu > 0, f"expected a positive SUSY contribution to a_mu, got {amu}"
assert math.isfinite(delta_amu) and delta_amu >= 0, "invalid a_mu uncertainty"
# Reference values for this on-shell input point (verified against libgm2calc).
assert math.isclose(amu, 2.33920775e-09, rel_tol=1e-3), f"unexpected a_mu: {amu}"
assert math.isclose(delta_amu, 2.33422571e-10, rel_tol=1e-3), (
    f"unexpected a_mu uncertainty: {delta_amu}"
)
