set -euxo pipefail

mkdir -p _build
cd _build

# Zlib is only a transitive dependency for libtiff; not needed
# We don't want to build the Python targets now
cmake ${CMAKE_ARGS} ${SRC_DIR} \
    -DDIP_BUILD_PYDIP=OFF \
    -DDIP_ENABLE_ZLIB=OFF \
    -DDIP_ENABLE_FFTW=ON \
    -DDIP_ENABLE_FREETYPE=ON \
    -DDIP_BUILD_DIPVIEWER_JAVA=OFF \
    -DDIP_BUILD_JAVAIO=OFF

make -j${CPU_COUNT} install

# Save a copy for the python variants later
cd ..
cp -r _build _build_copy
