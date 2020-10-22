BUILD_TYPE="Release"
CXXFLAGS="${CXXFLAGS//-march=nocona}"
CXXFLAGS="${CXXFLAGS//-mtune=haswell}"

# configure
cmake \
  -H${SRC_DIR} \
  -Bbuild \
  -GNinja \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DPYMOD_INSTALL_LIBDIR="${SP_DIR#$PREFIX/lib}"


# build and install, we test through pytest
cmake --build build --target install -- -j${CPU_COUNT} -v -d stats
