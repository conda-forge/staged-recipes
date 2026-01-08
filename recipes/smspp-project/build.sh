export LDFLAGS=${LDFLAGS//-Wl,--as-needed/}
export LDFLAGS=${LDFLAGS//-Wl,-dead_strip_dylibs/}

mkdir build
cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    ..
cmake --build . --config Release -j ${CPU_COUNT}
cmake --install . --config Release --prefix "$PREFIX"
