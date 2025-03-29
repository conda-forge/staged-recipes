set -euxo pipefail

rm -rf build || true
mkdir build
cd build

cmake ${SRC_DIR} ${CMAKE_ARGS} \
    -DAPR_INSTALL=OFF \
    -DAPR_BUILD_SHARED_LIB=ON \
    -DAPR_BUILD_STATIC_LIB=OFF \
    -DAPR_BUILD_EXAMPLES=OFF \
    -DAPR_USE_LIBTIFF=ON \
    -DAPR_TESTS=OFF \
    -DAPR_PREFER_EXTERNAL_GTEST=ON \
    -DAPR_PREFER_EXTERNAL_BLOSC=ON \
    -DAPR_USE_CUDA=OFF \
    -DAPR_USE_OPENMP=ON \
    -DAPR_BENCHMARK=OFF \
    -DAPR_DENOISE=OFF

make

version_major_minor_micro=$(echo $PKG_VERSION | sed -re 's/\.[0-9]+$//')
version_major=$(echo $PKG_VERSION | sed -e 's/\..*//')
if [[ $target_platform == linux-* ]]; then
    cp libAPR.so.${version_major_minor_micro} ${PREFIX}/lib/
    ln -s ${PREFIX}/lib/libAPR.so.${version_major_minor_micro} ${PREFIX}/lib/libAPR.so.${version_major}
    ln -s ${PREFIX}/lib/libAPR.so.${version_major_minor_micro} ${PREFIX}/lib/libAPR.so
else
    cp libAPR.${version_major_minor_micro}.dylib ${PREFIX}/lib/
    ln -s ${PREFIX}/lib/libAPR.${version_major_minor_micro}.dylib ${PREFIX}/lib/libAPR.${version_major}.dylib
    ln -s ${PREFIX}/lib/libAPR.${version_major_minor_micro}.dylib ${PREFIX}/lib/libAPR.dylib
fi
