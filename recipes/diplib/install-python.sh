set -euxo pipefail

# get a fresh copy of _build
rm -rf _build
cp -r _build_copy _build
cd _build
rm CMakeCache.txt || true

cmake ${CMAKE_ARGS} ${SRC_DIR} \
    -DPYTHON_EXECUTABLE="${PREFIX}/bin/python" \
    -DDIP_BUILD_PYDIP=ON \
    -DDIP_ENABLE_ZLIB=OFF \
    -DDIP_ENABLE_FFTW=ON \
    -DDIP_ENABLE_FREETYPE=ON \
    -DDIP_BUILD_DIPVIEWER_JAVA=OFF \
    -DDIP_BUILD_JAVAIO=OFF

make -j${CPU_COUNT} pip_install
