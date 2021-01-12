
if [ "$(uname)" == "Darwin" ]; then
    ENABLE_FORTRAN=OFF
fi
if [ "$(uname)" == "Linux" ]; then
    ENABLE_FORTRAN=ON
fi


${BUILD_PREFIX}/bin/cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DNAMESPACE_INSTALL_INCLUDEDIR="/" \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_FORTRAN=${ENABLE_FORTRAN} \
    -DENABLE_XHOST=OFF \
    -DBUILD_TESTING=ON

cd build
make -j${CPU_COUNT}

make install

ctest
