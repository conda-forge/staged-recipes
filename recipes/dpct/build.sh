mkdir build
cd build

if [ $(uname) == "Darwin" ]; then
    LDFLAGS="-undefined dynamic_lookup -L${PREFIX}/lib ${LDFLAGS}"
else
    LDFLAGS="-Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib ${LDFLAGS}"
fi

WITH_PYTHON=${WITH_PYTHON:-OFF}
MULTI_STAGE_BUILD=${MULTI_STAGE_BUILD:-OFF}

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython_EXECUTABLE=${PYTHON} \
    -DWITH_LOG=OFF \
    -DWITH_PYTHON=${WITH_PYTHON} \
    -DMULTI_STAGE_BUILD=${MULTI_STAGE_BUILD} \
    -DWITH_BIN=OFF \
    -DCMAKE_CXX_LINK_FLAGS="${LDFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    "${CMAKE_PLATFORM_FLAGS[@]}" \

make -j${CPU_COUNT}
make install
