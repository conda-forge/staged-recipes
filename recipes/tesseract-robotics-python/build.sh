#!/bin/sh

set -e

mkdir -p src
tar xf source.tar.gz --strip-components=1 -C src

if [[ "$(uname)" == "Darwin" ]]; then
  # 1. Prevent hard-linking to a specific libpython binary
  # 2. Allow missing symbols to resolve dynamically when Python imports it
  export LDFLAGS="${LDFLAGS} -Wl,-undefined,dynamic_lookup -Wl,-flat_namespace"
fi

cmake -GNinja \
  ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DTESSERACT_ENABLE_TESTING=OFF \
  -DTESSERACT_ENABLE_EXAMPLES=OFF \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DPYTHON_EXECUTABLE=$PYTHON \
  -DCMAKE_CXX_SCAN_FOR_MODULES=OFF\
  -S src/tesseract_python \
  -B build_dir

cmake --build build_dir --config Release -- -j$CPU_COUNT

$PYTHON -m pip install --no-deps --ignore-installed --no-build-isolation -vvv ./build_dir/python
$PYTHON -m pip install --no-deps --ignore-installed --no-build-isolation -vvv ./src/tesseract_viewer_python
