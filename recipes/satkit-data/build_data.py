"""Lay the downloaded data files out as a ``satkit_data`` Python package.

Run by conda-build (``{{ PYTHON }} build_data.py``) in place of a shell
script so the noarch build behaves identically on Linux, macOS, and
Windows. Mirrors the on-PyPI ``satkit_data`` layout so satkit's existing
``$SITE_PACKAGES/satkit_data/data`` resolver finds the files with no config.
"""

import os
import shutil

sp_dir = os.environ["SP_DIR"]
dest = os.path.join(sp_dir, "satkit_data", "data")
os.makedirs(dest, exist_ok=True)

for name in sorted(os.listdir("data")):
    src = os.path.join("data", name)
    if os.path.isfile(src):
        shutil.copy2(src, os.path.join(dest, name))
        print(f"copied {name}")

# Empty package marker so `import satkit_data` works.
open(os.path.join(sp_dir, "satkit_data", "__init__.py"), "w").close()
