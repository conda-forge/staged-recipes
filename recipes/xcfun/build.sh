# Mechanism to tweak compiler flags
# Pass with -DCMAKE_<LANG>_FLAGS=${ALLOPTS}
ALLOPTS="${CFLAGS}"

# configure
cmake \
     -H${SRC_DIR} \
     -Bbuild \
     -GNinja \
     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_CXX_COMPILER=${CXX} \
     -DPYTHON_EXECUTABLE=${PYTHON} \
     -DCMAKE_INSTALL_LIBDIR="lib" \
     -DPYMOD_INSTALL_LIBDIR="${SP_DIR#$PREFIX/lib}" \
     -DXCFUN_MAX_ORDER=8 \
     -DXCFUN_PYTHON_INTERFACE=ON

# build
cd build
cmake --build . -- -j${CPU_COUNT}

# test
# The Python interface is tested using pytest directly
ctest -E "python-interface" -j${CPU_COUNT} --output-on-failure --verbose

# install
cmake --build . --target install
