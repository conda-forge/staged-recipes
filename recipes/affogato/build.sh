##
## START THE BUILD
##

mkdir -p build
cd build

# Set the correct python flags, depending on the distribution
PY_VER=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
PY_ABIFLAGS=$(python -c "import sys; print('' if sys.version_info.major == 2 else sys.abiflags)")
PY_ABI=${PY_VER}${PY_ABIFLAGS}

##
## Configure
##
cmake .. \
        -DCMAKE_C_COMPILER=${CC} \
        -DCMAKE_CXX_COMPILER=${CXX} \
        -DCMAKE_BUILD_TYPE=RELEASE \
    ${CMAKE_ARGS} \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_ABI}${SHLIB_EXT} \
        -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_ABI} \

##
## Compile and install
##
make -j${CPU_COUNT}
make install
