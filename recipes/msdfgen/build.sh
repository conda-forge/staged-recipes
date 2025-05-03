set -ex

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DMSDFGEN_BUILD_STANDALONE=ON \
    -DMSDFGEN_USE_SKIA=OFF \
    -DMSDFGEN_DYNAMIC_RUNTIME=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DMSDFGEN_USE_VCPKG=OFF \
    -DMSDFGEN_INSTALL=ON \
    ..

ninja -j${CPU_COUNT} -v
ninja install
