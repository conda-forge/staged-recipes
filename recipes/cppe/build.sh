# configure
cmake \
      -H${SRC_DIR} \
      -Bbuild \
      -GNinja \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
      -DBUILD_SHARED_LIBS=ON \
      -DINSTALL_DEVEL_HEADERS=OFF \
      -DENABLE_OPENMP=ON \
      -DENABLE_XHOST=OFF \
      -DPYMOD_INSTALL_LIBDIR="${SP_DIR#$PREFIX/lib}" \
      -DENABLE_PYTHON_INTERFACE=ON

# build
cmake --build build -- -j${CPU_COUNT}

# install
cmake --build build --target install
