
if [ "$(uname)" == "Darwin" ]; then

    # Intel atop conda Clang
    #CMAKE_C_FLAGS="-clang-name=${CLANG} -msse4.1 -axCORE-AVX2"

    # configure
    ${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=${CC} \
        -DCMAKE_C_FLAGS="${CFLAGS}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DPYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
        -DINSTALL_PYMOD=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DENABLE_XHOST=OFF \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DMAX_AM=8
fi


if [ "$(uname)" == "Linux" ]; then

# to practice c-f
#  * ldd -r -u need && return 0 toggled
#  * not Intel compilers
#  * source/path: ../../../gau2grid
#    ALLOPTS="-gnu-prefix=${HOST}-"
#        -DCMAKE_C_COMPILER=${CC} \
#        -DCMAKE_C_FLAGS="${CFLAGS}" \

    ${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=${CC} \
        -DCMAKE_C_FLAGS="${CFLAGS}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DPYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
        -DINSTALL_PYMOD=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DENABLE_XHOST=OFF \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DMAX_AM=8

fi

cd build
make -j${CPU_COUNT}

make install
