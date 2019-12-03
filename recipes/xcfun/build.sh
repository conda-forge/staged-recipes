# Mechanism to tweak compiler flags
# Pass with -DCMAKE_<LANG>_FLAGS=${ALLOPTS}
if [ "$(uname)" == "Darwin" ]; then
    ALLOPTS="${CFLAGS}"
    Fortran_SUPPORT=OFF
fi
if [ "$(uname)" == "Linux" ]; then
    # revisit when c-f moves to gcc8
    ALLOPTS="${CFLAGS}"
    Fortran_SUPPORT=ON
fi

# configure
${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=${CXX} \
        -DCMAKE_C_COMPILER=${CC} \
        -DENABLE_FC_SUPPORT=${Fortran_SUPPORT} \
        -DCMAKE_Fortran_COMPILER=${FORTRAN} \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
        -DXCFun_XC_MAX_ORDER=6 \
        -DENABLE_PYTHON_INTERFACE=ON

# build
cd build
make -j${CPU_COUNT}

# test
# The Python interface is tested using pytest directly
ctest -E "python-interface" -j${CPU_COUNT} --output-on-failure --verbose

# install
make install
