set -euo pipefail

mkdir build && cd build

# Build without CUDA support or vendored libs
cmake .. \
    -DPython_EXECUTABLE=$PYTHON \
    -DHAVE_PYRE=YES \
    -DISCE3_FETCH_DEPS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DISCE_PACKAGESDIR=$SP_DIR \
    -GNinja

ninja install

ctest --output-on-failure
