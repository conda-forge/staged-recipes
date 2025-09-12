#!/bin/sh

# Make sure that vendored libraries are not used
rm -rf ./src/LuaJIT
rm -rf ./src/lua-5.1.5
rm -rf ./src/madras/libdgb/libdwarf/

mkdir build
cmake -S . -B build \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DUSE_SYSTEM_LUAJIT=ON \
    -DUSE_SYSTEM_LIBDWARF=ON \
    -DMAQAO_LINKING=EXTERNAL_DYNAMIC

make -C build -j${CPU_COUNT} install