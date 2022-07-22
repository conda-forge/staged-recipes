set -euxo pipefail

mkdir -p _build
cd _build

# Zlib is only a transitive dependency for libtiff; not needed
cmake ${CMAKE_ARGS} ${SRC_DIR} \
    -DPYTHON_EXECUTABLE="${PYTHON}" \
    -DDIP_ENABLE_ZLIB=OFF \
    -DDIP_ENABLE_FFTW=ON \
    -DDIP_ENABLE_FREETYPE=ON

make -j${CPU_COUNT} install
make pip_install
