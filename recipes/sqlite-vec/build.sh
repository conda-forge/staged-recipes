#!/usr/bin/env bash
set -euxo pipefail

# Loadable-extension suffix per platform (macOS uses .dylib, Linux uses .so).
if [[ "$(uname -s)" == "Darwin" ]]; then
  EXT="dylib"
else
  EXT="so"
fi

# 1. Generate sqlite-vec.h cleanly using standard sed.
# Single quotes protect ${VERSION} from being evaluated by bash as an empty variable.
sed 's/\({VERSION}/v'"\){PKG_VERSION}"'/g' sqlite-vec.h.tmpl > sqlite-vec.h

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
EOF

# Append the upstream-curated body (serialize_float32/int8, register_numpy).
cat extra_init.py >> build_pkg/sqlite_vec/__init__.py

# 4. Minimal setup.py
cat > build_pkg/setup.py <<EOF
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
EOF

# 5. Install the package natively
cd build_pkg
${PYTHON} -m pip install . --no-deps --no-build-isolation -vv
