cd "$SRC_DIR"
CORE_DIR=$(find "$SRC_DIR" -type d -path "*/isis/src/core" | head -n 1)
CORE_DIR=$(realpath "$CORE_DIR")

mkdir build_core && cd build_core

export ISISROOT=$PREFIX

cmake -GNinja \
  ${CMAKE_ARGS} \
  -DBUILD_CORE_TESTS=OFF \
  -DISIS_BUILD_SWIG=ON \
  -DBUILD_COVERAGE=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_DATADIR=$PREFIX \
  -DPython_EXECUTABLE="$PYTHON" \
  -DPython_ROOT_DIR="$PREFIX" \
  "$CORE_DIR"

ninja install
