"""Install the centres jar and the command wrappers.

Runs on every platform (rattler-build calls it with the build environment's python).
The licence texts are fetched as sources into licenses/ (see recipe.yaml).
"""
import os
import shutil
from pathlib import Path

prefix = Path(os.environ["PREFIX"])
recipe_dir = Path(os.environ["RECIPE_DIR"])
src = Path(os.environ.get("SRC_DIR", os.getcwd()))

# The jar, at a path that does not change between versions.
share = prefix / "share" / "centres"
share.mkdir(parents=True, exist_ok=True)
shutil.copy2(src / "centres.jar", share / "centres.jar")

# Command wrappers: bash for Linux and macOS, batch for Windows.
bin_dir = prefix / "bin"
bin_dir.mkdir(parents=True, exist_ok=True)
shutil.copy2(recipe_dir / "centres", bin_dir / "centres")
os.chmod(bin_dir / "centres", 0o755)
shutil.copy2(recipe_dir / "centres.bat", bin_dir / "centres.bat")

licenses = src / "licenses"
for path in sorted(p for p in licenses.rglob("*") if p.is_file()):
    print(path.relative_to(src).as_posix())
