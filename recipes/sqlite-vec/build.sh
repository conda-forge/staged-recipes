#!/usr/bin/env bash
set -euxo pipefail

# Loadable-extension suffix per platform (macOS uses .dylib, Linux uses .so).
if [[ "$(uname -s)" == "Darwin" ]]; then
  EXT="dylib"
else
  EXT="so"
fi

# 1. Compile the vec0 loadable SQLite extension from the upstream C amalgamation.
#    sqlite-vec.c includes sqlite3ext.h / sqlite3.h, provided by the libsqlite
#    host dependency under $PREFIX/include. The amalgamation already ships a
#    pre-generated sqlite-vec.h, so no Makefile templating (git/date) is needed.
${CC} -fPIC -shared -O3 \
  -I"${PREFIX}/include" \
  sqlite-vec.c -o vec0."${EXT}" -lm

# 2. Assemble the Python package layout that the upstream wheel ships:
#    sqlite_vec/__init__.py = sqlite-dist loader prefix + bundled extra_init.py,
#    plus the compiled vec0 loadable extension alongside it.
mkdir -p build_pkg/sqlite_vec
cp vec0."${EXT}" build_pkg/sqlite_vec/

cat > build_pkg/sqlite_vec/__init__.py <<PYEOF
from os import path
import sqlite3

__version__ = "${PKG_VERSION}"
__version_info__ = tuple(__version__.split("."))


def loadable_path():
    """Returns the full path to the sqlite-vec loadable SQLite extension bundled with this package"""
    loadable_path = path.join(path.dirname(__file__), "vec0")
    return path.normpath(loadable_path)


def load(conn: sqlite3.Connection) -> None:
    """Load the sqlite-vec SQLite extension into the given database connection."""
    conn.load_extension(loadable_path())


PYEOF

# Append the upstream-curated body (serialize_float32/int8, register_numpy).
cat extra_init.py >> build_pkg/sqlite_vec/__init__.py

# 3. Minimal setup.py so `pip install .` produces a proper .dist-info (pip check)
#    and packages the compiled vec0 extension as package data.
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
