#!/usr/bin/env bash
set -euxo pipefail

# Loadable-extension suffix per platform (macOS uses .dylib, Linux uses .so).
if [[ "$(uname -s)" == "Darwin" ]]; then
  EXT="dylib"
else
  EXT="so"
fi

# 1. Generate sqlite-vec.h using Python to avoid any shell escaping issues
cat > make_header.py << 'EOF'
import os
with open('sqlite-vec.h.tmpl', 'r', encoding='utf-8') as f:
    t = f.read()
v = os.environ.get('PKG_VERSION', '0.1.9')
with open('sqlite-vec.h', 'w', encoding='utf-8') as f:
    f.write(t.replace('${VERSION}', 'v' + v))
EOF
${PYTHON} make_header.py

# 2. Compile the vec0 loadable SQLite extension from the upstream C source.
${CC} -fPIC -shared -O3 \
  -I"${PREFIX}/include" \
  sqlite-vec.c -o vec0."${EXT}" -lm

# 3. Assemble the Python package layout
mkdir -p build_pkg/sqlite_vec
cp vec0."${EXT}" build_pkg/sqlite_vec/

cat > build_pkg/sqlite_vec/__init__.py < None:
    """Load the sqlite-vec SQLite extension into the given database connection."""
    conn.load_extension(loadable_path())

PYEOF

# Append the upstream-curated body (serialize_float32/int8, register_numpy).
cat extra_init.py >> build_pkg/sqlite_vec/__init__.py

# 4. Minimal setup.py
cat > build_pkg/setup.py <<PYEOF
from setuptools import setup

setup(
    name="sqlite-vec",
    version="${PKG_VERSION}",
    description="A vector search SQLite extension that runs anywhere",
    packages=["sqlite_vec"],
    package_data={"sqlite_vec": ["vec0.*"]},
    include_package_data=True,
    has_ext_modules=lambda: True,  # mark as platform (non-pure) wheel
    python_requires=">=3.9",
)
PYEOF

cd build_pkg
${PYTHON} -m pip install . --no-deps --no-build-isolation -vv
