import os, pathlib, shutil, subprocess, sys

SRC_DIR = pathlib.Path(os.environ["SRC_DIR"])
DIST = SRC_DIR / "dist"

shutil.copy2(
    DIST / "scripts" / "owlrl.py",
    DIST / os.environ["PKG_NAME"] / "_cli.py"
)

subprocess.check_call([
    sys.executable, "-m", "pip", "install", ".", "--no-deps", "-vv"], cwd=str(DIST))
