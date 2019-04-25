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
        -DBOOST_ROOT=${PREFIX} \
        -DBUILD_NIFTY_PYTHON=ON \
        -DWITH_BLOSC=ON \
        -DWITH_ZLIB=ON \
        -DWITH_BZIP2=ON \
        -DWITH_Z5=ON \
        -DWITH_HDF5=ON \
\
        -DCMAKE_PREFIX_PATH=${PREFIX} \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_ABI}${SHLIB_EXT} \
        -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_ABI} \

##
## Compile and install
##
make -j${CPU_COUNT}
make install
