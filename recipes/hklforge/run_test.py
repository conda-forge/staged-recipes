"""Smoke test: solve a reflection on the built-in psic geometry (checks the
solver and the packaged geometry files, with numpy and pyyaml only)."""
from hklforge import Diffractometer, Geometry
from hklforge.lattice import b_matrix

d = Diffractometer(Geometry.builtin("psic"), b_matrix(5.431, 5.431, 5.431),
                   energy=9000, surface_hkl=(0, 0, 1), reference_hkl=(0, 0, 1))
solutions = d.solve((1, 1, 2), {"eta": 0, "chi": 0, "phi": 0})
assert len(solutions) > 0, solutions
print(len(solutions), "solutions")
