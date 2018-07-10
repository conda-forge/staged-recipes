mkdir -p build
cd build
rm -rf ./*

export GCC_ARCH=core2
export LIB=${PREFIX}/lib
export INCLUDE=${PREFIX}/include

cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${SP_DIR} \
      -DBOOST_ROOT=${PREFIX} \
      -DPYTHON_EXECUTABLE=${PYTHON}

make install -j ${CPU_COUNT}
