#!/bin/bash
set -euo pipefail

export CFLAGS="${CFLAGS:-} -w"
export CXXFLAGS="${CXXFLAGS:-} -w"
export CUDAFLAGS="${CUDAFLAGS:-} -w -Xcompiler=-w"

mkdir -p "${SRC_DIR}/build"
cd "${SRC_DIR}/build"

cmake ${CMAKE_ARGS} "${SRC_DIR}/python" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="${SRC_DIR}/build/lib" \
    -DNVCV_TYPES_SOURCE_DIR="${PREFIX}" \
    -DPYTHON_VERSION="${PY_VER}" \
    -DENABLE_COMPAT_OLD_GLIBC=OFF \
    -DPYBIND11_FINDPYTHON=ON \
    -G Ninja

cmake --build . -j${CPU_COUNT}

cmake --install . --component "python${CONDA_PY}"

# Move extension from lib/python/cvcuda/ to site-packages
mkdir -p "${SP_DIR}/cvcuda"
mv "${PREFIX}/lib/python/cvcuda/"_cvcuda*.so "${SP_DIR}/cvcuda/"
rm -rf "${PREFIX}/lib/python"

# Substitutes @PACKAGE_NAME@ and @EXTRA_IMPORTS@ as cmake configure_file would.
${PYTHON} - "${SRC_DIR}/python/__init__.py.in" "${SP_DIR}/cvcuda/__init__.py" << 'PYEOF'
import sys

with open(sys.argv[1]) as f:
    content = f.read()

extra_imports = (
    "\n"
    "# Explicitly export C API capsule (not included in 'import *' since it starts with _)\n"
    "from ._cvcuda import _C_API  # noqa: F401"
)

content = content.replace("@PACKAGE_NAME@", "cvcuda")
content = content.replace("@EXTRA_IMPORTS@", extra_imports)

with open(sys.argv[2], "w") as f:
    f.write(content)
PYEOF
