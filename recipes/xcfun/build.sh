# Mechanism to tweak compiler flags
# Pass with -DCMAKE_<LANG>_FLAGS=${ALLOPTS}
ALLOPTS="${CFLAGS}"

# configure
${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=${CXX} \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DCMAKE_INSTALL_LIBDIR="lib" \
        -DPYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
        -DXCFUN_MAX_ORDER=8 \
        -DXCFUN_PYTHON_INTERFACE=ON

# build
cd build
make -j${CPU_COUNT}

# test
# The Python interface is tested using pytest directly
ctest -E "python-interface" -j${CPU_COUNT} --output-on-failure --verbose

# install
make install
