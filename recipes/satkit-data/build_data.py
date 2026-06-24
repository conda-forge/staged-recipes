"""Lay the downloaded data files out as a ``satkit_data`` Python package.

Invoked by build.sh / bld.bat (``"$PYTHON" "$RECIPE_DIR/build_data.py"``)
in place of a shell script so the noarch build behaves identically on
Linux, macOS, and Windows. Mirrors the on-PyPI ``satkit_data`` layout so
satkit's existing ``$SITE_PACKAGES/satkit_data/data`` resolver finds the
files with no config.
"""

import os
import shutil

sp_dir = os.environ["SP_DIR"]
# The data/ tree is extracted under the conda-build work dir ($SRC_DIR);
# resolve it explicitly rather than relying on the current directory.
src_data = os.path.join(os.environ.get("SRC_DIR", os.getcwd()), "data")

dest = os.path.join(sp_dir, "satkit_data", "data")
os.makedirs(dest, exist_ok=True)

for name in sorted(os.listdir(src_data)):
    src = os.path.join(src_data, name)
    if os.path.isfile(src):
        shutil.copy2(src, os.path.join(dest, name))
        print(f"copied {name}")

# Empty package marker so `import satkit_data` works.
open(os.path.join(sp_dir, "satkit_data", "__init__.py"), "w").close()
