# configure
${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=${CXX} \
        -DCMAKE_C_COMPILER=${CC} \
        -DENABLE_FC_SUPPORT=ON \
        -DCMAKE_Fortran_COMPILER=${FORTRAN} \
        -DPYTHON_EXECUTABLE="${PYTHON}" \
        -DPYMOD_INSTALL_LIBDIR="${PYMOD_INSTALL_LIBDIR}" \
        -DENABLE_PYTHON_INTERFACE=ON

# build
cd build
make -j${CPU_COUNT}

# test
# The Python interface is tested using pytest directly
ctest -E "python-interface" -j${CPU_COUNT} --output-on-failure --verbose

# install
make install
