"""Populate a vendor directory from installed (conda-forge / source-built) distributions.

Replacement for positron-python's `pip install --target DIR -r REQS --only-binary :all:`,
so the vendored pure-Python libraries come from conda-forge packages or from sdists
built in this recipe instead of PyPI wheels.

usage: copy_from_env.py REQUIREMENTS_FILE TARGET_DIR

Environment:
  CONDA_VENDOR_PATHS           os.pathsep-separated site dirs to search (in order)
  CONDA_VENDOR_ALLOW_MISMATCH  comma-separated names allowed to differ from the pin
  CONDA_VENDOR_LICENSES        directory to collect each distribution's license files into
"""
import os
import re
import shutil
import sys
from importlib.metadata import distributions
from pathlib import Path


def canon(name):
    return re.sub(r"[-_.]+", "-", name).lower()


def read_pins(path):
    pins = {}
    for line in Path(path).read_text().splitlines():
        line = line.split("#", 1)[0].strip().rstrip("\\").strip()
        m = re.match(r"^([A-Za-z0-9_.\-]+)==([^\s;]+)", line)
        if m:
            pins[canon(m.group(1))] = m.group(2)
    return pins


def main():
    req_file, target = sys.argv[1], Path(sys.argv[2])
    search = [p for p in os.environ.get("CONDA_VENDOR_PATHS", "").split(os.pathsep) if p]
    allow = {canon(n) for n in os.environ.get("CONDA_VENDOR_ALLOW_MISMATCH", "").split(",") if n}
    licenses = os.environ.get("CONDA_VENDOR_LICENSES")

    found = {}
    for d in distributions(path=search):
        found.setdefault(canon(d.metadata["Name"]), d)

    target.mkdir(parents=True, exist_ok=True)
    for name, pinned in read_pins(req_file).items():
        dist = found.get(name)
        if dist is None:
            sys.exit(f"copy_from_env: {name}=={pinned} is not installed in {search}")
        if dist.version != pinned and name not in allow:
            sys.exit(f"copy_from_env: {name} pinned to {pinned} but {dist.version} is installed")
        print(f"copy_from_env: {name} {dist.version} -> {target}")
        base = Path(dist.locate_file(""))
        copied = 0
        for f in dist.files or []:
            parts = Path(f).parts
            if parts[0] == ".." or "__pycache__" in parts or f.suffix == ".pyc":
                continue
            # installer metadata isn't needed at runtime, and conda tooling rewrites INSTALLER
            # (which would break the macOS app bundle's code signature)
            if parts[-1] in ("INSTALLER", "REQUESTED", "direct_url.json"):
                continue
            src = base / f
            if not src.is_file():
                continue
            dst = target / f
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            copied += 1
            if licenses and re.search(r"(LICEN[CS]E|COPYING|NOTICE)", src.name, re.I):
                out = Path(licenses) / f"{name}-{dist.version}" / src.name
                out.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, out)
        if not copied:
            sys.exit(f"copy_from_env: no files recorded for {name} (missing RECORD?)")


if __name__ == "__main__":
    main()
