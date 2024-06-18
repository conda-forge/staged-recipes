#!/bin/bash

set -ex

# strip std settings from conda
CXXFLAGS="${CXXFLAGS/-std=c++14/}"
CXXFLAGS="${CXXFLAGS/-std=c++11/}"
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
export CXXFLAGS

if [ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]; then
  mkdir native; pushd native;

  CXXFLAGS_NATIVE=${CXXFLAGS//$PREFIX/$BUILD_PREFIX}
  LDFLAGS_NATIVE=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
  CFLAGS_NATIVE=${CFLAGS//$PREFIX/$BUILD_PREFIX}

  CC=$CC_FOR_BUILD CXX=$CXX_FOR_BUILD \
    LDFLAGS=${LDFLAGS_NATIVE} \
    CFLAGS=${CFLAGS_NATIVE} \
    CXXFLAGS=${CXXFLAGS_NATIVE} \
    cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        ${EXTRA_CMAKE_ARGS} \
        ..

  export DIMBUILDER=`pwd`/bin/dimbuilder
  ninja dimbuilder
  popd
else
  export DIMBUILDER=dimbuilder

fi

rm -rf build
mkdir -p build
cd build

export PDAL_BUILD_DIR=`pwd`/install
mkdir $PDAL_BUILD_DIR

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -G Ninja \
  ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DDIMBUILDER_EXECUTABLE=$DIMBUILDER \
  -DBUILD_PLUGIN_E57=OFF \
  -DBUILD_PLUGIN_PGPOINTCLOUD=OFF \
  -DBUILD_PLUGIN_ARROW=OFF \
  -DENABLE_CTEST=OFF \
  -DWITH_TESTS=OFF \
  -DWITH_ZLIB=ON \
  -DWITH_ZSTD=ON \
  ..

ninja -j${CPU_COUNT}
ninja install

## Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d, see
## https://conda-forge.org/docs/maintainer/adding_pkgs.html#activate-scripts
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
