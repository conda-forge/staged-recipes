"""Exercise the installed native extension and its NumPy interface offline."""

import importlib.machinery
import subprocess
from importlib.metadata import version
from pathlib import Path

import numpy as np
import phasesmith
from phasesmith import _core, reference

assert phasesmith.__version__ == version("phasesmith")
assert any(_core.__file__.endswith(suffix) for suffix in importlib.machinery.EXTENSION_SUFFIXES)

# Exercise the installed launcher and resources outside the source checkout.
skill = subprocess.run(
    ["phasesmith", "skill", "--path"], check=True, capture_output=True, text=True
)
skill_path = Path(skill.stdout.strip())
assert skill_path.is_absolute()
for relative in (
    "SKILL.md",
    "agents/openai.yaml",
    "references/experiment.md",
    "references/workflow.md",
    "references/interpretation.md",
):
    assert (skill_path / relative).read_text(encoding="utf-8").strip(), relative

delta = np.linspace(-0.8, 0.8, 401, dtype=np.float64)
actual = phasesmith.profile(delta, 0.12, 0.35)
expected = reference.profile(delta, 0.12, 0.35)
for field in ("value", "d_delta", "d_fwhm", "d_eta"):
    np.testing.assert_allclose(
        getattr(actual, field), getattr(expected, field), rtol=4e-15, atol=2e-14
    )

x = np.linspace(10.003, 19.997, 4000, dtype=np.float64)
positions = np.array([11.0, 13.5, 17.0], dtype=np.float64)
intensities = np.array([100.0, 50.0, 80.0], dtype=np.float64)
fwhms = np.array([0.08, 0.12, 0.06], dtype=np.float64)
etas = np.array([0.2, 0.5, 0.8], dtype=np.float64)
actual = phasesmith.accumulate(x, positions, intensities, fwhms, etas, support_fwhm=7.37)
expected_y, expected_jacobian = reference.accumulate(
    x, positions, intensities, fwhms, etas, support_fwhm=7.37
)
np.testing.assert_allclose(actual.y, expected_y, rtol=3e-15, atol=2e-13)
np.testing.assert_allclose(
    actual.jacobian.to_dense(x.size), expected_jacobian, rtol=4e-15, atol=2e-13
)
print(f"PhaseSmith {phasesmith.__version__}: native profile and accumulation checks passed")
