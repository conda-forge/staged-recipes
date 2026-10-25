"""Build and install fformat with fpm, for the conda package (see recipe.yaml).

fpm fetches the dependencies in fpm.toml during the build. The compiler and flags are those of
the conda build environment.
"""

import os
import subprocess
import sys

env = dict(os.environ)
if sys.platform == "win32":
    # fpm detects Windows from OS=Windows_NT, which the build environment does not pass on;
    # without it, fpm takes the system for Unix and runs Unix commands (`mkdir -p`)
    env.setdefault("OS", "Windows_NT")
env["FPM_FC"] = os.environ.get("FC", "gfortran")
env["FPM_FFLAGS"] = os.environ.get("FFLAGS", "")
env["FPM_LDFLAGS"] = os.environ.get("LDFLAGS", "")

# executables go to $PREFIX/bin, or %LIBRARY_PREFIX%\bin on Windows
prefix = os.environ["LIBRARY_PREFIX"] if sys.platform == "win32" else os.environ["PREFIX"]
subprocess.run(["fpm", "install", "--profile", "release", "--prefix", prefix, "--verbose"],
               cwd=os.environ["SRC_DIR"], env=env, check=True)
