set -ex

export CXXFLAGS="${CXXFLAGS} -ldl"
# export CXX_FLAGS="${CXX_FLAGS} -ldl"

mkdir build-10
pushd build-10
cmake -LAH                                         \
      -DCMAKE_RULE_MESSAGES=ON                     \
      -DCMAKE_VERBOSE_MAKEFILE=OFF                 \
      -DCMAKE_BUILD_TYPE="Release"                 \
      -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
      -DHIGH_BIT_DEPTH='TRUE'                      \
      -DMAIN12='TRUE'                              \
      -DEXPORT_C_API='FALSE'                       \
      -DENABLE_CLI='FALSE'                         \
      -DENABLE_SHARED='FALSE'                      \
      ../source
make -j${CPU_COUNT}
popd
# --- Pixel depth 12

mkdir build-12
pushd build-12
cmake -LAH                                         \
      -DCMAKE_RULE_MESSAGES=ON                     \
      -DCMAKE_VERBOSE_MAKEFILE=OFF                 \
      -DCMAKE_BUILD_TYPE="Release"                 \
      -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
      -DHIGH_BIT_DEPTH='TRUE'                      \
      -DEXPORT_C_API='FALSE'                       \
      -DENABLE_CLI='FALSE'                         \
      -DENABLE_SHARED='FALSE'                      \
      ../source
make -j${CPU_COUNT}
popd

# --- Put all together

mkdir build-8
pushd build-8
ln -s ../build-10/libx265.a libx265_main10.a
ln -s ../build-12/libx265.a libx265_main12.a

cmake -LAH                                         \
      -DCMAKE_RULE_MESSAGES=ON                     \
      -DCMAKE_VERBOSE_MAKEFILE=OFF                 \
      -DCMAKE_BUILD_TYPE="Release"                 \
      -DCMAKE_INSTALL_PREFIX=${PREFIX}             \
      -DENABLE_SHARED='TRUE'                       \
      -DENABLE_HDR10_PLUS='TRUE'                   \
      -DLINKED_10BIT='TRUE'                        \
      -DLINKED_12BIT='TRUE'                        \
      -DEXTRA_LIB='x265_main10.a;x265_main12.a'    \
      -DEXTRA_LINK_FLAGS='-L .'                    \
      ../source
make -j${CPU_COUNT}
make install
popd
