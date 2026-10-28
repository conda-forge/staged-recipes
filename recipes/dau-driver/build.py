import os
from pathlib import Path
import subprocess
import sys

# The sdist includes a Linux binary; build the extension for the target platform.
for pattern in ("*.so", "*.pyd", "*.dll", "*.dylib"):
    for binary in Path("dau_driver").glob(pattern):
        binary.unlink()

# hatch-cpp invokes CXX directly without adding conda's compiler/linker flags.
if sys.platform == "win32":
    os.environ["CXX"] = os.environ.get("CXX", "cl") + " /MD"
else:
    os.environ["CXX"] += " " + os.environ.get("CXXFLAGS", "") + " " + os.environ.get("LDFLAGS", "")

subprocess.run(
    [sys.executable, "-m", "pip", "install", ".", "-vv", "--no-deps", "--no-build-isolation"],
    check=True,
)
