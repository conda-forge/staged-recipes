set -ex
export LDFLAGS=${LDFLAGS//-Wl,--as-needed/}
export LDFLAGS=${LDFLAGS//-Wl,-dead_strip_dylibs/}

mkdir build
cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_tests=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    ..
cmake --build . --config Release -j ${CPU_COUNT}
cmake --install . --config Release
