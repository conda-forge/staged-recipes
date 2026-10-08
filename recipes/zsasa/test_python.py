"""Check the zsasa Python package against the library and program of the environment."""

import math
import os
import shutil
import subprocess
import sys

import numpy as np

import zsasa
from zsasa import _ffi, cli

expected_version = sys.argv[1]
prefix = os.path.realpath(sys.prefix)


def inside_prefix(path):
    return os.path.realpath(path).startswith(prefix + os.sep)


# The library is the one of libzsasa, not a copy inside the Python package.
library = str(_ffi._find_library())
package_dir = os.path.dirname(os.path.realpath(zsasa.__file__))
assert inside_prefix(library), f"loaded {library}, which is outside {prefix}"
assert not os.path.realpath(library).startswith(package_dir + os.sep), library
assert zsasa.get_version() == expected_version, zsasa.get_version()

# One atom: the whole sphere of radius (atom + probe) is accessible.
result = zsasa.calculate_sasa(np.array([[0.0, 0.0, 0.0]]), np.array([1.8]))
expected_area = 4 * math.pi * (1.8 + 1.4) ** 2
assert abs(result.total_area - expected_area) < 0.01, result.total_area

# `zsasa` on PATH is the native program of zsasa-cli, not a Python console
# script, and it is the program `python -m zsasa` runs.
command = shutil.which("zsasa")
assert command is not None, "no zsasa on PATH"
assert inside_prefix(command), command
with open(command, "rb") as f:
    assert f.read(2) != b"#!", f"{command} is a script"
assert os.path.realpath(cli._find_binary()) == os.path.realpath(command), cli._find_binary()
if sys.platform == "win32":
    launcher = os.path.join(sys.prefix, "Scripts", "zsasa.exe")
    assert not os.path.exists(launcher), f"{launcher} would be a second zsasa command"

for argv in (["zsasa", "--version"], [sys.executable, "-m", "zsasa", "--version"]):
    run = subprocess.run(argv, capture_output=True, text=True, check=True)
    assert run.stdout == f"zsasa {expected_version}\n", (argv, run.stdout, run.stderr)

print(f"zsasa {expected_version}: library {library}, program {command}, area {result.total_area:.2f}")
