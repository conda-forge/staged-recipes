if [ "$(uname)" == "Darwin" ]; then

  # configure
  ${BUILD_PREFIX}/bin/cmake \
    ${CMARKE_ARGS} \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_XHOST=OFF

fi

if [ "$(uname)" == "Linux" ]; then

  # configure
  ${BUILD_PREFIX}/bin/cmake \
    ${CMARKE_ARGS} \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="${ALLOPTS}"
#needed?        -DENABLE_XHOST=OFF
fi

# build
cd build
make -j${CPU_COUNT}

# install
make install
