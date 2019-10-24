if [ "$(uname)" == "Darwin" ]; then
    ALLOPTS="${CFLAGS}"
fi
if [ "$(uname)" == "Linux" ]; then
    # revisit when c-f moves to gcc8
    ALLOPTS="${CFLAGS} -D__GG_NO_PRAGMA"
fi

${BUILD_PREFIX}/bin/cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_C_FLAGS="${ALLOPTS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DPYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
    -DINSTALL_PYMOD=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_XHOST=OFF \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DMAX_AM=8

cd build
make -j${CPU_COUNT}

make install

# tests outside build phase
