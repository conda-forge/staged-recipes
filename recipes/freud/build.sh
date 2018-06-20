mkdir -p build
cd build
rm -rf ./*

export GCC_ARCH=core2
export LIB=${PREFIX}/lib
export INCLUDE=${PREFIX}/include

if [ "$(uname)" == "Darwin" ]; then
    # Mac build
    cmake ../ \
          -DCMAKE_OSX_DEPLOYMENT_TARGET=10.8 \
          -DCMAKE_CXX_FLAGS="-mmacosx-version-min=10.8 -stdlib=libc++" \
          -DCMAKE_INSTALL_PREFIX=${SP_DIR} \
          -DBOOST_ROOT=${PREFIX} \
          -DPYTHON_EXECUTABLE=${PYTHON}
else
    # Linux build
    cmake ../ \
          -DCMAKE_INSTALL_PREFIX=${SP_DIR} \
          -DBOOST_ROOT=${PREFIX} \
          -DPYTHON_EXECUTABLE=${PYTHON}
fi

make install -j ${CPU_COUNT}
